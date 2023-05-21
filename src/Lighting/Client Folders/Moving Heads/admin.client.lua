-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local sharedFolder = ReplicatedStorage.Shared

local Util = require(ReplicatedStorage.Shared.Global.Util)
local module = {
	fixtureData = {
		name = "Moving Heads",
		mode = "Extended"
	},
	instances = {}
}

local Positions = require(sharedFolder.Positions[module.fixtureData.name])

local function effectSet(arguments, identifier)
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
			local data = { on = effectTable.on, effectName = effectTable.effectName, buttonReference = effectTable.buttonReference, effectType = "Something" }
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
		frame3 = holster["[Frame#3] Faders"],
		bezel = holster["Bezel"],
		positions = holster["[Frame#1.1] Positions"],
		zoom = holster["[Frame#1.2] Zoom"]
	}

	for _, button in pairs(frames.frame1:GetChildren()) do
		if button:GetAttribute("buttonType") ~= "effect" then continue end
		if not button:IsA("TextButton") then continue end

		button.MouseButton1Click:Connect(function()
			local codeEffectName = button:GetAttribute("effectName")
			if not codeEffectName then return end

			local on = if storage.effects[codeEffectName] then false else true

			eventsFolder.effect:FireServer({
				effects = {{
					effectName = codeEffectName,
					buttonReference = button,
					on = on
				}}
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

	for positionIndex, positionData in pairs(Positions) do
		local clone = frames.positions.template:Clone()
		clone.Text = "Pos: "..positionIndex
		clone.Visible = true
		clone.Parent = frames.positions

		clone.MouseButton1Click:Connect(function()
			eventsFolder.position:FireServer({ positionIndex = positionIndex })
		end)
	end

	for _, zoomButton in pairs(frames.zoom:GetChildren()) do
		if not zoomButton:IsA("TextButton") then continue end

		local attribute = zoomButton:GetAttribute("zoomValue") or 65
		zoomButton.MouseButton1Click:Connect(function()
			eventsFolder.zoom:FireServer({ zoomValue = attribute })
		end)
	end

	frames.frame1["Toggle SL"].MouseButton1Down:Connect(function()
		eventsFolder.spot:FireServer(true)
	end)

	frames.frame1["Toggle SL"].MouseButton2Down:Connect(function()
		eventsFolder.spot:FireServer(false)
	end)

	frames.bezel.Home.MouseButton1Click:Connect(function()
		frames.frame1.Visible = true
		frames.positions.Visible = false
		frames.zoom.Visible = false
	end)

	frames.bezel.Positions.MouseButton1Click:Connect(function()
		frames.frame1.Visible = false
		frames.positions.Visible = true
		frames.zoom.Visible = false
	end)

	frames.bezel.Zoom.MouseButton1Click:Connect(function()
		frames.frame1.Visible = false
		frames.positions.Visible = false
		frames.zoom.Visible = true
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

