-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
function evenChecker(num)
	return tonumber(num) % 2 == 0
end

local staticFunctions = {
	["Power"] = function(arguments)
		local lightUpdater = {
			["MouseButton1Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					light:setValue("Intensity", { value = 0 })
				end
			end,
			["MouseButton2Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					light:setValue("Intensity", { value = 1 })
				end
			end,
		}
		if not arguments.mouseButton then return end
		lightUpdater[arguments.mouseButton]()
	end,
	["Fade In"] = function(arguments)
		for _, light in pairs(arguments.fixtures) do
			task.spawn(function()
				for increment = 1, 0, -0.05 do
					light:setValue("Intensity", { value = increment })
					task.wait(0.03)
				end
			end)
		end
	end,
	["Fade Out"] = function(arguments)
		for _, light in pairs(arguments.fixtures) do
			task.spawn(function()
				for increment = 0, 1, 0.05 do
					light:setValue("Intensity", { value = increment })
					task.wait(0.03)
				end
				light:setValue("Intensity", { value = 1 })
			end)
		end
	end,
	["A^ - Pulse"] = function(arguments)
		local modes = {
			["MouseButton1Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					if not evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 0, 1, 0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
						light:setValue("Intensity", { value = 1 })
					end)
				end
			end,
			["MouseButton2Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					if evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 0, 1, 0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
						light:setValue("Intensity", { value = 1 })
					end)
				end
			end,
		}
		modes[arguments.mouseButton]()
	end,
	
	["B^ - Hold"] = function(arguments)
		local modes = {
			["MouseButton1Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					if evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 1, 0, -0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
					end)
				end
			end,
			["MouseButton2Down"] = function()
				for _, light in pairs(arguments.fixtures) do
					if not evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 1, 0, -0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
					end)
				end
			end,
			["MouseButton1Up"] = function()
				for _, light in pairs(arguments.fixtures) do
					if evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 0, 1, 0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
						light:setValue("Intensity", { value = 1 })
					end)
				end
			end,
			["MouseButton2Up"] = function()
				for _, light in pairs(arguments.fixtures) do
					if not evenChecker(light.personality.name) then continue end
					task.spawn(function()
						for increment = 0, 1, 0.05 do
							light:setValue("Intensity", { value = increment })
							task.wait(0.03)
						end
						light:setValue("Intensity", { value = 1 })
					end)
				end
			end,
		}
		modes[arguments.mouseButton]()
	end,
}

return staticFunctions