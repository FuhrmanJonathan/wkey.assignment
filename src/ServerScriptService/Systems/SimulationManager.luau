local ObjectStorage = require(game.ServerScriptService.Systems.ObjectStorage)
local RunService = game:GetService("RunService")

local SimulationManager = {}

function SimulationManager:Start()
	if self.Running then
		return
	end
	
	self.Running = true
	
	RunService.Heartbeat:Connect(function(DeltaTime)
        self:Simulate(DeltaTime)
    end)
end

return SimulationManager