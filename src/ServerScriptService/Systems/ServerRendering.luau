local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RenderSpawn = Remotes:WaitForChild("RenderSpawn")
local RenderUpdate = Remotes:WaitForChild("RenderUpdate")
local RenderDestroy = Remotes:WaitForChild("RenderDestroy")
local RenderEvent = Remotes:WaitForChild("RenderEvent")
local ModelClicked = Remotes:WaitForChild("ModelClicked")

local ServerRendering = {}

ServerRendering.ReplicatedObjects = {}

ServerRendering.LastUpdate = 0
ServerRendering.PriorityLastUpdate = 0

ServerRendering.UpdateInterval = 0.25
ServerRendering.PriorityUpdateInterval = 0.05

ServerRendering.PositionThreshold = 0.1
ServerRendering.PositionPrecision = 10
ServerRendering.Started = false

local function Quantize(Number, Precision)
	return math.round(Number * Precision)
end

function ServerRendering:Start()
	if self.Started then
		return
	end

	self.Started = true

	Players.PlayerAdded:Connect(function(Player)
		task.defer(function()
			self:SyncPlayer(Player)
		end)
	end)

	for _, Player in ipairs(Players:GetPlayers()) do
		task.defer(function()
			self:SyncPlayer(Player)
		end)
	end

	RunService.Heartbeat:Connect(function()
		local CurrentTime = os.clock()

		if CurrentTime - self.PriorityLastUpdate >= self.PriorityUpdateInterval then
			self.PriorityLastUpdate = CurrentTime
			self:SendUpdates(true)
		end

		if CurrentTime - self.LastUpdate >= self.UpdateInterval then
			self.LastUpdate = CurrentTime
			self:SendUpdates(false)
		end
	end)

	ModelClicked.OnServerEvent:Connect(function(Player, ObjectId)
		local Object = nil
		for _, Obj in pairs(self.ReplicatedObjects) do
			if Obj.ObjectId == ObjectId then
				Object = Obj
				break
			end
		end

		if Object then
			print(Object.ObjectId .. " clicked by " .. Player.Name .. " [SERVER]")
		end
	end)
end

function ServerRendering:BuildSpawnData(Object)
	local Position = Object.Position

	return {
		ObjectId = Object.ObjectId,
		ModelKey = Object.ModelKey,
		ModelVarianceSeed = Object.ModelVarianceSeed,
		X = Quantize(Position.X, self.PositionPrecision),
		Z = Quantize(Position.Z, self.PositionPrecision),
	}
end

function ServerRendering:SendSpawn(Player, Object)
	if not Object.ObjectId then
		return
	end

	if not Object.ModelKey then
		return
	end

	if not Object.Position then
		return
	end

	local SpawnData = self:BuildSpawnData(Object)

	if Player then
		RenderSpawn:FireClient(Player, SpawnData)
	else
		RenderSpawn:FireAllClients(SpawnData)
	end
end

function ServerRendering:RegisterObject(Object)
	if not Object.ObjectId then
		return
	end

	self.ReplicatedObjects[Object.ObjectId] = Object
	self:SendSpawn(nil, Object)
end

function ServerRendering:SyncPlayer(Player)
	for _, Object in pairs(self.ReplicatedObjects) do
		self:SendSpawn(Player, Object)
	end
end

function ServerRendering:RemoveObject(ObjectId)
	if not ObjectId then
		return
	end

	self.ReplicatedObjects[ObjectId] = nil
	RenderDestroy:FireAllClients(ObjectId)
end

function ServerRendering:FireEvent(ObjectId, EventName, Data)
	RenderEvent:FireAllClients(ObjectId, EventName, Data)
end

function ServerRendering:ShouldSendObject(Object, Position)
	local LastSentPosition = Object.LastSentPosition

	if not LastSentPosition then
		return true
	end

	return (Position - LastSentPosition).Magnitude >= self.PositionThreshold
end

function ServerRendering:AddObjectToPacket(Packet, ObjectId, Object, Position)
	Object.LastSentPosition = Position

	Packet[#Packet + 1] = {
		ObjectId,
		Quantize(Position.X, self.PositionPrecision),
		Quantize(Position.Z, self.PositionPrecision),
	}
end

function ServerRendering:SendUpdates(PriorityOnly)
	local Packet = {}

	for ObjectId, Object in pairs(self.ReplicatedObjects) do
		if PriorityOnly and not Object.Priority then
			continue
		end

		if not PriorityOnly and Object.Priority then
			continue
		end

		local Position = Object.Position

		if Position and self:ShouldSendObject(Object, Position) then
			self:AddObjectToPacket(Packet, ObjectId, Object, Position)
		end
	end

	if #Packet > 0 then
		RenderUpdate:FireAllClients(Packet)
	end
end

return ServerRendering