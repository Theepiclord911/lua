---@type boolean, lnxLib
local libLoaded, lnxLib = pcall(require, "lnxLib")
assert(libLoaded, "lnxLib not found, please install it!")
assert(lnxLib.GetVersion() >= 1.00, "lnxLib version is too old, please update it!")

local WPlayer, WWeapon = lnxLib.TF2.WPlayer, lnxLib.TF2.WWeapon

local scriptActive = false
local toggleKey = KEY_F
local toggleKeyLastPressed = 0
local toggleKeyDelay = 10
local lastWeaponID = nil
local chargeValue = 0.001

local stickyLauncherIDs = {
    [20] = true, [207] = true, [130] = true, [265] = true, [661] = true,
    [797] = true, [806] = true, [886] = true, [895] = true, [904] = true,
    [913] = true, [962] = true, [971] = true, [1150] = true, [15009] = true,
    [15012] = true, [15024] = true, [15038] = true, [15045] = true, [15048] = true,
    [15082] = true, [15083] = true, [15084] = true, [15113] = true, [15137] = true,
    [15138] = true, [15155] = true,
}

local function isStickyLauncher(weapon)
    return stickyLauncherIDs[weapon:GetPropInt("m_iItemDefinitionIndex")] or false
end

local function toggleCharge()
    if input.IsButtonPressed(toggleKey) and globals.FrameCount() > toggleKeyLastPressed + toggleKeyDelay then
        chargeValue = chargeValue == 0.001 and 73.33 or 0.001
        engine.PlaySound("weapons/det_pack_timer.wav")
        toggleKeyLastPressed = globals.FrameCount()
    end
end

local function getChargePercentage(weapon)
    local chargeBeginTime = weapon:GetChargeBeginTime()
    local currentCharge = weapon:GetCurrentCharge()
    if chargeBeginTime > 0 and currentCharge > 0 then
        return math.min((currentCharge / 1) * 100, 100)  -- Example max charge time is 1
    end
    return 0
end

local function handleWeaponSwitch()
    local me = WPlayer.GetLocal()
    if not me or not me:IsAlive() then return end
    local weapon = me:GetActiveWeapon()
    if not weapon then return end

    local isSticky = isStickyLauncher(weapon)
    local weaponID = weapon:GetPropInt("m_iItemDefinitionIndex")

    if isSticky and weaponID ~= lastWeaponID then
        scriptActive = true
        chargeValue = weaponID == 1150 and 100 or 0.001
        lastWeaponID = weaponID
    elseif not isSticky and weaponID ~= lastWeaponID then
        scriptActive = false
        lastWeaponID = weaponID
    end
end

local function onCreateMove(cmd)
    local localPlayer = WPlayer.GetLocal()
    if localPlayer then
        local activeWeapon = localPlayer:GetActiveWeapon()
        if activeWeapon and isStickyLauncher(activeWeapon) then
            if getChargePercentage(activeWeapon) >= chargeValue then
                cmd.buttons = cmd.buttons & ~IN_ATTACK  -- Simulate mouse button release
            end
        end
    end
end

local function onDraw()
    if scriptActive then
        if chargeValue == 73.33 then
            draw.Color(255, 0, 0, 255)  -- Red color
        else
            draw.Color(0, 255, 0, 255)  -- Green color
        end
    else
        draw.Color(255, 0, 0, 255)  -- Red color when inactive
    end
    draw.Text(10, 10, "Sticky Toggle: " .. (scriptActive and "Active" or "Inactive"))
    draw.Text(10, 30, "Charge Value: " .. chargeValue .. "%")
end

callbacks.Register("Draw", onDraw)
callbacks.Register("CreateMove", toggleCharge)
callbacks.Register("CreateMove", handleWeaponSwitch)
callbacks.Register("CreateMove", onCreateMove)