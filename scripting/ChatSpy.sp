#include <sourcemod>
#include <cstrike>
#include <multicolors>
#include <clientprefs>

#define TAG "[{Lime}CHATSPY{default}]"
Handle g_clientcookie;

public Plugin myinfo =
{
  name = "[CS:GO] ChatSpy",
  author = "ESK0",
  version = "1337",
  url = "www.steamcommunity.com/id/esk0"
}

public void OnPluginStart()
{
  RegAdminCmd("sm_chatspy", Command_ChatSpy, ADMFLAG_GENERIC);
  g_clientcookie = RegClientCookie("chatspy_cookie", "", CookieAccess_Private);
}
public Action Command_ChatSpy(int client, int args)
{
  char value[12];
  GetClientCookie(client, g_clientcookie, value, sizeof(value));
  if(StrEqual(value, ""))
  {
  	SetClientCookie(client, g_clientcookie, "1");
  	CPrintToChat(client,"%s ChatSpy {lightred}disabled", TAG);
  }
  else
  {
  	SetClientCookie(client, g_clientcookie, "");
  	CPrintToChat(client,"%s ChatSpy {lime}enabled", TAG);
  }
  return Plugin_Handled;
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
  if(IsValidClient(client))
  {
    if(StrEqual(command, "say_team"))
    {
      if(sArgs[0] != 0 && sArgs[0] != '@' && sArgs[0] != '/' && sArgs[0] != '!')
      {
        int iSender = GetClientTeam(client);
        int iReciever;
        for(int i = 1; i <= MaxClients; i++)
        {
          if(IsValidClient(i))
          {
            if(CheckCommandAccess(i, "", ADMFLAG_GENERIC, true))
            {
              iReciever = GetClientTeam(i);
              if(iSender != iReciever)
              {
                char szValue[12];
                GetClientCookie(i, g_clientcookie, szValue, sizeof(szValue));
                if(!StrEqual(szValue, "1"))
                {
                  CPrintToChat(i, "%s%s%s %N : %s",
                      (iSender == CS_TEAM_CT) ? "{blue}" : (iSender == CS_TEAM_T) ? "{orange}" : "{gray}",
                      IsPlayerAlive(client) ? "" : (iSender == CS_TEAM_T) ? "*DEAD*" : (iSender == CS_TEAM_CT) ? "*DEAD*" : "",
                      (iSender == CS_TEAM_CT) ? "(Counter-Terrorist)" : (iSender == CS_TEAM_T) ? "(Terrorist)" : "", iSender, sArgs);
                }
              }
            }
          }
        }
      }
    }
  }
  return Plugin_Continue;
}
stock bool IsValidClient(int client, bool alive = false)
{
  if(0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}
