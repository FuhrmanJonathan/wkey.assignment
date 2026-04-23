local RunService = game:GetService("RunService")

local Systems = {}
Systems.Cache = nil

local function LoadModulesFrom(Folder, Modules)
	for _, Instance in ipairs(Folder:GetDescendants()) do
		if Instance:IsA("ModuleScript") then
			Modules[Instance.Name] = require(Instance)
		end
	end
end

function Systems:Get()
	if not self.Cache then
		local Modules = {}

		local SharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Systems")
		LoadModulesFrom(SharedFolder, Modules)

		if RunService:IsServer() then
			local ServerFolder = game:GetService("ServerScriptService"):WaitForChild("Systems")
			LoadModulesFrom(ServerFolder, Modules)
		end

		self.Cache = Modules
	end

	return self.Cache
end

return Systems