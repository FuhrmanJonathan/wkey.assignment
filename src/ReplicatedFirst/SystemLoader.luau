local Systems = {}
Systems.Cache = nil

local function LoadModulesFrom(Folder)
	local Modules = {}

	for _, ModuleScript in ipairs(Folder:GetDescendants()) do
		if ModuleScript:IsA("ModuleScript") then
			Modules[ModuleScript.Name] = require(ModuleScript)
		end
	end

	return Modules
end

function Systems:Get()
	if not self.Cache then
		local SharedFolder = game.ReplicatedStorage:WaitForChild("Systems")
        
		self.Cache = LoadModulesFrom(SharedFolder)
	end

	return self.Cache
end

return Systems