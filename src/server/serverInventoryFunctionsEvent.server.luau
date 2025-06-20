local ReplicatedStorage = game:GetService("ReplicatedStorage")
local equipEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")

local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

equipEvent.OnServerInvoke = function(player: Player, tool: Tool)
	return inventoryFuncs.EquipTool(player, tool)
end
