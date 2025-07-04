local TweenService = game:GetService("TweenService")
local sphere = script.Parent
local targetRadius = sphere.Size.y / 2
sphere.Size = Vector3.new(0, 0, 0)

local grow = TweenService:Create(
	sphere,
	TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ Size = Vector3.new(targetRadius * 2, targetRadius * 2, targetRadius * 2) }
)

-- tween 2: fade + 20 % shrink
local shrinkFade = TweenService:Create(sphere, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
	Size = Vector3.new(targetRadius * 2.1, targetRadius * 2.1, targetRadius * 2.1),
	Transparency = 1,
})

grow.Completed:Connect(function()
	print("hallo")
	shrinkFade:Play()
end)

shrinkFade.Completed:Connect(function()
	sphere:Destroy()
end)

grow:Play()
