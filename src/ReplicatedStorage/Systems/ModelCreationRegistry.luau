local ModelCreationRegistry = {}

ModelCreationRegistry.Enemy = function(Seed)
	local Randomizer = Random.new(Seed)

	local ModelData = {
		ModelScale = Randomizer:NextNumber(0.85, 1.25)
	}
	
	local Model = Instance.new("Model")
	Model.Name = "Enemy"
	
	local PrimaryPart = Instance.new("Part")
	PrimaryPart.Name = "PrimaryPart"
	PrimaryPart.Size = Vector3.new(1, 1, 1) * ModelData.ModelScale
	PrimaryPart.Anchored = true
	PrimaryPart.Parent = Model
	Model.PrimaryPart = PrimaryPart

	return Model
end

return ModelCreationRegistry