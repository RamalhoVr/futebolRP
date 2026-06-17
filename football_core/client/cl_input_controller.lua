local footballControlsActive = false
local shootChargeStart = nil

function EnableFootballControls()
    footballControlsActive = true
end

function DisableFootballControls()
    footballControlsActive = false
end

function GetMovementInput()
    local x = GetControlNormal(0, 218) - GetControlNormal(0, 216)
    local y = GetControlNormal(0, 217) - GetControlNormal(0, 219)
    local magnitude = math.sqrt(x*x + y*y)
    
    if magnitude > 1.0 then
        x = x / magnitude
        y = y / magnitude
    end
    
    return vector2(x, y)
end

function ProcessShootInput()
    if IsControlJustPressed(0, 23) then
        shootChargeStart = GetGameTimer()
    end
    
    if IsControlJustReleased(0, 23) and shootChargeStart ~= nil then
        local power = math.min((GetGameTimer() - shootChargeStart) / 1000.0, 1.0)
        local fwd = GetEntityForwardVector(PlayerPedId())
        TriggerServerEvent('football:playerAction', {
            type = 'SHOOT', 
            power = power, 
            direction = fwd, 
            timestamp = GetGameTimer()
        })
        shootChargeStart = nil
    end
end

function ProcessPassInput()
    if IsControlJustPressed(0, 38) then
        TriggerServerEvent('football:playerAction', {type = 'SHORT_PASS'})
    elseif IsControlJustPressed(0, 44) then
        TriggerServerEvent('football:playerAction', {type = 'LONG_PASS'})
    elseif IsControlJustPressed(0, 45) then
        TriggerServerEvent('football:playerAction', {type = 'CROSS'})
    end
end

function ProcessSprintInput()
    return IsControlPressed(0, 21)
end

Citizen.CreateThread(function()
    while true do
        if not footballControlsActive then
            Citizen.Wait(500)
        else
            DisableAllControlActions(0)
            -- Reabilitar apenas câmera e mouse look
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 106, true)
            EnableControlAction(0, 107, true)
            
            ProcessShootInput()
            ProcessPassInput()
            
            local isSprinting = ProcessSprintInput()
            local dir = GetMovementInput()
            local dirMagnitude = math.sqrt(dir.x*dir.x + dir.y*dir.y)
            
            if dirMagnitude > 0.1 then
                local pos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('football:playerMovement', {
                    direction = {x = dir.x, y = dir.y}, 
                    isSprinting = isSprinting, 
                    position = {x = pos.x, y = pos.y, z = pos.z}, 
                    timestamp = GetGameTimer()
                })
            end
            
            Citizen.Wait(16)
        end
    end
end)

RegisterNetEvent('football:matchStart')
AddEventHandler('football:matchStart', function()
    EnableFootballControls()
end)

RegisterNetEvent('football:matchEnd')
AddEventHandler('football:matchEnd', function()
    DisableFootballControls()
end)
