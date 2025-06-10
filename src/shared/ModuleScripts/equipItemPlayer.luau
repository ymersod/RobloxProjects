local equipModule = {}
local replicatedStorage = game:GetService("ReplicatedStorage")
local toolsFolder = game:GetService("ServerStorage"):WaitForChild("Tools")
local slapLogic = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")

function equipModule.EquipTool(player: Player, tool: Tool)
	local playerChar = player.Character
	if not playerChar then
		return
	end

	local equippedTool = playerChar:FindFirstChildOfClass("Tool")

	--Unequip active tool
	if equippedTool then --Unequip active tool
		if equippedTool.Name == "Bomb" then
			return
		else
			print("Destroying equipped tool")
			equippedTool:Destroy()
			return
		end
	end

	local toolRef = toolsFolder:FindFirstChild(tool.Name)
	local toolClone = toolRef:Clone()
	local slapLogicClone = slapLogic:Clone()
	slapLogicClone.Parent = toolClone:FindFirstChildOfClass("Part")

	toolClone.Parent = playerChar
end

return equipModule
