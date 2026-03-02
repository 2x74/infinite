#include <sourcemod>
#include <sdktools>
#include <shavit>

public Plugin myinfo = {
    name = "Infinite Style",
    author = "luna",
    version = "1.1"
};

int g_iLastButtons[MAXPLAYERS + 1];
int g_iJumpCooldown[MAXPLAYERS + 1];
bool g_bUsedStartZone[MAXPLAYERS + 1];

public void OnPluginStart() {
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public void OnAllPluginsLoaded() {
    if (!LibraryExists("shavit"))
        SetFailState("shavit-core is required!");
}

// Reset when player spawns
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0)
        g_bUsedStartZone[client] = false;
    return Plugin_Continue;
}

// Called by shavit when player enters start zone
public void Shavit_OnEnterZone(int client, int type, int track, int id, int entity) {
    // type 0 = start zone
    if (type != 0)
        return;

    if (Shavit_GetBhopStyle(client) != 12)
        return;

    if (g_bUsedStartZone[client]) {
        // Teleport them back out / stop them from restarting
        // Easiest approach: just block their timer restart by teleporting them away
        // Or simply flag it — shavit will handle the restart, so we kick them back
        PrintToChat(client, " \x02[Infinite]\x01 You can only use the start zone once per run!");

        // Get their current position and push them back out of zone
        float vPos[3], vAng[3];
        GetClientAbsOrigin(client, vPos);
        GetClientAbsAngles(client, vAng);

        // Push forward so they exit the zone
        float vVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
        vVel[0] *= -1.0;
        vVel[1] *= -1.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
        return;
    }

    g_bUsedStartZone[client] = true;
}

// Reset flag when timer restarts (player chose to restart from start zone)
public void Shavit_OnRestart(int client, int track) {
    g_bUsedStartZone[client] = false;
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
    g_bUsedStartZone[client] = false;
}
// Plugin by luna! (https://github.com/2x74)
