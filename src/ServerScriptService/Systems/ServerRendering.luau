local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RenderSpawn = ReplicatedStorage.Remotes.RenderSpawn
local RenderUpdate = ReplicatedStorage.Remotes.RenderUpdate
local RenderDestroy = ReplicatedStorage.Remotes.RenderDestroy
local RenderEvent = ReplicatedStorage.Remotes.RenderEvent

local ServerRendering = {}

ServerRendering.ReplicatedObjects = {}
ServerRendering.LastUpdate = tick()
ServerRendering.UpdateInterval = 0.1

function ServerRendering:Start()
    RunService.Heartbeat:Connect(function()
        local CurrentTime = tick()
        if CurrentTime - self.LastUpdate < self.UpdateInterval then
            return
        end
        
        self.LastUpdate = CurrentTime
        self:SendUpdates()
    end)
end

function ServerRendering:RegisterObject(Object)
	self.ReplicatedObjects[Object.ObjectId] = Object

	RenderSpawn:FireAllClients({
		ObjectId = Object.ObjectId,
		ModelKey = Object.ModelKey,
		ModelVarianceSeed = Object.ModelVarianceSeed,
		Position = Object.Position,
	})
end

function ServerRendering:RemoveObject(ObjectId)
	self.ReplicatedObjects[ObjectId] = nil
	RenderDestroy:FireAllClients(ObjectId)
end

function ServerRendering:FireEvent(ObjectId, EventName, Data)
	RenderEvent:FireAllClients(ObjectId, EventName, Data)
end

function ServerRendering:SendUpdates()
	local Packet = {}

	for ObjectId, Object in pairs(self.ReplicatedObjects) do
		Packet[#Packet + 1] = {
			ObjectId = ObjectId,
			Position = Object.Position,
		}
	end

	if #Packet > 0 then
		RenderUpdate:FireAllClients(Packet)
	end
end

return ServerRendering