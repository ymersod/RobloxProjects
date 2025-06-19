local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverInventoryFunctionsEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("InventoryFunctionsServer")

local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

serverInventoryFunctionsEvent.OnServerInvoke = function(player: Player, tool: Tool, arg: string)
	-- print(player, tool)

	if arg and arg == "Equip" then
		return inventoryFuncs.EquipTool(player, tool)
	elseif arg == "GetInventory" then
		return inventoryFuncs.GetInventory(player)
	else
		return nil
	end
end
