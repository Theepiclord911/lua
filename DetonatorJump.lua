local player = entities.GetLocalPlayer()
if not player then return end

local delay = 0 -- delay in seconds between primary and secondary attacks
local lastAttackTime = 0
local shouldClickAttack2 = false
local angleOffset = 205 -- angle offset in degrees for the back direction
local pitchOffset = 30 -- pitch offset in degrees for vertical adjustment

local function ShootBehind(cmd)
    if not player:IsValid() then player = entities.GetLocalPlayer() end
    if not player then return end

    -- Check if the "R" key is pressed
    if input.IsButtonDown(KEY_R) then
        -- Get the current view angles
        local viewAngles = engine.GetViewAngles()

        -- Modify the yaw angle using the angle offset
        viewAngles.yaw = viewAngles.yaw + angleOffset

        -- Modify the pitch angle using the pitch offset
        viewAngles.pitch = viewAngles.pitch + pitchOffset

        -- Normalize the angles to ensure they are within valid range
        viewAngles:Normalize()

        -- Convert EulerAngles to Vector3
        local viewAnglesVector = Vector3(viewAngles.pitch, viewAngles.yaw, 0)

        -- Set the new view angles
        cmd.viewangles = viewAnglesVector

        -- Trigger the primary attack
        cmd.buttons = cmd.buttons | IN_ATTACK

        -- Record the time of the attack
        lastAttackTime = globals.RealTime()
        shouldClickAttack2 = true
    end

    -- Check if the delay has passed since the last attack
    if shouldClickAttack2 and globals.RealTime() - lastAttackTime >= delay then
        -- Trigger the secondary attack
        cmd.buttons = cmd.buttons | IN_ATTACK2
        shouldClickAttack2 = false
    end
end

callbacks.Register("CreateMove", ShootBehind)
