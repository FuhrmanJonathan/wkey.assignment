local GameObjectBase = require(script.Parent.GameObjectBase)

local ReplicatedSpriteBase = {}
ReplicatedSpriteBase.__index = ReplicatedSpriteBase
setmetatable(ReplicatedSpriteBase, {__index = GameObjectBase})

function ReplicatedSpriteBase.New(...)
	local self = setmetatable(GameObjectBase.New(...), ReplicatedSpriteBase)

	self.ModelVarianceSeed = math.random(1, 1000000)
	self.ModelKey = nil

	self.Position = Vector3.zero
	self.LastSentPosition = Vector3.zero

	self.Replicate = true

	return self
end

function ReplicatedSpriteBase:GetSpawnPacket()
	return {
		ObjectId = self.ObjectId,
		ModelKey = self.ModelKey,
		ModelVarianceSeed = self.ModelVarianceSeed,
		Position = self.Position,
	}
end

function ReplicatedSpriteBase:GetUpdatePacket()
	return {
		ObjectId = self.ObjectId,
		Position = self.Position,
	}
end

return ReplicatedSpriteBase