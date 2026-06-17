local ESX = nil

Citizen.CreateThread(function()
    print('[Football RP] Core iniciado')
    
    if exports['es_extended'] then
        ESX = exports['es_extended']:getSharedObject()
    else
        print('^1[ERRO] ESX não encontrado. Verifique se o es_extended está iniciado.^0')
    end
end)

ActiveMatches = {}
ActiveBalls = {}
PlayerStates = {}

RegisterNetEvent('football:getConfig')
AddEventHandler('football:getConfig', function()
    local _source = source
    if Config then
        TriggerClientEvent('football:receiveConfig', _source, Config)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('[Football RP] Core parando, limpando partidas ativas...')
    ActiveMatches = {}
end)
