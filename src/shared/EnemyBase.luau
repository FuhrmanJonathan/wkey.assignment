local GameObjectBase = require(script.Parent.GameObjectBase)

local EnemyBase = {}
EnemyBase.__index = EnemyBase
setmetatable(EnemyBase, {__index = GameObjectBase})

function EnemyBase.New(...)
	local self = setmetatable(GameObjectBase.New(...), EnemyBase)
	return self
end

return EnemyBase