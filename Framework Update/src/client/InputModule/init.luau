local UserInputService = game:GetService("UserInputService")
local Mouse = shared.Player:GetMouse()

-- Things to add
-- Keyboard Events
-- Mouse X/Y Pos/Events
-- Gamepad Joystick X/Y Pos/Events
-- Touch Screen Events

local DEFAULT_BINDS = require(script.DefaultBinds)

local InputModule = {}
shared.Input = {}
shared.Input.Binds = DEFAULT_BINDS

-- Get the status of a bind
-- @param any bind The bind you wish to check.
-- @return The pressed state of the bind. Shown in bind.Pressed
shared.Input.IsBindDown = function(bind)
    if not bind then error("Argument #1 missing or nil. You must provide a bind.") end
    if not bind.Pressed then bind.Pressed = false end
    return bind.Pressed
end

-- Adds the provided "inputs" (table of Enum or a single Enum) to the bind
-- @param any bind The bind you wish to modify.
-- @param any inputs The input(s) you wish to add.
shared.Input.AddInputsToBind = function(bind, inputs)
    if not bind then error("Argument #1 missing or nil. You must provide a bind.") end
    if not inputs then error("Argument #2 missing or nil. You must provide the input(s) you wish to remove. Shocking.") end

    if inputs[1] then
        for _, input in pairs(inputs) do
            table.insert(bind.Inputs, input)
        end
    else
         table.insert(bind.Inputs, inputs)
    end
end

-- Removes the provided inputs (table of enum or a single enum) from the bind
-- @param any bind The bind you wish to modify.
-- @param any inputs The input(s) you wish to remove.
shared.Input.RemoveInputsFromBind = function(bind, inputs)
    if not bind then error("Argument #1 missing or nil. You must provide a bind.") end
    if not inputs then error("Argument #2 missing or nil. You must provide the input(s) you wish to remove. Shocking.") end

    if inputs[1] then
        for _, input in pairs(inputs) do
            table.remove(bind.Inputs, table.find(bind.Inputs, input))
        end
    else
        table.remove(bind.Inputs, table.find(bind.Inputs, inputs))
    end
end

-- Overwrites the entire input table of a bind with the table you provide
-- @param bind The bind you wish to modify.
-- @param any The inputs you want to replace this bind's current inputs with. (Optional), 
shared.Input.OverwriteInputsOfBind = function(bind,  inputs)
    if not bind then error("Argument #1 missing or nil. You must provide a bind.") end

    bind.Inputs = inputs
end

-- Set the "Active" state of a bind. (true = enabled, false = disabled)
-- @param bind The bind you wish to modify.
-- @param boolean The active state of the bind. (enabled = true)
shared.Input.SetBindActive = function(bind, active)
    if not bind then error("Argument #1 missing or nil. You must provide a bind.") end
    if not active then error("Argument #2 missing or nil. You must provide the active state of the bind. That IS what you're trying to change after all.") end

    bind.Active = active
end

-- Creates a brand new bind with the provided name, inputs, active state, sends it to shared.Inputs and then returns it
-- @param string name The name of the bind.
-- @param any inputs The input(s) that the bind activates with. (Optional)
-- @param boolean active The bind's active state. (true = enabled) (Optional)
-- @param any bindDown The function that triggers when the bind is pressed down. (Optional)
-- @param any bindUp The function that triggers when the bind has been let go. (Optional)
-- @return any The bind inside of shared.Inputs.Binds
shared.Input.CreateBind = function(name, inputs, active, bindDown, bindUp)
    -- If someone actually forgets to provide the one required argument I'm done
    if not name then
        error("Argument #1 missing or nil. Bind must have at least a anme before creation.")
    end

    if shared.Input.Binds[name] then
        error("A bind with the same name already exists.")
    end
    
    local NewBind = {}
    NewBind.Name = name
    NewBind.Inputs, NewBind.Active, NewBind.BindDown, NewBind.BindUp = inputs, (active or true), bindDown, bindUp

    shared.Input.Binds[name] = NewBind

    return shared.Input.Binds[name]
end

-- Fires when a bind is down or initially pressed
-- [bind].BindDown

-- Fires when a bind is up or no longer pressed
-- [bind].BindUp

InputModule.Start = function()
    UserInputService.InputBegan:Connect(function(input)
        if not UserInputService:GetFocusedTextBox() then
            -- Go through all binds to sese if this KeyCode is active in one of them
            for _, Bind in pairs(shared.Input.Binds) do
                if not Bind.Active then continue end
                -- In case some binds have the same input for some god forsaken reason
                task.spawn(function()
                    if Bind.Inputs and table.find(Bind.Inputs, input.KeyCode) then
                        if Bind.BindDown then
                            Bind.Pressing = true
                            Bind.BindDown()
                        end
    
                        repeat task.wait() until not UserInputService:IsKeyDown(input.KeyCode)
    
                        if Bind .BindUp then
                            Bind.Pressing = false
                            Bind.BindUp()
                        end
                    end
                end)
            end
        end
    end)
end

return InputModule