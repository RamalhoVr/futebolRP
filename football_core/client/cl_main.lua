local isInMatch = false
local currentMatchId = nil

Citizen.CreateThread(function()
    print('[Football RP] Cliente carregado')
end)

RegisterNetEvent('football:matchStart')
AddEventHandler('football:matchStart', function(matchId)
    isInMatch = true
    currentMatchId = matchId
end)

RegisterNetEvent('football:matchEnd')
AddEventHandler('football:matchEnd', function()
    isInMatch = false
    currentMatchId = nil
end)

function IsInMatch()
    return isInMatch
end

function GetCurrentMatchId()
    return currentMatchId
end
