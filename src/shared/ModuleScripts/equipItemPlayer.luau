local equipModule = {}
local toolsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Tools")

function Equip(playerChar: Model, tool: Tool)
	local toolRef = toolsFolder:FindFirstChild(tool.Name)
	local toolClone = toolRef:Clone()

	toolClone.Parent = playerChar
end

function equipModule.EquipTool(player: Player, tool: Tool)
	local playerChar = player.Character
	if not playerChar then
		return
	end

	local equippedTool = playerChar:FindFirstChildOfClass("Tool")

	--Unequip active tool
	if not equippedTool then
		Equip(playerChar, tool)
	elseif equippedTool then
		if equippedTool.Name == "Bomb" then
			return
		elseif not equippedTool or equippedTool.Name ~= tool.Name then
			print("Equip new tool tool")
			equippedTool:Destroy()
			Equip(playerChar, tool)
		else
			print("Unequip active tool")
			equippedTool:Destroy()
		end
	end
end

return equipModule
