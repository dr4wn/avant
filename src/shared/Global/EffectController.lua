-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local LuaAdditions = require(Shared.LuaAdditions.MainModule)

local EffectController = {}
EffectController.__index = EffectController

function EffectController.new(identifier, name)
	if not EffectController[identifier] then
		EffectController[identifier] = {}
	end

	EffectController[identifier][name] = {}
end

function EffectController:Append(identifier, name, object)
	if not EffectController[identifier] then return warn("Group / Identifier does not exist.") end
	if (not name) or (not object)  then return end

	local array = EffectController[identifier][name]
	array[#array + 1] = object
end

function EffectController:Run(identifier, name, effectName)
	local effect = LuaAdditions.Table.find(EffectController[identifier][name], function(effect)
		return effectName == effect.personality.name
	end)

	if not effect then return end
	effect:start()
end

function EffectController:Stop(identifier, name, effectName)
	local effect = LuaAdditions.Table.find(EffectController[identifier][name], function(effect)
		return effectName == effect.personality.name
	end)

	if not effect then return end
	effect:stop()
end


return EffectController