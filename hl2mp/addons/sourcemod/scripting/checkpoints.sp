/**
\file checkpoints.sp
\brief Sourcemod plugin that facilitates checkpoint (location, view, velocity) saving

---------------------------------------------------------------------------------------------------------
-License:

Checkpoints - SourceMod Plugin
Copyright (C) 2012 B.D.A.K. Koch

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

As a special exception, AlliedModders LLC gives you permission to link the
code of this program (as well as its derivative works) to "Half-Life 2," the
"Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
by the Valve Corporation.  You must obey the GNU General Public License in
all respects for all other code used.  Additionally, AlliedModders LLC grants
this exception to all derivative works.  AlliedModders LLC defines further
exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
or <http://www.sourcemod.net/license.php>.
*/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#include <sqlh>

#include <checkpoints>

new Handle:g_hCvEnabled, g_CvEnabled,
	Handle:g_hCvMaxCheckpoints, g_CvMaxCheckpoints;

new Handle:g_hCheckpoint[MAXPLAYERS+1] = { INVALID_HANDLE, ... }, // { origin.x, origin.y, origin.z, eye_angles.pitch, eye_angles.yaw, eye_angles.roll, velocity.x, velocity.y, velocity.z }
	g_CurrentIndex[MAXPLAYERS+1] = { -1, ... };

new Handle:g_hDatabase = INVALID_HANDLE,
	SQLH_Type:g_DbType,
	g_DatabaseId[MAXPLAYERS+1]; // { 0:map, [1, MAXPLAYERS]:players }

new Handle:g_EventForward;

new bool:g_LateLoad;

#define PLUGIN_NAME "Checkpoints"
#define PLUGIN_AUTHOR "1Swat2KillThemAll"
#define PLUGIN_DESCRIPTION ""
#define PLUGIN_VERSION "1.0.0 (GNU/AGPLv3)"
#define PLUGIN_URL ""
#define PLUGIN_COMMAND_GROUP "checkpoints"
public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) {
	g_LateLoad = late;

	CreateNative("Checkpoints_Save", Native_Save);
	CreateNative("Checkpoints_Teleport", Native_Teleport);
	CreateNative("Checkpoints_Next", Native_Next);
	CreateNative("Checkpoints_Previous", Native_Previous);
	CreateNative("Checkpoints_Delete", Native_Delete);
	CreateNative("Checkpoints_Clear", Native_Clear);
	CreateNative("Checkpoints_GetNumberOfCheckpoints", Native_GetNumberOfCheckpoints);
	CreateNative("Checkpoints_GetCurrentCPIndex", Native_GetCurrentCPIndex);
	CreateNative("Checkpoints_SetCurrentCPIndex", Native_SetCurrentCPIndex);
	CreateNative("Checkpoints_HookEvents", Native_HookEvents);
	CreateNative("Checkpoints_UnhookEvents", Native_UnhookEvents);

	return APLRes_Success;
}

public OnPluginStart() {
	InitVersionCvar("checkpoints", PLUGIN_NAME, PLUGIN_VERSION, FCVAR_CHEAT);

	g_CvEnabled = InitCvar(g_hCvEnabled, OnConVarChanged, "sm_checkpoints_enabled", "1", "Whether this plugin should be enabled.", FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	g_CvMaxCheckpoints = InitCvar(g_hCvMaxCheckpoints, OnConVarChanged, "sm_checkpoints_max", "30", "Maximum number of checkpoints per player. (-1 disables limit)", FCVAR_DONTRECORD, true, -1.0);

	RegAdminCmd("sm_save", ConCmd_Save, 0, "sm_save [<checkpoint #>] - Saves your current location, view angles and velocity as a new checkpoint or overwrites the one specified by <checkpoint #>.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_tele", ConCmd_Tele, 0, "sm_tele [<checkpoint #>] - Teleports you to your current checkpoint or the one specified by <checkpoint #>.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_next", ConCmd_Next, 0, "sm_next - Teleports you to your next checkpoint.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_prev", ConCmd_Prev, 0, "sm_prev - Teleports you to your previous checkpoint.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_delete", ConCmd_Delete, 0, "sm_delete [<checkpoint #>] - Deletes your current checkpoint or the one specified by <checkpoint #>.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_clear", ConCmd_Clear, 0, "sm_clear - Clears all checkpoints.", PLUGIN_COMMAND_GROUP);
	RegAdminCmd("sm_cp", ConCmd_CP, 0, "sm_cp - Opens checkpoint menu.", PLUGIN_COMMAND_GROUP);

	InitialiseDatabase();

	if (g_LateLoad) {
		for (new i = 0; i <= MaxClients; i++) {
			if (IsClientValid(i, false)) {
				OnClientPostAdminCheck(i);
			}
		}
	}

	g_EventForward = CreateForward(ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Array);
	RegPluginLibrary("checkpoints");
}

public OnPluginEnd() {
	for (new i = 0; i <= MaxClients; i++) {
		if (IsClientValid(i, false)) {
			OnClientDisconnect(i);
		}
	}
}

public OnMapStart() {
	if (g_hDatabase == INVALID_HANDLE) {
		InitialiseDatabase();
	}

	g_DatabaseId[0] = -1;

	if (g_hDatabase != INVALID_HANDLE) {
		decl String:query[256],
			String:map[64],
			String:escaped_map[129];

		GetCurrentMap(map, sizeof(map));
		SQL_EscapeString(g_hDatabase, map, escaped_map, sizeof(escaped_map));
		Format(query, sizeof(query), "INSERT %sIGNORE INTO cp_maps (name) VALUES ('%s');", g_DbType == SQLH_TYPE_SQLITE ? "OR " : "", escaped_map);

		SQL_TQuery(g_hDatabase, SQLT_InsertMap, query, _, DBPrio_High);
	}
}

public OnClientPostAdminCheck(client) {
	CP_Initialise(client, true);
}

public OnClientDisconnect(client) {
	if (g_hDatabase != INVALID_HANDLE && g_hCheckpoint[client] != INVALID_HANDLE) {
		new size = GetArraySize(g_hCheckpoint[client]);
		decl String:query[512];

		for (new i = 0; i < size; i++) {
			decl Float:data[9];
			GetArrayArray(g_hCheckpoint[client], i, data, 9);

			Format(
				query, sizeof(query),
				"REPLACE INTO cp_checkpoints \
					(\
						player, map, cp_index, \
						origin_x, origin_y, origin_z, \
						angle_pitch, angle_yaw, angle_roll, \
						velocity_x, velocity_y, velocity_z\
					) \
					VALUES \
					(\
						'%i', '%i', '%i', \
						'%f', '%f', '%f', \
						'%f', '%f', '%f', \
						'%f', '%f', '%f'\
					)\
				;",
				g_DatabaseId[client], g_DatabaseId[0], i,
				data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]
			);

			SQL_TQuery(g_hDatabase, SQLT_InsertCheckpoint, query);
		}

		Format(query, sizeof(query), "DELETE FROM cp_checkpoints WHERE player = '%i' AND map = '%i' AND cp_index >= '%i';", g_DatabaseId[client], g_DatabaseId[0], size);
		SQL_TQuery(g_hDatabase, SQLT_DeleteCheckpoints, query);
	}

	CP_Deinitialise(client);
}

public Action:ConCmd_Save(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client) && CP_Initialise(client)) {
		if (GetClientTeam(client) < 2) {
			ReplyToCommand(client, "[SM] You need to join a team first.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(client)) {
			ReplyToCommand(client, "[SM] You need to be alive to do that.");
			return Plugin_Handled;
		}

		if (GetArraySize(g_hCheckpoint[client]) >= g_CvMaxCheckpoints) {
			ReplyToCommand(client, "[SM] You've reached the maximum amount of checkpoints.");
			return Plugin_Handled;
		}

		if (argc > 1) {
			ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
		}

		new index = -1;

		if (argc == 1) {
			decl String:buffer[32];
			GetCmdArg(1, buffer, sizeof(buffer));

			index = StringToInt(buffer) - 1;
		}

		index = CP_Save(client, index);

		if (index == -1) {
			ReplyToCommand(client, "[SM] Couldn't save checkpoint.");
		}
		else if (index != -2) {
			ReplyToCommand(client, "[SM] Succesfully saved checkpoint #%i/%i.", index + 1, g_CvMaxCheckpoints);
		}
	}

	return Plugin_Handled;
}

public Action:ConCmd_Tele(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client) && CP_Initialise(client)) {
		if (GetClientTeam(client) < 2) {
			ReplyToCommand(client, "[SM] You need to join a team first.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(client)) {
			ReplyToCommand(client, "[SM] You need to be alive to do that.");
			return Plugin_Handled;
		}

		if (argc > 1) {
			ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
		}

		new index = g_CurrentIndex[client];

		if (argc == 1) {
			decl String:buffer[32];
			GetCmdArg(1, buffer, sizeof(buffer));

			index = StringToInt(buffer) - 1;
		}

		index = CP_Teleport(client, index);

		if (index == -1) {
			ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
		}
		else if (index != -2) {
			ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", index + 1, GetArraySize(g_hCheckpoint[client]));
		}
	}

	return Plugin_Handled;
}

public Action:ConCmd_Next(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client) && CP_Initialise(client)) {
		if (GetClientTeam(client) < 2) {
			ReplyToCommand(client, "[SM] You need to join a team first.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(client)) {
			ReplyToCommand(client, "[SM] You need to be alive to do that.");
			return Plugin_Handled;
		}

		new index = CP_Next(client);

		if (index == -1) {
			ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
		}
		else if (index != -2) {
			ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", index + 1, GetArraySize(g_hCheckpoint[client]));
		}
	}

	return Plugin_Handled;
}

public Action:ConCmd_Prev(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client) && CP_Initialise(client)) {
		if (GetClientTeam(client) < 2) {
			ReplyToCommand(client, "[SM] You need to join a team first.");
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(client)) {
			ReplyToCommand(client, "[SM] You need to be alive to do that.");
			return Plugin_Handled;
		}

		new index = CP_Previous(client);

		if (index == -1) {
			ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
		}
		else if (index != -2) {
			ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", index + 1, GetArraySize(g_hCheckpoint[client]));
		}
	}

	return Plugin_Handled;
}

public Action:ConCmd_Delete(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client)) {
		if (argc > 1) {
			ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
		}

		new index = g_CurrentIndex[client];

		if (argc == 1) {
			decl String:buffer[32];
			GetCmdArg(1, buffer, sizeof(buffer));

			index = StringToInt(buffer) - 1;
		}

		index = CP_Delete(client, index);

		if (index == -1) {
			ReplyToCommand(client, "[SM] Couldn't delete checkpoint.");
		}
		else {
			ReplyToCommand(client, "[SM] Succesfully deleted checkpoint #%i.", index + 1);
		}
	}

	return Plugin_Handled;
}

public Action:ConCmd_Clear(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client)) {
		new items = CP_Clear(client);

		ReplyToCommand(client, "[SM] Cleared %i checkpoints.", items);
	}

	return Plugin_Handled;
}

public Action:ConCmd_CP(client, argc) {
	if (!g_CvEnabled) {
		return Plugin_Continue;
	}

	if (IsClientValid(client)) {
		CP_Menu(client);
	}


	return Plugin_Handled;
}

bool:CP_Initialise(client, bool:clear = false) {
	if (clear) {
		CP_Deinitialise(client);

		if (g_hDatabase != INVALID_HANDLE) {
			g_DatabaseId[client] = -1;

			decl String:query[128],
				String:auth[32],
				String:escaped_auth[65];

			GetClientAuthString(client, auth, sizeof(auth));
			SQL_EscapeString(g_hDatabase, auth, escaped_auth, sizeof(escaped_auth));
			Format(query, sizeof(query), "INSERT %sIGNORE INTO cp_players (auth) VALUES ('%s');", g_DbType == SQLH_TYPE_SQLITE ? "OR " : "", escaped_auth);

			SQL_TQuery(g_hDatabase, SQLT_InsertPlayer, query, GetClientUserId(client));
		}
	}

	if (g_hCheckpoint[client] == INVALID_HANDLE) {
		g_hCheckpoint[client] = CreateArray(9);
		g_CurrentIndex[client] = -1;
	}

	return g_hCheckpoint[client] != INVALID_HANDLE;
}

bool:CP_Deinitialise(client) {
	CloseHandle2(g_hCheckpoint[client]);
	g_CurrentIndex[client] = -1;

	return true;
}

CP_Save(client, index = -1) {
	if (!CP_Initialise(client)) {
		return -1;
	}

	decl Float:origin[3],
		Float:eye_angles[3],
		Float:velocity[3],
		Float:origin_copy[3],
		Float:eye_angles_copy[3],
		Float:velocity_copy[3];

	GetClientAbsOrigin(client, origin);
	GetClientAbsAngles(client, eye_angles);
	GetEntityAbsVelocity(client, velocity);

	origin_copy = origin;
	eye_angles_copy = eye_angles;
	velocity_copy = velocity;

	new size = GetArraySize(g_hCheckpoint[client]),
		bool:new_checkpoint = false;

	if (index < 0 || index > size || size == 0) {
		index = size;
		new_checkpoint = true;
	}

	new Action:ret = CallEventForward(CHECKPOINTS_EVENT_SAVE, client, index, origin_copy, eye_angles_copy, velocity_copy);

	if (ret == Plugin_Stop) {
		return -2;
	}
	else if (ret == Plugin_Changed) {
		origin = origin_copy;
		eye_angles = eye_angles_copy;
		velocity = velocity_copy;
	}

	if (new_checkpoint) {
		PushArrayCell(g_hCheckpoint[client], 0);
	}

	g_CurrentIndex[client] = index;

	for (new i = 0; i < 3; i++) {
		SetArrayCell(g_hCheckpoint[client], index, origin[i], i);
		SetArrayCell(g_hCheckpoint[client], index, eye_angles[i], i + 3);
		SetArrayCell(g_hCheckpoint[client], index, velocity[i], i + 6);
	}

	return index;
}

CP_Teleport(client, index) {
	if (!CP_Initialise(client)) {
		return -1;
	}

	new size = GetArraySize(g_hCheckpoint[client]);
	if (index >= size) {
		index = size - 1;
	}

	if (index < 0) {
		return -1;
	}

	decl Float:origin[3],
		Float:eye_angles[3],
		Float:velocity[3],
		Float:origin_copy[3],
		Float:eye_angles_copy[3],
		Float:velocity_copy[3];

	for (new i = 0; i < 3; i++) {
		origin[i] = GetArrayCell(g_hCheckpoint[client], index, i);
		eye_angles[i] = GetArrayCell(g_hCheckpoint[client], index, i + 3);
		velocity[i] = GetArrayCell(g_hCheckpoint[client], index, i + 6);
	}

	origin_copy = origin;
	eye_angles_copy = eye_angles;
	velocity_copy = velocity;

	new Action:ret = CallEventForward(CHECKPOINTS_EVENT_TELEPORT, client, index, origin_copy, eye_angles_copy, velocity_copy);

	if (ret == Plugin_Stop) {
		return -2;
	}
	else if (ret == Plugin_Changed) {
		origin = origin_copy;
		eye_angles = eye_angles_copy;
		velocity = velocity_copy;
	}

	TeleportEntity(client, origin, eye_angles, velocity);

	g_CurrentIndex[client] = index;

	return index;
}

CP_Next(client) {
	if (!CP_Initialise(client)) {
		return -1;
	}

	new size = GetArraySize(g_hCheckpoint[client]);
	if (++g_CurrentIndex[client] >= size) {
		g_CurrentIndex[client] = 0;
	}
	else if (size == 0) {
		g_CurrentIndex[client] = -1;
	}

	return CP_Teleport(client, g_CurrentIndex[client]);
}

CP_Previous(client) {
	if (!CP_Initialise(client)) {
		return -1;
	}

	new size = GetArraySize(g_hCheckpoint[client]);
	if (--g_CurrentIndex[client] < 0) {
		g_CurrentIndex[client] = size - 1;
	}
	else if (g_CurrentIndex[client] >= size) {
		g_CurrentIndex[client] = size;
	}

	return CP_Teleport(client, g_CurrentIndex[client]);
}

CP_Delete(client, index) {
	if (!CP_Initialise(client)) {
		return -1;
	}

	new size = GetArraySize(g_hCheckpoint[client]);
	if (index >= size) {
		index = size - 1;
	}

	if (index < 0) {
		return -1;
	}

	RemoveFromArray(g_hCheckpoint[client], index);

	if (g_CurrentIndex[client] >= index) {
		g_CurrentIndex[client]--;
	}

	CallEventForward(CHECKPOINTS_EVENT_DELETE, client, index);

	return index;
}

CP_Clear(client) {
	if (!CP_Initialise(client)) {
		return 0;
	}

	new items = GetArraySize(g_hCheckpoint[client]);

	ClearArray(g_hCheckpoint[client]);

	CallEventForward(CHECKPOINTS_EVENT_CLEAR, client);

	return items;
}

CP_Menu(client) {
	if (!g_CvEnabled) {
		return;
	}

	static Handle:menu = INVALID_HANDLE;

	if (menu == INVALID_HANDLE) {
		menu = CreateMenu(MenuHandler_CPMenu);

		if (menu != INVALID_HANDLE) {
			SetMenuTitle(menu, "Checkpoints:");

			AddMenuItem(menu, "save", "Save new checkpoint (!save)");
			AddMenuItem(menu, "tele", "Teleport to the current checkpoint (!tele)");
			AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
			AddMenuItem(menu, "next", "Teleport to the next checkpoint (!next)");
			AddMenuItem(menu, "prev", "Teleport to the previous checkpoint (!prev)");
			AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
			AddMenuItem(menu, "telemenu", "List all checkpoints");
			AddMenuItem(menu, "clear", "Clear all checkpoints");

			SetMenuExitButton(menu, true);
		}
	}

	if (menu != INVALID_HANDLE) {
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public MenuHandler_CPMenu(Handle:menu, MenuAction:action, param1, param2) {
	if (action == MenuAction_Select) {
		if (!g_CvEnabled) {
			return;
		}

		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));

		new bool:show_again = true;

		if (StrEqual(info, "save")) {
			ConCmd_Save(param1, 0);
		}
		else if (StrEqual(info, "tele")) {
			ConCmd_Tele(param1, 0);
		}
		else if (StrEqual(info, "next")) {
			ConCmd_Next(param1, 0);
		}
		else if (StrEqual(info, "prev")) {
			ConCmd_Prev(param1, 0);
		}
		else if (StrEqual(info, "telemenu")) {
			CP_Menu2(param1);
			show_again = false;
		}
		else if (StrEqual(info, "clear")) {
			ConCmd_Clear(param1, 0);
		}

		if (show_again) {
			CP_Menu(param1);
		}
	}
}

CP_Menu2(client) {
	if (!g_CvEnabled) {
		return;
	}

	new Handle:menu = CreateMenu(MenuHandler_CPMenu2);
	if (menu != INVALID_HANDLE) {
		SetMenuTitle(menu, "Teleport to:");

		decl String:info[32],
			String:display[64];
		new count = 0;
		for (new i = 0, size = GetArraySize(g_hCheckpoint[client]); i < size; i++) {
			Format(info, sizeof(info), "%i", i);
			Format(display, sizeof(display), "Checkpoint #%i", i + 1);
			AddMenuItem(menu, info, display);
			count++;
		}

		if (count == 0) {
			AddMenuItem(menu, "-1", "No checkpoints available", ITEMDRAW_DISABLED);
		}

		SetMenuExitButton(menu, true);
		SetMenuExitBackButton(menu, true);

		new item = 0;
		if (g_CurrentIndex[client] > 0 && g_CurrentIndex[client] < count) {
			item = (g_CurrentIndex[client] / 7) * 7;
		}

		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
	}
}

public MenuHandler_CPMenu2(Handle:menu, MenuAction:action, param1, param2) {
	if (action == MenuAction_Select) {
		if (!g_CvEnabled) {
			return;
		}

		if (IsClientValid(param1)) {
			if (GetClientTeam(param1) < 2) {
				ReplyToCommand(param1, "[SM] You need to join a team first.");
				return;
			}
			else if (!IsPlayerAlive(param1)) {
				ReplyToCommand(param1, "[SM] You need to be alive to do that.");
			}
			else {
				decl String:info[32];
				GetMenuItem(menu, param2, info, sizeof(info));

				new index = StringToInt(info);
				if (index != -1) {
					index = CP_Teleport(param1, index);

					if (index == -1) {
						ReplyToCommand(param1, "[SM] Couldn't teleport to checkpoint.");
					}
					else if (index != -2) {
						ReplyToCommand(param1, "[SM] Succesfully teleported to checkpoint #%i.", index + 1);
					}
				}
			}

			CP_Menu2(param1);
		}
	}
	else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack) {
			CP_Menu(param1);
		}
	}
	else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public OnConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	if (cvar == g_hCvEnabled) {
		g_CvEnabled = StringToInt(newVal);
	}
	else if (cvar == g_hCvMaxCheckpoints) {
		g_CvMaxCheckpoints = StringToInt(newVal);
	}
}

InitialiseDatabase() {
	if (SQLH_Connect("cfg/sourcemod/checkpoints.cfg", "Config", "checkpoints", g_hDatabase, g_DbType)) {
		LogError("Couldn't connect to database.");
	}

	if (g_hDatabase != INVALID_HANDLE) {
		decl String:path[256];
		BuildPath(Path_SM, path, sizeof(path), "configs/checkpoints/initialise.sql");

		if (!SQLH_FastQueriesFromFile(g_hDatabase, path, true)) {
			CloseHandle(g_hDatabase);

			LogError("Couldn't execute initialisation queries.");
		}
	}
}

public SQLT_InsertPlayer(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
	else {
		new client = GetClientOfUserId(data);

		if (!IsClientValid(client, false)) {
			return;
		}

		if (SQL_GetAffectedRows(hndl) != 0) {
			g_DatabaseId[client] = SQL_GetInsertId(hndl);
		}
		else {
			decl String:query[128],
			String:auth[32],
			String:escaped_auth[65];

			GetClientAuthString(client, auth, sizeof(auth));
			SQL_EscapeString(g_hDatabase, auth, escaped_auth, sizeof(escaped_auth));
			Format(query, sizeof(query), "SELECT id FROM cp_players WHERE auth = '%s';", escaped_auth);

			SQL_TQuery(g_hDatabase, SQLT_SelectPlayer, query, data);
		}
	}
}

public SQLT_SelectPlayer(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
	else {
		new client = GetClientOfUserId(data);

		if (!IsClientValid(client, false)) {
			return;
		}

		if (!SQL_FetchRow(hndl)) {
			CloseHandle2(g_hDatabase);
			return;
		}

		g_DatabaseId[client] = SQL_FetchInt(hndl, 0);

		LoadPlayerCheckpoints(client);
	}
}

LoadPlayerCheckpoints(client) {
	decl String:query[512];

	Format(
		query, sizeof(query),
		"SELECT \
			origin_x, origin_y, origin_z, \
			angle_pitch, angle_yaw, angle_roll, \
			velocity_x, velocity_y, velocity_z \
		FROM cp_checkpoints \
		WHERE \
			player = '%i' AND \
			map = '%i' \
		ORDER BY cp_index ASC\
		;",
		g_DatabaseId[client], g_DatabaseId[0]
	);

	SQL_TQuery(g_hDatabase, SQLT_SelectCheckpoints, query, GetClientUserId(client));
}

public SQLT_InsertMap(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
	else {
		if (SQL_GetAffectedRows(hndl) != 0) {
			g_DatabaseId[0] = SQL_GetInsertId(hndl);
		}
		else {
			decl String:query[256],
			String:map[64],
			String:escaped_map[129];

			GetCurrentMap(map, sizeof(map));
			SQL_EscapeString(g_hDatabase, map, escaped_map, sizeof(escaped_map));
			Format(query, sizeof(query), "SELECT id FROM cp_maps WHERE name = '%s';", escaped_map);

			SQL_TQuery(g_hDatabase, SQLT_SelectMap, query, _, DBPrio_High);
		}
	}
}

public SQLT_SelectMap(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
	else {
		if (!SQL_FetchRow(hndl)) {
			CloseHandle2(g_hDatabase);
			return;
		}

		g_DatabaseId[0] = SQL_FetchInt(hndl, 0);
	}
}

public SQLT_InsertCheckpoint(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
}

public SQLT_DeleteCheckpoints(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
}

public SQLT_SelectCheckpoints(Handle:owner, Handle:hndl, const String:error[], any:data) {
	if (hndl == INVALID_HANDLE) {
		LogError("Query failed: \"%s\"", error);
		CloseHandle2(g_hDatabase);
	}
	else {
		new client = GetClientOfUserId(data);

		if (!IsClientValid(client, false)) {
			return;
		}

		if (!CP_Initialise(client)) {
			return;
		}

		new start = GetArraySize(g_hCheckpoint[client]),
			count = 0;

		while (SQL_FetchRow(hndl)) {
			PushArrayCell(g_hCheckpoint[client], 0);

			for (new i = 0; i < 9; i++) {
				SetArrayCell(g_hCheckpoint[client], start + count, SQL_FetchFloat(hndl, i), i);
			}

			count++;
			
		}

		g_CurrentIndex[client] = start + count - 1;

		if (g_CvEnabled && IsClientInGame(client)) {
			PrintToChat(client, "[SM] Loaded %i checkpoints from database.", count);
		}
	}
}

Action:CallEventForward(ECheckpoints_Event:event, client, index = -1, Float:origin[3] = NULL_VECTOR, Float:eye_angles[3] = NULL_VECTOR, Float:velocity[3] = NULL_VECTOR) {
	Call_StartForward(g_EventForward);

	Call_PushCell(event);
	Call_PushCell(client);
	Call_PushCell(index);
	Call_PushArrayEx(origin, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(eye_angles, 3, SM_PARAM_COPYBACK);
	Call_PushArrayEx(velocity, 3, SM_PARAM_COPYBACK);

	decl Action:result;
	new error = SP_ERROR_NONE;
	if ((error = Call_Finish(result)) != SP_ERROR_NONE) {
		LogError("Couldn't broadcast event: %i", error);
		result = Plugin_Continue;
	}

	return result;
}

// #section natives

static AssertNativeError_Params(numParams, argc) {
	if (numParams != argc) {
		ThrowNativeError(SP_ERROR_PARAM, "wrong number of parameters supplied: got (%i), expected (%i)", numParams, argc);
		return true;
	}

	return false;
}

static AssertNativeError_ParamsRange(numParams, nlower, nupper) {
	if (numParams < nlower || numParams > nupper) {
		ThrowNativeError(SP_ERROR_PARAM, "wrong number of parameters supplied: got (%i), expected ([%i, %i])", numParams, nlower, nupper);
		return true;
	}

	return false;
}

static AssertNativeError_Client(&client) {
	if (!IsClientValid(client)) {
		ThrowNativeError(SP_ERROR_INDEX, "client index %i is invalid", client);
		return true;
	}

	return false;
}

public Native_Save(Handle:plugin, numParams) {
	if (AssertNativeError_ParamsRange(numParams, 1, 2)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	new index = numParams > 1 ? GetNativeCell(2) : -1;

	return CP_Save(client, index);
}

public Native_Teleport(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 2)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	new index = GetNativeCell(2);

	if (index < 0) {
		index = 0;
	}

	new size = 0;
	if (g_hCheckpoint[client] == INVALID_HANDLE || (size = GetArraySize(g_hCheckpoint[client])) == 0) {
		index = -1;
	}
	else if (index >= size) {
		index = size - 1;
	}

	return CP_Teleport(client, index);
}

public Native_Next(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	return CP_Next(client);
}

public Native_Previous(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	return CP_Previous(client);
}

public Native_Delete(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 2)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	return CP_Delete(client, GetNativeCell(2));
}

public Native_Clear(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	return CP_Clear(client);
}

public Native_GetNumberOfCheckpoints(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	if (g_hCheckpoint[client] == INVALID_HANDLE) {
		return 0;
	}

	return GetArraySize(g_hCheckpoint[client]);
}

public Native_GetCurrentCPIndex(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	return g_CurrentIndex[client];
}

public Native_SetCurrentCPIndex(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 2)) {
		return -1;
	}

	new client = GetNativeCell(1);

	if (AssertNativeError_Client(client)) {
		return -1;
	}

	new index = GetNativeCell(2);

	if (index < 0) {
		index = 0;
	}

	new size = 0;
	if (g_hCheckpoint[client] == INVALID_HANDLE || (size = GetArraySize(g_hCheckpoint[client])) == 0) {
		index = -1;
	}
	else if (index >= size) {
		index = size -1;
	}

	g_CurrentIndex[client] = index;

	return index;
}

public Native_HookEvents(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return false;
	}

	return AddToForward(g_EventForward, plugin, GetNativeCell(1));
}

public Native_UnhookEvents(Handle:plugin, numParams) {
	if (AssertNativeError_Params(numParams, 1)) {
		return false;
	}

	return RemoveFromForward(g_EventForward, plugin, GetNativeCell(1));
}

// #section stocks
/**
 * Retrieves the entity's absolute velocity
 *
 * \error									Entity is invalid or doesn't have entity property m_vecVelocity[]
 */
stock GetEntityAbsVelocity(
	entity,									///<! [in] The entity's index
	Float:vel[3]							///<! [out] Buffer used to store the entity's absolute velocity
) {
	for (new i = 0; i < 3; i++) {
		decl String:prop[32];
		Format(prop, sizeof(prop), "m_vecVelocity[%i]", i);
		vel[i] = GetEntPropFloat(entity, Prop_Send, prop);
	}
}

/**
 * \brief Returns whether the client is valid.
 *
 * If the client is out of range, this function assumes the input was a client serial.
 *
 * \return									Whether the client is valid
 */
stock IsClientValid(
	&client,								///<! [in, out] The client's index
	bool:in_game = true,					///<! [in] Whether the client has to be ingame
	bool:in_kick_queue = false				///<! [in] Whether the client can be in the kick queue
) {
	if (client <= 0 || client > MaxClients) {
		client = GetClientFromSerial(client);
	}

	return client > 0 && client <= MaxClients && IsClientConnected(client) && (!in_game || IsClientInGame(client)) && (in_kick_queue || !IsClientInKickQueue(client));
}

/**
 * \brief Closes a Handle. If the handle has multiple copies open, 
 * it is not destroyed unless all copies are closed.
 *
 * Closing a Handle has a different meaning for each Handle type. Make
 * sure you read the documentation on whatever provided the Handle.
 * No attempt is made to close the handle if INVALID_HANDLE is passed.
 * If the handle is closed, the input variable is set to INVALID_HANDLE.
 *	
 * \return									1 if successful, 0 if not closeable, -1 if the handled was already closed.
 * \error									Invalid handles will cause a run time error.
 */
stock CloseHandle2(
	&Handle:hndl							///<! [in, out] Handle to close.
) {
	if (hndl != INVALID_HANDLE) {
		if (CloseHandle(hndl)) {
			hndl = INVALID_HANDLE;
			return 1;
		}
		else {
			return 0;
		}
	}

	return -1;
}

/**
 * \brief Creates a plugin version console variable.
 *
 * \return									Whether creating the console variable was successful
 * \error									Convar name is blank or is the same as an existing console command
 */
stock InitVersionCvar(
	const String:cvar_name[],				///<! [in] The console variable's name (sm_<name>_version)
	const String:plugin_name[],				///<! [in] The plugin's name
	const String:plugin_version[],			///<! [in] The plugin's version
	additional_flags = 0					///<! [in] additional FCVAR_* flags  (default: FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD)
) {
	if (StrEqual(cvar_name, "") || StrEqual(plugin_name, "")) {
		return false;
	}

	new cvar_name_len = strlen(cvar_name) + 12,
		descr_len = strlen(cvar_name) + 20;
	decl String:name[cvar_name_len],
		String:descr[descr_len];

	Format(name, cvar_name_len, "sm_%s_version", cvar_name);
	Format(descr, descr_len, "\"%s\" - version number", plugin_name);

	new Handle:cvar = FindConVar(name),
		flags = FCVAR_NOTIFY | FCVAR_DONTRECORD | additional_flags;

	if (cvar != INVALID_HANDLE) {
		SetConVarString(cvar, plugin_version);
		SetConVarFlags(cvar, flags);
	}
	else {
		cvar = CreateConVar(name, plugin_version, descr, flags);
	}

	if (cvar != INVALID_HANDLE) {
		CloseHandle(cvar);
		return true;
	}

	LogError("Couldn't create version console variable \"%s\".", name);
	return false;
}

/**
 * \brief Creates a new console variable and hooks it to the specified OnConVarChanged: callback.
 *
 * This function attempts to deduce from the default value what type of data (int, float)
 * is supposed to be stored in the console variable, and returns its value accordingly.
 * (Its type can also be manually specified.) Alternatively one could opt to let the
 * ConVarChanged: callback do the initialisation. This is however prone to error,
 * should this callback handle multiple console variables distinguished by their
 * handles: if CreateConVar() fails, the appropriate code in the callback is never
 * reached.
 *
 * \return									Context sensitive; check detailed description
 * \error									Callback is invalid, or convar name is blank or is the same as an existing console command
 */
stock any:InitCvar(
	&Handle:cvar,							///<! [out] A handle to the newly created convar. If the convar already exists, a handle to it will still be returned.
	ConVarChanged:callback,					///<! [in] Callback function called when the convar's value is modified.
	const String:name[],					///<! [in] Name of new convar
	const String:defaultValue[],			///<! [in] String containing the default value of new convar
	const String:description[] = "",		///<! [in] Optional description of the convar
	flags = 0,								///<! [in] Optional bitstring of flags determining how the convar should be handled. See FCVAR_* constants for more details
	bool:hasMin = false,					///<! [in] Optional boolean that determines if the convar has a minimum value
	Float:min = 0.0,						///<! [in] Minimum floating point value that the convar can have if hasMin is true
	bool:hasMax = false,					///<! [in] Optional boolean that determines if the convar has a maximum value
	Float:max = 0.0,						///<! [in] Maximum floating point value that the convar can have if hasMax is true
	type = -1								///<! [in] Return / initialisation type
) {
	cvar = CreateConVar(name, defaultValue, description, flags, hasMin, min, hasMax, max);
	if (cvar != INVALID_HANDLE) {
		HookConVarChange(cvar, callback);
	}
	else {
		LogMessage("Couldn't create console variable \"%s\", using default value \"%s\".", name, defaultValue);
	}

	if (type < 0 || type > 3) {
		type = 1;
		new len = strlen(defaultValue);
		for (new i = 0; i < len; i++) {
			if (defaultValue[i] == '.') {
				type = 2;
			}
			else if (IsCharNumeric(defaultValue[i])) {
				continue;
			}
			else {
				type = 0;
				break;
			}
		}
	}

	if (type == 1) {
		return cvar != INVALID_HANDLE ? GetConVarInt(cvar) : StringToInt(defaultValue);
	}
	else if (type == 2) {
		return cvar != INVALID_HANDLE ? GetConVarFloat(cvar) : StringToFloat(defaultValue);
	}
	else if (cvar != INVALID_HANDLE && type == 3) {
		Call_StartFunction(INVALID_HANDLE, callback);
		Call_PushCell(cvar);
		Call_PushString("");
		Call_PushString(defaultValue);
		Call_Finish();

		return true;
	}

	return 0;
}
