local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")
local getOddsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("GetOddsServer")

local rollFunctions = require(ServerScriptService.Server.ServerModuleScripts.rollSystemManager)

rollEvent.OnServerInvoke = function(player: Player, rollSlot: number)
	return rollFunctions.getNewItem(player, rollSlot)
end

getOddsEvent.OnServerInvoke = function(_: Player): { common: number, uncommon: number, rare: number, legendary: number }
	return rollFunctions.GetOdds()
end
