local leaderboardScript = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("DynamicLogic")
	:WaitForChild("globalLeaderboard")
local collectionService = game:GetService("CollectionService")
local tag = "GlobalLeaderBoard"
for _, obj in ipairs(collectionService:GetTagged(tag)) do
	local scriptClone = leaderboardScript:Clone()
	scriptClone.Parent = obj
end
