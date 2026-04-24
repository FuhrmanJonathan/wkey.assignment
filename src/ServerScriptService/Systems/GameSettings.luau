local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SettingsChanged = Remotes:WaitForChild("SettingsChanged")
local UpdateSettings = Remotes:WaitForChild("UpdateSettings")
local RequestSettings = Remotes:WaitForChild("RequestSettings")

local BindableSettingsChanged = Remotes:WaitForChild("BindableSettingsChanged")

local GameSettings = {}

GameSettings.Definitions = {
	EnemySpawnRate = {
		Default = 1,
		Min = 0,
		Max = 60,
	},

	EnemySpawnLimit = {
		Default = 20,
		Min = 0,
		Max = 10000,
	},
}

GameSettings.Values = {}

GameSettings.BindableSettingsChanged = BindableSettingsChanged

function GameSettings:InitializeDefaults()
	for SettingName, Data in pairs(self.Definitions) do
		if self.Values[SettingName] == nil then
			self.Values[SettingName] = Data.Default
		end
	end
end

function GameSettings:Get(SettingName)
	return self.Values[SettingName]
end

function GameSettings:Set(SettingName, Value)
	local Definition = self.Definitions[SettingName]
	if not Definition then
		return false
	end

	Value = tonumber(Value)
	if not Value then
		return false
	end

	Value = math.clamp(
		Value,
		Definition.Min,
		Definition.Max
	)

	if SettingName == "EnemySpawnLimit" then
		Value = math.floor(Value)
	end

	self.Values[SettingName] = Value

	SettingsChanged:FireAllClients(
		SettingName,
		Value
	)

    BindableSettingsChanged:Fire(SettingName, Value)

	return true
end

function GameSettings:SendAllSettings(Player)
	for SettingName, _ in pairs(self.Definitions) do
		SettingsChanged:FireClient(
			Player,
			SettingName,
			self.Values[SettingName]
		)
	end
end

function GameSettings:Start()

	self:InitializeDefaults()

	UpdateSettings.OnServerEvent:Connect(function(Player, SettingName, Value)
		self:Set(SettingName, Value)
	end)

    RequestSettings.OnServerEvent:Connect(function(Player)
        self:SendAllSettings(Player)
    end)

	Players.PlayerAdded:Connect(function(Player)
		self:SendAllSettings(Player)
	end)

	for _, Player in ipairs(Players:GetPlayers()) do
		self:SendAllSettings(Player)
	end
end

return GameSettings