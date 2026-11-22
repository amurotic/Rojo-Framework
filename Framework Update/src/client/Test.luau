

-- For when I need to test something with other modules

local Test = {}

Test.Start = function()
    task.wait(1)
    
    print("????")

    shared.Input.CreateBind("JumpTest", {Enum.KeyCode.E}, true, function()
        print("active   ")
        shared.Humanoid.Health = 0
    end)

    shared.Input.CreateBind("Sprint", {Enum.KeyCode.LeftShift}, true, function()
        shared.Humanoid.WalkSpeed = 50
    end, function()
        shared.Humanoid.WalkSpeed = 16
    end)

    shared.Humanoid.JumpHeight = 50
end

return Test