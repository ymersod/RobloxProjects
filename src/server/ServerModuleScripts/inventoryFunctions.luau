local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inventoryFunctions = {}
local toolsFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")

function getCharacter(player)
	if player.Character then
		return player.Character
	else
		return player.CharacterAdded:Wait()
	end
end

function UnequipTool(playerChar: Model, tool: Tool)
	local equippedTool = playerChar:FindFirstChildOfClass("Tool")

	if equippedTool and equippedTool.Name ~= "Bomb" and tool.Name == equippedTool.Name then
		equippedTool:Destroy()
	else
		warn("Cant unequip that tool")
	end
end

function Equip(playerChar: Model, tool: Tool)
	local toEquipToolSaveSlot = tool:GetAttribute("SaveSlot")
	local toolRef = toolsFolder:FindFirstChild(tool.Name)
	if not toolRef then
		warn("Cant find tool")
		return
	end

	local toolClone = toolRef:Clone()
	toolClone.Parent = playerChar
	toolClone:SetAttribute("SaveSlot", toEquipToolSaveSlot)

	local slapLogic: Script? = toolClone.PrimaryPart and toolClone.PrimaryPart:FindFirstChildOfClass("Script")
	local abilityLogic: Script? = toolClone and toolClone:FindFirstChildOfClass("Script")
	if not slapLogic or not abilityLogic then
		warn("Could not find 1 or mroe logic scripts")
		return
	end

	slapLogic.Enabled = true
	abilityLogic.Enabled = true

	return toolClone
end

function removeToolsInSlot(playerChar: Model, inventory: Folder, slot: number)
	for _, toolInInventory in ipairs(inventory:GetChildren()) do
		if toolInInventory:IsA("Tool") then
			local toolInInventorySaveSlot = toolInInventory:GetAttribute("SaveSlot")
			if toolInInventorySaveSlot and tostring(toolInInventorySaveSlot) == tostring(slot) then
				UnequipTool(playerChar, toolInInventory)
				toolInInventory:Destroy()
			end
		end
	end
end

function inventoryFunctions.AddToInventory(player: Player, tool: Tool, slot: number)
	local inventory = player:FindFirstChild("Inventory") :: Folder?
	local playerChar = getCharacter(player)

	if inventory and playerChar then
		removeToolsInSlot(playerChar, inventory, slot)
		local slotsAvailable = inventory:FindFirstChildOfClass("IntValue").Value
		local invetoryCount = #inventory:GetChildren()
		if slotsAvailable and invetoryCount - 1 < slotsAvailable then
			local toolClone = tool:Clone()
			toolClone.Parent = inventory
			toolClone:SetAttribute("SaveSlot", slot)
			-- task.delay(2, function()
			-- 	tool:Destroy()
			-- end)
		else
			warn("No more room in inventory")
			return false
		end
	else
		warn("Cant find inventory on player, might not be initialized yet")
		return false
	end
	return true
end
function inventoryFunctions.GetInventory(player: Player): { Tool }
	local bpItems: { Tool } = {}
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

function inventoryFunctions.HasTool(player: Player, tool: Tool): boolean
	local inventory = player:FindFirstChild("Inventory")
	if inventory then
		for _, item in ipairs(inventory:GetChildren()) do
			if item:IsA("Tool") and item:GetAttribute("ToolId") == tool:GetAttribute("ToolId") then
				return true
			end
		end
	else
		warn("Cant find inventory on player, might not be initialized yet")
	end

	return false
end

function inventoryFunctions.RemoveFromInventory(player: Player, slotToRemove: number)
	local inventory = player:FindFirstChild("Inventory")
	local playerChar = getCharacter(player)
	if inventory then
		removeToolsInSlot(playerChar, inventory, slotToRemove)
	else
		warn("Inventory or tool not found")
	end
end

function inventoryFunctions.RemoveAllFromInventory(player: Player)
	local inventory = player:FindFirstChild("Inventory")

	if inventory then
		for _, tool in ipairs(inventory:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	else
		warn("Cant find inventory")
	end
end

function inventoryFunctions.EquipTool(player: Player, tool: Tool)
	local playerChar = getCharacter(player)
	if not playerChar then
		return
	end
	if not tool then
		warn("No tool was provided to equip")
		return
	end

	local equippedTool = playerChar:FindFirstChildOfClass("Tool")
	local equippedSaveSlot = equippedTool and equippedTool:GetAttribute("SaveSlot") :: number?
	local toolSaveSlot = tool:GetAttribute("SaveSlot") :: number?
	--Unequip active tool
	if not equippedTool then
		equippedTool = Equip(playerChar, tool)
		return equippedTool
	elseif equippedTool and equippedSaveSlot and toolSaveSlot then
		if equippedTool.Name == "Bomb" then
			print("Cant equip got bomb")
			return equippedTool
		elseif equippedSaveSlot ~= toolSaveSlot then
			print("Equip new tool tool")
			equippedTool:Destroy()
			equippedTool = Equip(playerChar, tool)
			return equippedTool
		else
			print("Unequip active tool")
			equippedTool:Destroy()
			return nil
		end
	end

	return nil
end

function inventoryFunctions.EquipBomb(player: Player, bomb: Tool, cd: number)
	local playerChar = getCharacter(player)
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
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum.Health > 0 then
				Equip(char, equippedClone)
			else
				print("player is dead")
			end
		end)
	else
		bomb.Parent = playerChar
	end
end

function inventoryFunctions.IncrementSlotSpace(player: Player)
	local inventory = player:FindFirstChild("Inventory") :: Folder?
	local value = inventory:FindFirstChildOfClass("IntValue")
	value.Value = value.Value + 1
end

return inventoryFunctions
