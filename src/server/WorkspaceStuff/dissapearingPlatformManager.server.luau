local CollectionService = game:GetService("CollectionService")
local platforms: { Part } = CollectionService:GetTagged("DissapearingPlatform")
local CHECK_INTERVAL = 0.05

for _, platform in platforms do
	local SPEED = platform:GetAttribute("Speed")
	local COOLDOWN = platform:GetAttribute("Cooldown")

	platform.Touched:Connect(function()
		local platformTransparency = platform.Transparency
		while platformTransparency < 1 do
			platform.Transparency = platformTransparency + SPEED
			platformTransparency = platform.Transparency
			task.wait(CHECK_INTERVAL)
		end
		platform.CanCollide = false

		task.delay(COOLDOWN, function()
			platform.Transparency = 0
			platform.CanCollide = true
		end)
	end)
end
