local Players = game:GetService("Players")

local ReplicatedSpriteBase = require(script.Parent.ReplicatedSpriteBase)
local Config = require(game.ReplicatedStorage.Config)

local EnemyBase = {}
EnemyBase.__index = EnemyBase
setmetatable(EnemyBase, {__index = ReplicatedSpriteBase})

function EnemyBase.New(...)
	local self = setmetatable(ReplicatedSpriteBase.New(...), EnemyBase)

	self.ModelKey = "Enemy"

	self.CharacterTarget = nil
	self.RoamPosition = nil

	self.Speed = 6
	self.AttackDamage = 10
	self.AttackCooldown = 1

	return self
end

function EnemyBase:GetEnemyArea()
	return workspace:FindFirstChild("EnemyArea")
end

function EnemyBase:IsPositionInEnemyArea(Position)
	local EnemyArea = self:GetEnemyArea()
	if not EnemyArea then
		return true
	end

	local RelativePosition = Position - EnemyArea.Position
	local HalfSize = EnemyArea.Size / 2

	return math.abs(RelativePosition.X) <= HalfSize.X
		and math.abs(RelativePosition.Z) <= HalfSize.Z
end

function EnemyBase:FindCharacterTarget()
	local ClosestCharacter = nil
	local ClosestDistance = math.huge

	for _, Player in ipairs(Players:GetPlayers()) do
		local Character = Player.Character
		local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

		if RootPart and self:IsPositionInEnemyArea(RootPart.Position) then
			local Distance = (RootPart.Position - self.Position).Magnitude

			if Distance < ClosestDistance then
				ClosestCharacter = Character
				ClosestDistance = Distance
			end
		end
	end

	return ClosestCharacter
end

function EnemyBase:FindRoamPosition()
	local EnemyArea = self:GetEnemyArea()
	if not EnemyArea then
		return self.Position
	end

	local HalfSize = EnemyArea.Size / 2

	return Vector3.new(
		EnemyArea.Position.X + math.random(-HalfSize.X, HalfSize.X),
		Config.YLevel,
		EnemyArea.Position.Z + math.random(-HalfSize.Z, HalfSize.Z)
	)
end

function EnemyBase:MoveTowards(TargetPosition, DeltaTime)
	local FlatTarget = Vector3.new(TargetPosition.X, Config.YLevel, TargetPosition.Z)
	local FlatPosition = Vector3.new(self.Position.X, Config.YLevel, self.Position.Z)

	local Difference = FlatTarget - FlatPosition
	local Distance = Difference.Magnitude

	if Distance < 0.01 then
		return
	end

	local Direction = Difference.Unit
	local Step = math.min(self.Speed * DeltaTime, Distance)

	self.Position = FlatPosition + Direction * Step
end

function EnemyBase:Simulate(DeltaTime)
	self.CharacterTarget = self:FindCharacterTarget()

	if self.CharacterTarget then
		local RootPart = self.CharacterTarget:FindFirstChild("HumanoidRootPart")

		if RootPart then
			self:MoveTowards(RootPart.Position, DeltaTime)
			return
		end
	end

	if not self.RoamPosition or (self.RoamPosition - self.Position).Magnitude <= 1 then
		self.RoamPosition = self:FindRoamPosition()
	end

	self:MoveTowards(self.RoamPosition, DeltaTime)
end

return EnemyBase