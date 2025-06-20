local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")

local rollFunctions = require(ReplicatedStorage.Shared.ModuleScripts.rollSystemManager)

rollEvent.OnServerInvoke = function(player: Player)
	return rollFunctions.getNewItem(player)
end
