-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local TweenService = game:GetService("TweenService")

local Fixture = {}
Fixture.__index = Fixture

local supportedTypes = {
	["Blinders"] = {
		["Intensity"] = true,
	},
	["Moving Heads"] = {
		["Intensity"] = true,
		["Position"] = true,
		["Color"] = true,
		["Zoom"] = true
	},
	["Magic Dots"] = {
		["Intensity"] = true,
		["Position"] = true,
		["Color"] = true,
		["Zoom"] = true
	},
	["LED Panel"] = {
		["Intensity"] = true,
		["Color"] = true,
	},
	["Washes"] = {
		["Intensity"] = true,
		["Position"] = true,
		["Color"] = true,
		["Zoom"] = true
	},
	["LED Bars"] = {
		["Intensity"] = true,
		["Color"] = true,
	},
	["LED"] = {
		["Intensity"] = true,
		["Color"] = true,
	},
	["Pars"] = {
		["Intensity"] = true,
		["Color"] = true,
	},
	["Ambience"] = {
		["Intensity"] = true,
		["Color"] = true,
	},
}

local functionalities = {
	["Washes"] = {
		["Intensity"] = function(self, data)
			self.instances.lens.Transparency = data.value
			self.instances.spotlight.Brightness = (1 - data.value) * self.extras.brightnessMultiplier
			self.instances.beam.Transparency = NumberSequence.new(data.value)
		end,
		["Position"] = function(self, data)
			if data.pan then
				self.instances.pan.DesiredAngle = data.pan
			end
			if data.tilt then
				self.instances.tilt.DesiredAngle = data.tilt
			end
		end,
		["Color"] = function(self, data)
			self.instances.lens.Color = data.value
			self.instances.spotlight.Color = data.value
			self.instances.beam.Color = ColorSequence.new(data.value)
		end,
		["Zoom"] = function(self, data)
			TweenService:Create(self.instances.beam, TweenInfo.new(0.5), { Width0 = data.value }):Play()
		end
	},
	["Moving Heads"] = {
		["Intensity"] = function(self, data)
			self.instances.lens.Transparency = 1 - data.value
			self.instances.spotlight.Brightness = (data.value) * self.extras.brightnessMultiplier

			if data.regularBeam then
				self.instances.beam.Transparency = NumberSequence.new(1 - data.value, 1)
			end

			if data.goboBeam then
				for _, gobo in pairs(self.instances.gobos) do
					gobo.Transparency = NumberSequence.new(1 - data.value, 1)
				end
			end
		end,
		["Position"] = function(self, data)
			if data.pan then
				self.instances.pan.DesiredAngle = data.pan
			end
			if data.tilt then
				self.instances.tilt.DesiredAngle = data.tilt
			end
			if data.gobo then
				self.instances.gobo.DesiredAngle = data.gobo
			end
		end,
		["Color"] = function(self, data)
			self.instances.lens.Color = data.value
			self.instances.spotlight.Color = data.value
			self.instances.beam.Color = ColorSequence.new(data.value)

			for _, gobo in pairs(self.instances.gobos) do
				gobo.Color = ColorSequence.new(data.value)
			end
		end,
		["Zoom"] = function(self, data)
			TweenService:Create(self.instances.beam, TweenInfo.new(0.5), { Width1 = data.value }):Play()
		end
	},
	["Blinders"] = {
		["Intensity"] = function(self, data)
			self.instances.lens.Transparency =  1 - data.value
			self.instances.spotlight.Brightness = (data.value) * self.extras.brightnessMultiplier
		end,
	},
	["Ambience"] = {
		["Intensity"] = function(self, data)
			self.instances.lens.Transparency = data.value
			self.instances.spotlight.Brightness = (1 - data.value) * self.extras.brightnessMultiplier
		end,
		["Color"] = function(self, data)
			self.instances.lens.Color = data.value
			self.instances.spotlight.Color = data.value
		end,
	},
	["LED"] = {
		["Intensity"] = function(self, data)
			self.instances.led.BackgroundTransparency = data.value
			self.instances.spotlight.Brightness = (1 - data.value) * self.extras.brightnessMultiplier
		end,
		["Color"] = function(self, data)
			self.instances.led.BackgroundColor3 = data.value
			self.instances.spotlight.Color = data.value
		end,
	},
	["Pars"] = {
		["Intensity"] = function(self, data)
			self.instances.lens.Transparency = data.value
			self.instances.spotlight.Brightness = (1 - data.value) * self.extras.brightnessMultiplier
			self.instances.beam.Transparency = NumberSequence.new(data.value)
		end,
		["Color"] = function(self, data)
			self.instances.lens.Color = data.value
			self.instances.spotlight.Color = data.value
			self.instances.beam.Color = ColorSequence.new(data.value)
		end,
	},
	["LED Bars"] = {
		["Intensity"] = function(self, data)
			local pixel = if self.instances.pixels[self.pixel] then self.instances.pixels[self.pixel] else self.instances.pixels[1]
			local spotlight = pixel.SpotLight

			pixel.Transparency = data.value
			spotlight.Brightness = (1 - data.value) * self.extras.brightnessMultiplier
		end,
		["Color"] = function(self, data)
			local pixel = if self.instances.pixels[self.pixel] then self.instances.pixels[self.pixel] else self.instances.pixels[1]
			local spotlight = pixel.SpotLight

			pixel.Color = data.value
			spotlight.Color = data.data
		end,
	},
	["Lasers"] = {
		["Intensity"] = function(self, data)
			local laser = if self.instances.lasers[data.pixel] then self.instances.lasers[data.pixel] else self.instances.lasers[1]
			laser.Transparency = NumberSequence.new(data.value, 1)
		end,
		["Position"] = function(self, data)
			local attachment = if self.instances.attachments[data.pixel] then self.instances.attachments[data.pixel] else self.instances.attachments[1]
			attachment.Position = Vector3.new()
		end,
		["Color"] = function(self, data)
			local laser = if self.instances.laser[data.pixel] then self.instances.laser[data.pixel] else self.instances.laser[1]
			laser.Color = ColorSequence.new(data.color)
		end,
	}
}

function Fixture.new(data)
	local self = {
		personality = data.personality,
		instances = data.instances,
		extras = data.extras
	}
	return setmetatable(self, Fixture)
end

function Fixture:setValue(attribute, data)
	local featureSupported = supportedTypes[self.personality.fixture][attribute]
	local sanityCheck = functionalities[self.personality.fixture][attribute]
	local fixtureEnabled = self.personality.enabled

	if not fixtureEnabled then return end
	if featureSupported and sanityCheck then
		functionalities[self.personality.fixture][attribute](self, data)
	end
end

return Fixture