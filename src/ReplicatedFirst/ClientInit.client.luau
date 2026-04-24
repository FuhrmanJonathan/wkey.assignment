local Players = game:GetService("Players")

local ClientRendering = require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("ClientRendering"))
local CameraController = require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("CameraController"))
local GuiComponents = require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("GuiComponents"))

local LocalPlayer = Players.LocalPlayer

local function CharacterAdded(Character)
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	CameraController:SetFocusPart(RootPart)
end

local function ClientInitializationPipeline()
	ClientRendering:Start()
	CameraController:Start()
    GuiComponents:Start()

	if LocalPlayer.Character then
		CharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
end

ClientInitializationPipeline()