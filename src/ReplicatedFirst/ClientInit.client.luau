local ClientRendering = require(game.ReplicatedStorage:WaitForChild("Systems"):WaitForChild("ClientRendering"))

local function ClientInitializationPipeline()
    ClientRendering:Start()
end

ClientInitializationPipeline()