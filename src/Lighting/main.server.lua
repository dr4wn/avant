-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ServerScriptService = game:GetService("ServerScriptService")
local lightingFolder = ServerScriptService:WaitForChild("Lighting")

local avant = require(lightingFolder.avant)

--[[
	Avant Lighting System
	Created by @draaawn | drawn#0001
	Licensed to friends, outer use is not permitted.
	DM For help, friends :)
]]

local ALL_MODULES = {
	"Generic",
	"Blinders",
	"Pars",
	"Ambience",
	"LED",
	"Washes",
	"Moving Heads",
	"Pyro"
}

--[[

	HOW TO SETUP AVANT:

	This console works straight out of the box if you do the following:
	- move the "Lighting" folder to ServerScriptService
	- move the "Shared" folder to ReplicatedStorage
	- configure your name in the "administrators" table below.

	1) Configure the "admins" table by adding your name, Example:
	["this_guy"] = true, <-- If you want to add more people after another
	make sure to add a comma

	2) Create the stage name or whatever it's called. This console was made
	for multiple instances being run at once but it can also just run one if
	that's all you'd like. If you are going to be using moving heads only one
	person can use them unless you find the identifier and give another person
	the script (Which is fairly simple using "Generic" but you'd have to do a
	little scripting)

	3) There is a variable called STAGE which holds the console the lights
	Creating a variable like this is completely optional and is just there for
	easier editing. Just make sure to path to the folder that contains all the
	lights. Like example the lights are in a folder named "Avant Stuff", all you
	gotta do is make the "lights" variable equal game.Workspace["Avant Stuff"] or
	something else. Keep in mind you can name the lights & console whatever you want
	as long as the script can path to it.

	4 [Semi-Optional]) If you are using moving heads, or if the module for moving heads
	is enabled, this is for you. Keep in mind what you name the stage because you're going
	to have to go into the module of the moving heads and edit a user id.

	Here's what the default moving heads module-info looks like:
]]
	local example = {
		fixtureData = {
			name = "Moving Heads",
			mode = "Extended"
		},
		effectData = {},
		instances = {},

		-- PAY ATTENTION TO WHAT IS BELOW --

		customAdmins = {
			[1110174992] = "Main Stage",
		}

		-- PAY ATTENTION TO WHAT IS ABOVE --
	}
--[[
	Whoever you want to control the moving heads will go here. At the moment, there is only
	support for one person to be able to control the moving heads per stage, however it is possible
	to add more through some funky scripting methods.

	This variable only takes user id's, so usernames will not work.

	5) To set-up certain modules, you're going to need to add a table including a list of all the modules,
	example:
]]

local exampleModules = {
	"Generic",
	"Blinders",
	"Pars",
	"Ambience",
	"LED",
	"Washes",
	"Moving Heads",
	"Pyro"
}

--[[
	5, cont.) A full list of modules is documented at the top of the script:

	Attempting to add more modules that aren't created like Lasers, Source 4's will error the console
	and it will not start the console at all.

	6, optional) Editing Keybinds:

	If you wish to edit the keybinds, you are going to have to travel to ReplicatedStorage > Shared > Global > Keybinds
	Once you are there, there will be things like "Enum.KeyCode.One" or "Enum.KeyCode.A". Numbers are written as words and
	Numpad things are written as Keypad. So if you were wanting to do something like Numpad Minus or Numpad 3 it would be
	written as "Enum.KeyCode.KeypadMinus" or "Enum.KeyCode.NumpadThree".

	If you want to start multiple consoles, you can either create a table to create more instances or you could store them
	all in the avant.new() function. All you have to do is create a new table for storing the objects or you could path them
	directly in the instance. I don't know what will happen if you try to launch two of the same console, and you probably
	shouldn't either way, only you are affected by it, lol.


	7) Numbering Chart

	Chart for: Pars, Ambience, & LED.
    - -------------------------------------------------------
      | Stage Right         Stage Center         Stage Left |
      | 1  2  3  4  5  6  7  8   |   8  7  6  5  4  3  2  1 |
      |          Naming          |          Naming          |
      -------------------------------------------------------

	Chart for: Moving Heads: (Attribtues in the models for symmetry movements btw, look at the bottom of the chart for guide)
    - -------------------------------------------------------
      | Stage Right         Stage Center         Stage Left |
      | 1  2  3  4  5  6  7  8   |   8  7  6  5  4  3  2  1 |
      |      GroupId: 1          |         GroupId: 2       |
      -------------------------------------------------------

	  	Chart for: Washes:
    - -------------------------------------------------------
      | Stage Right         Stage Center         Stage Left |
      |   1 2 3 4 5 6 7 8 9 10   |   10 9 8 7 6 5 4 3 2 1   |
      |      Naming              |             Naming       |
      -------------------------------------------------------
]]

local admins = {
	["draaawn"] = true,
}

local STAGE = {
	console = game.Workspace.Kit.Console["Avant Lite"], -- Paths to the kit that I gave you, please change this if you are running a show.
	lights = game.Workspace.Kit["Lights"],
}

local instances = {
	{
		console = STAGE.console,
		lights = STAGE.lights,
		stage = "STAGE",
		modules = {
			"Generic",
			"Blinders",
			"Pars",
			"Ambience",
			"LED",
			"Washes",
			"Moving Heads",
			"Pyro"
		},
		administrators = admins,
	}
}

avant.new(instances)