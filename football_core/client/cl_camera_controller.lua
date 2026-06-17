local footballCam = nil
local lastKnownBallPos = vector3(0.0, 0.0, 0.0)
local camSideOffset = 60.0
local camHeight = 25.0
local fieldCenterPos = vector3(0.0, 0.0, 0.0)

function Lerp(a, b, t)
    return a + (b - a) * math.min(t, 1.0)
end

function LerpVector3(a, b, t)
    local t_clamped = math.min(t, 1.0)
    return vector3(
        a.x + (b.x - a.x) * t_clamped,
        a.y + (b.y - a.y) * t_clamped,
        a.z + (b.z - a.z) * t_clamped
    )
end

function CreateFootballCamera(fieldCenter)
    fieldCenterPos = fieldCenter
    local camX = fieldCenter.x
    local camY = fieldCenter.y - camSideOffset
    local camZ = fieldCenter.z + camHeight
    
    footballCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camX, camY, camZ, -25.0, 0.0, 0.0, 65.0, false, 0)
    SetCamActive(footballCam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

function DestroyFootballCamera()
    if footballCam then
        RenderScriptCams(false, true, 1000, true, false)
        DestroyCam(footballCam, false)
        footballCam = nil
    end
end

function UpdateCamera(ballPos, deltaTime)
    if not footballCam then return end
    
    lastKnownBallPos = LerpVector3(lastKnownBallPos, ballPos, 3.0 * deltaTime)
    
    local newCamX = lastKnownBallPos.x
    local newCamY = fieldCenterPos.y - camSideOffset
    local newCamZ = fieldCenterPos.z + camHeight
    
    SetCamCoord(footballCam, newCamX, newCamY, newCamZ)
    PointCamAtCoord(footballCam, lastKnownBallPos.x, lastKnownBallPos.y, lastKnownBallPos.z + 0.5)
    
    local distFromCenter = math.abs(lastKnownBallPos.x - fieldCenterPos.x)
    local fov = Lerp(60.0, 70.0, distFromCenter / 50.0) 
    SetCamFov(footballCam, fov)
end

Citizen.CreateThread(function()
    while true do
        if footballCam ~= nil then
            UpdateCamera(lastKnownBallPos, 0.016)
        end
        Citizen.Wait(16)
    end
end)

RegisterNetEvent('football:ballUpdate')
AddEventHandler('football:ballUpdate', function(data)
    if data and data.pos then
        lastKnownBallPos = vector3(data.pos.x, data.pos.y, data.pos.z)
    end
end)

RegisterNetEvent('football:matchStart')
AddEventHandler('football:matchStart', function(matchId, fieldCenter)
    if fieldCenter then
        lastKnownBallPos = vector3(fieldCenter.x, fieldCenter.y, fieldCenter.z)
        CreateFootballCamera(lastKnownBallPos)
    else
        lastKnownBallPos = GetEntityCoords(PlayerPedId())
        CreateFootballCamera(lastKnownBallPos)
    end
end)

RegisterNetEvent('football:matchEnd')
AddEventHandler('football:matchEnd', function()
    DestroyFootballCamera()
end)