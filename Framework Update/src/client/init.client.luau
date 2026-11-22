local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until game:IsLoaded()

print("Loading..")

local Modules = script:GetChildren() 

shared.Modules = {}
shared.Player    = game.Players.LocalPlayer
shared.Character = shared.Player.Character or shared.Player.CharacterAdded:Wait()
shared.Humanoid = shared.Character:WaitForChild("Humanoid")

-- Get the new Character when the old one is destroyed
shared.Player.CharacterAdded:Connect(function(character)
	shared.Character = character
	shared.Humanoid = character:WaitForChild("Humanoid")
end)

local Remotes = {}

-- For hiding remote names from low level exploiters
-- Made mostly by Pugser_Plays
if ReplicatedStorage:FindFirstChild("Events") then
	shared.Events = ReplicatedStorage.Events
    shared.Remotes = {}
    
    task.spawn(function()
    	for _, remote in pairs(game.ReplicatedStorage.Events:GetChildren()) do
    		if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("BindableEvent") then
    			Remotes[remote.Name] = remote
    		end
    	end
    
    	-- this hides the remotes when you print shared.Events
    	-- not perfect but it's just to protect from the snoopers
    
    	-- Just go shared.Events.RemoteName -- like normal basically
    	local Remotes = setmetatable({}, {
    		__index = function(_, key)
    			return Remotes[key]
    		end,
    
    		__newindex = function()
    			error("Remotes table is read-only", 2)
    		end,
    
    		__pairs = function()
    			return function() end
    		end,
    
    		__len = function()
    			return 0
    		end
    	})
    
    	shared.Events = Remotes
    
    	while task.wait(5) do
    		for _, remote in pairs(game.ReplicatedStorage.Events:GetChildren()) do
    			remote.Name = game:GetService("HttpService"):GenerateGUID(false)
    		end
    	end
    end)

	Remotes = shared.Remotes
else
	warn("'ReplicatedStorage.Events' could not be found. Remote functionality has been skipped.")

	Remotes = {}
end

-- Preload assets in ReplicatedStorage
game:GetService("ContentProvider"):PreloadAsync(ReplicatedStorage:GetDescendants())

-- LOads all modules
-- A module must have at least a start function to work
for _, Module in pairs(Modules) do
	-- Prevent modules with the tag "Disabled" from ever loading
	if table.find(Module:GetTags(), "Disabled") then continue end

	shared.Modules[Module.Name] = require(Module)
	task.spawn(function()
		shared.Modules[Module.Name].Start()
	end)
	
	Module.Changed:Connect(function()
		shared.Nuke("A client module (or the whole framework) was tampered with")
	end)
end


print("Loaded modules")