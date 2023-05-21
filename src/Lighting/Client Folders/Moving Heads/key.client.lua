-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local Keybinds = require(sharedFolder.Global.Keybinds)

local module = {
	fixtureData = {
		name = "Moving Heads",
		mode = "Extended"
	},
}

local instancesAttribute = script:GetAttribute("identifier")
if not instancesAttribute then return end

local eventsFolder = ReplicatedStorage["Remote Events"]:FindFirstChild(instancesAttribute):FindFirstChild(module.fixtureData.name)

UserInputService.InputBegan:Connect(function(key, processed)
	if not processed then
		local keybindLookup = Keybinds[key.KeyCode]
		if not keybindLookup then return end
		
		eventsFolder.input:FireServer({
			key = key.KeyCode
		})
	end
end)
