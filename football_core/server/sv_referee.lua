local refereeIntervals = {}
local pauseMatchPhysics = {}

function CheckBallEvents(matchId)
    if pauseMatchPhysics[matchId] then return end
    
    local match = ActiveMatches[matchId]
    local ball = ActiveBalls[matchId]
    
    if not match or not ball then return end
    
    local center = Config and Config.StadiumCoords or vector3(0.0, 0.0, 0.0)
    local pos = ball.position
    
    -- Gol Home: X < centro.x - 29, Y entre centro.y-7 e centro.y+7, Z < 3.0
    if pos.x < center.x - 29 and pos.y > center.y - 7 and pos.y < center.y + 7 and pos.z < center.z + 3.0 then
        RegisterGoal(matchId, 'home')
        return
    end
    
    -- Gol Away: X > centro.x + 29
    if pos.x > center.x + 29 and pos.y > center.y - 7 and pos.y < center.y + 7 and pos.z < center.z + 3.0 then
        RegisterGoal(matchId, 'away')
        return
    end
    
    -- Linha lateral: Y < centro.y-32 ou Y > centro.y+32
    if pos.y < center.y - 32 or pos.y > center.y + 32 then
        RegisterThrowIn(matchId)
        return
    end
    
    -- Linha de fundo: X < centro.x-33 ou X > centro.x+33
    if pos.x < center.x - 33 or pos.x > center.x + 33 then
        -- Lógica simplificada: determina se é escanteio ou tiro de meta pela metade do campo
        if pos.x < center.x - 33 then
            RegisterCornerKick(matchId)
        else
            RegisterGoalKick(matchId)
        end
        return
    end
end

function RegisterGoal(matchId, scoringTeam)
    local match = ActiveMatches[matchId]
    if not match then return end
    
    if scoringTeam == 'home' then
        match.homeScore = match.homeScore + 1
    else
        match.awayScore = match.awayScore + 1
    end
    
    pauseMatchPhysics[matchId] = true
    
    for _, pid in ipairs(match.players) do
        TriggerClientEvent('football:goalScored', pid)
        TriggerClientEvent('football:scoreUpdate', pid, match.homeScore, match.awayScore)
    end
    
    Citizen.SetTimeout(5000, function()
        local ball = ActiveBalls[matchId]
        if ball then
            ball.position = match.fieldCenter
            ball.velocity = vector3(0.0, 0.0, 0.0)
            ball.owner = nil
        end
        pauseMatchPhysics[matchId] = false
    end)
end

function RegisterThrowIn(matchId)
    local match = ActiveMatches[matchId]
    if not match then return end
    
    pauseMatchPhysics[matchId] = true
    
    for _, pid in ipairs(match.players) do
        TriggerClientEvent('football:throwIn', pid)
    end
    
    Citizen.SetTimeout(2000, function()
        local ball = ActiveBalls[matchId]
        if ball then
            local center = Config and Config.StadiumCoords or vector3(0.0, 0.0, 0.0)
            local sideY = ball.position.y > center.y and (center.y + 31) or (center.y - 31)
            ball.position = vector3(ball.position.x, sideY, 0.5)
            ball.velocity = vector3(0.0, 0.0, 0.0)
            ball.owner = nil
        end
        pauseMatchPhysics[matchId] = false
    end)
end

function RegisterCornerKick(matchId)
    local match = ActiveMatches[matchId]
    if not match then return end
    
    pauseMatchPhysics[matchId] = true
    
    for _, pid in ipairs(match.players) do
        TriggerClientEvent('football:cornerKick', pid)
    end
    
    Citizen.SetTimeout(2000, function()
        local ball = ActiveBalls[matchId]
        if ball then
            local center = Config and Config.StadiumCoords or vector3(0.0, 0.0, 0.0)
            local cornerX = ball.position.x > center.x and (center.x + 32) or (center.x - 32)
            local cornerY = ball.position.y > center.y and (center.y + 31) or (center.y - 31)
            
            ball.position = vector3(cornerX, cornerY, 0.5)
            ball.velocity = vector3(0.0, 0.0, 0.0)
            ball.owner = nil
        end
        pauseMatchPhysics[matchId] = false
    end)
end

function RegisterGoalKick(matchId)
    local match = ActiveMatches[matchId]
    if not match then return end
    
    pauseMatchPhysics[matchId] = true
    
    for _, pid in ipairs(match.players) do
        TriggerClientEvent('football:goalKick', pid)
    end
    
    Citizen.SetTimeout(2000, function()
        local ball = ActiveBalls[matchId]
        if ball then
            local center = Config and Config.StadiumCoords or vector3(0.0, 0.0, 0.0)
            local kickX = ball.position.x > center.x and (center.x + 25) or (center.x - 25)
            
            ball.position = vector3(kickX, center.y, 0.5)
            ball.velocity = vector3(0.0, 0.0, 0.0)
            ball.owner = nil
        end
        pauseMatchPhysics[matchId] = false
    end)
end

function StartRefereeLoop(matchId)
    if refereeIntervals[matchId] then return end
    
    refereeIntervals[matchId] = SetInterval(function()
        CheckBallEvents(matchId)
    end, 100)
end

function StopRefereeLoop(matchId)
    if refereeIntervals[matchId] then
        ClearInterval(refereeIntervals[matchId])
        refereeIntervals[matchId] = nil
    end
end