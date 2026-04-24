local ModelCreationRegistry = {}

ModelCreationRegistry.Enemy = function(Seed)
	local Randomizer = Random.new(Seed)

	local ModelData = {
		ModelScale = Randomizer:NextNumber(0.5, 2),
		ModelColor = Color3.fromHSV(Randomizer:NextNumber(0, 1), 1, 1),
	}
	
	local Model = Instance.new("Model")
	Model.Name = "Enemy"
	
	local PrimaryPart = Instance.new("Part")
	PrimaryPart.Name = "PrimaryPart"
	PrimaryPart.Color = ModelData.ModelColor
	PrimaryPart.Size = Vector3.new(1, 1, 1) * ModelData.ModelScale
	PrimaryPart.Anchored = true
	PrimaryPart.CanCollide = false
	PrimaryPart.Parent = Model
	Model.PrimaryPart = PrimaryPart

	return Model
end

return ModelCreationRegistry