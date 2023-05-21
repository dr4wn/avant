-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ServerScriptService = game:GetService("ServerScriptService")

if script.Parent.Parent ~= ServerScriptService then
	return warn(table.concat({
		"",
		"------------------",
		"Avant's \"Lighting\" folder is not parented to \"ServerScriptService\". ",
		"The console will not run unless so.",
		"------------------",
	}, "\n"))
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local lightingFolder = ServerScriptService:WaitForChild("Lighting")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local initModules = lightingFolder["Initiation Modules"]

local LuaAdditions = require(7564836781)
local Events = require(lightingFolder.Extra.events)
local Util = require(sharedFolder.Global.Util)

local avant = {}
local instanceValues = {}
local allAdmins = {}
avant.stages = {}

local avantLightingHolster = Util:createScreenGui("Avant v3 Lighting Holster", script)
local replicatedInterfaces = Util:createFolder("Interfaces", ReplicatedStorage)
local remoteFolder = Util:createFolder("Remote Events", ReplicatedStorage)
local eventsFolder = game.ReplicatedStorage:WaitForChild("Remote Events")
local interfaces = lightingFolder.Interfaces

function avant.new(instances)
	for _, consoleInstance in pairs(instances) do
		local isConsolePresent = LuaAdditions.Table.find(avant.stages, function(stageName)
			return stageName == consoleInstance.stage
		end)

		if isConsolePresent then continue end
		local consoleIdentifier = HttpService:GenerateGUID(false)
		instanceValues[#instanceValues + 1] = consoleIdentifier

		avant.stages[consoleIdentifier] = {
			administrators = consoleInstance.administrators,
			modules = consoleInstance.modules,
			stage = consoleInstance.stage,
			identifier = consoleIdentifier
		}

		local consoleInterfaces = Util:createFolder(consoleIdentifier, replicatedInterfaces)
		local consoleRemoteFolder = Util:createFolder(consoleIdentifier, eventsFolder)

		CollectionService:AddTag(consoleInstance.console, "[Avant v3] Console "..consoleIdentifier)
		CollectionService:AddTag(consoleInstance.lights, "[Avant v3] Lights "..consoleIdentifier)

		local startedLighting = {}

		for user, _ in pairs(consoleInstance.administrators) do
			allAdmins[user] = true
		end

		for _, module in pairs(consoleInstance.modules) do
			local requiredFile = require(initModules[module]) or require(initModules.Generic)

			if not avantLightingHolster:FindFirstChild(requiredFile.fixtureData.name) then
				local folder = Util:createFolder(requiredFile.fixtureData.name)
				folder.Parent = avantLightingHolster
			end

			requiredFile.load({
				console = consoleInstance.console,
				lights = consoleInstance.lights,
				stageName = consoleInstance.stage,
				administrators = consoleInstance.administrators,
				events = Events[module],
				consoleIdentifier = consoleIdentifier,
			})

			local moduleFolder = Util:createFolder(requiredFile.fixtureData.name, consoleRemoteFolder)
			Util:loader(Events[requiredFile.fixtureData.name], moduleFolder)

			requiredFile.listenToEvents(consoleIdentifier)

			startedLighting[#startedLighting + 1] = requiredFile.fixtureData.name
			interfaces[requiredFile.fixtureData.name]:Clone().Parent = consoleInterfaces
		end
		consoleInstance.console:SetAttribute("startedLighting", HttpService:JSONEncode(startedLighting))
	end
end

function avant.setup(player)
	local playerGui = player:WaitForChild("PlayerGui", 10)
	if not playerGui then return player:Kick("failed to initialize") end

	avantLightingHolster:SetAttribute("consoleInstances", HttpService:JSONEncode(instanceValues))
	if not lightingFolder.selector:GetAttribute("consoleInstances") then
		lightingFolder.selector:SetAttribute("consoleInstances", HttpService:JSONEncode(instanceValues))
	end

	if not playerGui:FindFirstChild("Avant v3 Lighting Holster") then
		avantLightingHolster:Clone().Parent = playerGui
	end

	if not playerGui["Avant v3 Lighting Holster"]:FindFirstChild("selector") then
		if allAdmins[player.Name] then
			lightingFolder.selector:Clone().Parent = playerGui["Avant v3 Lighting Holster"]
		end
	end

	for _, instance in pairs(avant.stages) do
		local isAdmin = avant.stages[instance.identifier].administrators[player.Name] or false
		for _, module in pairs(instance.modules) do
			local requiredFile = require(initModules[module]) or require(initModules.Generic)
			requiredFile.setupClient({ player = player, identifier = instance.identifier, isAdmin = isAdmin })
		end
	end
end

Players.PlayerAdded:Connect(avant.setup)

return avant