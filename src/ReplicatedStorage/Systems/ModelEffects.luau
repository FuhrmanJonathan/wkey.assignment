local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelEffects = {}

function ModelEffects:Highlight(Model, Duration)
	local Highlight = Instance.new("Highlight")
	Highlight.Adornee = Model
	Highlight.Parent = workspace

	task.delay(Duration, function()
		if Highlight then
			Highlight:Destroy()
		end
	end)

	return Highlight
end

function ModelEffects:Hit(Model)
	local Highlight = ModelEffects:Highlight(Model, 0.25)
	Highlight.FillColor = Color3.new(1, 0, 0)
	Highlight.OutlineColor = Color3.new(1, 0, 0)
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	local Sound = ReplicatedStorage.Sounds.Hit:Clone()
	Sound.Parent = Model
	Sound:Play()

	task.delay(Sound.TimeLength, function()
		if Sound then
			Sound:Destroy()
		end
	end)
end

return ModelEffects