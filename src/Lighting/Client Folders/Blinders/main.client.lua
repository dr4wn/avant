-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local module = {
	fixtureData = {
		name = "Blinders",
		mode = "Extended"
	},
	instances = {}
}

local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
local Fixture = require(sharedFolder.Global.Fixture)
local FixtureController = require(sharedFolder.Global.FixtureController)

function module:createInstances(identifier)
	local lightFolder = CollectionService:GetTagged("[Avant v3] Lights "..identifier)[1]
	local fixtureFolder = lightFolder:FindFirstChild(module.fixtureData.name)

	for _, blinder in pairs(fixtureFolder:GetChildren()) do
		local blinderFixture = Fixture.new({
			personality = {
				fixture = module.fixtureData.name,
				name = blinder.Name,
				enabled = true
			},
			instances = {
				lens = blinder.Lens,
				spotlight = blinder.BlinderPart.SurfaceLight
			},
			extras = {
				brightnessMultiplier = 1
			},
		})
		FixtureController:Append(identifier, module.fixtureData.name, blinderFixture)
	end
end

function module:listenToEvents(identifier)
	local eventsFolder = ReplicatedStorage["Remote Events"]:FindFirstChild(identifier):FindFirstChild(module.fixtureData.name)
	local boolTranslator = { [true] = 1, [false] = 0 }
	local fixtures = FixtureController:Get(identifier, module.fixtureData.name)

	eventsFolder.replicator.OnClientEvent:Connect(function(arguments)
		local storage = arguments.storage

		for _, light in pairs(fixtures) do
			light:setValue("Intensity", { value = boolTranslator[storage.lightOn] })
			light.instances.spotlight.Enabled = storage.spotOn
		end
	end)

	eventsFolder.dimmer.OnClientEvent:Connect(function(arguments)
		local lightOn = arguments.lightOn or false

		for _, light in pairs(fixtures) do
			light:setValue("Intensity", { value = boolTranslator[lightOn] })
		end
	end)

	eventsFolder.spot.OnClientEvent:Connect(function(arguments)
		for _, light in pairs(fixtures) do
			light.instances.spotlight.Enabled = arguments.spotOn
		end
	end)
end

function module.setup(listOfIdentifiers)
	for _, instanceIdentifier in pairs(listOfIdentifiers) do
		local console = CollectionService:GetTagged("[Avant v3] Console "..instanceIdentifier)[1]
		local startedLighting = HttpService:JSONDecode(console:GetAttribute("startedLighting"))
		local flippedLighting = {}

		for _, light in pairs(startedLighting) do
			flippedLighting[light] = true
		end

		if not flippedLighting[module.fixtureData.name] then continue end

		FixtureController.new(instanceIdentifier, module.fixtureData.name)

		module.instances[instanceIdentifier] = {
			storage = {}
		}

		module:createInstances(instanceIdentifier)
		module:listenToEvents(instanceIdentifier)

	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

