local safeZones = game:GetService("CollectionService"):GetTagged("SafeZone")
local Players = game:GetService("Players")

local function isPlayerPositionInsideZone(position, safeZone)
	local zoneCenter = safeZone.Position
	local radius = safeZone.Size.y / 2 -- Look like its the y value that determines a sphere diameter, correct me if wrong :)

	return (position - zoneCenter).Magnitude <= radius
end

local function checkForEachZone(player)
	local character = player.Character
	if not character then
		player.States.Safe.Value = false
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		player.States.Safe.Value = false
		return
	end
	for _, safeZone in pairs(safeZones) do
		if isPlayerPositionInsideZone(root.Position, safeZone) then
			player.States.Safe.Value = true
			return
		end
	end
	player.States.Safe.Value = false
end
task.spawn(function()
	while true do
		for _, player in pairs(Players:GetPlayers()) do
			checkForEachZone(player)
		end
		task.wait(0.5)
	end
end)
