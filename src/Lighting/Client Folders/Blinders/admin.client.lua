-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local Util = require(ReplicatedStorage.Shared.Global.Util)

local module = {
	fixtureData = {
		name = "Blinders",
		mode = "Extended"
	},
	instances = {}
}

function getInterfaceFolder(identifier)
	return ReplicatedStorage.Interfaces:FindFirstChild(identifier)
end

function getRemoteFolder(identifier)
	return ReplicatedStorage["Remote Events"]:FindFirstChild(identifier):FindFirstChild(module.fixtureData.name)
end

function module:listenToEvents(identifier) -- For stuff like indicators
	local eventsFolder = getRemoteFolder(identifier)

	-- eventsFolder..OnClientEvent:Connect(function(arguments)
	-- 	warn(arguments)
	-- end)
end

function module:createButtons(identifier)
	local interfaceLoc = Util:getInterfaceFolder(identifier)[module.fixtureData.name]
	local interface = interfaceLoc
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)

	local holster = interface.Holster
	local frames = {
		frame1 = holster["[Frame#1] Main"],
		frame2 = holster["[Frame#2] Colors"],
		frame3 = holster["[Frame#3] Faders"]
	}

	frames.frame1.Power.MouseButton1Click:Connect(function()
		eventsFolder.dimmer:FireServer({ lightOn = true })
	end)
	frames.frame1.Power.MouseButton2Click:Connect(function()
		eventsFolder.dimmer:FireServer({ lightOn = false })
	end)

	frames.frame1["Hold Power"].MouseButton1Down:Connect(function()
		eventsFolder.dimmer:FireServer({ lightOn = true })
	end)
	frames.frame1["Hold Power"].MouseButton1Up:Connect(function()
		eventsFolder.dimmer:FireServer({ lightOn = false })
	end)

	frames.frame1["Spot Power"].MouseButton1Click:Connect(function()
		eventsFolder.spot:FireServer({ spotOn = true })
	end)
	frames.frame1["Spot Power"].MouseButton2Click:Connect(function()
		eventsFolder.spot:FireServer({ spotOn = false })
	end)
end

function module.setup(listOfIdentifiers)
	for _, instanceIdentifier in pairs(listOfIdentifiers) do
		local startedLighting = Util:getAndDecodeConsole("[Avant v3] Console "..instanceIdentifier, "startedLighting")
		local flippedLighting = {}

		for _, light in pairs(startedLighting) do
			flippedLighting[light] = true
		end

		if not flippedLighting[module.fixtureData.name] then continue end

		module:listenToEvents(instanceIdentifier)
		module:createButtons(instanceIdentifier)
	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

