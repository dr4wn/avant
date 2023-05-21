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

local statuses = {
	[true] = 0.25,
	[false] = 0,
}

local pyro = {
	["Top Fire"] = function(folder, status)
		for _, fire in pairs(folder:GetChildren()) do
			fire.ParticleEmitter.Enabled = status
		end
	end,
	["Flames"] = function(folder, status)
		for _, fire in pairs(folder:GetChildren()) do
			fire.ParticleEmitter.Enabled = status
			TweenService:Create(fire.PointLight, TweenInfo.new(0.25), { Brightness = statuses[status] }):Play()
		end
	end,
	["Co2"] = function(folder, status)
		for _, smoke in pairs(folder:GetChildren()) do
			smoke.ParticleEmitter.Enabled = status
			smoke.ParticleEmitter2.Enabled = status
		end
	end,
	["Confetti"] = function(folder, status)
		for _, confetti in pairs(folder:GetChildren()) do
			confetti.P1.Enabled = status
			confetti.P3.Enabled = status
		end
	end,
	["Sparks"] = function(folder, status)
		for _, spark in pairs(folder:GetChildren()) do
			spark.ParticleEmitter.Enabled = status
			spark.ParticleEmitter2.Enabled = status
			spark.ParticleEmitter3.Enabled = status
			TweenService:Create(spark.PointLight, TweenInfo.new(0.25), { Brightness = statuses[status] }):Play()
		end
	end,
}

local cryo = {
	["FWC"] = function(folder)
		for _,firework in pairs(folder:GetChildren()) do
			task.spawn(function()
				firework.ParticleEmitter1.Enabled = true
				firework.ParticleEmitter2.Enabled = true
				task.wait(.2)
				firework.ParticleEmitter1.Enabled = false
				firework.ParticleEmitter2.Enabled = false
			end)
		end
	end,
	["FWC31"] = function(folder)
		for _,firework in pairs(folder:GetChildren()) do
			task.spawn(function()
				firework.ParticleEmitter1.Enabled = true
				firework.ParticleEmitter2.Enabled = true
				firework.ParticleEmitter3.Enabled = true
				task.wait(.2)
				firework.ParticleEmitter1.Enabled = false
				firework.ParticleEmitter2.Enabled = false
				firework.ParticleEmitter3.Enabled = false
			end)
		end
	end,
	["FWS"] = function(folder)
		for _,firework in pairs(folder:GetChildren()) do
			task.spawn(function()
				firework.ParticleEmitter1.Enabled = true
				firework.ParticleEmitter2.Enabled = true
				firework.ParticleEmitter3.Enabled = true
				task.wait(.2)
				firework.ParticleEmitter1.Enabled = false
				firework.ParticleEmitter2.Enabled = false
				firework.ParticleEmitter3.Enabled = false
			end)
		end
	end,
	["FWSPR"] = function(folder, status)
		for _,firework in pairs(folder:GetDescendants()) do
			if firework:IsA("ParticleEmitter") then
				task.spawn(function()
					firework.Enabled = true
					task.wait(.2)
					firework.Enabled = false
				end)
			end
		end
	end,
}

function module:listenToEvents(identifier)
	local eventsFolder = Util:getRemoteFolder(identifier, module.fixtureData.name)
	local lightFolder = CollectionService:GetTagged("[Avant v3] Lights "..identifier)[1]

	eventsFolder.pyroEvent.OnClientEvent:Connect(function(arguments)
		pyro[arguments.pyro](lightFolder.Pyro[arguments.pyro], arguments.status)
	end)

	eventsFolder.cryoEvent.OnClientEvent:Connect(function(arguments)

		cryo[arguments.cryo](lightFolder.Pyro.Fireworks[arguments.cryo], arguments.status)
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
	end
end

module.setup(
	HttpService:JSONDecode(instancesAttribute)
)

