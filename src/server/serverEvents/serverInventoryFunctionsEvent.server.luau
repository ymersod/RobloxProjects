local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local addToInventoryEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("AddToInventoryServer")
local equipEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")
local incrementSlotsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("IncrementSlots")

local inventoryFunctions = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)

equipEvent.OnServerInvoke = function(player: Player, tool: Tool)
	return inventoryFunctions.EquipTool(player, tool)
end

addToInventoryEvent.OnServerInvoke = function(player: Player, tool: Tool, slot: number)
	return inventoryFunctions.AddToInventory(player, tool, slot)
end

incrementSlotsEvent.OnServerInvoke = function(player: Player)
	return inventoryFunctions.IncrementSlotSpace(player)
end
