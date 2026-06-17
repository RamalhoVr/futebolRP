local matchTimers = {}

function CreateMatch(requestingPlayerId, fieldCenter)
    local matchId = os.time() + math.random(1000)
    local baseBucket = Config and Config.MatchRoutingBucketBase or 1000
    local routingBucket = baseBucket + (matchId % 1000)
    
    local match = {
        id = matchId,
        status = 'waiting',
        routingBucket = routingBucket,
        players = {},
        fieldCenter = fieldCenter,
        ballSpawn = fieldCenter,
        homeScore = 0,
        awayScore = 0,
        startTime = nil,
        timerInterval = nil,
        timeElapsed = 0
    }
    
    ActiveMatches[matchId] = match
    return matchId
end

function JoinMatch(matchId, playerId)
    local match = ActiveMatches[matchId]
    if match then
        table.insert(match.players, playerId)
        SetPlayerRoutingBucket(playerId, match.routingBucket)
        TriggerClientEvent('football:playerJoinedMatch', playerId, matchId)
    end
end

function StartMatch(matchId)
    local match = ActiveMatches[matchId]
    if match then
        match.status = 'active'
        match.startTime = os.time()
        match.timeElapsed = 0
        
        InitBall(matchId, match.ballSpawn)
        StartPhysicsLoop(matchId)
        
        if StartRefereeLoop then
            StartRefereeLoop(matchId)
        end

        for _, pid in ipairs(match.players) do
            TriggerClientEvent('football:matchStart', pid, matchId, match.fieldCenter)
        end
        
        local matchDuration = Config and Config.MatchDuration or 600
        
        match.timerInterval = SetInterval(function()
            local currentMatch = ActiveMatches[matchId]
            if not currentMatch or currentMatch.status ~= 'active' then
                ClearInterval(currentMatch and currentMatch.timerInterval)
                return
            end
            
            currentMatch.timeElapsed = currentMatch.timeElapsed + 1
            
            local mins = math.floor(currentMatch.timeElapsed / 60)
            local secs = currentMatch.timeElapsed % 60
            local timeStr = string.format("%02d:%02d", mins, secs)
            
            for _, pid in ipairs(currentMatch.players) do
                TriggerClientEvent('football:timeUpdate', pid, timeStr)
            end
            
            if currentMatch.timeElapsed >= matchDuration then
                EndMatch(matchId)
            end
        end, 1000)
    end
end

function EndMatch(matchId)
    local match = ActiveMatches[matchId]
    if match then
        if match.timerInterval then
            ClearInterval(match.timerInterval)
            match.timerInterval = nil
        end
        
        StopPhysicsLoop(matchId)
        if StopRefereeLoop then
            StopRefereeLoop(matchId)
        end
        
        match.status = 'finished'
        
        for _, pid in ipairs(match.players) do
            TriggerClientEvent('football:matchEnd', pid)
            SetPlayerRoutingBucket(pid, 0)
        end
    end
end

function ProcessPlayerAction(playerId, action)
    local playerMatchId = nil
    for mId, match in pairs(ActiveMatches) do
        for _, pid in ipairs(match.players) do
            if pid == playerId then
                playerMatchId = mId
                break
            end
        end
    end
    
    if not playerMatchId then return end
    
    local ball = ActiveBalls[playerMatchId]
    if not ball then return end
    
    if action.type == 'SHOOT' and ball.owner == playerId then
        local power = action.power or 1.0
        ApplyForce(playerMatchId, action.direction, 80.0 * power, 0.0)
        
    elseif action.type == 'SHORT_PASS' and ball.owner == playerId then
        local dir = action.direction or vector3(1.0, 0.0, 0.0)
        ApplyForce(playerMatchId, dir, 40.0, 0.0)
        
    elseif action.type == 'LONG_PASS' and ball.owner == playerId then
        local dir = action.direction or vector3(1.0, 0.0, 0.0)
        local liftDir = vector3(dir.x, dir.y, dir.z + 0.3)
        ApplyForce(playerMatchId, liftDir, 65.0, 0.0)
        
    elseif action.type == 'CROSS' and ball.owner == playerId then
        local dir = action.direction or vector3(1.0, 0.0, 0.0)
        local liftDir = vector3(dir.x, dir.y, dir.z + 0.4)
        ApplyForce(playerMatchId, liftDir, 55.0, 0.5)
    end
end

RegisterNetEvent('football:playerAction')
AddEventHandler('football:playerAction', function(action)
    local _source = source
    ProcessPlayerAction(_source, action)
end)

RegisterNetEvent('football:playerMovement')
AddEventHandler('football:playerMovement', function(data)
    local _source = source
    PlayerStates[_source] = data
end)

RegisterCommand('criarpartida', function(source, args, rawCommand)
    local center = Config and Config.StadiumCoords or vector3(0.0, 0.0, 0.0)
    if source > 0 then
        center = GetEntityCoords(GetPlayerPed(source))
    end
    
    local matchId = CreateMatch(source, center)
    
    for _, playerId in ipairs(GetPlayers()) do
        JoinMatch(matchId, tonumber(playerId))
    end
    print('[Football RP] Partida criada: ' .. matchId)
end, true)

RegisterCommand('iniciarpartida', function(source, args, rawCommand)
    for matchId, match in pairs(ActiveMatches) do
        if match.status == 'waiting' then
            StartMatch(matchId)
            print('[Football RP] Partida iniciada: ' .. matchId)
            return
        end
    end
end, true)

RegisterCommand('finalizarpartida', function(source, args, rawCommand)
    for matchId, match in pairs(ActiveMatches) do
        if match.status == 'active' then
            EndMatch(matchId)
            print('[Football RP] Partida finalizada: ' .. matchId)
            return
        end
    end
end, true)