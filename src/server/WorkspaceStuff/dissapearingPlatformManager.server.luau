local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local platforms: { Part } = CollectionService:GetTagged("DissapearingPlatform")
local CHECK_INTERVAL = 0.05

for _, platform in platforms do
	local SPEED = platform:GetAttribute("Speed")
	local COOLDOWN = platform:GetAttribute("Cooldown")
	local hitBox: Part? = platform:FindFirstChild("HitBox") or platform

	if hitBox then
		hitBox.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			if not character then
				return
			end

			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end

			-- Check if it's a "foot" part (R15) or HumanoidRootPart (fallback)
			local validFeetParts = {
				["LeftFoot"] = true,
				["RightFoot"] = true,
				["Left Leg"] = true, -- R6
				["Right Leg"] = true,
				["HumanoidRootPart"] = true, -- fallback
			}
			if not validFeetParts[hit.Name] then
				return
			end

			-- Prevent triggering again while already disappearing
			if platform.Transparency >= 1 then
				return
			end

			-- Fade out the platform
			local platformTransparency = platform.Transparency
			while platformTransparency < 1 do
				platform.Transparency = platformTransparency + SPEED
				platformTransparency = platform.Transparency
				task.wait(CHECK_INTERVAL)
			end
			platform.CanCollide = false

			-- Respawn after cooldown
			task.delay(COOLDOWN, function()
				platform.Transparency = 0
				platform.CanCollide = true
			end)
		end)
	end
end
