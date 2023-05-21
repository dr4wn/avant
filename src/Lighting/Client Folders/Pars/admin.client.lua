-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local Util = require(ReplicatedStorage.Shared.Global.Util)

local module = {
	fixtureData = {
		name = "Pars",
		mode = "Extended"
	},
	instances = {}
}

function effectSet(arguments, identifier)
	local consoleInstance = module.instances[identifier]
	local storage = consoleInstance.storage.effects

	local info = if arguments.on then
		{ color = Color3.new(0, 1, 0), data = { effectName = arguments.effectName, buttonReference = arguments.buttonReference, effectType = "Nothing!"} }
	else
		{ color = Color3.new(1, 0, 0), data = nil }

	TweenService:Create(arguments.buttonReference.Frame, TweenInfo.new(0.25), { BackgroundColor3 = info.color }):Play()
	storage[arguments.effectName] = info.data
end

function module:listenToEvents(identifier)
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)

	local function effectGateway(arguments, identifier)
		for _, effectTable in pairs(arguments.effects) do
			local data = { on = effectTable.on, effectName = effectTable.effectName, buttonReference = effectTable.buttonReference, effectType = "Something" }-- account for how this looks on the admin perspective
			effectSet(data, identifier)
		end
	end

	eventsFolder.effect.OnClientEvent:Connect(function(arguments)
		effectGateway(arguments, identifier)
	end)

	eventsFolder.data.Event:Connect(function(arguments)
		effectGateway(arguments, identifier)
	end)
end

function module:createButtons(identifier)
	local interfaceLoc = Util:getInterfaceFolder(identifier)[module.fixtureData.name]
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)
	local interface = interfaceLoc
	local holster = interface.Holster

	local storage = module.instances[identifier].storage

	local frames = {
		frame1 = holster["[Frame#1] Main"],
		frame2 = holster["[Frame#2] Colors"],
		frame3 = holster["[Frame#3] Faders"]
	}

	for _, button in pairs(frames.frame1:GetChildren()) do
		if not button:IsA("TextButton") then continue end
		if button:GetAttribute("buttonType") ~= "effect" then continue end

		button.MouseButton1Click:Connect(function()
			local codeEffectName = button:GetAttribute("effectName")
			if not codeEffectName then return end

			local on = if storage.effects[codeEffectName] then false else true

			eventsFolder.effect:FireServer({
				effects = {
					{
						effectName = codeEffectName,
						buttonReference = button,
						on = on
					}
				}
			})
		end)
	end

	for _, faderFrame in pairs(frames.frame3:GetChildren()) do
		if not faderFrame:IsA("Frame") then continue end
		
		Util:generateFader({
			sensorPos = faderFrame.Fader.AbsolutePosition,
			sensorSize = faderFrame.Fader.AbsoluteSize,
			frame = faderFrame.Fader,
			connection = function(args)
				eventsFolder.bpm:FireServer({
					valueName = faderFrame,
					value = args
				})
			end,
			faderInstance = faderFrame.Fader.Frame
		})
	end

	Util:generateColorPicker({
		sensor = frames.frame2["Color Frame"].Picker.Sensor,
		pointer = frames.frame2["Color Frame"].Picker.Pointer,
		indicator = frames.frame2["Color Frame"].Frame,
		connection = function(args)
			eventsFolder.color:FireServer({
				color = args
			})
		end
	})

	for _, dimmerContainer in pairs(Util:returnButtonInfo(frames.frame1, "dimmerButtons")) do
		if not dimmerContainer.button:IsA("TextButton") then continue end

		for _, buttonType in pairs(dimmerContainer["buttonToggle"]) do
			local data = {
				staticFunction = dimmerContainer.button.Name,
				dimmerButton = buttonType[1],
				lightOn = buttonType[2]
			}
			dimmerContainer.button[buttonType[1]]:Connect(function()
				eventsFolder.dimmer:FireServer(data)
			end)
		end
	end

	frames.frame1["Toggle SL"].MouseButton1Down:Connect(function()
		eventsFolder.spot:FireServer(true)
	end)

	frames.frame1["Toggle SL"].MouseButton2Down:Connect(function()
		eventsFolder.spot:FireServer(false)
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

		module.instances[instanceIdentifier] = {
			storage = {
				effects = {}
			}
		}

		module:listenToEvents(instanceIdentifier)
		module:createButtons(instanceIdentifier)
	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

