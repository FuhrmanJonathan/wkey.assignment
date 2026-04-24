local GameSettings = require(game.ServerScriptService.Systems.GameSettings)

local EnemySpawner = require(game.ServerScriptService.Systems.EnemySpawner)
local ServerRendering = require(game.ServerScriptService.Systems.ServerRendering)
local SimulationManager = require(game.ServerScriptService.Systems.SimulationManager)

local function ServerInitializationPipeline()
    GameSettings:Start()

    EnemySpawner:Start()
    ServerRendering:Start()
    SimulationManager:Start()
end

ServerInitializationPipeline()