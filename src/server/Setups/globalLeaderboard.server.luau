local leaderboardScript = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("DynamicLogic")
	:WaitForChild("globalLeaderboard")

local leaderboardPart = workspace:FindFirstChild("leaderboard")
leaderboardScript.Parent = leaderboardPart