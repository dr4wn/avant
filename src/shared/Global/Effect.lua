-- Copyright (C) 2023 Avant/Dr4wn | All Rights Reserved
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Effect = {}
Effect.__index = Effect

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local waveforms = require(sharedFolder:FindFirstChild("Global"):FindFirstChild("Waveforms"))

function Effect.new(options)
	local self = {
		personality = options.personality,
		engine = {
			callback = options.engine.callback,
			formFunction = waveforms[options.engine.waveform] or waveforms["Sine"],
			step = 0,
		},
		instances = options.instances,
	}
	return setmetatable(self, Effect)
end

function Effect:isRunning()
	return self.engine.connection ~= nil
end

function Effect:start()
	if self:isRunning() then return end
	if self.engine.isRunning then return end
	
	self.engine.isRunning = true
	self.engine.connection = RunService.Heartbeat:Connect(function(delta)
		self.engine.callback(self, delta)
	end)
end

function Effect:stop()
	if not self:isRunning() then return end
	if not self.engine.isRunning then return end

	self.engine.isRunning = false
	self.engine.connection:Disconnect()
	self.engine.connection = nil
end

return Effect