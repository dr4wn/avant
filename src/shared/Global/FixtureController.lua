-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local LuaAdditions = require(Shared.LuaAdditions.MainModule)

local FixtureController = {}
FixtureController.__index = FixtureController

function FixtureController.new(identifier, name)
	if not FixtureController[identifier] then
		FixtureController[identifier] = {}
	end
	
	FixtureController[identifier][name] = {}
end

function FixtureController:Append(identifier, name, object)
	if not FixtureController[identifier] then return end
	if (not name) or (not object)  then return end

	local array = FixtureController[identifier][name]
	array[#array + 1] = object
end

function FixtureController:Get(identifier, name)
	if not FixtureController[identifier] then return end
	local success = pcall(function()
		table.sort(FixtureController[identifier][name], function(a, b)
			return tonumber(a.personality.name) > tonumber(b.personality.name)
		end)
	end)
	return FixtureController[identifier][name]
end


return FixtureController