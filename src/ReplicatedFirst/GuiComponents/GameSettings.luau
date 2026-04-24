local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SettingsChanged = Remotes:WaitForChild("SettingsChanged")
local UpdateSettings = Remotes:WaitForChild("UpdateSettings")
local RequestSettings = Remotes:WaitForChild("RequestSettings")

local SettingBindings = {
	EnemySpawnLimit = "SpawnLimit",
	EnemySpawnRate = "SpawnRate",
}

return function(Gui)
	local SpawnLimitHolder = Gui.Main.Holder.SpawnLimit.Holder
	local SpawnRateHolder = Gui.Main.Holder.SpawnRate.Holder

	local TextBoxes = {
		EnemySpawnLimit = SpawnLimitHolder.Value,
		EnemySpawnRate = SpawnRateHolder.Value,
	}

	local function SetTextBoxValue(SettingName, Value)
		local TextBox = TextBoxes[SettingName]
		if not TextBox then
			return
		end

		TextBox.Text = tostring(Value)
	end

	for SettingName, TextBox in pairs(TextBoxes) do
		TextBox.FocusLost:Connect(function(EnterPressed)
			local NumberValue = tonumber(TextBox.Text)
			if not NumberValue then
				return
			end

			UpdateSettings:FireServer(SettingName, NumberValue)
		end)
	end

	SettingsChanged.OnClientEvent:Connect(function(SettingName, Value)
		SetTextBoxValue(SettingName, Value)
	end)

    RequestSettings:FireServer()
end