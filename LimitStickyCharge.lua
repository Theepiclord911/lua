---@type boolean, lnxLib
local libLoaded, lnxLib = pcall(require, "lnxLib")
assert(libLoaded, "lnxLib not found, please install it!")
assert(lnxLib.GetVersion() >= 1.00, "lnxLib version is too old, please update it!")

local WPlayer, WWeapon = lnxLib.TF2.WPlayer, lnxLib.TF2.WWeapon

-- Weapon definitions for sticky launchers
local stickyLauncherIDs = {
    [20] = true, [207] = true, [130] = true, [265] = true, [661] = true,
    [797] = true, [806] = true, [886] = true, [895] = true, [904] = true,
    [913] = true, [962] = true, [971] = true, [1150] = true, [15009] = true,
    [15012] = true, [15024] = true, [15038] = true, [15045] = true, [15048] = true,
    [15082] = true, [15083] = true, [15084] = true, [15113] = true, [15137] = true,
    [15138] = true, [15155] = true,
}

-- Function to check if the active weapon is a sticky launcher
local function isStickyLauncher(weapon)
    return stickyLauncherIDs[weapon:GetPropInt("m_iItemDefinitionIndex")] or false
end

-- Function to get the charge percentage
local function getChargePercentage(weapon)
    local chargeBeginTime = weapon:GetChargeBeginTime()
    local currentCharge = weapon:GetCurrentCharge()
    if chargeBeginTime > 0 and currentCharge > 0 then
        return math.min((currentCharge / 1) * 100, 100)  -- Example max charge time is 1
    end
    return 0
end

-- Function to handle CreateMove event
local function onCreateMove(cmd)
    local localPlayer = WPlayer.GetLocal()
    if localPlayer then
        local activeWeapon = localPlayer:GetActiveWeapon()
        if activeWeapon and isStickyLauncher(activeWeapon) then
            if getChargePercentage(activeWeapon) >= 73.3 then -- Change how much it will charge
                cmd.buttons = cmd.buttons & ~IN_ATTACK  -- Simulate mouse button release
            end
        end
    end
end

callbacks.Register("CreateMove", onCreateMove)