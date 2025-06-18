local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverInventoryFunctionsEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("InventoryFunctionsServer")

local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

serverInventoryFunctionsEvent.OnServerInvoke = function(player: Player, tool: Tool)
	-- print(player, tool)
	inventoryFuncs.EquipTool(player, tool)

	return "Success"
end
