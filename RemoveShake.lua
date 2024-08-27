client.RemoveConVarProtection("sv_cheats") -- bypass security (bypass sv_cheats check)
client.SetConVar("sv_cheats", 1, true)

local function StopScreenShake(cmd)
    client.Command("shake_stop", true)
end

callbacks.Unregister("CreateMove", "StopScreenShake")
callbacks.Register("CreateMove", "StopScreenShake", StopScreenShake)
