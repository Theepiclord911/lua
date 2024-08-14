local libLoaded, lnxLib = pcall(require, "lnxLib")
assert(libLoaded, "lnxLib not found, please install it!")
assert(lnxLib.GetVersion() >= 1.00, "lnxLib version is too old, please update it!")

local Math, Conversion = lnxLib.Utils.Math, lnxLib.Utils.Conversion
local WPlayer, WWeapon, WEntity = lnxLib.TF2.WPlayer, lnxLib.TF2.WWeapon, lnxLib.TF2.WEntity
local Helpers = lnxLib.TF2.Helpers
local Prediction = lnxLib.TF2.Prediction
local Fonts = lnxLib.UI.Fonts
local Input = lnxLib.Utils.Input
local Notify = lnxLib.UI.Notify
local Timer = lnxLib.Utils.Timer

local font = draw.CreateFont("Tahoma", 16, 800)
draw.SetFont(font)
draw.Color(255, 255, 255, 255)

-- Function to get the ammo of all weapons of the player being healed
local function GetPlayerAmmo(player)
    local ammoInfo = {}
    for i = 0, 2 do -- Assuming 0 is primary, 1 is secondary, 2 is melee
        local weapon = player:GetEntityForLoadoutSlot(i)
        if weapon then
            local wpnId = weapon:GetPropInt("m_iItemDefinitionIndex")
            if wpnId then
                local wpnName = itemschema.GetItemDefinitionByID(wpnId):GetName()
                local ammo = weapon:GetPropInt("m_iClip1") -- Assuming m_iClip1 gets the ammo in the clip
                table.insert(ammoInfo, { wpnName, ammo })
            end
        end
    end
    return ammoInfo
end

-- Function to draw the ammo information on the screen
local function DrawAmmoInfo(ammoInfo)
    local x, y = 10, 50
    for _, info in ipairs(ammoInfo) do
        local weaponName, ammo = table.unpack(info)
        draw.Text(x, y, weaponName .. ": " .. ammo)
        y = y + 15
    end
end

-- Main function to handle drawing
callbacks.Register("Draw", function()
    local localPlayer = WPlayer.GetLocal()
    if not localPlayer then 
        return 
    end

    local medigun = localPlayer:GetActiveWeapon()
    if medigun and medigun:IsMedigun() then
        local healingTarget = medigun:GetPropEntity("m_hHealingTarget")
        if healingTarget then
            local ammoInfo = GetPlayerAmmo(healingTarget)
            DrawAmmoInfo(ammoInfo)
        end
    end
end)