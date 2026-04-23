local Systems = require(game.ReplicatedFirst.SystemLoader):Get()

local EnemySpawnerSystem = {}

EnemySpawnerSystem.SpawnRate = 1
EnemySpawnerSystem.MaxEnemies = 20
EnemySpawnerSystem.Running = false

function EnemySpawnerSystem:Start()
	if self.Running then
		return
	end
	
	self.Running = true
	
	task.spawn(function()
		while self.Running do
			self:Step()
			task.wait(1 / self.SpawnRate)
		end
	end)
end

function EnemySpawnerSystem:Step()

    local ServerObjectStorage = Systems.ServerObjectStorage
    local EnemyBase = Systems.EnemyBase
    
    local CurrentEnemyCount = 0
    for _, Object in pairs(ServerObjectStorage.ObjectsById) do
        if ServerObjectStorage:IsObjectADescendantOf(Object, EnemyBase) then
            CurrentEnemyCount = CurrentEnemyCount + 1
        end
    end
    
    if CurrentEnemyCount >= self.MaxEnemies then
        return
    end
    
    print("Spawning a new enemy! Current count: " .. CurrentEnemyCount)
end

return EnemySpawnerSystem