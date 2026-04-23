local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RenderSpawn = ReplicatedStorage.Remotes.RenderSpawn
local RenderUpdate = ReplicatedStorage.Remotes.RenderUpdate
local RenderDestroy = ReplicatedStorage.Remotes.RenderDestroy
local RenderEvent = ReplicatedStorage.Remotes.RenderEvent

local ModelCreationRegistry = require(ReplicatedStorage.Systems.ModelCreationRegistry)

local ClientRendering = {}

ClientRendering.VisualObjects = {}

function ClientRendering:Start()
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

function ClientRendering:CreateObject(SpawnData)
	local CreateFunction = ModelCreationRegistry[SpawnData.ModelKey]
	if not CreateFunction then
		return
	end

	local Model = CreateFunction(SpawnData.ModelVarianceSeed)
	if not Model then
		return
	end

	Model:PivotTo(CFrame.new(SpawnData.Position))
	Model.Parent = workspace

	self.VisualObjects[SpawnData.ObjectId] = {
		ObjectId = SpawnData.ObjectId,
		Model = Model,
		CurrentPosition = SpawnData.Position,
		TargetPosition = SpawnData.Position,
		ModelKey = SpawnData.ModelKey,
		ModelVarianceSeed = SpawnData.ModelVarianceSeed,
	}
end

function ClientRendering:ApplyUpdates(UpdatePacket)
	for _, UpdateData in ipairs(UpdatePacket) do
		local VisualObject = self.VisualObjects[UpdateData.ObjectId]
		if VisualObject then
			VisualObject.TargetPosition = UpdateData.Position
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
	local Alpha = math.clamp(DeltaTime * 10, 0, 1)

	for _, VisualObject in pairs(self.VisualObjects) do
		VisualObject.CurrentPosition = VisualObject.CurrentPosition:Lerp(VisualObject.TargetPosition, Alpha)

		if VisualObject.Model then
			VisualObject.Model:PivotTo(CFrame.new(VisualObject.CurrentPosition))
		end
	end
end

return ClientRendering