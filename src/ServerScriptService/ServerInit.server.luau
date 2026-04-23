local EnemySpawner = require(game.ServerScriptService.Systems.EnemySpawner)

local function ServerInitializationPipeline()
    EnemySpawner:Start()
end

ServerInitializationPipeline()