local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerGui = shared.Player:WaitForChild("PlayerGui")
local Mouse = shared.Player:GetMouse()

-- Things to do
-- Finish autoupdate on UI

local InterfaceModule = {}
shared.InterfaceClasses = require(script.DefaultClasses)

local Target = nil

-- Slightly less typing
InterfaceModule.FireClassEvent = function(name, object)
    if not object then return end
    
    local Class = object:GetAttribute("Class")

    if Class and shared.InterfaceClasses[Class] then
        shared.InterfaceClasses[Class][name](object)
    end
end

InterfaceModule.Click = function()
    -- Fire the click event from the element's class
    if Target == nil then return end

    InterfaceModule.FireClassEvent("Click", Target)
end

InterfaceModule.Start = function()
    -- Handles the inputs for the other functions
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("click 1")
            InterfaceModule.Click()
        end
    end)

    -- The loop that gets the current targgeted UI element
    RunService.PreRender:Connect(function()
        local Objects = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
        
        -- Roblox does the ZIndex stuff for us so I can just get the first index from the list 
        if Objects then
            local NextTarget = Objects[1]

            -- Since we're changing to another target, let the last target get the "MouseLeave" function
            if Target and NextTarget ~= Target then
                InterfaceModule.FireClassEvent("MouseLeave", Target)
            end

            -- Also give the new one "MouseEnter"
            if NextTarget and NextTarget ~= Target then
                InterfaceModule.FireClassEvent("MouseEnter", NextTarget)
            end

            Target = NextTarget
        end
    end)
end

return InterfaceModule