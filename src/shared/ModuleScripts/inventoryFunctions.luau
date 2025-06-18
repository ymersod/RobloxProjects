local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inventoryFunctions = {}
local toolsFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")
function inventoryFunctions.AddToInventory(player: Player, tool: Tool)
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		local toolClone = tool:Clone()
		toolClone.Parent = inventory
	else
		warn("Cant find inventory on player, might not be initialized yet")
	end
end
function inventoryFunctions.GetInventory(player: Player)
	local bpItems = {}
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		for _, item in ipairs(inventory:GetChildren()) do
			table.insert(bpItems, item)
		end
	else
		warn("Cant find inventory on player, might not be initialized yet")
	end

	return bpItems
end

function Equip(playerChar: Model, tool: Tool)
	local toolRef = toolsFolder:FindFirstChild(tool.Name)

	if not toolRef then
		warn("Cant find tool")
		return
	end

	local toolClone = toolRef:Clone()
	toolClone.Parent = playerChar

	local slapLogic: Script? = toolClone.PrimaryPart and toolClone.PrimaryPart:FindFirstChildOfClass("Script")
	if not slapLogic then
		warn("Could not find slaplogic")
		return
	end

	slapLogic.Enabled = true

	return toolClone
end

function inventoryFunctions.EquipTool(player: Player, tool: Tool)
	local playerChar = player.Character
	if not playerChar then
		return
	end
	if not tool then
		warn("No tool was provided to equip")
		return
	end

	local equippedTool = playerChar:FindFirstChildOfClass("Tool")

	--Unequip active tool
	if not equippedTool then
		equippedTool = Equip(playerChar, tool)
	elseif equippedTool then
		if equippedTool.Name == "Bomb" then
			print("Cant equip got bomb")
			return
		elseif equippedTool.Name ~= tool.Name then
			print("Equip new tool tool")
			equippedTool:Destroy()
			equippedTool = Equip(playerChar, tool)
		else
			print("Unequip active tool")
			equippedTool:Destroy()
		end
	end

	if equippedTool == nil then
		return "None"
	else
		return equippedTool.Name
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
