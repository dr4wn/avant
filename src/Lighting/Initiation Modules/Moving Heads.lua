-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {
	fixtureData = {
		name = "Moving Heads",
		mode = "Extended"
	},
	effectData = {
		["Random Strobe"] = Enum.KeyCode.Two,
		["Random Fade"] = Enum.KeyCode.Two,
		["Strobe"] = Enum.KeyCode.Two,
		["Gobo Random Strobe"] = Enum.KeyCode.Six,
		["Gobo Random Fade"] = Enum.KeyCode.Six,
		["Gobo Strobe"] = Enum.KeyCode.Six,
		["Effect_1"] = Enum.KeyCode.Two,
		["Effect_2"] = Enum.KeyCode.Two,
		["Effect_3"] = Enum.KeyCode.Two,
		["Effect_4"] = Enum.KeyCode.Two,
		["Effect_5"] = Enum.KeyCode.Six,
		["Effect_6"] = Enum.KeyCode.Six,
		["Effect_7"] = Enum.KeyCode.Six,
		["Effect_8"] = Enum.KeyCode.Six,
	},
	instances = {},
	customAdmins = { -- people assigned to what stage
		[1110174992] = "STAGE", -- Drawn
	}
}

local remoteEvents = ReplicatedStorage:WaitForChild("Remote Events")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local lightingFolder = ServerScriptService:WaitForChild("Lighting")
local fixedClientFolder = lightingFolder["Client Folders"][module.fixtureData.name]

local Keybinds = require(sharedFolder.Global.Keybinds)

local function isAdmin(user, array)
	if (not array) or (not user) then return false end
	return array[user.Name] or array[user.UserId]
end

function module.listenToEvents(identifier)
	local eventsFolder = remoteEvents[identifier][module.fixtureData.name]
	local consoleInstance = module.instances[identifier]

	local storage = consoleInstance.storage
	local administrators = consoleInstance.administrators

	eventsFolder.input.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end
		local keybind = Keybinds[arguments.key]
		storage.lightOn = keybind.setLight or false
		eventsFolder[keybind.eventName]:FireAllClients({
			keybind = arguments.key
		})
	end)

	eventsFolder.effect.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end


		for _, effectTable in pairs(arguments.effects) do
			if effectTable.on then
				storage.effects[effectTable.effectName] = effectTable.buttonReference
			else
				storage.effects[effectTable.effectName] = nil

				if module.effectData[effectTable.effectName] then
					storage.lightOn = arguments.lightOn or false
					eventsFolder.dimmer:FireAllClients({
						keybind = module.effectData[effectTable.effectName]
					})
				end
			end
		end
		eventsFolder.effect:FireAllClients(arguments)
	end)

	eventsFolder.color.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		pcall(function()
			storage.color = arguments.color
		end)

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

	eventsFolder.zoom.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		local zoomValue = tonumber(arguments.zoomValue) or 35
		storage.zoomValue = zoomValue
		eventsFolder.zoom:FireAllClients(zoomValue)
	end)

	eventsFolder.position.OnServerEvent:Connect(function(player, arguments)
		if not isAdmin(player, administrators) then return end

		local posIndex = tonumber(arguments.positionIndex) or 1
		storage.positionIndex = posIndex
		eventsFolder.position:FireAllClients(posIndex)
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
			bpm = { dimmer = 60, movement = 60, color = 60 },
			effects = {},
			spotOn = true,
			lightOn = false,
			positionIndex = 1,
			zoomValue = 50
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
		if module.customAdmins[player.UserId] == module.instances[consoleIdentifier].stage then
			local cloned = fixedClientFolder.key:Clone()
			cloned:SetAttribute("identifier", consoleIdentifier)
			cloned.Parent = fixedStorageFolder
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