local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerGui = shared.Player:WaitForChild("PlayerGui")
local Mouse = shared.Player:GetMouse()

-- Things to do
-- Replace autoupdate with a Start() function
-- Add touch screen/UI nav support

local InterfaceModule = {}
shared.Interface = {}
shared.Interface.Classes = require(script.DefaultClasses)

local Target = nil

-- Creates a brand new class with the provided name, update scheduling, and functions and sends it to shared.Interface.Classes and then returns it
-- @param string name The name of the class.
-- @param any The function that triggers when you click the object. (MUST INCLUDE AN OBJECT ARGUMENT) (Optional)
-- @param any The function that triggers when the mouse hovers over the UI object. (MUST INCLUDE AN OBJECT ARGUMENT)
-- @param any The function that triggers when the mouse leaves the UI object. (MUST INCLUDE AN OBJECT ARGUMENT) (Optional)
-- @param any The function used to Update the class. Can also be activated on a timer. (MUST INCLUDE AN OBJECT ARGUMENT) (Optional)
-- @return any The class inside of shared.Interface.Classes
shared.Interface.CreateClass = function(name, click, mouseEnter, mouseLeave, updateFunction)
    if not name then
        error("Argument #1 missing or nil. Class must have at least a anme before creation.")
    end

    if shared.Interface.Classes[name] then
        error("A class with the same name already exists.")
    end
    
    local NewClass = {}
    NewClass.Name = name
    NewClass.Click, NewClass.MouseEnter, NewClass.MouseLeave, NewClass.Update = click, mouseEnter, mouseLeave, updateFunction

    shared.Interface.Classes[name] = NewClass

    return shared.Interface.Classes[name]
end

-- Gets a class with it's name.
-- @param string The name of a class.
-- @return any The class.
shared.Interface.GetClass = function(className)
    if not className then
        error("Argument #1 missing or nil.")
    end
end

-- Emulates a class event
shared.Interface.FireClassEvent = function(name, object)
    if not object then return end
    
    local Class = object:GetAttribute("Class")

    if Class and shared.Interface.Classes[Class] then
        shared.Interface.Classes[Class][name](object)
    end
end

InterfaceModule.Click = function()
    -- Fire the click event from the element's class
    if Target == nil then return end

    shared.Interface.FireClassEvent("Click", Target)
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
                shared.Interface.FireClassEvent("MouseLeave", Target)
            end

            -- Also give the new one "MouseEnter"
            if NextTarget and NextTarget ~= Target then
                shared.Interface.FireClassEvent("MouseEnter", NextTarget)
            end

            Target = NextTarget
        end
    end)
end

return InterfaceModule