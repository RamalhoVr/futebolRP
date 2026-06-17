local currentSpeed = 0.0
local isPlayerMoving = false
local playerStamina = Config and Config.StaminaMax or 100.0

function UpdateStamina(deltaTime, isSprinting)
    local sprintCost = Config and Config.StaminaSprintCost or 15.0
    local recoveryRate = Config and Config.StaminaRecoveryRate or 10.0
    local maxStamina = Config and Config.StaminaMax or 100.0

    if isSprinting and isPlayerMoving then
        playerStamina = math.max(0.0, playerStamina - (sprintCost * deltaTime))
    else
        playerStamina = math.min(maxStamina, playerStamina + (recoveryRate * deltaTime))
    end
    
    TriggerEvent('football:staminaUpdate', playerStamina)
end

function CalculateTargetSpeed(movementInput, isSprinting)
    local magnitude = #(movementInput)
    if magnitude < 0.1 then
        return 0.0
    end
    
    local maxSpeed = Config and Config.PlayerMaxSpeed or 5.0
    
    if isSprinting and playerStamina > 5.0 then
        local sprintMult = Config and Config.SprintSpeedMultiplier or 1.5
        return maxSpeed * sprintMult
    end
    
    return maxSpeed
end

function ApplyMovement(movementInput, isSprinting, deltaTime)
    local targetSpeed = CalculateTargetSpeed(movementInput, isSprinting)
    isPlayerMoving = targetSpeed > 0.1
    
    -- Lerp da velocidade
    local accel = 4.0
    local decel = 6.0
    
    if targetSpeed > currentSpeed then
        currentSpeed = currentSpeed + (accel * deltaTime)
        if currentSpeed > targetSpeed then currentSpeed = targetSpeed end
    elseif targetSpeed < currentSpeed then
        currentSpeed = currentSpeed - (decel * deltaTime)
        if currentSpeed < targetSpeed then currentSpeed = targetSpeed end
    end
    
    -- Converter input 2D em direção 3D baseada na câmera
    local camRot = GetFinalRenderedCamRot(2)
    local zRot = math.rad(camRot.z)
    
    local forward = vector3(-math.sin(zRot), math.cos(zRot), 0.0)
    local right = vector3(math.cos(zRot), math.sin(zRot), 0.0)
    
    local moveDir = (right * movementInput.x) + (forward * movementInput.y)
    
    -- Normalizar a direção
    local dirLen = math.sqrt(moveDir.x^2 + moveDir.y^2)
    if dirLen > 0.001 then
        moveDir = vector3(moveDir.x / dirLen, moveDir.y / dirLen, 0.0)
    else
        moveDir = vector3(0.0, 0.0, 0.0)
    end
    
    local ped = PlayerPedId()
    local velZ = GetEntityVelocity(ped).z
    SetEntityVelocity(ped, moveDir.x * currentSpeed, moveDir.y * currentSpeed, velZ)
    
    UpdateStamina(deltaTime, isSprinting)
end

function GetCurrentStamina()
    return playerStamina
end

RegisterNetEvent('football:applyMovement')
AddEventHandler('football:applyMovement', function(movementInput, isSprinting, deltaTime)
    ApplyMovement(vector2(movementInput.x, movementInput.y), isSprinting, deltaTime)
end)

RegisterNetEvent('football:matchStart')
AddEventHandler('football:matchStart', function()
    FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent('football:matchEnd')
AddEventHandler('football:matchEnd', function()
    FreezeEntityPosition(PlayerPedId(), true)
    currentSpeed = 0.0
end)
