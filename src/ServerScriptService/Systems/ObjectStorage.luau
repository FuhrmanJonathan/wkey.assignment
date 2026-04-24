local ObjectStorage = {}

ObjectStorage.ObjectsById = {}
ObjectStorage.ObjectsByParent = {}

local function IsDescendantOf(Object, ParentClassReference)
	local CurrentMetatable = getmetatable(Object)

	while CurrentMetatable do
		if CurrentMetatable == ParentClassReference then
			return true
		end

		CurrentMetatable = getmetatable(CurrentMetatable)
		if CurrentMetatable then
			CurrentMetatable = CurrentMetatable.__index
		end
	end

	return false
end

function ObjectStorage:AddObject(ObjectToAdd)
	if typeof(ObjectToAdd) ~= "table" then
		return
	end

	local ObjectId = ObjectToAdd.ObjectId
	if not ObjectId then
		error("ObjectToAdd is missing ObjectId")
	end

	self.ObjectsById[ObjectId] = ObjectToAdd

	for ParentClassReference, CachedObjects in pairs(self.ObjectsByParent) do
		if IsDescendantOf(ObjectToAdd, ParentClassReference) then
			CachedObjects[ObjectId] = ObjectToAdd
		end
	end
end

function ObjectStorage:RemoveObject(ObjectToRemove)
	if typeof(ObjectToRemove) ~= "table" then
		return
	end

	local ObjectId = ObjectToRemove.ObjectId
	if not ObjectId then
		return
	end

	self.ObjectsById[ObjectId] = nil

	for _, CachedObjects in pairs(self.ObjectsByParent) do
		CachedObjects[ObjectId] = nil
	end
end

function ObjectStorage:IsObjectADescendantOf(Object, ParentClassReference)
	if typeof(Object) ~= "table" then
		return false
	end

	local Meta = getmetatable(Object)
	if not Meta or not Meta.__index then
		return false
	end

	return IsDescendantOf(Object, ParentClassReference)
end

function ObjectStorage:GetAllObjectsWithParent(ParentClassReference, Exclude)
	local CachedObjects = self.ObjectsByParent[ParentClassReference]

	if not CachedObjects then
		CachedObjects = {}
		self.ObjectsByParent[ParentClassReference] = CachedObjects

		for ObjectId, TrackedObject in pairs(self.ObjectsById) do
			if IsDescendantOf(TrackedObject, ParentClassReference) then
				CachedObjects[ObjectId] = TrackedObject
			end
		end
	end

	local Result = {}
	local ExcludeSet = nil

	if Exclude then
		ExcludeSet = {}

		for _, Object in pairs(Exclude) do
			if typeof(Object) == "table" and Object.ObjectId then
				ExcludeSet[Object.ObjectId] = true
			end
		end
	end

	for ObjectId, Object in pairs(CachedObjects) do
		if not ExcludeSet or not ExcludeSet[ObjectId] then
			table.insert(Result, Object)
		end
	end

	return Result
end

return ObjectStorage