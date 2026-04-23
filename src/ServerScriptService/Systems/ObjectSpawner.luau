local ObjectSpawner = {}

local ServerObjectStorage = require(script.Parent.ServerObjectStorage)

ObjectSpawner.ActiveObjects = {}

function ObjectSpawner:Spawn(ClassReference, ...)

	local Object = ClassReference.New(...)
	local ObjectId = Object.ObjectId

	ServerObjectStorage:AddObject(Object)

	self.ActiveObjects[ObjectId] = Object

	return Object
end

function ObjectSpawner:Destroy(Object)
	if not Object then
		return
	end

	local ObjectId = Object.ObjectId

	if not ObjectId then
		return
	end

	if Object.Destroy then
		Object:Destroy()
	end

	ServerObjectStorage:RemoveObject(Object)

	self.ActiveObjects[ObjectId] = nil
end

function ObjectSpawner:Get(ObjectId)
	return self.ActiveObjects[ObjectId]
end

function ObjectSpawner:GetAll()
	return self.ActiveObjects
end

function ObjectSpawner:DestroyAll()
	for _, Object in pairs(self.ActiveObjects) do
		self:Destroy(Object)
	end
end

return ObjectSpawner