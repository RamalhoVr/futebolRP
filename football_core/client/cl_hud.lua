Citizen.CreateThread(function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent('football:matchStart')
AddEventHandler('football:matchStart', function()
    SendNUIMessage({
        type = 'showHUD',
        show = true
    })
end)

RegisterNetEvent('football:matchEnd')
AddEventHandler('football:matchEnd', function()
    SendNUIMessage({
        type = 'showHUD',
        show = false
    })
end)

RegisterNetEvent('football:goalScored')
AddEventHandler('football:goalScored', function()
    SendNUIMessage({
        type = 'showGoal'
    })
end)

RegisterNetEvent('football:throwIn')
AddEventHandler('football:throwIn', function()
    SendNUIMessage({
        type = 'showAction',
        actionText = 'LATERAL!'
    })
end)

RegisterNetEvent('football:cornerKick')
AddEventHandler('football:cornerKick', function()
    SendNUIMessage({
        type = 'showAction',
        actionText = 'ESCANTEIO!'
    })
end)

RegisterNetEvent('football:goalKick')
AddEventHandler('football:goalKick', function()
    SendNUIMessage({
        type = 'showAction',
        actionText = 'TIRO DE META!'
    })
end)

RegisterNetEvent('football:staminaUpdate')
AddEventHandler('football:staminaUpdate', function(currentStamina)
    SendNUIMessage({
        type = 'updateStamina',
        stamina = currentStamina
    })
end)

RegisterNetEvent('football:timeUpdate')
AddEventHandler('football:timeUpdate', function(formattedTime)
    SendNUIMessage({
        type = 'updateTime',
        time = formattedTime
    })
end)

RegisterNetEvent('football:scoreUpdate')
AddEventHandler('football:scoreUpdate', function(homeScore, awayScore)
    SendNUIMessage({
        type = 'updateScore',
        home = homeScore,
        away = awayScore
    })
end)

RegisterNetEvent('football:possessionUpdate')
AddEventHandler('football:possessionUpdate', function(hasBall)
    SendNUIMessage({
        type = 'updatePossession',
        hasPossession = hasBall
    })
end)