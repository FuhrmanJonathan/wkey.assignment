local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RenderSpawn = Remotes:WaitForChild("RenderSpawn")
local RenderUpdate = Remotes:WaitForChild("RenderUpdate")
local RenderDestroy = Remotes:WaitForChild("RenderDestroy")
local RenderEvent = Remotes:WaitForChild("RenderEvent")

local ModelCreationRegistry = require(ReplicatedStorage.Systems.ModelCreationRegistry)

local ClientRendering = {}

ClientRendering.VisualObjects = {}
ClientRendering.Started = false
ClientRendering.LerpSpeed = 10
ClientRendering.PlatformY = 0
ClientRendering.PositionPrecision = 10

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
		self.PlatformY,
		Dequantize(Z, self.PositionPrecision)
	)
end

function ClientRendering:CreateObject(SpawnData)
	local CreateFunction = ModelCreationRegistry[SpawnData.ModelKey]
	if not CreateFunction then
		warn("No model creation function for:", SpawnData.ModelKey)
		return
	end

	local Model = CreateFunction(SpawnData.ModelVarianceSeed)
	if not Model then
		warn("Model creation failed for:", SpawnData.ModelKey)
		return
	end

	local Position = self:GetPositionFromData(SpawnData.X, SpawnData.Z)

	Model:PivotTo(CFrame.new(Position))
	Model.Parent = workspace

	self.VisualObjects[SpawnData.ObjectId] = {
		ObjectId = SpawnData.ObjectId,
		Model = Model,
		CurrentPosition = Position,
		TargetPosition = Position,
		ModelKey = SpawnData.ModelKey,
		ModelVarianceSeed = SpawnData.ModelVarianceSeed,
	}
end

function ClientRendering:ApplyUpdates(UpdatePacket)
	for _, UpdateData in ipairs(UpdatePacket) do
		local ObjectId = UpdateData[1]
		local X = UpdateData[2]
		local Z = UpdateData[3]

		local VisualObject = self.VisualObjects[ObjectId]
		if VisualObject then
			VisualObject.TargetPosition = self:GetPositionFromData(X, Z)
		end
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
	local Alpha = math.clamp(DeltaTime * self.LerpSpeed, 0, 1)

	for _, VisualObject in pairs(self.VisualObjects) do
		if (VisualObject.CurrentPosition - VisualObject.TargetPosition).Magnitude < 0.01 then
			continue
		end

		VisualObject.CurrentPosition =
			VisualObject.CurrentPosition:Lerp(VisualObject.TargetPosition, Alpha)

		if VisualObject.Model then
			VisualObject.Model:PivotTo(CFrame.new(VisualObject.CurrentPosition))
		end
	end
end

return ClientRendering