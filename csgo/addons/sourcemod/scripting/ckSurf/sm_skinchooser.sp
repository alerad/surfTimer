/*******************************************************************************

  SM Skinchooser

  Version: 4.0
  Author: Andi67
  
  Updated to new Syntax.
  Added more Cvars for customization.
   
  Added CSGO Armmodels support. 
  Updated SteamId check for matching SteamId3.
  Plugin now uses mapbased cnnfigs.
   
  
  Added more Botchecks , some cosmetic. 
   
   
  Now you can force a skin to Admins automaticly. 
   
  
   
  Added possebility to restrict the sm_models/!models command by cvar. 
  Added Timer for Menu closing automaticly. 
  
   
  Changed some cvars from "enabled" to "disabled" by default , seams necessary since some people are not able to read the documentation , 
  also changed some code. 
   
  

  Added new Cvar "sm_skinchooser_forceplayerskin" , only works if "sm_skinchooser_playerspawntimer" is set to "1" !!!
  This is used to force players become a customskin on Spawn.
  Added autocreating configfile on first start.
  
 
  Update to 2.2
  Added Cvar for displaying Menu only for Admins
  Added Cvar for Mods like Resistance and Liberation where player_spawn is fired a little bit later so we add an one second timer
  to make sure Model is set on spawn.
  
  
  Update to 2.1:
  Added new Cvar sm_skinchooser_admingroup , brings back the old GroupSystem.
  Bahhhh amazing now you can use Flags and multiple Groups!!!
  
   
  Update to 2.0: 
  New cvar sm_skinchooser_SkinBots , forces Bots to have a skin.
  New cvar sm_skinchooser_displaytimer , makes it possible to display the menu a little bit
  later not directly by choosing a team.
  New cvar sm_skinchooser_menustarttime , here you can modify the time when Menu should be displayed by joining the team
  related to sm_skinchooser_displaytimer.
  
  
  Update to 1.9:
  Removed needing of Gamedata.txt , so from now Gamedata.txt is no more needed!!!  
   
   
  Update to 1.8:
  Fixed another Handlebug. 
   
    
  Update to 1.7: 
   
  Added new Cvar "sm_skinchooser_autodisplay"   
  
  
  Update to 1.6: 
   
  Supported now all Flags
   
  
  Update to 1.5:
  
  Fixed native Handle error
  

  Update to 1.4:
   
   Plugin now handles the following Flags:
   
   "" - for Public
   "b" - Generic Admins
   "g" - Mapchange Admins
   "t" - Custom Admins for use Reserved Skins
   "z" - Root Admins
    
   Now you only will see Sections/Groups in the Menu you have Access to 
    
    Rearranged skins.ini for better overview
   
   Fixed some Menubugs
  
  Added Gamedata for Hl2mp


  
	Everybody can edit this plugin and copy this plugin.
	
  Thanks to:
	Pred,Tigerox,Recon for making Modelmenu

	Swat_88 for making sm_downloader and precacher
	
	Paegus,Ghosty for helping me to bring up the Menu on Teamjoin
	
	And special THX to Feuersturm who helped me to fix the Spectatorbug!!!
	
  HAVE FUN!!!

*******************************************************************************/

public int LoadModels(const char[][] models, char[] ini_file)
{
	char buffer[MAX_FILE_LEN];
	char file[MAX_FILE_LEN];
	int models_count;

	BuildPath(Path_SM, file, MAX_FILE_LEN, ini_file);

	//open precache file and add everything to download table
	Handle fileh = OpenFile(file, "r");
	while (ReadFileLine(fileh, buffer, MAX_FILE_LEN))
	{
		// Strip leading and trailing whitespace
		TrimString(buffer);
		
		// Skip comments
		if (buffer[0] != '/')
		{
		// Skip non existing files (and Comments)
			if (FileExists(buffer))
			{
				// Tell Clients to download files
				AddFileToDownloadsTable(buffer);
				// Tell Clients to cache model
				if (StrEqual(buffer[strlen(buffer)-4], ".mdl", false) && (models_count<MODELS_PER_TEAM))
				{
					strcopy(models[models_count++], strlen(buffer)+1, buffer);
					PrecacheModel(buffer, true);
				}
			}
		}
	}
	return models_count;
}

void LoadMapFile(const char[] file)
{	
	char path[100];	
	
	kv = CreateKeyValues("Commands");
	
	FileToKeyValues(kv, file);
	
	if (!KvGotoFirstSubKey(kv))
	{
		return;
	}
	do
	{
		KvJumpToKey(kv, "Team1");
		KvGotoFirstSubKey(kv);
		do
		{
			KvGetString(kv, "path", path, sizeof(path),"");
			if (FileExists(path , true))
				PrecacheModel(path,true);
		} 
		while (KvGotoNextKey(kv));
		
		KvGoBack(kv);
		KvGoBack(kv);
		KvJumpToKey(kv, "Team2");
		KvGotoFirstSubKey(kv);
		do
		{
			KvGetString(kv, "path", path, sizeof(path),"");
			if (FileExists(path , true))
				PrecacheModel(path,true);
		}
		while (KvGotoNextKey(kv));
			
		KvGoBack(kv);
		KvGoBack(kv);	
	} 
	while (KvGotoNextKey(kv));	
		
	KvRewind(kv);
}

void LoadArmsMapFile(const char[] filea)
{	
	char arms[100];	
	
	kva = CreateKeyValues("Commands");
	
	FileToKeyValues(kva, filea);
	
	if (!KvGotoFirstSubKey(kva))
	{
		return;
	}
	do
	{
		KvJumpToKey(kva, "Team1");
		KvGotoFirstSubKey(kva);
		do
		{
			KvGetString(kva, "arms", arms, sizeof(arms),"");
			if (FileExists(arms , true))
				PrecacheModel(arms,true);
		} 
		while (KvGotoNextKey(kva));
		
		KvGoBack(kva);
		KvGoBack(kva);
		KvJumpToKey(kva, "Team2");
		KvGotoFirstSubKey(kva);
		do
		{
			KvGetString(kva, "arms", arms, sizeof(arms),"");
			if (FileExists(arms , true))
				PrecacheModel(arms,true);
		}
		while (KvGotoNextKey(kva));
			
		KvGoBack(kva);
		KvGoBack(kva);
			
	} 
	while (KvGotoNextKey(kva));	
		
	KvRewind(kva);
}

Handle BuildMainMenu(int client)
{
	/* Create the menu Handle */
	Handle menu = CreateMenu(Menu_Group);
	
	if (!KvGotoFirstSubKey(kv))
	{
		return INVALID_HANDLE;
	}
	
	char buffer[30];
	char accessFlag[5];
	AdminId admin = GetUserAdmin(client);

	{
		do
		{
			if(GetConVarInt(g_AdminGroup) == 1)
			{
				// check if they have access
				char group[30];
				char temp[2];
				KvGetString(kv,"Admin",group,sizeof(group));
				AdminId AdmId = GetUserAdmin(client);
				int count = GetAdminGroupCount(AdmId);
				for (int i =0; i<count; i++) 
				{
					if (FindAdmGroup(group) == GetAdminGroup(AdmId, i, temp, sizeof(temp)))
					{
						// Get the model group name and add it to the menu
						KvGetSectionName(kv, buffer, sizeof(buffer));		
						AddMenuItem(menu,buffer,buffer);
					}
				}
			}

			//Get accesFlag and see if the Admin is in it
			KvGetString(kv, "admin", accessFlag, sizeof(accessFlag));
			
			if(StrEqual(accessFlag,""))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"a") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Reservation, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}			
			
			if(StrEqual(accessFlag,"b") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Generic, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"c") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Kick, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"d") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Ban, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"e") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Unban, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"f") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Slay, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}			
			
			if(StrEqual(accessFlag,"g") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Changemap, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"h") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Convars, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"i") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Config, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"j") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Chat, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"k") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Vote, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"l") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Password, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"m") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_RCON, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"n") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Cheats, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"o") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom1, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"p") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom2, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"q") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom3, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"r") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom4, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"s") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom5, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}			
				
			if(StrEqual(accessFlag,"t") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom6, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
			if(StrEqual(accessFlag,"z") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Root, Access_Effective))
			{
			KvGetSectionName(kv, buffer, sizeof(buffer));
			AddMenuItem(menu,buffer,buffer);
			}
			
		} while (KvGotoNextKey(kv));	
	}
	KvRewind(kv);

	AddMenuItem(menu,"none","None");
	SetMenuTitle(menu, "Skins");
 
	return menu;
}

public void ReadFileFolder(char[] path )
{
	Handle dirh = INVALID_HANDLE;
	char buffer[256];
	char tmp_path[256];
	FileType type = FileType_Unknown;
	int len;
	
	len = strlen(path);
	if (path[len-1] == '\n')
		path[--len] = '\0';

	TrimString(path);
	
	if(DirExists(path))
	{
		dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,path);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					if(downloadtype == 1)
					{
						ReadItem(tmp_path);
					}
					
				
				}
			}
		}
	}
	else{
		if(downloadtype == 1)
		{
			ReadItem(path);
		}
		
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

void ReadDownloads(const char[] files)
{
	Handle fileh = OpenFile(files, "r");
	char buffer[256];
	downloadtype = 1;
	int len;
	
	GetCurrentMap(map,255);
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{	
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE)
	{
		CloseHandle(fileh);
	}
}

void ReadArmsDownloads(const char[] fileb)
{
	Handle fileh = OpenFile(fileb, "r");
	char buffer[256];
	downloadtype = 1;
	int len;
	
	GetCurrentMap(map,255);
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{	
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE)
	{
		CloseHandle(fileh);
	}
}

public void ReadItem(char[] buffer)
{
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		if(StrContains(buffer,"//") >= 0)
		{
			ReplaceString(buffer,255,"//","");
		}
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		if(StrContains(mediatype,"Model",true) >= 0)
		{
			PrecacheModel(buffer,true);
		}
		AddFileToDownloadsTable(buffer);
		}
	}

public int Menu_Group(Menu menu, MenuAction action, int param1, int param2)
{
	// User has selected a model group
	if (action == MenuAction_Select)
	{
		char info[30];
		
		// Get the group they selected
		bool found = GetMenuItem(menu, param2, info, sizeof(info));
		
		if (!found)
			return;
			
		//tigeox
		// Check to see if the user has decided they don't want a model
		// (e.g. go to a stock model)%%
		if(StrEqual(info,"none"))
		{
			// Get the player's authid			
			KvJumpToKey(playermodelskv,authid[param1],true);
		
			// Clear their saved model so that the next time
			// they spawn, they are able to use a stock model
			if (GetClientTeam(param1) == 2)
			{
				KvSetString(playermodelskv, "Team1", "");
				KvSetString(playermodelskv, "Team1Group", "");
			}
			else if (GetClientTeam(param1) == 3)
			{
				KvSetString(playermodelskv, "Team2", "");
				KvSetString(playermodelskv, "Team2Group", "");				
			}
			
			// Rewind the KVs
			KvRewind(playermodelskv);
			
			// We don't need to go any further, return
			return;
		}
			
		// User selected a group
		// advance kv to this group
		KvJumpToKey(kv, info);
		
		
		// Check users team		
		if (GetClientTeam(param1) == 2)
		{
			// Show team 1 models
			KvJumpToKey(kv, "Team1");
		}
		else if (GetClientTeam(param1) == 3)
		{
			// Show team 2 models
			KvJumpToKey(kv, "Team2");
		}
		else
		
			// They must be spectator, return
			return;
			
		
		// Get the first model		
		KvGotoFirstSubKey(kv);
		
		// Create the menu
		Handle tempmenu = CreateMenu(Menu_Model);

		// Add the models to the menu
		char buffer[30];
		char path[256];
		do
		{
			// Add the model to the menu
			KvGetSectionName(kv, buffer, sizeof(buffer));			
			KvGetString(kv, "path", path, sizeof(path),"");			
			AddMenuItem(tempmenu,path,buffer);
	
		} 
		while (KvGotoNextKey(kv));
		
		
		// Set the menu title to the model group name
		SetMenuTitle(tempmenu, info);
		
		// Rewind the KVs
		KvRewind(kv);
		
		// Display the menu
		DisplayMenu(tempmenu, param1, MENU_TIME_FOREVER);
	}
		else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public int Menu_Model(Handle menu, MenuAction action, int param1, int param2)
{
	// User choose a model	
	if (action == MenuAction_Select)
	{
		char info[256];
		char group[30];

		// Get the model's menu item
		bool found = GetMenuItem(menu, param2, info, sizeof(info));

		
		if (!found)
			return;
			
		// Set the user's model
		if (!StrEqual(info,"") && IsModelPrecached(info) && IsClientConnected(param1))
		{
			// Set the model
			SetEntityModel(param1, info);
			SetEntityRenderColor(param1, 255, 255, 255, 255);
		}
					
		KvJumpToKey(playermodelskv,authid[param1],true);		
		
		// Save the user's choice so it is automatically applied
		// each time they spawn
		if (GetClientTeam(param1) == 2)
		{
			KvSetString(playermodelskv, "Team1", info);
			KvSetString(playermodelskv, "Team1Group", group);
		}
		else if (GetClientTeam(param1) == 3)
		{
			KvSetString(playermodelskv, "Team2", info);
			KvSetString(playermodelskv, "Team2Group", group);
		}
		
		// Rewind the KVs
		KvRewind(playermodelskv);
	}	
	
	// If Game is not CSGO, close the menu handle else display Armsmenu
	if(action == MenuAction_Select)
	{
		if (StrEqual(Game, "csgo") && GetConVarInt(g_arms_enabled) == 1)
		{
			CreateTimer(0.1 , CommandSecMenu , param1);			
		}

		else
		{
			CloseHandle(menu);
		}
	}
}

public Action CommandSecMenu(Handle timer, any param1)
{
	armsmainmenu = BuildArmsMainMenu(param1);
	
	if (armsmainmenu == INVALID_HANDLE)
	{ 
		// We don't, send an error message and return
		PrintToConsole(param1, "There was an error generating the menu. Check your skins.ini file.");
		return Plugin_Handled;
	}
	
	DisplayMenu(armsmainmenu, param1, GetConVarInt(g_CloseMenuTimer));
	return Plugin_Handled;
}

Handle BuildArmsMainMenu(int param1)
{
			/* Create the menu Handle */
			Handle secmenu = CreateMenu(Menu_Arms_Group);
	
			if (!KvGotoFirstSubKey(kva))
			{
				return INVALID_HANDLE;
			}
	
			char buffer[30];
			char accessFlag[5];
			AdminId admin = GetUserAdmin(param1);

			{
				do
				{
					if(GetConVarInt(g_AdminGroup) == 1)
					{
						// check if they have access
						char group[30];
						char temp[2];
						KvGetString(kva,"Admin",group,sizeof(group));
						AdminId AdmId = GetUserAdmin(param1);
						int count = GetAdminGroupCount(AdmId);
						for (int i =0; i<count; i++) 
						{
							if (FindAdmGroup(group) == GetAdminGroup(AdmId, i, temp, sizeof(temp)))
							{
								// Get the model group name and add it to the menu
								KvGetSectionName(kva, buffer, sizeof(buffer));		
								AddMenuItem(secmenu,buffer,buffer);
							}
						}
					}

					//Get accesFlag and see if the Admin is in it
					KvGetString(kva, "admin", accessFlag, sizeof(accessFlag));
			
					if(StrEqual(accessFlag,""))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"a") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Reservation, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}			
			
					if(StrEqual(accessFlag,"b") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Generic, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"c") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Kick, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"d") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Ban, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"e") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Unban, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"f") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Slay, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}			
			
					if(StrEqual(accessFlag,"g") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Changemap, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"h") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Convars, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"i") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Config, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"j") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Chat, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"k") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Vote, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"l") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Password, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"m") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_RCON, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"n") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Cheats, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"o") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom1, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"p") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom2, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"q") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom3, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"r") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom4, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"s") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom5, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}			
				
					if(StrEqual(accessFlag,"t") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom6, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
					if(StrEqual(accessFlag,"z") && admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Root, Access_Effective))
					{
						KvGetSectionName(kva, buffer, sizeof(buffer));
						AddMenuItem(secmenu,buffer,buffer);
					}
			
				} while (KvGotoNextKey(kva));	
			}
			KvRewind(kva);

			AddMenuItem(secmenu,"none","None");
			SetMenuTitle(secmenu, "Arms");
 
			return secmenu;	
}

public int Menu_Arms_Group(Menu secmenu, MenuAction action,int param1, int param2)
{
	// User has selected a model group
	if (action == MenuAction_Select)
	{
		char info[30];
		
		// Get the group they selected
		bool found = GetMenuItem(secmenu, param2, info, sizeof(info));
		
		if (!found)
			return;
			
		//tigeox
		// Check to see if the user has decided they don't want a model
		// (e.g. go to a stock model)%%
		if(StrEqual(info,"none"))
		{
			// Get the player's authid			
			KvJumpToKey(playermodelskva,authid[param1],true);
		
			// Clear their saved model so that the next time
			// they spawn, they are able to use a stock model
			if (GetClientTeam(param1) == 2)
			{
				KvSetString(playermodelskva, "Team1", "");
				KvSetString(playermodelskva, "Team1Group", "");
			}
			else if (GetClientTeam(param1) == 3)
			{
				KvSetString(playermodelskva, "Team2", "");
				KvSetString(playermodelskva, "Team2Group", "");				
			}
			
			// Rewind the KVs
			KvRewind(playermodelskva);
			
			// We don't need to go any further, return
			return;
		}
			
		// User selected a group
		// advance kv to this group
		KvJumpToKey(kva, info);
		
		
		// Check users team		
		if (GetClientTeam(param1) == 2)
		{
			// Show team 1 models
			KvJumpToKey(kva, "Team1");
		}
		else if (GetClientTeam(param1) == 3)
		{
			// Show team 2 models
			KvJumpToKey(kva, "Team2");
		}
		else
		
			// They must be spectator, return
			return;
			
		
		// Get the first model		
		KvGotoFirstSubKey(kva);
		
		// Create the menu
		Menu atempmenu = CreateMenu(Menu_Arms);

		// Add the models to the menu
		char buffer[30];
		char arms[256];
		do
		{
			// Add the model to the menu
			KvGetSectionName(kva, buffer, sizeof(buffer));			
			KvGetString(kva, "arms", arms, sizeof(arms),"");			
			AddMenuItem(atempmenu,arms,buffer);
	
		} 
		while (KvGotoNextKey(kva));
		
		
		// Set the menu title to the model group name
		SetMenuTitle(atempmenu, info);
		
		// Rewind the KVs
		KvRewind(kva);
		
		// Display the menu
		DisplayMenu(atempmenu, param1, MENU_TIME_FOREVER);
	}
		else if (action == MenuAction_End)
	{
		CloseHandle(secmenu);
	}
}

public int Menu_Arms(Menu amenu, MenuAction action, int param1,int param2)
{
	// User choose a model	
	if (action == MenuAction_Select)
	{
		char info[256];
		char group[30];

		// Get the model's menu item
		bool found = GetMenuItem(amenu, param2, info, sizeof(info));

		
		if (!found)
			return;
			
		// Set the user's model
		if (!StrEqual(info,"") && IsModelPrecached(info) && IsClientConnected(param1))
		{
			// Set the model
			SetEntPropString(param1, Prop_Send, "m_szArmsModel", info);
			CreateTimer(0.15, RemoveItemTimer, EntIndexToEntRef(param1), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		// Get the player's steam		
		KvJumpToKey(playermodelskva,authid[param1], true);		
		
		// Save the user's choice so it is automatically applied
		// each time they spawn
		if (GetClientTeam(param1) == 2)
		{
			KvSetString(playermodelskva, "Team1", info);
			KvSetString(playermodelskva, "Team1Group", group);
		}
		else if (GetClientTeam(param1) == 3)
		{
			KvSetString(playermodelskva, "Team2", info);
			KvSetString(playermodelskva, "Team2Group", group);
		}
		
		// Rewind the KVs
		KvRewind(playermodelskva);
	}
	
	// If they picked exit, close the menu handle
	if (action == MenuAction_End)
	{
		CloseHandle(amenu);
	}
}

public void OnClientPostAdminCheck(int client)
{	
	if(GetConVarInt(g_steamid) == 0)	
	{	
		GetClientAuthId(client,AuthId_Steam2, authid[client], sizeof(authid[]));
	}
	else if(GetConVarInt(g_steamid) == 1)	
	{	
		GetClientAuthId(client,AuthId_Steam3, authid[client], sizeof(authid[]));
	}	
		
	if(GetConVarInt(g_CommandCountsEnabled) == 1)	
	{	
		g_CmdCount[client] = 0;
	}
}

public Action Timer_Menu(Handle timer, any client)
{
	if(GetClientTeam(client) == 2 || GetClientTeam(client) == 3 && IsValidClient(client))
	{
		Command_Model(client, 0);
	}
	
	mainmenu = BuildMainMenu(client);
	
	if (mainmenu == INVALID_HANDLE)
	{ 
		// We don't, send an error message and return
		PrintToConsole(client, "There was an error generating the menu. Check your skins.ini file.");
		return Plugin_Handled;
	}
	
	DisplayMenu(mainmenu, client, GetConVarInt(g_CloseMenuTimer));
	PrintToChat(client, "Skinmenu is open , choose your Model!!!");
	return Plugin_Handled;
}

public Action Command_Model(int client,int args)
{
	if(GetConVarInt(g_enabled) == 1 && !IsFakeClient(client) && g_bflagTitles[client][0])	
	{
		if(GetConVarInt(g_CommandCountsEnabled) == 1)	
		{
			g_CmdCount[client]++;	
			int curCount = g_CmdCount[client];
		
			if(curCount <= GetConVarInt(g_CommandCounts))
			{
				//Create the main menu
				mainmenu = BuildMainMenu(client);
	
				// Do we have a valid model menu
				if (mainmenu == INVALID_HANDLE)
				{ 
					// We don't, send an error message and return
					PrintToConsole(client, "There was an error generating the menu. Check your skins.ini file.");
					return Plugin_Handled;
				}
	
				AdminId admin = GetUserAdmin(client);
	
				if (GetConVarInt(g_AdminOnly) == 1 && admin != INVALID_ADMIN_ID)
				{
					// We have a valid menu, display it and return
					DisplayMenu(mainmenu, client, GetConVarInt(g_CloseMenuTimer));
				}
				else if(GetConVarInt(g_AdminOnly) == 0)
				{
					DisplayMenu(mainmenu, client, GetConVarInt(g_CloseMenuTimer));
				}
			}
		}
		else if(GetConVarInt(g_CommandCountsEnabled) == 0)
		{
			//Create the main menu
			mainmenu = BuildMainMenu(client);
	
			// Do we have a valid model menu
			if (mainmenu == INVALID_HANDLE)
			{ 
				// We don't, send an error message and return
				PrintToConsole(client, "There was an error generating the menu. Check your skins.ini file.");
				return Plugin_Handled;
			}
	
			AdminId admin = GetUserAdmin(client);
	
			if (GetConVarInt(g_AdminOnly) == 1 && admin != INVALID_ADMIN_ID)
			{
				// We have a valid menu, display it and return
				DisplayMenu(mainmenu, client, GetConVarInt(g_CloseMenuTimer));
			}
			else if(GetConVarInt(g_AdminOnly) == 0)
			{
				DisplayMenu(mainmenu, client, GetConVarInt(g_CloseMenuTimer));
			}
		}
	} else {
		PrintToChat(client, "This is a VIP command");
	}
	return Plugin_Handled;	
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i <= MaxClients; i++)
	{	
		g_CmdCount[i] = 0;
	}
}

public Action Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	if(GetConVarInt(g_enabled) == 1)	
	{	
		if( GetConVarBool(g_autodisplay) )
		{
			int client = GetClientOfUserId(GetEventInt(event, "userid"));
			int team = GetEventInt(event, "team");
			if( GetConVarBool(g_displaytimer))
			{
				if((team == 2 || team == 3) && IsValidClient(client) && !IsFakeClient(client))
				{
					CreateTimer(GetConVarFloat(g_menustarttime), Timer_Menu, client);
				}
			}
		
			else if((team == 2 || team == 3) && IsValidClient(client) && !IsFakeClient(client))
			{
				Command_Model(client, 0);
			}
			return;
		}
	}
}

public Action Event_PlayerSpawn(Handle event,  const char[] name, bool dontBroadcast)
{
	if(GetConVarInt(g_enabled) == 1)	
	{	
		// Get the userid and client
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		
		if (StrEqual(Game, "csgo") && GetConVarInt(g_arms_enabled) == 1)
		{				
			// Get the user's authid				
			KvJumpToKey(playermodelskva,authid[client],true);
	
			char arms[256];
			char groups[30];	
	
			// Get the user's model pref
			if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 2)
			{
				KvGetString(playermodelskva, "Team1", arms, sizeof(arms), "");
				KvGetString(playermodelskva, "Team1Group", groups, sizeof(groups), "");
			}
			else if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 3)
			{
				KvGetString(playermodelskva, "Team2", arms, sizeof(arms), "");
				KvGetString(playermodelskva, "Team2Group", groups, sizeof(groups), "");
			}		
	
			// Make sure that they have a valid model pref
			if (!StrEqual(arms,"", false) && IsModelPrecached(arms))
			{
				// Set the Armsmodel
				SetEntPropString(client, Prop_Send, "m_szArmsModel", arms);
			}
			if (!StrEqual(arms,"") && IsModelPrecached(arms))
			{
				SetEntPropString(client, Prop_Send, "m_szArmsModel", arms);
			}
	
			// Rewind the KVs
			KvRewind(playermodelskva);
		}
	
		if( GetConVarInt(g_PlayerSpawnTimer) == 1)
		{
			if(!IsFakeClient(client) && IsValidClient(client))
			{
				CreateTimer(0.5, Timer_Spawn, client);
			}
		}
	
		else if( GetConVarInt(g_PlayerSpawnTimer) == 0)
		{
			// Get the user's authid			
			KvJumpToKey(playermodelskv,authid[client],true);
	
			char model[256];
			char group[30];	
	
			// Get the user's model pref
			if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 2)
			{
				KvGetString(playermodelskv, "Team1", model, sizeof(model), "");
				KvGetString(playermodelskv, "Team1Group", group, sizeof(group), "");
			}
			else if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 3)
			{
				KvGetString(playermodelskv, "Team2", model, sizeof(model), "");
				KvGetString(playermodelskv, "Team2Group", group, sizeof(group), "");
			}		
	
			// Make sure that they have a valid model pref
			if (!StrEqual(model,"", false) && IsModelPrecached(model))
			{
				// Set the model
				SetEntityModel(client, model);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
			if (!StrEqual(model,"") && IsModelPrecached(model))
			{
				SetEntityModel(client, model);
				SetEntityRenderColor(client, 255, 255, 255, 255);
			}
	
			// Rewind the KVs
			KvRewind(playermodelskv);
		}		
	
		if(IsFakeClient(client) && GetConVarInt(g_SkinBots) == 1)
		{
			skin_bots(client);
		}

		AdminId admin = GetUserAdmin(client);
	
		if (!IsFakeClient(client) && GetConVarInt(g_SkinAdmin) == 1 && admin != INVALID_ADMIN_ID && GetConVarInt(g_PlayerSpawnTimer) == 1)
		{
//			skin_admin(client);
			CreateTimer(1.0, skin_admin, client);
		}
		if(!IsFakeClient(client) && GetConVarInt(g_ForcePlayerSkin) == 1  && admin == INVALID_ADMIN_ID && GetConVarInt(g_PlayerSpawnTimer) == 1)
		{
//			skin_players(client);
			CreateTimer(1.0, skin_players, client);	
		}
	}	
}

public Action Timer_Spawn(Handle timer, any client)
{
	// Get the user's authid	
	KvJumpToKey(playermodelskv,authid[client],true);
	
	char model[256];
	char group[30];	
	
	// Get the user's model pref
	if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 2)
	{
		KvGetString(playermodelskv, "Team1", model, sizeof(model), "");
		KvGetString(playermodelskv, "Team1Group", group, sizeof(group), "");
	}
	else if (!IsFakeClient(client) && IsValidClient(client) && GetClientTeam(client) == 3)
	{
		KvGetString(playermodelskv, "Team2", model, sizeof(model), "");
		KvGetString(playermodelskv, "Team2Group", group, sizeof(group), "");
	}		
	
	// Make sure that they have a valid model pref
	if (!StrEqual(model,"", false) && IsModelPrecached(model))
	{
		// Set the model
		SetEntityModel(client, model);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	if (!StrEqual(model,"") && IsModelPrecached(model))
	{
		SetEntityModel(client, model);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	
	// Rewind the KVs
	KvRewind(playermodelskv);
}

public Action RemoveItemTimer(Handle timer, any ref)
{
	int client = EntRefToEntIndex(ref);
	
	if (client != INVALID_ENT_REFERENCE)
	{
		int item = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if (item > 0)
		{
			RemovePlayerItem(client, item);
			
			Handle ph=CreateDataPack();
			WritePackCell(ph, EntIndexToEntRef(client));
			WritePackCell(ph, EntIndexToEntRef(item));
			CreateTimer(0.15 , AddItemTimer, ph, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action AddItemTimer(Handle timer, any ph)
{  
	int client, item;
	
	ResetPack(ph);
	
	client = EntRefToEntIndex(ReadPackCell(ph));
	item = EntRefToEntIndex(ReadPackCell(ph));
	
	if (client != INVALID_ENT_REFERENCE && item != INVALID_ENT_REFERENCE)
	{
		EquipPlayerWeapon(client, item);
	}
}

void skin_bots(int client)
{
	int team = GetClientTeam(client);
	if (team==2)
	{
		SetEntityModel(client,g_ModelsBotsTeam2[GetRandomInt(0, g_ModelsBots_Count_Team2-1)]);
	}
	else if (team==3)
	{
		SetEntityModel(client,g_ModelsBotsTeam3[GetRandomInt(0, g_ModelsBots_Count_Team3-1)]);
	}
}

public Action skin_players(Handle timer, any client)
{
	int team = GetClientTeam(client);
	if (team==2)
	{
		SetEntityModel(client,g_ModelsPlayerTeam2[GetRandomInt(0, g_ModelsPlayer_Count_Team2-1)]);
	}
	else if (team==3)
	{
		SetEntityModel(client,g_ModelsPlayerTeam3[GetRandomInt(0, g_ModelsPlayer_Count_Team3-1)]);
	}
}

public Action skin_admin(Handle timer, any client)
{
	int team = GetClientTeam(client);
	if (team==2)
	{
		SetEntityModel(client,g_ModelsAdminTeam2[GetRandomInt(0, g_ModelsAdmin_Count_Team2-1)]);
	}
	else if (team==3)
	{
		SetEntityModel(client,g_ModelsAdminTeam3[GetRandomInt(0, g_ModelsAdmin_Count_Team3-1)]);
	}
}