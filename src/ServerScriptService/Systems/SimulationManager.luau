local ObjectStorage = require(game.ServerScriptService.Systems.ObjectStorage)
local GameObjectBase = require(game.ServerScriptService.Systems.Classes.GameObjectBase)
local RunService = game:GetService("RunService")

local SimulationManager = {}

function SimulationManager:Start()
	if self.Running then
		return
	end
	
	self.Running = true
	
	RunService.Heartbeat:Connect(function(DeltaTime)
        for _, Object in pairs(ObjectStorage:GetAllObjectsWithParent(GameObjectBase)) do
            if Object.Simulate then
                Object:Simulate(DeltaTime)
            end
        end
    end)
end

return SimulationManager