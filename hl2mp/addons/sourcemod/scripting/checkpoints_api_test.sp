/**
\file checkpoints_api_test.sp
\brief Sourcemod plugin that tests Checkpoints' SM plugin API.

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

#include <checkpoints>

new bool:g_Block = false;

#define PLUGIN_NAME "Checkpoints API Test"
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

public OnPluginStart() {
	// Mimic Checkpoint's base functions
	RegAdminCmd("sm_cp_test_save", ConCmd_Save, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_tele", ConCmd_Tele, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_next", ConCmd_Next, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_prev", ConCmd_Prev, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_delete", ConCmd_Delete, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_clear", ConCmd_Clear, ADMFLAG_ROOT);

	// Test Checkpoints_SetCurrentCPIndex()
	RegAdminCmd("sm_cp_test_first", ConCmd_First, ADMFLAG_ROOT);
	RegAdminCmd("sm_cp_test_last", ConCmd_Last, ADMFLAG_ROOT);

	// Test blocking events
	RegAdminCmd("sm_cp_test_block", ConCmd_Block, ADMFLAG_ROOT);

	Checkpoints_HookEvents(OnCheckpointEvent);
}

public Action:ConCmd_Save(client, argc) {
	if (argc > 1) {
		ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
	}

	new index = -1;

	if (argc == 1) {
		decl String:buffer[32];
		GetCmdArg(1, buffer, sizeof(buffer));

		index = StringToInt(buffer) - 1;
	}

	index = Checkpoints_Save(client, index);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't save checkpoint.");
	}
	else if (index != -2) {
		ReplyToCommand(client, "[SM] Succesfully saved checkpoint #%i/%i.", Checkpoints_GetCurrentCPIndex(client) + 1, Checkpoints_GetNumberOfCheckpoints(client));
	}

	return Plugin_Handled;
}

public Action:ConCmd_Tele(client, argc) {

	if (argc > 1) {
		ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
	}

	new index = Checkpoints_GetCurrentCPIndex(client);

	if (argc == 1) {
		decl String:buffer[32];
		GetCmdArg(1, buffer, sizeof(buffer));

		index = StringToInt(buffer) - 1;
	}

	index = Checkpoints_Teleport(client, index);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
	}
	else if (index != -2) {
		ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", Checkpoints_GetCurrentCPIndex(client) + 1, Checkpoints_GetNumberOfCheckpoints(client));
	}

	return Plugin_Handled;
}

public Action:ConCmd_Next(client, argc) {
	new index = Checkpoints_Next(client);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
	}
	else if (index != -2) {
		ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", Checkpoints_GetCurrentCPIndex(client) + 1, Checkpoints_GetNumberOfCheckpoints(client));
	}

	return Plugin_Handled;
}

public Action:ConCmd_Prev(client, argc) {
	new index = Checkpoints_Previous(client);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't teleport to checkpoint.");
	}
	else if (index != -2) {
		ReplyToCommand(client, "[SM] Succesfully teleported to checkpoint #%i/%i.", Checkpoints_GetCurrentCPIndex(client) + 1, Checkpoints_GetNumberOfCheckpoints(client));
	}

	return Plugin_Handled;
}

public Action:ConCmd_Delete(client, argc) {
	if (argc > 1) {
		ReplyToCommand(client, "[SM] Wrong number of parameters supplied.");
	}

	new index = Checkpoints_GetCurrentCPIndex(client);

	if (argc == 1) {
		decl String:buffer[32];
		GetCmdArg(1, buffer, sizeof(buffer));

		index = StringToInt(buffer) - 1;
	}

	index = Checkpoints_Delete(client, index);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't delete checkpoint.");
	}
	else {
		ReplyToCommand(client, "[SM] Succesfully deleted checkpoint #%i.", index + 1);
	}

	return Plugin_Handled;
}

public Action:ConCmd_Clear(client, argc) {
	ReplyToCommand(client, "[SM] Cleared %i checkpoints.", Checkpoints_Clear(client));

	return Plugin_Handled;
}

public Action:ConCmd_First(client, argc) {
	new index = Checkpoints_SetCurrentCPIndex(client, 0);

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't set current checkpoint.");
	}
	else {
		ReplyToCommand(client, "[SM] Set current checkpoint to #%i.", index + 1);
	}

	return Plugin_Handled;
}

public Action:ConCmd_Last(client, argc) {
	new index = Checkpoints_SetCurrentCPIndex(client, Checkpoints_GetNumberOfCheckpoints(client));

	if (index == -1) {
		ReplyToCommand(client, "[SM] Couldn't set current checkpoint.");
	}
	else {
		ReplyToCommand(client, "[SM] Set current checkpoint to #%i.", index + 1);
	}

	return Plugin_Handled;
}

public Action:ConCmd_Block(client, argc) {
	g_Block = !g_Block;

	ReplyToCommand(client, "Turned blocking events %s.", g_Block ? "on" : "off");
}

public Action:OnCheckpointEvent(ECheckpoints_Event:event, client, index, Float:origin[3], Float:eye_angles[3], Float:velocity[3]) {
	if (!CheckCommandAccess(client, "", ADMFLAG_ROOT, true)) {
		return Plugin_Continue;
	}

	// Should never happen
	if (event < ECheckpoints_Event:0 || event >= ECheckpoints_Event) {
		PrintToChat(client, "[SM] OnCheckpointEvent - invalid event #");
		return Plugin_Continue;
	}

	static String:event_name[ECheckpoints_Event][] = {
		"EVENT_SAVE",
		"EVENT_TELEPORT",
		"EVENT_DELETE",
		"EVENT_CLEAR"
	};

	PrintToConsole(client, "[SM] OnCheckpointEvent(%s, %N, %i, {%.1f, %.1f, %.1f}, {%.1f, %.1f, %.1f}, {%.1f, %.1f, %.1f}",
		event_name[event], client, index,
		origin[0], origin[1], origin[2], 
		eye_angles[0], eye_angles[1], eye_angles[2],
		velocity[0], velocity[1], velocity[2]
	);

	new Action:ret = Plugin_Continue;

	if (g_Block) {
		PrintToChat(client, "[SM] Blocking event.");
		// Should block CHECKPOINTS_EVENT_SAVE and CHECKPOINTS_EVENT_TELEPORT
		ret = Plugin_Stop;
	}
	else {
		switch (event) {
			case CHECKPOINTS_EVENT_SAVE:
			{
				// Test changing values
				if ((GetEntityFlags(client) & FL_ONGROUND) != FL_ONGROUND) {
					PrintToChat(client, "[SM] You're saving in the air, nullifying velocity.");

					for (new i = 0; i < 3; i++) {
						velocity[i] = 0.0;
					}

					ret = Plugin_Changed;
				}
			}
			case CHECKPOINTS_EVENT_TELEPORT:
			{
				// Won't do anything since Plugin_Changed isn't returned
				for (new i = 0; i < 3; i++) {
					velocity[i] *= 3.0;
				}
			}

			// Unblockable, can be used to keep track of checkpoint indeces
			case CHECKPOINTS_EVENT_DELETE:
			{
			}
			case CHECKPOINTS_EVENT_CLEAR:
			{
			}
		}
	}

	return ret;
}
