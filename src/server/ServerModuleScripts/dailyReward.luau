local DataStoreService = game:GetService("DataStoreService")
local rewardsStore = DataStoreService:GetDataStore("DailyRewards")


dailyRewardFunctions = {}

function dailyRewardFunctions.getAllRewards()
	return "lots a things"
end

function dailyRewardFunctions.getRewardProgress(playerId)
	local success, rewardProgress = pcall(function()
		return rewardsStore:GetAsync(playerId)
	end)
	if success then
		return { lastClaimedDate = rewardProgress:split(";")[1], count = rewardProgress:split(";")[2] }
	end
	return { lastClaimedDate = "n/a", count = "-1" }
end

function dailyRewardFunctions.progressRewards(playerId)
	local success, err = pcall(function()
		return rewardsStore:SetAsync(playerId,os.date("%x")..";"..1)
	end)
	if not success then
		warn(err)
	end
end

return dailyRewardFunctions