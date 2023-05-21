-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {
	fixtureData = {
		name = "LED",
		mode = "Extended"
	},
	instances = {}
}

local remoteEvents = ReplicatedStorage:WaitForChild("Remote Events")
local lightingFolder = ServerScriptService:WaitForChild("Lighting")
local fixedClientFolder = lightingFolder["Client Folders"][module.fixtureData.name]

local function isAdmin(user, array)
	if (not array) or (not user) then return false end
	return array[user.Name] or array[user.UserId]
end

function module.listenToEvents(identifier)
	local eventsFolder = remoteEvents[identifier][module.fixtureData.name]
	local consoleInstance = module.instances[identifier]

	local storage = consoleInstance.storage
	local administrators = consoleInstance.administrators

	eventsFolder.dimmer.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		consoleInstance.storage.lightOn = arguments.lightOn or false
		eventsFolder.dimmer:FireAllClients(arguments)
	end)

	eventsFolder.effect.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		for _, effectTable in pairs(arguments.effects) do
			if effectTable.on then
				storage.effects[effectTable.effectName] = effectTable.buttonReference
			else
				storage.effects[effectTable.effectName] = nil

				eventsFolder.dimmer:FireAllClients({
					staticFunction = "Power",
					dimmerButton = "MouseButton2Down",
					lightOn = false
				})
			end
		end
		eventsFolder.effect:FireAllClients(arguments)
	end)

	eventsFolder.color.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		local success, message = pcall(function()
			storage.color = arguments.color
		end)

		if not success then
			warn(success, "\n", message, "\n", consoleInstance.color, "\n", arguments.color)
		end

		eventsFolder.color:FireAllClients({ color = storage.color })
	end)

	eventsFolder.bpm.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		local newName = string.lower(arguments.valueName.Name)
		storage.bpm[newName] = arguments.value

		eventsFolder.bpm:FireAllClients({ valueName = newName, value = arguments.value })
	end)

	eventsFolder.spot.OnServerEvent:Connect(function(player, mode)
		if not isAdmin(player, administrators) then return end

		storage.spotOn = mode
		eventsFolder.spot:FireAllClients(mode)
	end)
end

function module.load(arguments)
	module.instances[arguments.consoleIdentifier] = {
		administrators = arguments.administrators,
		stage = arguments.stageName,
		console = arguments.console,
		events = arguments.events,
		lights = arguments.lights,
		storage = {
			color = Color3.new(1, 1, 1),
			effects = {},
			bpm = { dimmer = 60, movement = 60, color = 60 },
			spotOn = true,
			lightOn = false,
		},
	}
end

function module.setupClient(arguments)
	local player = arguments.player
	local consoleIdentifier = arguments.identifier
	local isAdmin = arguments.isAdmin

	local playerGui  = player.PlayerGui

	local screenScriptStorage = playerGui["Avant v3 Lighting Holster"]
	local fixedStorageFolder = screenScriptStorage[module.fixtureData.name]
	local eventsFolder = remoteEvents[consoleIdentifier][module.fixtureData.name]

	if isAdmin then
		if not fixedStorageFolder:FindFirstChild(fixedClientFolder.admin.Name) then
			fixedClientFolder.admin:Clone().Parent = fixedStorageFolder
		end
	end

	if not fixedStorageFolder:FindFirstChild(fixedClientFolder.main.Name) then
		fixedClientFolder.main:Clone().Parent = fixedStorageFolder
	end

	eventsFolder.replicator:FireClient(player, { storage = module.instances[consoleIdentifier].storage })
end

function module.returnFixtureData(path)
	if not path then return module end

	local success = pcall(function()
		return module[path]
	end)
	if not success then return module end
end

return module