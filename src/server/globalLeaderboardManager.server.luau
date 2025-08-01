local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local globalLeaderBoard = require(ServerScriptService.Server.ServerModuleScripts.globalLeaderBoard)
local leaderboardManagersInScene: { Instance } = CollectionService:GetTagged("GlobalLeaderBoard")
local leaderboardManager = leaderboardManagersInScene and leaderboardManagersInScene[1]
local playerInfoPrefab = leaderboardManager and leaderboardManager:FindFirstChildOfClass("Frame")

local leadboards: { Part } = {}
if leaderboardManager then
	for _, leaderBoard in leaderboardManager:GetChildren() do
		if leaderBoard:IsA("Part") then
			table.insert(leadboards, leaderBoard)
		end
	end
end

if not playerInfoPrefab and #leadboards >= 0 then
	warn("Something went wrong in initalizing leaderboard locals")
	return
end

function setup()
	if leaderboardManager then
		for _, leaderBoard in leaderboardManager:GetChildren() do
			if leaderBoard:IsA("Part") then
				table.insert(leadboards, leaderBoard)
			end
		end
	end
end
setup()

local leaderboardCoroutine = coroutine.create(function()
	while true do
		local sortedLevels = globalLeaderBoard.GetTop10()
		local playerRanks = {}
		for i, e in ipairs(sortedLevels) do
			local success, playerName = pcall(function()
				return Players:GetNameFromUserIdAsync(e.key)
			end)
			if success then
				table.insert(playerRanks, { rank = i, name = playerName, lvl = e.value })
			end
		end

		for _, board in ipairs(leadboards) do
			local gridFrame = board:WaitForChild("SurfaceGui"):WaitForChild("GridFrame") :: Frame
			for _, child in ipairs(gridFrame:GetChildren()) do
				if not child:IsA("UIGridLayout") then
					child:Destroy()
				end
			end

			for _, p in ipairs(playerRanks) do
				local playerInfoClone = playerInfoPrefab:Clone()
				local rankText = playerInfoClone
					:FindFirstChild("RankFrame")
					:FindFirstChild("RankCircle")
					:FindFirstChildOfClass("TextLabel")
				local playerText = playerInfoClone:FindFirstChild("PlayerFrame"):FindFirstChildOfClass("TextLabel")
				local levelText = playerInfoClone:FindFirstChild("LevelFrame"):FindFirstChildOfClass("TextLabel")

				rankText.Text = p.rank
				playerText.Text = p.name
				levelText.Text = p.lvl
				playerInfoClone.Parent = gridFrame
			end
		end
		wait(2)
	end
end)

coroutine.resume(leaderboardCoroutine)
