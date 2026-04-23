local HttpService = game:GetService("HttpService")

local GameObjectBase = {}
GameObjectBase.__index = GameObjectBase

function GameObjectBase.New()
	local self = setmetatable({}, GameObjectBase)
	
	self.ObjectId = HttpService:GenerateGUID(false)

	return self
end

function GameObjectBase:Spawn()

end

function GameObjectBase:Destroy()
	
end

return GameObjectBase