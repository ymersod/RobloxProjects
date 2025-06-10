local ReplicatedStorage = game:GetService("ReplicatedStorage")
local equipServerEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("EquipServerEvent")

local eqiupModule = require(ReplicatedStorage.Shared.ModuleScripts.equipItemPlayer)

equipServerEvent.OnServerEvent:Connect(function(player: Player, tool: Tool)
	print(player, tool)
	eqiupModule.EquipTool(player, tool)
end)
