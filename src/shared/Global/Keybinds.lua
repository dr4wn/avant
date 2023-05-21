-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
return {
	-- Dimmer Beam Functions

	[Enum.KeyCode.One] = {
		setLight = true,
		callbackName = "lightOn",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Two] = {
		setLight = false,
		callbackName = "lightOff",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Three] = {
		setLight = true,
		callbackName = "lightFadeIn",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Four] = {
		setLight = false,
		callbackName = "lightFadeOut",
		eventName = "dimmer",
	},

	-- Dimmer Gobo Functions

	[Enum.KeyCode.Five] = {
		setLight = true,
		callbackName = "goboOn",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Six] = {
		setLight = false,
		callbackName = "goboOff",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Seven] = {
		setLight = true,
		callbackName = "goboFadeIn",
		eventName = "dimmer",
	},
	[Enum.KeyCode.Eight] = {
		setLight = false,
		callbackName = "goboFadeOut",
		eventName = "dimmer",
	},

	-- Fixture Speed Functions

	[Enum.KeyCode.Q] = {
		callbackName = "speedSlow",
		eventName = "speed",
	},
	[Enum.KeyCode.E] = {
		callbackName = "speedMedium",
		eventName = "speed",
	},
	[Enum.KeyCode.R] = {
		callbackName = "speedFast",
		eventName = "speed",
	},

	-- Special Animations / Sequences

	[Enum.KeyCode.F] = {
		callbackName = "oddPower",
		eventName = "dimmer",
	},
	[Enum.KeyCode.G] = {
		callbackName = "evenPower",
		eventName = "dimmer",
	},
	[Enum.KeyCode.H] = {
		callbackName = "evenGoboPower",
		eventName = "dimmer",
	},
	[Enum.KeyCode.J] = {
		callbackName = "oddGoboPower",
		eventName = "dimmer",
	},

	-- Animation Chases

	[Enum.KeyCode.K] = {
		setLight = false,
		callbackName = "chaseOut",
		eventName = "dimmer",
	},
	[Enum.KeyCode.L] = {
		setLight = false,
		callbackName = "chaseOutGobo",
		eventName = "dimmer",
	},
}