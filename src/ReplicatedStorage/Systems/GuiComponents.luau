local GuiComponentsFolder = game.ReplicatedFirst:WaitForChild("GuiComponents")

local GuiComponents = {}

function GuiComponents:Start()
	
	GuiComponents.PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	GuiComponents.Components = {}
	
	for _, Module in pairs(GuiComponentsFolder:GetDescendants()) do
		if Module:IsA("ModuleScript") then
			GuiComponents.Components[Module.Name] = require(Module)
		end
	end

	local function Apply(Gui)
		if Gui and Gui.Parent then
			if Gui:GetAttribute("IdGui") and Gui:GetAttribute("IdGui") ~= "" then
				if GuiComponents.Components[Gui:GetAttribute("IdGui")] then
					GuiComponents.Components[Gui:GetAttribute("IdGui")](Gui)
				end
			end
		end
	end

	local Essentials = game.StarterGui:GetChildren()
	for _, Essential in pairs(Essentials) do
		local Key = Essential.Name
		local Gui = GuiComponents.PlayerGui:WaitForChild(Key)
		Apply(Gui)
		for _, V in pairs(Gui:GetDescendants()) do
			Apply(V)
		end
		Gui.DescendantAdded:Connect(Apply)
	end
	
end

return GuiComponents