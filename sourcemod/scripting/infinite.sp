#include <sourcemod>
#include <sdktools>
#include <shavit>

public Plugin myinfo = {
    name = "Infinite Style",
    author = "luna",
    version = "1.5"
};

int g_iLastButtons[MAXPLAYERS + 1];
int g_iJumpCooldown[MAXPLAYERS + 1];
bool g_bTimerStarted[MAXPLAYERS + 1];

public void OnPluginStart() {
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnAllPluginsLoaded() {
    if (!LibraryExists("shavit"))
        SetFailState("shavit-core is required!");
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0)
        g_bTimerStarted[client] = false;
    return Plugin_Continue;
}

public Action Shavit_OnStart(int client, int track) {
    if (Shavit_GetBhopStyle(client) == 12)
        g_bTimerStarted[client] = true;
    return Plugin_Continue;
}

public void Shavit_OnStop(int client, int track) {
    g_bTimerStarted[client] = false;
}

public void Shavit_OnRestart(int client, int track) {
    g_bTimerStarted[client] = false;
}

public void Shavit_OnFinish(int client, int track, float time, int jumps, int strafes, float sync, int style, float oldtime) {
    g_bTimerStarted[client] = false;
}

public void Shavit_OnEnterZone(int client, int type, int track, int id, int entity) {
    if (type != 0)
        return;

    if (Shavit_GetBhopStyle(client) != 12)
        return;

    if (GetEntityMoveType(client) == MOVETYPE_NOCLIP)
        return;

    float vVel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
    float fSpeed = SquareRoot((vVel[0] * vVel[0]) + (vVel[1] * vVel[1]));

    if (g_bTimerStarted[client] && fSpeed > 1705.0) {
        PrintToChat(client, " \x02[Infinite]\x01 Speed reset - don't re-enter the start zone!");
        vVel[0] = 0.0;
        vVel[1] = 0.0;
        vVel[2] = 0.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
    }
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3]) {
    if (!IsPlayerAlive(client))
        return Plugin_Continue;

    if (Shavit_GetBhopStyle(client) != 12)
        return Plugin_Continue;

    int flags = GetEntityFlags(client);
    bool bJustPressedJump = (buttons & IN_JUMP) && !(g_iLastButtons[client] & IN_JUMP);

    if (bJustPressedJump && !(flags & FL_ONGROUND) && g_iJumpCooldown[client] == 0) {
        float vVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
        vVel[2] = 290.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
        g_iJumpCooldown[client] = 3;
    }

    g_iLastButtons[client] = buttons;

    if (g_iJumpCooldown[client] > 0)
        g_iJumpCooldown[client]--;

    return Plugin_Continue;
}

public void OnClientDisconnect(int client) {
    g_iLastButtons[client] = 0;
    g_iJumpCooldown[client] = 0;
    g_bTimerStarted[client] = false;
}
// Plugin by luna! (https://github.com/2x74)
