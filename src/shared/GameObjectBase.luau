local Systems = require(game.ReplicatedStorage.Shared.SystemLoader):Get()

local GameObjectBase = {}
GameObjectBase.__index = GameObjectBase

function GameObjectBase.New()
	local self = setmetatable({}, GameObjectBase)
	
	self.ObjectId = nil

	Systems.ServerObjectStorage:AddObject(self)

	return self
end

function GameObjectBase:Destroy()

	if self.ObjectId then
		Systems.ServerRenderingManager:RemoveModel(self.ObjectId)
	end
	
	Systems.ServerObjectStorage:RemoveObject(self)
end

return GameObjectBase