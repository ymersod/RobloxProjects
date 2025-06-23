local ServerScriptService = game:GetService("ServerScriptService")
local dailyRewardScript =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("dailyReward")

local dailyRewardFunctions = require(dailyRewardScript)
