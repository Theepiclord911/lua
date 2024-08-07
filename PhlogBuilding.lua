local player = entities.GetLocalPlayer()
if not player then return end

local onEnemyBuilding = false
local commandSent = false
local rage, wep
local detectedEntity = nil

function main()
    if not player:IsValid() then player = entities.GetLocalPlayer() end

    local playerPos = player:GetAbsOrigin()
    local traceStartPos = playerPos + Vector3(0, 0, 32) -- Start trace slightly above the player
    local traceEndPos = playerPos - Vector3(0, 0, 64) -- Extend trace further down

    -- Adjusted trace hull dimensions to better detect teleporters
    local trace = engine.TraceHull(traceStartPos, traceEndPos, Vector3(-32, -32, -32), Vector3(32, 32, 32), MASK_ALL, function(ent)
        return ent:IsPlayer() or (ent:GetClass() == "CObjectTeleporter" or ent:GetClass() == "CObjectDispenser")
    end)

    if trace.entity and (trace.entity:GetClass() == "CObjectTeleporter" or trace.entity:GetClass() == "CObjectDispenser") and trace.entity:GetTeamNumber() ~= player:GetTeamNumber() then
        local health = trace.entity:GetPropInt("m_iHealth")
        local maxHealth = trace.entity:GetPropInt("m_iMaxHealth")
        local healthDiminishingRate = (maxHealth - health) / maxHealth

        print("Detected entity: " .. trace.entity:GetClass() .. " with health: " .. health .. "/" .. maxHealth)

        if healthDiminishingRate > 0.9 then -- Adjust this threshold as needed
            if not onEnemyBuilding then
                wep = player:GetPropEntity("m_hActiveWeapon")
                if wep ~= nil then
                    local itemDefinitionIndex = wep:GetPropInt("m_iItemDefinitionIndex")
                    if itemDefinitionIndex ~= 594 then
                        return
                    end
                end
                rage = tostring(player:GetPropFloat("m_flRageMeter"))
                onEnemyBuilding = true
                commandSent = false
                detectedEntity = trace.entity -- Store the detected entity
            end
        else
            onEnemyBuilding = false
            commandSent = false
            detectedEntity = nil
        end
    else
        onEnemyBuilding = false
        commandSent = false
        detectedEntity = nil
    end
end

callbacks.Register("CreateMove", function(cmd)
    main()
    if onEnemyBuilding and rage == "100.0" and detectedEntity then
        local health = detectedEntity:GetPropInt("m_iHealth")
        if cmd.buttons & IN_ATTACK ~= 0 and health <= 10 then -- Check if the player is attacking and the building's health is low
            cmd:SetButtons(cmd.buttons | IN_ATTACK2)
        end
    end
end)