local DefaultClasses = {}

-- Define UI classes here or do it in other modules.
-- You can also add a class during runtime by inserting into the shared.Modules.InterfaceModule.Classes table
DefaultClasses.TestButton = {
    UpdateOnStart = false, -- Runs Update() immediately when the game loads
    UpdateOnTimer = false, -- Runs Update() automaticlaly on an interval. Timer is defined by "UpdateTimer"
    UpdateTimer = 10, -- The interval on which "UPdateOnTimer" runs at
    
    -- Runs when a clcik/tap is detected and the target is this object
    -- Put logic for when the object is clicked here
    Click = function(object)
        object:Destroy()
        game.SoundService.Sound:Play()
    end,

    -- Runs when Target is set to this object
    MouseEnter = function(object)
        object.BackgroundColor3 = Color3.new(0, 255, 0)
    end,

    -- Runs when Target is changed off of this object
    MouseLeave = function(object)
        object.BackgroundColor3 = Color3.new(255, 0, 0)
    end,

    -- Runs either on an interval, on game start or manually by you. Used for text with requires updates (stats, placement, health)
    -- Put the code that updates information on this object here and fire it from another module using InterfaceModule.Update(object)
    Update = function(object)
        object.BackgroundColor3 = Color3.new(0, 0, 255)
    end,
}

return DefaultClasses