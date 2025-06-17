local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inventoryFunctions = {}
local toolsFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")

function inventoryFunctions.AddToInventory(player: Player) end
function inventoryFunctions.GetInventory(player: Player) end

function Equip(playerChar: Model, tool: Tool)
	local toolRef = toolsFolder:FindFirstChild(tool.Name)

	if not toolRef then
		warn("Cant find tool")
		return
	end

	local toolClone = toolRef:Clone()

	toolClone.Parent = playerChar
end

function inventoryFunctions.EquipTool(player: Player, tool: Tool)
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
		elseif equippedTool.Name ~= tool.Name then
			print("Equip new tool tool")
			equippedTool:Destroy()
			Equip(playerChar, tool)
		else
			print("Unequip active tool")
			equippedTool:Destroy()
		end
	end
end

function inventoryFunctions.EquipBomb(player: Player, bomb: Tool, cd: number)
	local playerChar = player.Character
	if not playerChar then
		warn("Playerchar not found")
		return
	end

	local equippedTool = playerChar:FindFirstChildOfClass("Tool")

	if equippedTool then
		if equippedTool.Name == "Bomb" then
			return
		end

		local equippedClone = equippedTool:Clone()
		equippedClone.Parent = ReplicatedStorage
		equippedTool:Destroy()
		wait(cd)
		bomb.Parent = player.Character

		bomb.AncestryChanged:Once(function()
			print("Re-equip")
			Equip(playerChar, equippedClone)
		end)
	else
		bomb.Parent = player
	end
end
return inventoryFunctions
