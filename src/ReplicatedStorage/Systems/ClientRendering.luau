local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RenderSpawn = Remotes:WaitForChild("RenderSpawn")
local RenderUpdate = Remotes:WaitForChild("RenderUpdate")
local RenderDestroy = Remotes:WaitForChild("RenderDestroy")
local RenderEvent = Remotes:WaitForChild("RenderEvent")

local ModelCreationRegistry = require(ReplicatedStorage.Systems.ModelCreationRegistry)
local Config = require(ReplicatedStorage.Config)

local ClientRendering = {}

ClientRendering.VisualObjects = {}
ClientRendering.Started = false
ClientRendering.PositionPrecision = 10
ClientRendering.CorrectionSpeed = 1
ClientRendering.VelocityDecayTime = 0.3

local function Dequantize(Number, Precision)
	return Number / Precision
end

function ClientRendering:Start()
	if self.Started then
		return
	end

	self.Started = true

	RenderSpawn.OnClientEvent:Connect(function(SpawnData)
		self:CreateObject(SpawnData)
	end)

	RenderUpdate.OnClientEvent:Connect(function(UpdatePacket)
		self:ApplyUpdates(UpdatePacket)
	end)

	RenderDestroy.OnClientEvent:Connect(function(ObjectId)
		self:DestroyObject(ObjectId)
	end)

	RenderEvent.OnClientEvent:Connect(function(ObjectId, EventName, Data)
		self:HandleEvent(ObjectId, EventName, Data)
	end)

	RunService.RenderStepped:Connect(function(DeltaTime)
		self:RenderStep(DeltaTime)
	end)
end

function ClientRendering:GetPositionFromData(X, Z)
	return Vector3.new(
		Dequantize(X, self.PositionPrecision),
		Config.YLevel,
		Dequantize(Z, self.PositionPrecision)
	)
end

function ClientRendering:CreateObject(SpawnData)
	local CreateFunction = ModelCreationRegistry[SpawnData.ModelKey]
	if not CreateFunction then
		return
	end

	local Model = CreateFunction(SpawnData.ModelVarianceSeed)
	if not Model then
		return
	end

	local Position = self:GetPositionFromData(SpawnData.X, SpawnData.Z)

	Model:PivotTo(CFrame.new(Position))
	Model.Parent = workspace

	self.VisualObjects[SpawnData.ObjectId] = {
		ObjectId          = SpawnData.ObjectId,
		Model             = Model,
		ModelKey          = SpawnData.ModelKey,
		ModelVarianceSeed = SpawnData.ModelVarianceSeed,

		-- The smoothed visual position driven each RenderStepped
		CurrentPosition   = Position,

		-- Last authoritative position received from the server
		ServerPosition    = Position,

		-- Estimated movement per second derived from consecutive server updates
		Velocity          = Vector3.zero,

		-- tick() timestamp of the most recent server update
		LastUpdateTime    = tick(),
	}
end

function ClientRendering:ApplyUpdates(UpdatePacket)
	local Now = tick()

	for _, UpdateData in ipairs(UpdatePacket) do
		local ObjectId = UpdateData[1]
		local X = UpdateData[2]
		local Z = UpdateData[3]

		local VisualObject = self.VisualObjects[ObjectId]
		if not VisualObject then
			continue
		end

		local NewServerPosition = self:GetPositionFromData(X, Z)
		local DeltaTime = Now - VisualObject.LastUpdateTime

		if DeltaTime >= 0.005 then
			local Displacement = NewServerPosition - VisualObject.ServerPosition
			VisualObject.Velocity  = Displacement / DeltaTime
		end

		VisualObject.ServerPosition = NewServerPosition
		VisualObject.LastUpdateTime = Now
	end
end

function ClientRendering:DestroyObject(ObjectId)
	local VisualObject = self.VisualObjects[ObjectId]
	if not VisualObject then
		return
	end

	if VisualObject.Model then
		VisualObject.Model:Destroy()
	end

	self.VisualObjects[ObjectId] = nil
end

function ClientRendering:HandleEvent(ObjectId, EventName, Data)
	local VisualObject = self.VisualObjects[ObjectId]
	if not VisualObject then
		return
	end
end

function ClientRendering:RenderStep(DeltaTime)
	local Now = tick()

	for _, VisualObject in pairs(self.VisualObjects) do
		local TimeSinceUpdate = Now - VisualObject.LastUpdateTime

		local VelocityWeight = math.clamp(
			1 - (TimeSinceUpdate / self.VelocityDecayTime),
			0,
			1
		)
		local DecayedVelocity = VisualObject.Velocity * VelocityWeight
		local PredictedPosition = VisualObject.ServerPosition
			+ DecayedVelocity * TimeSinceUpdate

		local Alpha = math.clamp(DeltaTime * self.CorrectionSpeed, 0, 1)
		VisualObject.CurrentPosition =
			VisualObject.CurrentPosition:Lerp(PredictedPosition, Alpha)

		if VisualObject.Model then
			VisualObject.Model:PivotTo(CFrame.new(VisualObject.CurrentPosition))
		end
	end
end

return ClientRendering