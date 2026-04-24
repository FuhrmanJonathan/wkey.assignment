local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CameraController = {}

CameraController.Enabled = false
CameraController.CameraEffectsEnabled = true
CameraController.CameraOffset = CFrame.new()
CameraController.PauseIndex = 0
CameraController.FocusPart = nil
CameraController.Camera = workspace.CurrentCamera
CameraController.FovMax = 16
CameraController.FovMin = 14

local function GetMouseDistance(Camera)
	local Mouse = Players.LocalPlayer:GetMouse()
	local CenterX = Camera.ViewportSize.X / 2.05
	local CenterY = Camera.ViewportSize.Y / 2

	return Mouse.X - CenterX, Mouse.Y - CenterY
end

local function ComputeTargetFOV(MouseDistanceX, MouseDistanceY)
	local Buffer = 75
	local RawFOV = CameraController.FovMin
		+ (math.abs(MouseDistanceX) / Buffer)
		+ (math.abs(MouseDistanceY) / Buffer)

	return math.min(RawFOV, CameraController.FovMax)
end

local function ComputeCameraOffset(MouseDistanceX, MouseDistanceY)
	return CFrame.new(0, 0, 0)
		* CFrame.Angles(
			math.rad(-MouseDistanceY / 250),
			math.rad(-MouseDistanceX / 250),
			0
		)
end

local function ComputeGoalCFrame(FocusPoint, CameraOffset)
	local OrbitCFrame = CFrame.new(FocusPoint) * CFrame.new(60, 60, -60)
	return CFrame.lookAt(OrbitCFrame.Position, FocusPoint) * CameraOffset
end

local function OnRenderStepped()
	local Camera = CameraController.Camera
	local FocusPoint = if CameraController.FocusPart
		then CameraController.FocusPart.Position
		else Vector3.zero

	local MouseDistanceX, MouseDistanceY = GetMouseDistance(Camera)

	local TargetFOV = ComputeTargetFOV(MouseDistanceX, MouseDistanceY)
	CameraController.CameraOffset = ComputeCameraOffset(MouseDistanceX, MouseDistanceY)

	local GoalCFrameRaw = ComputeGoalCFrame(FocusPoint, CameraController.CameraOffset)
	local GoalCFrame = Camera.CFrame:Lerp(GoalCFrameRaw, 0.05)

	Camera.FieldOfView += (TargetFOV - Camera.FieldOfView) * 0.01
	Camera.CameraType = Enum.CameraType.Scriptable

	local IsFarFromGoal = (GoalCFrame.Position - Camera.CFrame.Position).Magnitude > 5
	Camera.CFrame = if IsFarFromGoal then GoalCFrameRaw else GoalCFrame
end

function CameraController:Start()
	RunService.RenderStepped:Connect(OnRenderStepped)
	CameraController.Enabled = true
end

function CameraController:SetFocusPart(FocusPart)
	CameraController.FocusPart = FocusPart
end

return CameraController