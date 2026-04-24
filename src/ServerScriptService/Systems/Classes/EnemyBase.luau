local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedSpriteBase = require(script.Parent.ReplicatedSpriteBase)
local Config = require(ReplicatedStorage.Config)
local ModelEffects = require(ReplicatedStorage.Systems.ModelEffects)

local EnemyBase = {}
EnemyBase.__index = EnemyBase
setmetatable(EnemyBase, {__index = ReplicatedSpriteBase})

function EnemyBase.New(...)
	local self = setmetatable(ReplicatedSpriteBase.New(...), EnemyBase)

	self.ModelKey = "Enemy"

	self.CharacterTarget = nil
	self.RoamPosition = nil

	self.Speed = 6

	self.AttackDamage = 4
	self.AttackCooldown = 3
	self.AttackRange = 1
	self.LastAttackTime = 0

	self.IsDashing = false
	self.DashSpeed = 80
	self.DashTime = 0.25
	self.DashTimer = 0
	self.DashDirection = nil

	return self
end

function EnemyBase:GetEnemyArea()
	return workspace:FindFirstChild("EnemyArea")
end

function EnemyBase:GetFlatPosition(Position)
	return Vector3.new(Position.X, Config.YLevel, Position.Z)
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
	local FlatTarget = self:GetFlatPosition(TargetPosition)
	local FlatPosition = self:GetFlatPosition(self.Position)

	local Difference = FlatTarget - FlatPosition
	local Distance = Difference.Magnitude

	if Distance < 0.01 then
		return
	end

	local Direction = Difference.Unit
	local Step = math.min(self.Speed * DeltaTime, Distance)

	self.Position = FlatPosition + Direction * Step
end

function EnemyBase:CanAttack()
	if os.clock() - self.LastAttackTime < self.AttackCooldown then
		return false
	end

	if not self.CharacterTarget then
		return false
	end

	local RootPart = self.CharacterTarget:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return false
	end

	local FlatTarget = self:GetFlatPosition(RootPart.Position)
	local FlatPosition = self:GetFlatPosition(self.Position)

	return (FlatTarget - FlatPosition).Magnitude <= self.AttackRange
end

function EnemyBase:StartDash(TargetPosition)
	local FlatTarget = self:GetFlatPosition(TargetPosition)
	local FlatPosition = self:GetFlatPosition(self.Position)

	local Difference = FlatTarget - FlatPosition
	if Difference.Magnitude < 0.01 then
		return
	end

	self.Priority = false

	self.IsDashing = true
	self.DashTimer = self.DashTime
	self.DashDirection = Difference.Unit
end

function EnemyBase:Attack()
	if not self:CanAttack() then
		return
	end

	self.LastAttackTime = os.clock()

	local RootPart = self.CharacterTarget:FindFirstChild("HumanoidRootPart")
	if RootPart then
		self:StartDash(RootPart.Position)
	end

	task.delay(0.25, function()
		local Humanoid = self.CharacterTarget:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid:TakeDamage(self.AttackDamage)
		end
		
		ModelEffects:Hit(self.CharacterTarget)
	end)
end

function EnemyBase:SimulateDash(DeltaTime)
	if not self.IsDashing then
		return false
	end

	self.DashTimer -= DeltaTime

	if self.DashDirection then
		self.Position += self.DashDirection * self.DashSpeed * DeltaTime
		self.Position = self:GetFlatPosition(self.Position)
	end

	if self.DashTimer <= 0 then
		self.Priority = false

		self.IsDashing = false
		self.DashTimer = 0
		self.DashDirection = nil
	end

	return true
end

function EnemyBase:SimulateChase(DeltaTime)
	self.CharacterTarget = self:FindCharacterTarget()

	if not self.CharacterTarget then
		return false
	end

	local RootPart = self.CharacterTarget:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return false
	end

	self:MoveTowards(RootPart.Position, DeltaTime)
	self:Attack()

	return true
end

function EnemyBase:SimulateRoam(DeltaTime)
	if not self.RoamPosition or (self.RoamPosition - self.Position).Magnitude <= 1 then
		self.RoamPosition = self:FindRoamPosition()
	end

	self:MoveTowards(self.RoamPosition, DeltaTime)
end

function EnemyBase:Simulate(DeltaTime)
	if self:SimulateDash(DeltaTime) then
		return
	end

	if self:SimulateChase(DeltaTime) then
		return
	end

	self:SimulateRoam(DeltaTime)
end

return EnemyBase