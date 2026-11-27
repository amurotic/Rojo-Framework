local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
-- Built in module for camera smoothness/leaning, customizable
-- h
local CURRENT_CAMERA = workspace.CurrentCamera

local bobbingTick = 0
local bobbingTimer = 0

local CameraModule = {}
CameraModule.Configuration = {
    -- Camera settings
    StartingFOV = 55,
    
    -- Tilting when walking left/right
    TiltEnabled = true,
    TiltAmount = 0.2,
    TiltLerp = 0.05,

    -- Camera smoothing and how long it takes for the smoothing to reach the destination
    -- This only applies to mouse movement
    CameraSmoothingEnabled = true,
    CameraSmoothingTime = 0.15,

    -- Bobbing when walking
    WalkBobbingEnabled = true,
    WalkBobbingAmount = 2,
    WalkBobbingStepModifier = 0.25,
    WalkBobbingRotationModifier = 1.2,
    WalkBobbingResetTime = 5, -- how many ticks until the bob stops while not moving
    WalkBobbingStepTime = 0.5,

    MovingSoundEnabled = false,
    MovingSoundAssignedSound = nil,
    MovingSoundVolume = 0.1
}

-- I got this from the dev forum I fucking hate doing camera scripts
local function angleDelta(from, to)
    return (to - from + math.pi) % (2 * math.pi) - math.pi
end

CameraModule.Start = function()
    CURRENT_CAMERA.FieldOfView = CameraModule.Configuration.StartingFOV
    bobbingTimer = CameraModule.Configuration.WalkBobbingResetTime

    local yaw, pitch = nil, nil
    local yawVel, pitchVel = 0, 0
    local yawGoal, lastTargetYaw = nil, nil
    local lastTarget = nil

    local leanVector = 0
    local cameraRightVector = 0
    
    local bobbingRotation = CFrame.Angles(0, 0, 0)
    local bobbingOffset = Vector3.new()

    RunService:BindToRenderStep("CameraModuleRestore", Enum.RenderPriority.Camera.Value - 1, function()
        if lastTarget then
            CURRENT_CAMERA.CFrame = lastTarget
        end
    end)

    RunService:BindToRenderStep("CameraModuleRender", Enum.RenderPriority.Camera.Value + 1, function(dt)
        -- Smoothing (fml)
        local target = CURRENT_CAMERA.CFrame
        lastTarget = target

        local targetPitch, targetYaw = target:ToOrientation()

        if not yaw then
            yaw, pitch = targetYaw, targetPitch
            yawGoal, lastTargetYaw = targetYaw, targetYaw
        end

        local smoothTime = CameraModule.Configuration.CameraSmoothingTime / 3

        yawGoal += angleDelta(lastTargetYaw, targetYaw)
        lastTargetYaw = targetYaw

        yaw, yawVel = TweenService:SmoothDamp(yaw, yawGoal, yawVel, smoothTime, math.huge, dt)
        pitch, pitchVel = TweenService:SmoothDamp(pitch, targetPitch, pitchVel, smoothTime, math.huge, dt)

        -- Tilting (left/right)
        local velocity = shared.Character.PrimaryPart.Velocity
        local tiltVelocity = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

        cameraRightVector = -(shared.Humanoid.MoveDirection:Dot(CURRENT_CAMERA.CFrame.RightVector))
        local targetLean = cameraRightVector * tiltVelocity
        leanVector = leanVector + (targetLean - leanVector) * CameraModule.Configuration.TiltLerp
        local tiltRotation = CFrame.Angles(0, 0, math.rad(leanVector * CameraModule.Configuration.TiltAmount))

        -- Bobbing while walking
        if shared.Humanoid.MoveDirection.Magnitude > 0.01 then
            bobbingTick += (1 * 60) * dt
            bobbingTimer = CameraModule.Configuration.WalkBobbingResetTime
        else
            if bobbingTimer <= 0 then
                bobbingTick = 0
            else
                bobbingTimer -= (1 * 60) * dt
            end
        end
        
        local dividedTick = bobbingTick * math.pi / (30 * CameraModule.Configuration.WalkBobbingStepTime) -- / 6
        
        local cfgRot = CameraModule.Configuration.WalkBobbingRotationModifier
        local cfgStep = CameraModule.Configuration.WalkBobbingStepModifier

        local rotationGoal = CFrame.Angles(0, 0, math.rad(math.cos(dividedTick / 2) * cfgRot))
        local offsetGoal = Vector3.new(math.sin(dividedTick / 2) * cfgStep, math.sin(dividedTick) * cfgStep, 0)
        
        bobbingRotation = bobbingRotation:Lerp(rotationGoal, (0.1 * 60) * dt)
        bobbingOffset = bobbingOffset:Lerp(offsetGoal, (0.1 * 60) * dt)

        -- Update everything
        local focus = CURRENT_CAMERA.Focus.Position
        local targetRotation = CFrame.fromOrientation(targetPitch, targetYaw, 0)
        local smoothRotation = CFrame.fromOrientation(pitch, yaw, 0)
        local offset = targetRotation:VectorToObjectSpace(target.Position - focus)

        CURRENT_CAMERA.CFrame = (CFrame.new(focus + smoothRotation:VectorToWorldSpace(offset)) * smoothRotation) * tiltRotation * bobbingRotation
        shared.Humanoid.CameraOffset = bobbingOffset
    end)
end

return CameraModule