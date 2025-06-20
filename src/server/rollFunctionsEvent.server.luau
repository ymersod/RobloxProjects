local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")

local rollFunctions = require(ReplicatedStorage.Shared.ModuleScripts.rollSystemManager)

rollEvent.OnServerInvoke = function(player: Player, rollSlot: number)
	return rollFunctions.getNewItem(player, rollSlot)
end
