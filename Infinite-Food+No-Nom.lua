--[[
    Infinite Food automation
    Credits: Baan
    Author: LNX (github.com/lnx00)
    Dependencies: LNXlib (github.com/lnx00/Lmaobox-Library)
    bug 1: eats sandvich when lmaobox gui is open and u click
    bug 2: if u taunt with sandvich in hand youll say "Yes" voice command
]]

---@type boolean, lnxLib
local libLoaded, Lib = pcall(require, "LNXlib")
assert(libLoaded, "LNXlib not found, please install it!")
assert(Lib.GetVersion() >= 1.00, "LNXlib version is too old, please update it!")

local KeyHelper, Timer, WPlayer = Lib.Utils.KeyHelper, Lib.Utils.Timer, Lib.TF2.WPlayer

local key = KeyHelper.new(MOUSE_LEFT) -- Key
local tauntTimer = Timer.new()

local commandExecuted = false
local tauntStartTime = 0
local delay = 1.0  -- 1.0 second delay

local function isHeavyEatingFood(localPlayer)
    local weapon = localPlayer:GetActiveWeapon()
    if not weapon then return false end

    local weaponID = weapon:GetPropInt("m_iItemDefinitionIndex")
    local isTaunting = localPlayer:InCond(TFCond_Taunting)
    local foodItems = {42, 159, 1190, 311, 433, 863, 1002}

    return localPlayer:GetPropInt("m_iClass") == 6 and table.contains(foodItems, weaponID) and isTaunting
end

---@param userCmd UserCmd
local function OnUserCmd(userCmd)
    local localPlayer = WPlayer.GetLocal()
    if not localPlayer then return end

    if not localPlayer:IsAlive() or engine.IsGameUIVisible() then
        return
    end

    -- Original functionality tied to the F key
    if key:Down() then
        local weapon = localPlayer:GetActiveWeapon()
        if weapon and not weapon:IsShootingWeapon() and not weapon:IsMeleeWeapon() then
            userCmd:SetButtons(userCmd:GetButtons() | IN_ATTACK)
            if tauntTimer:Run(0.5) then
                client.Command("taunt", true)
            end
        end
    end

    -- New functionality for Heavy eating food items
    if isHeavyEatingFood(localPlayer) then
        if not commandExecuted then
            if tauntStartTime == 0 then
                tauntStartTime = globals.RealTime()
            elseif globals.RealTime() - tauntStartTime >= delay then
                client.Command("voicemenu 0 6", true)
                commandExecuted = true
            end
        end
    else
        commandExecuted = false
        tauntStartTime = 0
    end
end

callbacks.Unregister("CreateMove", "LNX_IF_UserCmd")
callbacks.Register("CreateMove", "LNX_IF_UserCmd", OnUserCmd)
