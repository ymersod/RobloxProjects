local players = game:GetService("Players")

local function leaderboardSetup(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local kingScore = Instance.new("IntValue")
	kingScore.Name = "King Score"
	kingScore.Value = 0
	kingScore.Parent = leaderstats
end

players.PlayerAdded:Connect(leaderboardSetup)
