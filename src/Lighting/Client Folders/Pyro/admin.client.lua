-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local screenHolster = script.Parent.Parent
local instancesAttribute = screenHolster:GetAttribute("consoleInstances")
if not instancesAttribute then return end

local Util = require(ReplicatedStorage.Shared.Global.Util)

local module = {
	fixtureData = {
		name = "Pyro",
		mode = "Extended"
	},
	instances = {}
}



function module:listenToEvents(identifier)
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)

end

function module:createButtons(identifier)
	local interfaceLoc = Util:getInterfaceFolder(identifier)[module.fixtureData.name]
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)
	local interface = interfaceLoc
	local holster = interface.Holster

	local frames = {
		frame1 = holster["[Frame#1] Main"],
		frame2 = holster["[Frame#2]"],
		frame3 = holster["[Frame#3] Faders"]
	}

	local lightFolder = CollectionService:GetTagged("[Avant v3] Lights "..identifier)[1]
	
	for _, pyroFolder in pairs(lightFolder.Pyro:GetChildren()) do
		if pyroFolder.Name == "Fireworks" or pyroFolder.Name == "Haze" then continue end
		local template = frames.frame1.Template:Clone()
		template.Visible = true
		template.Parent = frames.frame1
		template.Name = pyroFolder.Name
		template.Text = pyroFolder.Name
		template.MouseButton1Down:Connect(function()
			eventsFolder.pyroEvent:FireServer({
				status = true,
				pyro = pyroFolder.Name
			})
		end)

		template.MouseButton1Up:Connect(function()
			eventsFolder.pyroEvent:FireServer({
				status = false,
				pyro = pyroFolder.Name
			})
		end)
	end

	for _, pyroFolder in pairs(lightFolder.Pyro:GetChildren()) do
		if pyroFolder.Name == "Fireworks" then
			for _, f in pairs(pyroFolder:GetChildren()) do
				local template = frames.frame1.Template:Clone()
				template.Visible = true
				template.Parent = frames.frame2
				template.Name = f.Name
				template.Text = f.Name
				template.MouseButton1Down:Connect(function()
					eventsFolder.cryoEvent:FireServer({
						status = true,
						cryo = f.Name
					})
				end)
			end
		end
	end
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

