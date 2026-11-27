-- For when I need to test something with other modules

local Test = {}

Test.Start = function()
    task.wait(1)
    
    print("????")

    shared.Input.CreateBind("Kill", {Enum.KeyCode.L}, true, function()
        shared.Humanoid.Health = 0
    end)

    shared.Input.CreateBind("Sprint", {Enum.KeyCode.LeftShift}, true, function()
        shared.Humanoid.WalkSpeed = 18
        shared.Modules.CameraModule.Configuration.WalkBobbingStepTime = 0.35
    end, function()
        shared.Humanoid.WalkSpeed = 9
        shared.Modules.CameraModule.Configuration.WalkBobbingStepTime = 0.5
    end)

    shared.Humanoid.JumpHeight = 50
end

return Test