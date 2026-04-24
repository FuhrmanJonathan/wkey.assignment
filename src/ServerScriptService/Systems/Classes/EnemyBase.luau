local ReplicatedSpriteBase = require(script.Parent.ReplicatedSpriteBase)

local EnemyBase = {}
EnemyBase.__index = EnemyBase
setmetatable(EnemyBase, {__index = ReplicatedSpriteBase})

function EnemyBase.New(...)
	local self = setmetatable(ReplicatedSpriteBase.New(...), EnemyBase)

	self.ModelKey = "Enemy"

	self.Target = nil

	self.Speed = 3
	self.AttackDamage = 10
	self.AttackCooldown = 1

	return self
end

function EnemyBase:FindCharacterTarget()
	local ClosestCharacter, ClosestDistance = nil, math.huge
	for _, Player in pairs(game.Players:GetChildren()) do
		if Player:IsA("Player") and Player.Character then
			local Distance = (Player.Character.PrimaryPart.Position - self.Position).Magnitude
			if Distance < ClosestDistance then
				ClosestCharacter = Player.Character
				ClosestDistance = Distance
			end
		end
	end
	return ClosestCharacter
end

function EnemyBase:Simulate(DeltaTime)
	if self.CharacterTarget and self.CharacterTarget.PrimaryPart then
		local Direction = (self.CharacterTarget.PrimaryPart.Position - self.Position).Unit
		self.Position = self.Position + Direction * self.Speed * DeltaTime
	else
		self.CharacterTarget = self:FindCharacterTarget()
	end
end

return EnemyBase