local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local levelupRewards = require(ServerScriptService.Server.ServerModuleScripts.levelupRewards)

local getRewardProgress = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("LevelupRewardsFunctions")
	:WaitForChild("getRewardProgress")
local progressRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("LevelupRewardsFunctions")
	:WaitForChild("progressRewards")

getRewardProgress.OnServerInvoke = function(player: Player)
	-- local f = dailyReward.getRewardProgress(player.UserId)
	-- print("ooo")
	return levelupRewards.getRewardProgress(player.UserId)
end

progressRewards.OnServerInvoke = function(player: Player)
	return levelupRewards.progressRewards(player.UserId)
end
