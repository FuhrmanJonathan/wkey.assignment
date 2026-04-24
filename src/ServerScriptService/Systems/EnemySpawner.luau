local ObjectStorage = require(game.ServerScriptService.Systems.ObjectStorage)
local ObjectSpawner = require(game.ServerScriptService.Systems.ObjectSpawner)
local EnemyBase = require(game.ServerScriptService.Systems.Classes.EnemyBase)

local EnemySpawner = {}

EnemySpawner.SpawnRate = 5
EnemySpawner.MaxEnemies = 20
EnemySpawner.Running = false

function EnemySpawner:Start()
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

function EnemySpawner:Step()
    
    local CurrentEnemyCount = 0
    for _, Object in pairs(ObjectStorage.ObjectsById) do
        if ObjectStorage:IsObjectADescendantOf(Object, EnemyBase) then
            CurrentEnemyCount = CurrentEnemyCount + 1
        end
    end
    
    if CurrentEnemyCount >= self.MaxEnemies then
        return
    end
    
    local EnemyObject = ObjectSpawner:Spawn(EnemyBase)
    ObjectStorage:AddObject(EnemyObject)
end

return EnemySpawner