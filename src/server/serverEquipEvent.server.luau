local ReplicatedStorage = game:GetService("ReplicatedStorage")
local equipServerEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("EquipServerEvent")

local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

equipServerEvent.OnServerEvent:Connect(function(player: Player, tool: Tool)
	print(player, tool)
	inventoryFuncs.EquipTool(player, tool)
end)
