local safezone = script.Parent
local Players = game:GetService("Players")

local function isPlayerPositionInsideZone(position)
	local zoneCenter = safezone.Position
	local radius = safezone.Size.y / 2 -- Look like its the y value that determines a sphere diameter, correct me if wrong :)

	return (position - zoneCenter).Magnitude <= radius
end

task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			local character = player.Character
			if not character then
				player.States.Safe.Value = false
				continue
			end

			local root = character:FindFirstChild("HumanoidRootPart")
			if not root then
				player.States.Safe.Value = false
				continue
			end
			player.States.Safe.Value = isPlayerPositionInsideZone(root.Position)
		end
		task.wait(0.5) -- Determines how often it runs, better than every frame
	end
end)

--The touch and touch ended did not work very well in multiplayer
--[[safezone.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and not playersTouching[player] then
		player.States.Safe.Value = true
		playersTouching[player] = true
	end
end)

safezone.TouchEnded:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and playersTouching[player] then
		print("yoyoyoyo")
		player.States.Safe.Value = false
		playersTouching[player] = nil
	end
end)]]
