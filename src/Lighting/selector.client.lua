-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local consoleInstances = script:GetAttribute("consoleInstances")
local arrayOfIdentifiers = HttpService:JSONDecode(consoleInstances)

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local Util = require(sharedFolder.Global.Util)

local module = {
	interfaceStorage = {},
	interfaceRef = {}
}

function createHighlights(...)
	for _, part in pairs( ... ) do
		if not part:GetAttribute("avantScreenPart") then continue end

		local highlight = Instance.new("SelectionBox")
		highlight.Name = "avant-v3-selection-box"
		highlight.Parent = part
		highlight.Transparency = 0
		highlight.LineThickness = 0.05
		highlight.Adornee = part
	end
end

function deleteHighlights(...)
	for _, part in pairs(...) do
		if not part:GetAttribute("avantScreenPart") then continue end

		if part:FindFirstChild("avant-v3-selection-box") then
			part["avant-v3-selection-box"]:Destroy()
		end
	end
end

function displayInterface(button, part, identifier)
	if not part:GetAttribute("avantScreenPart") then return end

	local _button = button:GetAttribute("lightScreenFocus")
	local interfaceFolder = Util:getInterfaceFolder(identifier)
	local gui = module.interfaceRef[identifier][_button]
	local screenName = part.Name

	if module.interfaceStorage[identifier][screenName] then
		module.interfaceStorage[identifier][screenName].Parent = interfaceFolder
	else
		module.interfaceStorage[identifier][screenName] = gui
	end

	gui.Parent = part
	module.interfaceStorage[identifier][screenName] = gui
end

function module:createListener(button, consoleScreens, identifier)
	local selecting = false

	button.MouseButton1Down:Connect(function()
		if selecting then return end

		selecting = true
		createHighlights(consoleScreens:GetChildren())
	end)

	mouse.Button1Down:Connect(function()
		if selecting then
			local target = mouse.Target
			for _, consoleScreen in pairs(consoleScreens:GetChildren()) do
				if target ~= consoleScreen then continue end

				if target:GetAttribute("avantScreenPart") then
					if target:FindFirstChild("Intro Screen") then
						target["Intro Screen"]:Destroy()
					end
					displayInterface(button, target, identifier)
				end
			end
			selecting = false
			deleteHighlights(consoleScreens:GetChildren())
		end
	end)
end

function module:createButtons(startedLighting, console, identifier)
	local consoleScreens = console:WaitForChild("Screens")
	local controlScreen = consoleScreens:WaitForChild("Control Screen")
	local buttonContainer = controlScreen.MainGUI.Holster.Main

	for _, light in pairs(startedLighting) do
		local template = script.Template:Clone()
		template:SetAttribute("lightScreenFocus", light)

		template.Text = light
		template.Name = light
		template.Parent = buttonContainer
		template.Visible = true
		template:SetAttribute("lightScreenFocus", light)

		module.interfaceRef[identifier][light] = Util:getInterfaceFolder(identifier)[light]

		module:createListener(template, consoleScreens, identifier)
	end
end

for key, identifier in pairs(arrayOfIdentifiers) do
	local startedLighting, console = Util:getAndDecodeConsole("[Avant v3] Console "..identifier, "startedLighting")
	for _, screen in pairs(console.Screens:GetChildren()) do
		if not screen:GetAttribute("avantScreenPart") then continue end
		console.Misc["Intro Screen"]:Clone().Parent = screen
	end

	module.interfaceStorage[identifier] = {}
	module.interfaceRef[identifier] = {}
	module:createButtons(startedLighting, console, identifier)
	warn("[Avant v3: ["..key.."]["..identifier.."] selector.client.lua] Initialized:", table.concat(startedLighting, ", "))
end
