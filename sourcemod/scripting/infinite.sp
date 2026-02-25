#include <sourcemod>
#include <sdktools>
public Plugin myinfo = {
    name = "Infinite Style",
    author = "luna",
    version = "1.0"
};
int g_iLastButtons[MAXPLAYERS + 1];
int g_iJumpCooldown[MAXPLAYERS + 1];
// Forward declaration for style check
native int Shavit_GetBhopStyle(int client);
public void OnPluginStart() {
    // Optional: mark as optional so plugin loads even if shavit isn't ready yet
}
public void OnAllPluginsLoaded() {
    // Verify shavit is loaded
    if (!LibraryExists("shavit"))
        SetFailState("shavit-core is required!");
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3]) {
    if (!IsPlayerAlive(client))
        return Plugin_Continue;

    // Only work if player is using style 11 (CHANGE THIS ACCORDING TO YOUR STYLE LIST)
    if (Shavit_GetBhopStyle(client) != 11)
        return Plugin_Continue;

    int flags = GetEntityFlags(client);

    // Check if jump button was just pressed
    bool bJustPressedJump = (buttons & IN_JUMP) && !(g_iLastButtons[client] & IN_JUMP);

    // If they just pressed jump (not holding) and in air and cooldown expired
    if (bJustPressedJump && !(flags & FL_ONGROUND) && g_iJumpCooldown[client] == 0) {
        // Give upward velocity for mid-air jump
        float vVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
        vVel[2] = 290.0; // Jump strength
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);

        // Short cooldown to prevent spam
        g_iJumpCooldown[client] = 3;
    }

    // Store buttons for next frame
    g_iLastButtons[client] = buttons;

    // Tick down cooldown
    if (g_iJumpCooldown[client] > 0)
        g_iJumpCooldown[client]--;

    return Plugin_Continue;
}
public void OnClientDisconnect(int client) {
    g_iLastButtons[client] = 0;
    g_iJumpCooldown[client] = 0;
}

// Plugin by luna! (https://github.com/2x74)
