local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ModelClicked = Remotes:WaitForChild("ModelClicked")

local MouseController = {}

function MouseController:Start()
	game:GetService("UserInputService").InputBegan:Connect(function(Input, GameProcessed)
		if GameProcessed then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			local Target = game:GetService("Players").LocalPlayer:GetMouse().Target
			if Target and Target.Parent and Target.Parent:IsA("Model") then
				print(Target.Parent.Name .. " clicked [CLIENT]")
				ModelClicked:FireServer(Target.Parent.Name)
			end
		end
	end)
end

return MouseController