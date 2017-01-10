#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define VERSION "1.0"

new String:path_decals[PLATFORM_MAX_PATH];

public Plugin:myinfo =
{
	name = "Lasers with menu",
	author = "Franc1sco franug",
	description = "",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug/"
}
Handle cvar_life;
float g_life;

new Float:LastLaser[MAXPLAYERS+1][3];
new bool:LaserE[MAXPLAYERS+1] = {false, ...};
new g_sprite;
enum Listado
{
	String:Nombre[32],
	colors[4]
}
new Handle:c_GameSprays = INVALID_HANDLE;
new g_sprays[128][Listado];
new g_sprayCount = 0;
new g_sprayElegido[MAXPLAYERS + 1];


public OnPluginStart() {
	c_GameSprays = RegClientCookie("FLasers", "FLasers", CookieAccess_Private);
	RegAdminCmd("+draw", CMD_laser_p, ADMFLAG_RESERVATION);
	RegAdminCmd("-draw", CMD_laser_m, ADMFLAG_RESERVATION);
	RegAdminCmd("+lasers", CMD_laser_p, ADMFLAG_RESERVATION);
	RegAdminCmd("-lasers", CMD_laser_m, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_lasers", GetSpray, ADMFLAG_RESERVATION);
	
	cvar_life = CreateConVar("sm_lasers_lifetime", "1800.0", "Lifetime for lasers");
	g_life = GetConVarFloat(cvar_life);
	HookConVarChange(cvar_life, OnConVarChanged);
}
public OnConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_life = StringToFloat(newValue);
}


public OnPluginEnd()
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public OnClientCookiesCached(client)
{
	new String:SprayString[12];
	GetClientCookie(client, c_GameSprays, SprayString, sizeof(SprayString));
	g_sprayElegido[client]  = StringToInt(SprayString);
}

public OnClientDisconnect(client)
{
	if(AreClientCookiesCached(client))
	{
		new String:SprayString[12];
		Format(SprayString, sizeof(SprayString), "%i", g_sprayElegido[client]);
		SetClientCookie(client, c_GameSprays, SprayString);
	}
}
public OnMapStart() {
	g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	CreateTimer(0.1, Timer_Pay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	BuildPath(Path_SM, path_decals, sizeof(path_decals), "configs/franug_lasers.cfg");
	ReadL();
}
public OnClientPutInServer(client)
{
	LaserE[client] = false;
	LastLaser[client][0] = 0.0;
	LastLaser[client][1] = 0.0;
	LastLaser[client][2] = 0.0;
}
public Action:Timer_Pay(Handle:timer)
{
	new Float:pos[3];
	int index;
	int Colors[4];
	
	for(new Y = 1; Y <= MaxClients; Y++) 
	{
		if(IsClientInGame(Y) && LaserE[Y])
		{
			TraceEye(Y, pos);
			if(GetVectorDistance(pos, LastLaser[Y]) > 6.0) {
				
				if (g_sprayElegido[Y] == 0)index = GetRandomInt(1, g_sprayCount - 1);
				else index = g_sprayElegido[Y];
				
				Colors[0] = g_sprays[index][colors][0];
				Colors[1] = g_sprays[index][colors][1];
				Colors[2] = g_sprays[index][colors][2];
				Colors[3] = g_sprays[index][colors][3];
				
				LaserP(LastLaser[Y], pos, Colors);
				LastLaser[Y][0] = pos[0];
				LastLaser[Y][1] = pos[1];
				LastLaser[Y][2] = pos[2];
			}
		} 
	}
}
public Action:CMD_laser_p(client, args) {
	if (!g_bflagTitles[client][0])
	{
		ReplyToCommand(client, "[CK] This command requires the VIP title.");
		return Plugin_Handled;
	}
	TraceEye(client, LastLaser[client]);
	LaserE[client] = true;
	return Plugin_Handled;
}

public Action:CMD_laser_m(client, args) {
	if (!g_bflagTitles[client][0])
	{
		ReplyToCommand(client, "[CK] This command requires the VIP title.");
		return Plugin_Handled;
	}
	LastLaser[client][0] = 0.0;
	LastLaser[client][1] = 0.0;
	LastLaser[client][2] = 0.0;
	LaserE[client] = false;
	return Plugin_Handled;
}
stock LaserP(Float:start[3], Float:end[3], color[4]) {
	TE_SetupBeamPoints(start, end, g_sprite, 0, 0, 0, g_life, 2.0, 2.0, 10, 0.0, color, 0);
	TE_SendToAll();
}
TraceEye(client, Float:pos[3]) {
	decl Float:vAngles[3], Float:vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(INVALID_HANDLE)) TR_GetEndPosition(pos, INVALID_HANDLE);
	return;
}
public bool:TraceEntityFilterPlayer(entity, contentsMask) {
	return (entity > GetMaxClients() || !entity);
}

ReadL() {
	
	
	decl Handle:kv;
	g_sprayCount = 1;
	decl String:buffer[PLATFORM_MAX_PATH];

	kv = CreateKeyValues("Lasers");
	FileToKeyValues(kv, path_decals);

	if (!KvGotoFirstSubKey(kv)) {

		SetFailState("CFG File not found: %s", path_decals);
		CloseHandle(kv);
	}
	do {

		KvGetSectionName(kv, buffer, sizeof(buffer));
		Format(g_sprays[g_sprayCount][Nombre], 32, "%s", buffer);
		
		decl String:color[64][4];
		KvGetString(kv, "color", buffer, 64);
		ExplodeString(buffer, " ", color, 4, 64);
		
		g_sprays[g_sprayCount][colors][0] = StringToInt(color[0]);
		g_sprays[g_sprayCount][colors][1] = StringToInt(color[1]);
		g_sprays[g_sprayCount][colors][2] = StringToInt(color[2]);
		g_sprays[g_sprayCount][colors][3] = StringToInt(color[3]);
		
		g_sprayCount++;
	} while (KvGotoNextKey(kv));
	CloseHandle(kv);
}

public Action:GetSpray(client, args)
{	
	if (!g_bflagTitles[client][0])
	{
		ReplyToCommand(client, "[CK] This command requires the VIP title.");
		return Plugin_Handled;
	}
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Choose your Laser color");
	decl String:item[4];
	AddMenuItem(menu, "0", "Random Color");
	for (new i=1; i<g_sprayCount; ++i) {
		Format(item, 4, "%i", i);
		AddMenuItem(menu, item, g_sprays[i][Nombre]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		decl String:info[4];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		g_sprayElegido[client] = StringToInt(info);
		PrintToChat(client, " \x04You have choosen your color!");
	}
		
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
