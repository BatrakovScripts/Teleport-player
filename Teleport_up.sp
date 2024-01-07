#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//*
//*                 Teleport Player
//*                 Status: beta
//*					Автор первого релиза by Dr. HyperKiLLeR Release version 1.2
//*                	Автор доработки by Alexander_Mirny(Ник в игре ploxarik) Release version 1.4
//*
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
public void OnPluginStart()
{
	RegAdminCmd("sm_goto", Command_Goto, ADMFLAG_BAN,"Телепортироваться к игроку");
	RegAdminCmd("sm_gethere", Command_Gethere, ADMFLAG_BAN,"Телепортировать игрока к себе");
	//
	CreateConVar("l4d_teleport_version", "1.4", "Версия плагина", FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
}

public void OnClientPostAdminCheck(int client)
{
	ClientCommand(client, "bind f9 sm_goto; bind f10 sm_gethere;");
}

//=====================[Команда sm_goto]==========================//
public Action Command_Goto(int client, int args)
{
	ShowGotoMenu(client);
	return Plugin_Handled;
}

stock void ShowGotoMenu(int client)
{
	Menu menu = CreateMenu(Goto_Menu); 
	SetMenuTitle(menu, "Телепортироваться к игроку:\n \n"); 
	char userid[15], name[32]; 
	for (int i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i)) 
		{ 
			IntToString(GetClientUserId(i), userid, 15); 
			GetClientName(i, name, 32); 
			AddMenuItem(menu, userid, name);  
		}
	}
	DisplayMenu(menu, client, 0); 
}

public int Goto_Menu(Menu menu, MenuAction action, int client, int option) 
{
	if (action == MenuAction_End) 
	{
		delete menu; 
		return; 
	}
	if (action != MenuAction_Select) return; 
	char userid[15]; 
	GetMenuItem(menu, option, userid, 15); 
	int target = GetClientOfUserId(StringToInt(userid));
	int MaxPlayers;
	char PlayerName[32];
	float TeleportOrigin[3];
	float PlayerOrigin[3];
	char Name[32];
	
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	MaxPlayers = MaxClients;
	for(int X = 1; X <= MaxPlayers; X++)
	{
		if(!IsClientConnected(X)) continue;

		GetClientName(X, Name, sizeof(Name));

		if(StrContains(Name, PlayerName, false) != -1) target = X;
	}
	GetClientName(target, Name, sizeof(Name));
	GetClientAbsOrigin(target, PlayerOrigin);

	TeleportOrigin[0] = PlayerOrigin[0];
	TeleportOrigin[1] = PlayerOrigin[1];
	TeleportOrigin[2] = (PlayerOrigin[2] + 73);

	TeleportEntity(client, TeleportOrigin, NULL_VECTOR, NULL_VECTOR);
	PrintToChat(target, "\x04Админ \x03%N \x04телепортировался к вам.", client);
	PrintToChatAll("\x04Админ \x03%N \x04телепортировался к игроку \x03%N", client, target);
}

//=====================[Команда sm_gethere]==========================//
public Action Command_Gethere(int client, int args)
{
	ShowGethereMenu(client);
	return Plugin_Handled;
}

stock void ShowGethereMenu(int client)
{
	Menu menu = CreateMenu(Gethere_Menu); 
	SetMenuTitle(menu, "Телепортировать игрока к себе:\n \n"); 
	char userid[15], name[32]; 
	for (int i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i)) 
		{ 
			IntToString(GetClientUserId(i), userid, 15); 
			GetClientName(i, name, 32); 
			AddMenuItem(menu, userid, name);  
		}
	}
	DisplayMenu(menu, client, 0); 
}

public int Gethere_Menu(Menu menu, MenuAction action, int client, int option) 
{
	if (action == MenuAction_End) 
	{
		delete menu; 
		return; 
	}
	if (action != MenuAction_Select) return; 
	char userid[15]; 
	GetMenuItem(menu, option, userid, 15); 
	int target = GetClientOfUserId(StringToInt(userid));  
	int MaxPlayers;
	char PlayerName[32];
	float TeleportOrigin[3];
	float PlayerOrigin[3];
	char Name[32];

	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	MaxPlayers = MaxClients;
	for(int X = 1; X <= MaxPlayers; X++)
	{
		if(!IsClientConnected(X)) continue;

		GetClientName(X, Name, sizeof(Name));

		if(StrContains(Name, PlayerName, false) != -1) target = X;
	}
	GetClientName(target, Name, sizeof(Name));
	GetCollisionPoint(client, PlayerOrigin);

	TeleportOrigin[0] = PlayerOrigin[0];
	TeleportOrigin[1] = PlayerOrigin[1];
	TeleportOrigin[2] = (PlayerOrigin[2] + 4);

	TeleportEntity(target, TeleportOrigin, NULL_VECTOR, NULL_VECTOR);
	PrintToChat(target, "\x04Админ \x03%N \x04телепортировал вас к себе.", client);
	PrintToChatAll("\x04Админ \x03%N \x04телепортировал игрока \x03%N \x04к себе", client, target);
}

stock void GetCollisionPoint(int client, float pos[3])
{
	float vOrigin[3], vAngles[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		delete trace;

		return;
	}

	delete trace;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
}