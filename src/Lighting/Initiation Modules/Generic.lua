-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {
	fixtureData = {
		name = "Generic",
		mode = "Extended"
	},
	instances = {}
}

local remoteEvents = ReplicatedStorage:WaitForChild("Remote Events")
local lightingFolder = ServerScriptService:WaitForChild("Lighting")
local fixedClientFolder = lightingFolder["Client Folders"][module.fixtureData.name]

local function isAdmin(user, array)
	if (not array) or (not user) then return false end
	return array[user.Name]
end

function module.listenToEvents(identifier)
	local eventsFolder = remoteEvents[identifier][module.fixtureData.name]
	local consoleInstance = module.instances[identifier]

	local storage = consoleInstance.storage
	local administrators = consoleInstance.administrators

	eventsFolder.test_event.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		local largeTestMsg = table.concat({
			"",
			"[SERVER]",
			"",
			"Avant v2.5 Console",
			"Debug Information",
			"\"Generic\" Module",
			"Stage: \""..tostring(consoleInstance.stage).."\" ",
			"",
			"Event Gotten, \"arguments\" below:",
			if arguments ~= nil then tostring(table.concat(arguments, "\n")) else "none gotten!",
			string.format("Player Name: %s, Player UserId: %s", player.Name, player.UserId),
			""
		}, "\n")
		warn(largeTestMsg)
	end)

	eventsFolder.init.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		eventsFolder.init:FireAllClients(arguments)
	end)
	eventsFolder.dimmer.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		storage.dimmerValue = arguments.value
		eventsFolder.dimmer:FireAllClients(arguments)
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
			dimmerValue = 0,
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