local ReplicatedSpriteBase = require(script.Parent.ReplicatedSpriteBase)

local EnemyBase = {}
EnemyBase.__index = EnemyBase
setmetatable(EnemyBase, {__index = ReplicatedSpriteBase})

function EnemyBase.New(...)
	local self = setmetatable(ReplicatedSpriteBase.New(...), EnemyBase)

	self.ModelKey = "Enemy"

	return self
end

function EnemyBase:Simulate(DeltaTime)

end

return EnemyBase