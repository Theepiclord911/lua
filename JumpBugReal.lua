---@type boolean, lnxLib
local libLoaded, lnxLib = pcall(require, "lnxLib")
assert(libLoaded, "lnxLib not found, please install it!")
assert(lnxLib.GetVersion() >= 1.00, "lnxLib version is too old, please update it!")

local WPlayer = lnxLib.TF2.WPlayer
local Input = lnxLib.Utils.Input

-- Constants
local JUMPBUG_DISTANCE = 5 -- Distance from the ground to trigger the jumpbug
local KEY_BIND = KEY_R -- Key to queue the jumpbug
local JUMP_DELAY_TICKS = 1 -- Delay in ticks before jumping after uncrouching

-- Variables
local isJumpBugQueued = false
local crouchPressed = false
local jumpPressed = false
local tickCounter = 0

-- Function to get the player's distance from the ground
local function GetDistanceToGround()
    local player = WPlayer.GetLocal()
    if not player then return end

    local playerPos = player:GetAbsOrigin()
    local traceStartPos = playerPos + Vector3(0, 0, 10) -- Start trace slightly above the player
    local traceEndPos = playerPos - Vector3(0, 0, 100) -- Extend trace further down

    -- Adjusted trace hull dimensions to better detect the ground
    local trace = engine.TraceHull(traceStartPos, traceEndPos, Vector3(-16, -16, -16), Vector3(16, 16, 16), MASK_PLAYERSOLID, player.ShouldHitEntity)

    if trace.fraction < 1 then
        local distance = (traceStartPos.z - trace.endpos.z)
        return distance
    else
        return nil
    end
end

-- Function to handle CreateMove event
local function onCreateMove(cmd)
    local player = WPlayer.GetLocal()
    if not player then return end

    -- Check if the player is in the air
    if not player:IsOnGround() then
        -- Display text in green if the player has queued a jumpbug
        if isJumpBugQueued then
            draw.Color(0, 255, 0, 255)
            draw.Text(10, 10, "Jumpbug Queued")
        else
            draw.Color(255, 0, 0, 255)
            draw.Text(10, 10, "Jumpbug Not Queued")
        end
    end

    -- Check if the jumpbug is queued and the player is at the right distance from the ground
    if isJumpBugQueued then
        local distance = GetDistanceToGround()
        print("Distance to ground:", distance)
        if distance and distance <= JUMPBUG_DISTANCE then
            if crouchPressed then
                cmd.buttons = cmd.buttons & ~IN_DUCK -- Release crouch
                crouchPressed = false
                tickCounter = JUMP_DELAY_TICKS -- Set the tick counter for the delay
                print("Crouch released. cmd.buttons:", cmd.buttons)
            end
        end

        -- Check if the tick counter has reached zero to perform the jump
        if tickCounter > 0 then
            tickCounter = tickCounter - 1
            if tickCounter == 0 and not jumpPressed then
                cmd.buttons = cmd.buttons | IN_JUMP -- Press jump
                jumpPressed = true
                isJumpBugQueued = false -- Deactivate jumpbug after execution
                print("Jump pressed. cmd.buttons:", cmd.buttons)
            end
        end
    end
end

-- Function to handle key press
local function onKeyPress(key)
    if key == KEY_BIND then
        isJumpBugQueued = true
        crouchPressed = true
        jumpPressed = false
        tickCounter = 0 -- Reset the tick counter
        print("Jumpbug queued!")
    end
end

-- Register the key press callback
callbacks.Register("CreateMove", onCreateMove)

-- Register the Draw callback
callbacks.Register("Draw", function()
    if input.IsButtonDown(KEY_BIND) then
        onKeyPress(KEY_BIND)
    end

    -- Display text in the upper corner
    if isJumpBugQueued then
        draw.Color(0, 255, 0, 255)
        draw.Text(10, 10, "Jumpbug Queued")
    else
        draw.Color(255, 0, 0, 255)
        draw.Text(10, 10, "Jumpbug Not Queued")
    end
end)