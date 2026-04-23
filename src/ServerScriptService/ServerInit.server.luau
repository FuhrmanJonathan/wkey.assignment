local Systems = require(game.ReplicatedFirst.SystemLoader):Get()

local function ServerInitializationPipeline()
    Systems.EnemySpawnerSystem:Start()
end

ServerInitializationPipeline()