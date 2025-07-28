local leaderboardScript = game:GetService("ServerScriptService")
	:WaitForChild("Server")
	:WaitForChild("DynamicLogic")
	:WaitForChild("globalLeaderboard")
local collectionService = game:GetService("CollectionService")
local tag = "GlobalLeaderBoard"
for _, obj in ipairs(collectionService:GetTagged(tag)) do
	local scriptClone = leaderboardScript:Clone()
	scriptClone.Parent = obj
	scriptClone.Enabled = true
end
