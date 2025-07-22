local CollectionService = game:GetService("CollectionService")
local platforms: { Part } = CollectionService:GetTagged("DissapearingPlatform")
local CHECK_INTERVAL = 0.05

for _, platform in platforms do
	local SPEED = platform:GetAttribute("Speed")
	local COOLDOWN = platform:GetAttribute("Cooldown")
	local hitBox: Part? = platform:FindFirstChild("HitBox")
	if not hitBox then
		hitBox = platform
	end
	if hitBox then
		hitBox.Touched:Connect(function()
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
end
