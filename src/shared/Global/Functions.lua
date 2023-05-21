-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
function evenChecker(num)
	return tonumber(num) % 2 == 0
end

function setSpeed(fixtures, speed)
	for _, light in pairs(fixtures) do
		light.instances.pan.MaxVelocity = speed
		light.instances.tilt.MaxVelocity = speed
		light.instances.gobo.MaxVelocity = speed
	end
end

function setIntensity(fixtures, value, mode)
	if mode == "beam" then
		for _, light in pairs(fixtures) do
			light:setValue("Intensity", { regularBeam = true, value = value })
		end
	elseif mode == "gobo" then
		for _, light in pairs(fixtures) do
			light:setValue("Intensity", { goboBeam = true, value = value })
		end
	end
end

return {
	["lightOn"] = function(fixtures)
		setIntensity(fixtures, 1, "beam")
	end,
	["lightOff"] = function(fixtures)
		setIntensity(fixtures, 0, "beam")
	end,
	["lightFadeIn"] = function(fixtures)
		coroutine.wrap(function()
			for increment = 0, 1,.25 do
				setIntensity(fixtures, increment, "beam")
				wait(0.025)
			end
		end)()
	end,
	["lightFadeOut"] = function(fixtures)
		coroutine.wrap(function()
			for increment = 1, 0, -.25 do
				setIntensity(fixtures, increment, "beam")
				wait(0.025)
			end
		end)()
	end,
	["goboOn"] = function(fixtures)
		setIntensity(fixtures, 1, "gobo")
	end,
	["goboOff"] = function(fixtures)
		setIntensity(fixtures, 0, "gobo")
	end,
	["goboFadeIn"] = function(fixtures)
		coroutine.wrap(function()
			for increment = 0, 1, .25 do
				setIntensity(fixtures, increment, "gobo")
				wait(0.025)
			end
		end)()
	end,
	["goboFadeOut"] = function(fixtures)
		coroutine.wrap(function()
			for increment = 1, 0, -.25 do
				setIntensity(fixtures, increment, "gobo")
				wait(0.025)
			end
		end)()
	end,

	["speedSlow"] = function(fixtures)
		setSpeed(fixtures, 0.01)
	end,
	["speedMedium"] = function(fixtures)
		setSpeed(fixtures, 0.05)
	end,
	["speedFast"] = function(fixtures)
		setSpeed(fixtures, 0.1)
	end,

	["oddPower"] = function(fixtures)
		for _, light in pairs(fixtures) do
			if not evenChecker(tonumber(light.personality.name)) then
				light:setValue("Intensity", { regularBeam = true, value = 0 })
				continue
			end
			light:setValue("Intensity", { regularBeam = true, value = 1 })
		end
	end,
	["evenPower"] = function(fixtures)
		for _, light in pairs(fixtures) do
			if not evenChecker(tonumber(light.personality.name)) then
				light:setValue("Intensity", { regularBeam = true, value = 1 })
				continue
			end
			light:setValue("Intensity", { regularBeam = true, value = 0 })
		end
	end,
	["evenGoboPower"] = function(fixtures)
		for _, light in pairs(fixtures) do
			if not evenChecker(tonumber(light.personality.name)) then
				light:setValue("Intensity", { goboBeam = true, value = 0 })
				continue
			end
			light:setValue("Intensity", { goboBeam = true, value = 1 })
		end
	end,
	["oddGoboPower"] = function(fixtures)
		for _, light in pairs(fixtures) do
			if not evenChecker(tonumber(light.personality.name)) then
				light:setValue("Intensity", { goboBeam = true, value = 1 })
				continue
			end
			light:setValue("Intensity", { goboBeam = true, value = 0 })
		end
	end,

	["chaseOut"] = function(fixtures)

	end,
	["chaseOutGobo"] = function(fixtures)

	end,
}