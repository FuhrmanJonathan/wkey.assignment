local ObjectStorage = require(game.ServerScriptService.Systems.ObjectStorage)
local ObjectSpawner = require(game.ServerScriptService.Systems.ObjectSpawner)
local GameSettings = require(game.ServerScriptService.Systems.GameSettings)
local EnemyBase = require(game.ServerScriptService.Systems.Classes.EnemyBase)

local EnemySpawner = {}

EnemySpawner.Running = false

function EnemySpawner:Start()
	if self.Running then
		return
	end
	
	self.Running = true
	
	task.spawn(function()
		while self.Running do
			self:Step()
			task.wait(1 / GameSettings.Values.EnemySpawnRate)
		end
	end)

    GameSettings.BindableSettingsChanged.Event:Connect(function(SettingName, Value)
        if SettingName == "EnemySpawnLimit" then
            local CurrentEnemies = ObjectStorage:GetAllObjectsWithParent(EnemyBase)
            local ExcessEnemies = #CurrentEnemies - Value

            if ExcessEnemies > 0 then
                for Index = 1, ExcessEnemies do
                    local EnemyToRemove = CurrentEnemies[Index]
                    if EnemyToRemove and EnemyToRemove.Destroy then
                        ObjectSpawner:Destroy(EnemyToRemove)
                    end
                end
            end
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
    
    if CurrentEnemyCount >= GameSettings.Values.EnemySpawnLimit then
        return
    end
    
    local EnemyObject = ObjectSpawner:Spawn(EnemyBase)
    ObjectStorage:AddObject(EnemyObject)
end

return EnemySpawner