-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local module = {
	fixtureData = {
		name = "Washes",
		mode = "Extended"
	},
	instances = {}
}

local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)

local Fixture = require(sharedFolder.Global.Fixture)
local Effect = require(sharedFolder.Global.Effect)

local FixtureController = require(sharedFolder.Global.FixtureController)
local EffectController = require(sharedFolder.Global.EffectController)

local StaticFunctions = require(sharedFolder.Static.Base)
local Effects = require(sharedFolder.Effects[module.fixtureData.name])
local Positions = require(sharedFolder.Positions[module.fixtureData.name])

function module:createInstances(identifier)
	local lightFolder = CollectionService:GetTagged("[Avant v3] Lights "..identifier)[1]
	local fixtureFolder = lightFolder:FindFirstChild(module.fixtureData.name)

	for _, washLight in pairs(fixtureFolder:GetChildren()) do
		local washFixture = Fixture.new({
			personality = {
				fixture = module.fixtureData.name,
				name = washLight.Name,
				enabled = true
			},
			instances = {
				lens = washLight.Head.Lens,
				spotlight = washLight.Head.Beam.SpotLight,
				beam = washLight.Head.Beam.light,
				pan = washLight.Motors.Pan,
				tilt = washLight.Motors.Tilt
			},
			extras = {
				brightnessMultiplier = 1
			},
		})
		FixtureController:Append(identifier, module.fixtureData.name, washFixture)
	end

	local fixtures = FixtureController:Get(identifier, module.fixtureData.name)

	for effectData, callback in pairs(Effects) do
		local effectObj = Effect.new({
			personality = {
				name = effectData.effect.name,
				bpm = effectData.effect.bpm,
				speedgroup = effectData.effect.group,
				editableByBPM = effectData.effect.editableByBPM
			},
			engine = {
				waveform = effectData.engine.waveform,
				callback = callback
			},

			instances = {
				group = fixtures
			}
		})
		EffectController:Append(identifier, module.fixtureData.name, effectObj)
	end
end

function module:listenToEvents(identifier)
	local eventsFolder = ReplicatedStorage["Remote Events"]:FindFirstChild(identifier):FindFirstChild(module.fixtureData.name)
	local fixtures = FixtureController:Get(identifier, module.fixtureData.name)
	local consoleInstance = module.instances[identifier]
	local storage = consoleInstance.storage

	local function setBPM(speedGroup, value)
		local specificEffects = EffectController[identifier][module.fixtureData.name]
		local formula = ((value) / 500) * .5
		for _, effectObj in pairs(specificEffects) do
			if not effectObj.personality.editableByBPM then continue end
			if effectObj.personality.speedgroup ~= speedGroup then continue end
			local newValue = if effectObj.personality.speedgroup == "movement" then
				value * .5 else value
			effectObj.personality.bpm = newValue
			if effectObj.personality.speedgroup == "movement" then
				for _, light in pairs(fixtures) do
					light.instances.pan.MaxVelocity = formula
					light.instances.tilt.MaxVelocity = formula
				end
			end
		end
	end

	local function setColor(color)
		for _, light in pairs(fixtures) do
			light:setValue("Color", { value = color })
		end
	end

	local function setBeam(mode)
		for _, light in pairs(fixtures) do
			light.instances.spotlight.Enabled = mode
			light.instances.beam.Enabled = mode
		end
	end

	local function setPosition(positionIndex)
		local positionData = Positions[positionIndex] or Positions[1]
		for _, light in pairs(fixtures) do
			local lightPosData = if positionData[tonumber(light.personality.name)] then
				positionData[tonumber(light.personality.name)] else positionData[1]

			local data = {
				pan = if lightPosData.pan then lightPosData.pan else nil,
				tilt = if lightPosData.tilt then lightPosData.tilt else nil,
			}
			light:setValue("Position", data)
		end
	end

	local function setZoom(zoomValue)
		local zoomValue = tonumber(zoomValue) or 25

		for _, light in pairs(fixtures) do
			light:setValue("Zoom", { value = zoomValue })
		end
	end

	eventsFolder.replicator.OnClientEvent:Connect(function(arguments)
		local storage = arguments.storage
		local temporaryHolder = {}

		if storage.lightOn then
			StaticFunctions["Power"]({ mouseButton = "MouseButton1Down", fixtures = fixtures })
		else
			StaticFunctions["Power"]({ mouseButton = "MouseButton2Down", fixtures = fixtures })
		end

		for speedGroup, value in pairs(storage.bpm) do
			setBPM(speedGroup, value)
		end

		setBeam(storage.spotOn)
		setPosition(storage.positionIndex)
		setZoom(storage.zoomValue)
		setColor(storage.color)

		for effectName, buttonReference in pairs(storage.effects) do
			local tableConstruct = {
				buttonReference = buttonReference,
				effectName = effectName,
				on = true
			}
			EffectController:Run(identifier, module.fixtureData.name, effectName)
			table.insert(temporaryHolder, tableConstruct)
		end

		eventsFolder.data:Fire({ effects = temporaryHolder })
	end)

	eventsFolder.dimmer.OnClientEvent:Connect(function(arguments)
		StaticFunctions[arguments.staticFunction]({ mouseButton = arguments.dimmerButton, fixtures = fixtures })
	end)

	eventsFolder.effect.OnClientEvent:Connect(function(arguments)
		for _, effectTable in pairs(arguments.effects) do
			if effectTable.on then
				EffectController:Run(identifier, module.fixtureData.name, effectTable.effectName)
				storage.effects[effectTable.effectName] = effectTable.buttonReference
			else
				EffectController:Stop(identifier, module.fixtureData.name, effectTable.effectName)
				storage.effects[effectTable.effectName] = nil
			end
		end
	end)

	eventsFolder.bpm.OnClientEvent:Connect(function(arguments)
		setBPM(arguments.valueName, arguments.value)
	end)

	eventsFolder.color.OnClientEvent:Connect(function(arguments)
		setColor(arguments.color)
	end)

	eventsFolder.spot.OnClientEvent:Connect(function(mode)
		setBeam(mode)
	end)

	eventsFolder.position.OnClientEvent:Connect(function(positionIndex)
		setPosition(positionIndex)
	end)

	eventsFolder.zoom.OnClientEvent:Connect(function(zoomValue)
		setZoom(zoomValue)
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

		module.instances[instanceIdentifier] = {
			storage = {
				effects = {}
			}
		}

		FixtureController.new(instanceIdentifier, module.fixtureData.name)
		EffectController.new(instanceIdentifier, module.fixtureData.name)

		module:createInstances(instanceIdentifier)
		module:listenToEvents(instanceIdentifier)

	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

