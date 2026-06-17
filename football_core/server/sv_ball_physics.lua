ActiveBalls = {}

function InitBall(matchId, spawnPos)
    local ball = {
        position = spawnPos,
        velocity = vector3(0.0, 0.0, 0.0),
        spin = 0.0,
        owner = nil,
        lastTouch = nil,
        isGrounded = false,
        matchId = matchId
    }
    ActiveBalls[matchId] = ball
    return ball
end

function ApplyForce(matchId, direction, force, spinFactor)
    local ball = ActiveBalls[matchId]
    if ball then
        ball.velocity = ball.velocity + (direction * force)
        ball.spin = ball.spin + spinFactor
        ball.owner = nil
    end
end

function TickPhysics(matchId, deltaTime)
    local ball = ActiveBalls[matchId]
    if not ball then return end

    -- Integração de Euler
    ball.position = ball.position + (ball.velocity * deltaTime)
    
    -- Gravidade
    local gravity = Config and Config.BallGravity or -9.81
    ball.velocity = vector3(ball.velocity.x, ball.velocity.y, ball.velocity.z + (gravity * deltaTime))
    
    -- Drag
    local friction = Config and Config.BallFriction or 0.99
    ball.velocity = ball.velocity * friction
    
    -- Spin (desvia velocity.x pelo spin * 0.02)
    ball.velocity = vector3(ball.velocity.x + (ball.spin * 0.02), ball.velocity.y, ball.velocity.z)
    
    -- Colisão com chão (z <= 0)
    if ball.position.z <= 0.0 then
        local restitution = Config and Config.BallRestitution or 0.8
        -- velocity.z invertido * restitution, friction 0.7 em x e y
        ball.velocity = vector3(ball.velocity.x * 0.7, ball.velocity.y * 0.7, math.abs(ball.velocity.z) * restitution)
        ball.position = vector3(ball.position.x, ball.position.y, 0.1)
    end
    
    -- isGrounded = true se velocity.z < 0.1 e position.z <= 0.2
    if math.abs(ball.velocity.z) < 0.1 and ball.position.z <= 0.2 then
        ball.isGrounded = true
    else
        ball.isGrounded = false
    end

    TriggerClientEvent('football:ballUpdate', -1, {
        pos = {x = ball.position.x, y = ball.position.y, z = ball.position.z},
        vel = {x = ball.velocity.x, y = ball.velocity.y, z = ball.velocity.z},
        owner = ball.owner
    })
end

function GetBallState(matchId)
    local ball = ActiveBalls[matchId]
    if ball then
        return {
            position = vector3(ball.position.x, ball.position.y, ball.position.z),
            velocity = vector3(ball.velocity.x, ball.velocity.y, ball.velocity.z),
            spin = ball.spin,
            owner = ball.owner,
            lastTouch = ball.lastTouch,
            isGrounded = ball.isGrounded,
            matchId = ball.matchId
        }
    end
    return nil
end

local physicsLoops = {}

function StartPhysicsLoop(matchId)
    if physicsLoops[matchId] then return end

    physicsLoops[matchId] = SetInterval(function()
        TickPhysics(matchId, 0.016)
    end, 16)
end

function StopPhysicsLoop(matchId)
    if physicsLoops[matchId] then
        ClearInterval(physicsLoops[matchId])
        physicsLoops[matchId] = nil
    end
end

function CheckProximity(matchId, playerId, playerPos)
    local ball = ActiveBalls[matchId]
    if not ball then return end

    if ball.owner == nil then
        local dist = #(ball.position - playerPos)
        if dist <= 1.5 then
            ball.owner = playerId
            ball.lastTouch = playerId
            TriggerClientEvent('football:ballOwnerChanged', -1, matchId, playerId)
        end
    end
end
