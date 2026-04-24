local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RenderSpawn = Remotes:WaitForChild("RenderSpawn")
local RenderUpdate = Remotes:WaitForChild("RenderUpdate")
local RenderDestroy = Remotes:WaitForChild("RenderDestroy")
local RenderEvent = Remotes:WaitForChild("RenderEvent")

local ServerRendering = {}

ServerRendering.ReplicatedObjects = {}
ServerRendering.LastUpdate = 0
ServerRendering.UpdateInterval = 0.15
ServerRendering.PositionThreshold = 0.1
ServerRendering.PlatformY = 0
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

		if CurrentTime - self.LastUpdate < self.UpdateInterval then
			return
		end

		self.LastUpdate = CurrentTime
		self:SendUpdates()
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

function ServerRendering:SendUpdates()
	local Packet = {}

	for ObjectId, Object in pairs(self.ReplicatedObjects) do
		local Position = Object.Position

		if Position then
			local LastSentPosition = Object.LastSentPosition

			if not LastSentPosition or (Position - LastSentPosition).Magnitude >= self.PositionThreshold then
				Object.LastSentPosition = Position

				Packet[#Packet + 1] = {
					ObjectId,
					Quantize(Position.X, self.PositionPrecision),
					Quantize(Position.Z, self.PositionPrecision),
				}
			end
		end
	end

	if #Packet > 0 then
		RenderUpdate:FireAllClients(Packet)
	end
end

return ServerRendering