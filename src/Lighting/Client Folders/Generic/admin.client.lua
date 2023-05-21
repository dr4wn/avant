-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local instancesAttribute = script.Parent.Parent:GetAttribute("consoleInstances") or "NO_INSTANCES"
if instancesAttribute == "NO_INSTANCES" then return warn("none") end

local module = {
	fixtureData = {
		name = "Generic",
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

function module:listenToEvents(identifier)
	local eventsFolder = getRemoteFolder(identifier)

	eventsFolder.init.OnClientEvent:Connect(function(arguments)
	end)
end

function module:createButtons(identifier)
	local interfaceLoc = getInterfaceFolder(identifier)[module.fixtureData.name]
	local interface = interfaceLoc
	local eventsFolder = getRemoteFolder(identifier)

	local holster = interface.Holster
	local frames = {
		frame1 = holster["[Frame#1] Main"],
		frame2 = holster["[Frame#2] Colors"],
		frame3 = holster["[Frame#3] Faders"]
	}

	frames.frame1.Test.MouseButton1Down:Connect(function()
		eventsFolder.test_event:FireServer({"testing | identifier: "..identifier})
	end)

	frames.frame1.SD100.MouseButton1Down:Connect(function()
		eventsFolder.dimmer:FireServer({ value = 100 })
	end)

	frames.frame1.SD0.MouseButton1Down:Connect(function()
		eventsFolder.dimmer:FireServer({ value = 0 })
	end)
end

function module.setup(listOfIdentifiers)
	for _, instanceIdentifier in pairs(listOfIdentifiers) do
		module:listenToEvents(instanceIdentifier)
		module:createButtons(instanceIdentifier)
	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

