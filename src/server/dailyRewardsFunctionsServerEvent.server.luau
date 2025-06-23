local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local dailyReward = require(ServerScriptService.Server.ServerModuleScripts.dailyReward)

local getRewardProgress = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("getRewardProgress")
local progressRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("progressRewards")

getRewardProgress.OnServerInvoke = function(player: Player)
	-- local f = dailyReward.getRewardProgress(player.UserId)
	-- print("ooo")
	return dailyReward.getRewardProgress(player.UserId)
end

progressRewards.OnServerInvoke = function(player: Player)
	return dailyReward.progressRewards(player.UserId)
end
