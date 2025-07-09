local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local getDailyRewardsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DataFunctions")
	:WaitForChild("getDailyRewards")
local getLevelUpRewardsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DataFunctions")
	:WaitForChild("getLevelUpRewards")
local RewardsData = require(ServerScriptService.Server.DataModules.RewardsData)

getDailyRewardsEvent.OnServerInvoke = function()
	return RewardsData.GetDailyRewardsData()
end

getLevelUpRewardsEvent.OnServerInvoke = function()
	return RewardsData.GetLevelupRewardsData()
end
