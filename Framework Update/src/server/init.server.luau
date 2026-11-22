print("Loading..")

local Modules = script:GetDescendants() 

shared.RepStorage = game:GetService("ReplicatedStorage")
shared.Events = shared.RepStorage.Events

shared.Modules = {}

for _, Module in pairs(Modules) do
	shared.Modules[Module.Name] = require(Module)
	task.spawn(function()
		shared.Modules[Module.Name].Start()
	end)
end

print("Loaded modules")