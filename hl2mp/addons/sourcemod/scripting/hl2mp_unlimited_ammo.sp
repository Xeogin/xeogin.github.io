#include <sdkhooks>
#include <sourcemod>

new bool:enable;

new const m_iClip_sizes[] =
{
	0,		//skip
	30,		//AR2			pri
	3,		//AR2AltFire	sec
	18,		//Pistol		pri
	45,		//SMG1			pri
	6,		//357			pri
	99,		//XBowBolt		pri
	6,		//Buckshot		pri
	1,		//RPG_Round		pri
	3,		//SMG1_Grenade	sec
	5,		//Grenade		pri
	5,		//Slam			sec
}

new const m_iAmmo_sizes[] =
{
	0,		//skip
	60,		//AR2			pri
	3,		//AR2AltFire	sec
	144,	//Pistol		pri
	225,	//SMG1			pri
	12,		//357			pri
	0,		//XBowBolt		pri
	30,		//Buckshot		pri
	3,		//RPG_Round		pri
	3,		//SMG1_Grenade	sec
	5,		//Grenade		pri
	5,		//Slam			sec
}

#define AR2 1
//#define AR2AltFire 2
#define Pistol 3
#define SMG1 4
//#define 357 5 //Not possible, but using for reference
#define XBowBolt 6
#define Buckshot 7
#define RPG_Round 8
//#define SMG1_Grenade 9
#define Grenade 10
//#define Slam 11

public OnPluginStart()
{
	new Handle:cvar = CreateConVar("sm_hl2mp_unlimited_ammo", "0", "Lots of lots of ammunitions", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	enable = GetConVarBool(cvar);
	HookConVarChange(cvar, cvar_changed);
	CloseHandle(cvar);

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public cvar_changed(Handle:convar, const String:oldValue[], const String:newValue[])
{
	enable = StringToInt(newValue) == 1 ? true:false;
}

public OnClientPutInServer(client)
{
	//SDKHookEx(client, SDKHook_FireBulletsPost, FireBulletsPost);
	SDKHookEx(client, SDKHook_WeaponSwitchPost, WeaponSwitchPost);
}

//public FireBulletsPost(client, shots, const String:weaponname[])
//{
//	if(!enable)
//	{
//		return;
//	}
//
//	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
//
//	if(weapon != -1)
//	{
//		ReFillWeapon(client, weapon);
//	}
//}

public Action:OnPlayerRunCmd(client, &buttons, &impulse)
{
	if(buttons & IN_ATTACK)
	{
		if(!enable)
		{
			return;
		}

		new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if(weapon != -1)
		{
			ReFillWeapon(client, weapon);
		}
	}
}

public WeaponSwitchPost(client, weapon)
{
	if(enable && weapon != -1)
	{
		ReFillWeapon(client, weapon);
	}
}

//public OnEntityCreated(entity, const String:classname[])
//{
//	if (strcmp(classname, "crossbow_bolt") == 0)
//	{
//		if(!enable)
//		{
//			return;
//		}
//
//		new client = 
//
//		if(weapon != -1)
//		{
//			ReFillWeapon(client, weapon);
//		}
//	}
//}

ReFillWeapon(client, weapon)
{
	new m_iPrimaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if(m_iPrimaryAmmoType != -1 && m_iPrimaryAmmoType != RPG_Round && m_iPrimaryAmmoType != Grenade)
	{
		if(m_iPrimaryAmmoType != RPG_Round && m_iPrimaryAmmoType != Grenade && m_iPrimaryAmmoType != AR2 && m_iPrimaryAmmoType != SMG1 && m_iPrimaryAmmoType != Pistol && m_iPrimaryAmmoType != Buckshot)
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", m_iClip_sizes[m_iPrimaryAmmoType]);
		}
		//if(m_iPrimaryAmmoType != XBowBolt)
		//{
		SetEntProp(client, Prop_Send, "m_iAmmo", m_iAmmo_sizes[m_iPrimaryAmmoType], _, m_iPrimaryAmmoType);
		//}
	}

	//new m_iSecondaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iSecondaryAmmoType");
	//if(m_iSecondaryAmmoType != -1 && m_iSecondaryAmmoType != AR2AltFire && m_iSecondaryAmmoType != SMG1_Grenade && m_iSecondaryAmmoType != Slam)
	//{
	//	SetEntProp(client, Prop_Send, "m_iAmmo", 255, _, m_iSecondaryAmmoType);
	//}
}