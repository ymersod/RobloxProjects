local ReplicatedStorage = game:GetService("ReplicatedStorage")
local equipEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")
local addToInventoryEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("AddToInventoryServer")

local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

equipEvent.OnServerInvoke = function(player: Player, tool: Tool)
	return inventoryFuncs.EquipTool(player, tool)
end

addToInventoryEvent.OnServerInvoke = function(player: Player, tool: Tool, slot: number)
	return inventoryFuncs.AddToInventory(player, tool, slot)
end
