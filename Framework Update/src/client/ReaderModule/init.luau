local RunService = game:GetService("RunService")
local PlayerGui = shared.Player:WaitForChild("PlayerGui")
local Mouse = shared.Player:GetMouse()

local Reader = {}
Reader.TTS = nil
Reader.HIGHLIGHT = nil

local Target = nil

Reader.SetupTTS = function()
    -- The important part
    local TTS = Instance.new("AudioTextToSpeech")
	TTS.VoiceId = "9"
    TTS.Speed = 1.5
	TTS.Parent = workspace
    TTS.Text = "Hello"

    -- Make this because ROBLOX sucks
	local AudioOut = Instance.new("AudioDeviceOutput")
	AudioOut.Parent = workspace

    -- And this
	local Wire = Instance.new("Wire")
	Wire.SourceInstance, Wire.TargetInstance, Wire.Parent = TTS, AudioOut, workspace
    
    -- This is actually important though
    local Highlight = Instance.new("UIStroke")
    Highlight.Thickness = 0.1
    Highlight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Highlight.LineJoinMode = Enum.LineJoinMode.Miter
    Highlight.Parent = workspace
    Highlight.Name = "Reader Highlight"
    Highlight.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
    Highlight.Color = Color3.new(1, 0.737255, 0.282353)

    Reader.TTS = TTS
    Reader.HIGHLIGHT = Highlight
end

Reader.ReadText = function(text)
    Reader.TTS:Pause()
    Reader.TTS.Text = text
    
    print(text)

	Reader.TTS:Play()

    task.delay(1, function()
        if not Reader.TTS.Playing then
            Reader.TTS:Play()
        end
    end)
end


-- Moves the highlight to the targetted object
-- TEMP SOLUTION: Highlight will be destroyed with other destroyed UI objects
Reader.EnterObject = function(object)
    -- Read text (the whole point)
    if object:IsA("TextButton") then
        Reader.ReadText(object.Text .. " Button")
    end
    if object:IsA("TextBox") then
        Reader.ReadText(object.Text .. " Edittable Text Field")
    end
    if object:IsA("TextLabel") then
        Reader.ReadText(object.Text .. " Text")
    end
    if object:IsA("ImageButton") then
        Reader.ReadText("Image Button")
    end
    if object:IsA("ImageLabel") then
        Reader.ReadText("Image")
    end

    Reader.HIGHLIGHT.Parent = object
end

Reader.LeaveObject = function(object)
    Reader.HIGHLIGHT.Parent = workspace
end

-- Sounds I want to add
-- Hover: 119354387183704
-- Click: 136108770017536
-- Mobile Double Tap: 103003970474571

Reader.Start = function()
    Reader.SetupTTS()

    RunService.PreRender:Connect(function()
        local Objects = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
        
        -- Roblox does the ZIndex stuff for us so I can just get the first index from the list 
        if Objects then
            local NextTarget = Objects[1]

            -- Since we're changing to another target, let the last target get the "MouseLeave" function
            if Target and NextTarget ~= Target then
                Reader.LeaveObject(Target)
            end

            -- Also give the new one "MouseEnter"
            if NextTarget and NextTarget ~= Target then
                Reader.EnterObject(NextTarget)
            end

            Target = NextTarget
        end
    end)
end

return Reader