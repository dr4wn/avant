-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local hslModule = require(ReplicatedStorage.Shared.Global.HSLtoRGB)

local utility = {}

function utility:generateColorPicker(data)
	local self = {
		pickerDown = false,
		sensor = data.sensor,
		pointer = data.pointer,
		sensorSize = data.sensor.AbsoluteSize,
		sensorPos = data.sensor.AbsolutePosition,
		connection = data.connection,
		indicator = data.indicator
	}

	self.sensor.MouseButton1Down:Connect(function()
		self.pickerDown = true
	end)
	self.sensor.MouseButton1Up:Connect(function()
		self.pickerDown = false
	end)
	self.sensor.MouseLeave:Connect(function()
		self.pickerDown = false
	end)

	self.sensor.MouseMoved:Connect(function(x, y)
		local x, y = x - self.sensorPos.X, y - self.sensorPos.Y
		if self.pickerDown then
			self.pointer.Position = UDim2.new(x / self.sensorSize.X, 0, y / self.sensorSize.Y, 0)
			local color = Color3.new(hslModule.hslToRgb( (x / self.sensorSize.X), 1, y / self.sensorSize.Y, 1 ))
			self.indicator.BackgroundColor3 = color
			self.connection(color)
		end
	end)
end

function utility:generateFader(data)
	local self = {
		sensorPos = data.sensorPos,
		sensorSize = data.sensorSize,
		frame = data.frame,
		connection = data.connection,
		faderInstance = data.faderInstance,
		multiplier = tonumber(data.multiplier) or 1,
		heldDown = false
	}

	self.frame.MouseButton1Down:Connect(function()
		self.heldDown = true
	end)

	self.frame.MouseButton1Up:Connect(function()
		self.heldDown = false
	end)

	self.frame.MouseLeave:Connect(function()
		self.heldDown = false
	end)

	self.frame.MouseMoved:Connect(function(x, y)
		local y = y - self.sensorPos.Y
		if self.heldDown then
			local v = (y / self.sensorSize.Y)
			if v >= 0.97 then
				v = 1
			end
			if v <= 0.03 then
				v = 0
			end
			self.faderInstance.Size = UDim2.new(1, 0, 1 - v, 0)
			local faderValue = (- v * 2 * 90) + 180
			self.connection(faderValue * self.multiplier)
		end
	end)
end

function utility:returnButtonInfo(frame, category)
	local categories = {
		dimmerButtons = {{
				button = frame["Power"],
				buttonToggle = {
					{"MouseButton1Down", true}, {"MouseButton2Down", false} }
			}, {
				button = frame["Fade In"],
				buttonToggle = { {"MouseButton1Down", true} }
			}, {
				button = frame["Fade Out"],
				buttonToggle = { {"MouseButton1Down", false} }
			}, {
				button = frame["A^ - Pulse"],
				buttonToggle = { {"MouseButton1Down", false}, {"MouseButton2Down", false} }
			}, {
				button = frame["B^ - Hold"],
				buttonToggle = {
					{"MouseButton1Down", true}, {"MouseButton2Down", true},
					{"MouseButton1Up", false}, {"MouseButton2Up", false},
				}
			}
		},
	}
	return categories[category]
end

function utility:getInterfaceFolder(identifier)
	return ReplicatedStorage.Interfaces:WaitForChild(identifier)
end

function utility:getRemoteFolder(identifier, name)
	return ReplicatedStorage["Remote Events"]:WaitForChild(identifier):WaitForChild(name)
end

function utility:getAndDecodeConsole(tag, attribute)
	local a_tag = CollectionService:GetTagged(tag)[1]
	local decodedTag = HttpService:JSONDecode(a_tag:GetAttribute(attribute))
	return decodedTag, a_tag
end

function utility:createScreenGui(name, parent)
	local screenGui	= Instance.new("ScreenGui")
	screenGui.ResetOnSpawn = false
	screenGui.Name = name or "NoName "..HttpService:GenerateGUID(false)
	screenGui.Parent = parent
	return screenGui
end

function utility:createFolder(name, parent)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent or nil
	return folder
end

function utility:loader(arrayOfEvents, folder)
	for eventName, className in pairs(arrayOfEvents) do
		local remote = Instance.new(className)
		remote.Name = eventName
		remote.Parent = folder
	end
end

return utility