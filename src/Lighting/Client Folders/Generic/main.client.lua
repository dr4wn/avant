-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local module = {
	fixtureData = {
		name = "Generic",
		mode = "Extended"
	},
	instances = {}
}

function module:createInstances(identifier)

end

function module:listenToEvents(identifier)
	local eventsFolder = ReplicatedStorage["Remote Events"]:FindFirstChild(identifier):FindFirstChild(module.fixtureData.name)
	eventsFolder.test_event.OnClientEvent:Connect(function(arguments)
		local largeTestMsg = table.concat({
			"",
			"[CLIENT]",
			"",
			"Avant v2.5 Console",
			"Debug Information",
			"\"Generic\" Module",
			"",
			"Event Gotten, \"arguments\" below:",
			if arguments ~= nil then tostring(table.concat(arguments, "\n")) else "none gotten!",
			""
		}, "\n")
		warn(largeTestMsg)
	end)

	eventsFolder.replicator.OnClientEvent:Connect(function(arguments)
		-- Set the things and the stuff here but because
		-- this is a base, we don't have shit to work with lmao.
	end)
end

function module.setup(listOfIdentifiers)
	for _, instanceIdentifier in pairs(listOfIdentifiers) do
		module:listenToEvents(instanceIdentifier)
		module:createInstances(instanceIdentifier)
		
		module.instances[instanceIdentifier] = {
			storage = {}
		}
	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

