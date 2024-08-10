client.RemoveConVarProtection("sv_cheats") --bypass security(bypass sv_cheats check)
client.SetConVar("sv_cheats", 1, true)
local dist = 300 -- how close the projectile needs to be for shake_stop to be triggered (hammer units)
local shake_duration = 0.1 -- duration to continue spamming shake_stop after projectile is gone (seconds)

local demoman_projectile_class_names = {
    "CTFGrenadePipebombProjectile"
}

local projectile_timestamps = {}

local function CalculateDistance(vec1, vec2)
    local dx, dy, dz = vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function IsProjectileClose(lPlayer, projectile, min_distance)
    return CalculateDistance(lPlayer:GetAbsOrigin(), projectile:GetAbsOrigin()) < min_distance
end

local function SpamShakeStop(cmd)
    local lPlayer = entities.GetLocalPlayer()
    if not lPlayer then return end

    local current_time = globals.CurTime()

    for _, class_name in ipairs(demoman_projectile_class_names) do
        for _, p in pairs(entities.FindByClass(class_name)) do 
            if not p:IsDormant() and IsProjectileClose(lPlayer, p, dist) then
                projectile_timestamps[p:GetIndex()] = current_time
            end
        end
    end

    for index, timestamp in pairs(projectile_timestamps) do
        if current_time - timestamp < shake_duration then
            client.Command("shake_stop", true)
        else
            projectile_timestamps[index] = nil
        end
    end
end

callbacks.Unregister("CreateMove", "SpamShakeStop")
callbacks.Register("CreateMove", "SpamShakeStop", SpamShakeStop)
