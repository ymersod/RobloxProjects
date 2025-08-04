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
				for i = 1, 10 do
					local gridFrame = leaderBoard:WaitForChild("SurfaceGui"):WaitForChild("GridFrame") :: Frame
					local playerInfoClone = playerInfoPrefab:Clone()
					local rankText = playerInfoClone
						:FindFirstChild("RankFrame")
						:FindFirstChild("RankCircle")
						:FindFirstChildOfClass("TextLabel")
					rankText.Text = i
					playerInfoClone:SetAttribute("nr", i)
					playerInfoClone.Parent = gridFrame

					table.insert(leadboards, leaderBoard)
				end
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
			local gridFrameChildren =
				board:FindFirstChildOfClass("SurfaceGui"):FindFirstChild("GridFrame"):GetChildren()

			for _, playerInfo in ipairs(gridFrameChildren) do
				if not playerInfo:IsA("Frame") then
					continue
				end
				local rank = playerInfo:GetAttribute("nr")

				local foundEntry = nil
				for _, entry in ipairs(playerRanks) do
					if entry.rank == rank then
						foundEntry = entry
						break
					end
				end

				local playerText = playerInfo:FindFirstChild("PlayerFrame"):FindFirstChildOfClass("TextLabel")
				local levelText = playerInfo:FindFirstChild("LevelFrame"):FindFirstChildOfClass("TextLabel")
				if foundEntry then
					playerText.Text = foundEntry.name
					levelText.Text = foundEntry.lvl
				else
					playerText.Text = "???"
					levelText.Text = "???"
				end
			end
		end
		wait(2)
	end
end)

coroutine.resume(leaderboardCoroutine)
