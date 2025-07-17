local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local equipServerEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")
local CoreGui = game:GetService("StarterGui")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local equippedSlapstylePrefab = ReplicatedStorage:WaitForChild("UI")
	:WaitForChild("DynamicGUI")
	:WaitForChild("Inventory")
	:WaitForChild("SlotUITweenReference")
local bgTargetPrefab = equippedSlapstylePrefab:WaitForChild("Bg")
local statsTargetPrefab = equippedSlapstylePrefab:WaitForChild("Stats")
local nameTargetPrefab = statsTargetPrefab:WaitForChild("Name")
local powerTargetPrefab = statsTargetPrefab:WaitForChild("Power")
local rangeTargetPrefab = statsTargetPrefab:WaitForChild("Range")
local speedTargetPrefab = statsTargetPrefab:WaitForChild("Speed")

local slotStateEnums = {
	Locked = 0,
	UnlockedNoTool = 1,
	UnlockedWithTool = 2,
	UnlockedWithEquippedTool = 3,
}

-- PLAYER GUI
local inventoryGUI = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Inventory")
local inventorySlotsParent = inventoryGUI:WaitForChild("CanvasGroup")

local slotArr: { Frame } = {}
local tweens: { [number]: { GrowBg: Tween, ShrinkBg: Tween } } = {}
for _, child in ipairs(inventorySlotsParent:GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)

		local slotUI = child:FindFirstChildOfClass("Frame")
		local bg: Frame = slotUI:FindFirstChild("Bg")

		local growBgTween = createTweenFunctions.Grow2(bg, 0.1, bgTargetPrefab.Size)
		local shrinkBgTween = createTweenFunctions.Shrink2(bg, 0.1, bg.Size)

		tweens[child:GetAttribute("SlotNumber")] = { GrowBg = growBgTween, ShrinkBg = shrinkBgTween }
	end
end

-- OTHER VARS
-- TODO: Should find new colors and put them in enums.Colors
local statBarColors = {
	DarkRed = Color3.fromRGB(139, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(128, 0, 128),
}

function onEquip(curSlot: Frame?)
	local id = curSlot and curSlot:GetAttribute("ToolIdRef") :: string?
	local inventorySaveSlot = curSlot and curSlot:GetAttribute("SlotNumber") :: number?
	if not id then
		warn("Cant find id of weap to equip")
		return
	end
	local curPlayerInventory = player:FindFirstChild("Inventory")
	local toolToEquip: Tool? = nil
	for _, toolInBp in ipairs(curPlayerInventory:GetChildren()) do
		local bpId = toolInBp:GetAttribute("ToolId") :: string?
		local toolSaveSlot = toolInBp:GetAttribute("SaveSlot") :: number?
		if
			bpId
			and toolSaveSlot
			and id
			and inventorySaveSlot
			and bpId == id
			and tostring(inventorySaveSlot) == tostring(toolSaveSlot)
		then
			toolToEquip = toolInBp
			break
		end
	end
	if not toolToEquip then
		warn("No bp-tool mathcing UI Slot")
		return
	end

	local playerChar = player.Character
	if not playerChar then
		warn("Playerchar not existing")
		return
	end
	local result = equipServerEvent:InvokeServer(toolToEquip) -- equip tool

	if result and result.name ~= "Bomb" then
		-- TODO: do something
	end
end
function extractDataFromTool(tool: Tool)
	local statVals = tool:FindFirstChild("StatVals")
	return {
		Damage = statVals:GetAttribute("Damage") :: number?,
		Range = statVals:GetAttribute("Range") :: number?,
		Speed = statVals:GetAttribute("Speed") :: number?,
		Icon = tool:GetAttribute("InventoryImageID") :: string?,
		ToolId = tool:GetAttribute("ToolId") :: string?,
		Name = tool:GetAttribute("name") :: string?,
	}
end

function updateStatBar(bar: Frame, val: number)
	if val >= 1 and val <= 4 then
		local scale, color

		if val == 1 then
			color = statBarColors.DarkRed
			scale = 0.25
		elseif val == 2 then
			color = statBarColors.Yellow
			scale = 0.5
		elseif val == 3 then
			color = statBarColors.Blue
			scale = 0.75
		elseif val == 4 then
			color = statBarColors.Purple
			scale = 1
		else
			warn(bar.Name .. " value of: " .. val .. " is not 1, 2, 3 or 4")
		end

		if color and scale then
			bar.BackgroundColor3 = color
			bar.Size = UDim2.new(scale, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
		end
	else
		warn(bar.Name .. " value of: " .. val .. " is out of the 1–4 range")
	end
end

function setStateOfSlotUI(state, slotUI: Frame)
	local bg = slotUI:FindFirstChild("Bg") :: Frame
	local stats = slotUI:FindFirstChild("Stats") :: Frame
	local button = bg:FindFirstChild("EquipButton") :: ImageButton
	local gradient = bg:FindFirstChildOfClass("UIGradient")
	local parent = slotUI.Parent
	local slotNumber = parent and parent:GetAttribute("SlotNumber")
	local equipped = parent and parent:GetAttribute("Equipped")

	if state == slotStateEnums.Locked then
		bg.Visible = true
		gradient.Color = ColorSequence.new(enums.Colors.NotUnlockedBpSpace.Color)

		stats.Visible = false
		button.Visible = false
	elseif state == slotStateEnums.UnlockedNoTool then
		bg.Visible = true
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})

		stats.Visible = false
		button.Visible = false
	elseif state == slotStateEnums.UnlockedWithEquippedTool then
		bg.Visible = true
		-- TODO: Should match rarity at some point
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})

		stats.Visible = true
		button.Visible = true

		tweens[slotNumber].GrowBg:Play()
	elseif state == slotStateEnums.UnlockedWithTool then
		bg.Visible = true
		-- TODO: Should match rarity at some point
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})

		stats.Visible = true
		button.Visible = true
		tweens[slotNumber].ShrinkBg:Play()
	end
end

function updateBackpackGUI()
	local playerInventory = player:FindFirstChild("Inventory")
	local openSlots = playerInventory:FindFirstChildOfClass("IntValue").Value
	local inventoryArr = playerInventory:GetChildren()

	-- if openslots = 2, 1 and 2 should be open
	for _, slot in ipairs(slotArr) do
		local slotUI = slot:FindFirstChildOfClass("Frame")
		local saveSlot: number = slot:GetAttribute("SlotNumber")

		if saveSlot > openSlots then
			print("On saveslot:" .. saveSlot .. " Open slots: " .. openSlots)
			setStateOfSlotUI(slotStateEnums.Locked, slotUI)
			continue
		end

		local foundTool = nil
		for _, inventoryTool in ipairs(inventoryArr) do
			if inventoryTool:IsA("Tool") then
				local toolSlot: number? = inventoryTool:GetAttribute("SaveSlot")
				if toolSlot and tostring(toolSlot) == tostring(saveSlot) then
					foundTool = inventoryTool
					-- print("saveslot: ", saveSlot, " toolslot: ", toolSlot)
					break
				end
			end
		end
		if foundTool then
			if not foundTool then
				warn("No slot for tool found")
				return
			end

			local equipButton = slotUI:FindFirstChild("Bg"):FindFirstChildOfClass("ImageButton")

			local data = extractDataFromTool(foundTool)
			local stats = slotUI:FindFirstChild("Stats") :: Frame
			updateStatBar(stats:FindFirstChild("Power"):WaitForChild("Fill"), data.Damage)
			updateStatBar(stats:FindFirstChild("Range"):WaitForChild("Fill"), data.Range)
			updateStatBar(stats:FindFirstChild("Speed"):WaitForChild("Fill"), data.Speed)
			stats:FindFirstChild("Name"):FindFirstChildOfClass("TextLabel").Text = data.Name

			local parent = slotUI.Parent
			local toolId = foundTool:GetAttribute("ToolId")
			local _ = parent and toolId and parent:SetAttribute("ToolIdRef", toolId)

			setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI)

			equipButton.MouseButton1Click:Connect(function()
				onEquip(slotUI.Parent)
				setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI)
			end)
		else
			setStateOfSlotUI(slotStateEnums.UnlockedNoTool, slotUI)
		end
	end
end

function trackBackpack()
	local inventory = player:FindFirstChild("Inventory")

	if not inventory then
		warn("inventory not initialized")
		return
	end
	updateBackpackGUI()

	inventory.ChildAdded:Connect(function(child)
		if child.Name == "Bomb" then
			return
		end
		updateBackpackGUI()
	end)

	inventory.ChildRemoved:Connect(function(child)
		if child.Name == "Bomb" then
			return
		end
		updateBackpackGUI()
	end)
end
trackBackpack()

local inventory: Folder = player:FindFirstChild("Inventory")
local slotsOpen = inventory:FindFirstChildOfClass("IntValue")

if not inventory or not slotsOpen then
	warn("Inventory or slotsopen not found")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local keyMap = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
		[Enum.KeyCode.Seven] = 7,
		[Enum.KeyCode.Eight] = 8,
		[Enum.KeyCode.Nine] = 9,
		[Enum.KeyCode.Zero] = 10,
	}

	local slotIndex = keyMap[input.KeyCode]
	if slotIndex and slotIndex <= slotsOpen.Value then
		local slotUIFound: Frame? = nil
		for _, slotSpace in ipairs(slotArr) do
			local slotSpaceVal = slotSpace:GetAttribute("SlotNumber")
			if tostring(slotIndex) == tostring(slotSpaceVal) then
				slotUIFound = slotSpace
			end
		end
		if slotUIFound then
			onEquip(slotUIFound)

			local slotUI = slotUIFound:FindFirstChildOfClass("Frame")
			setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI)
		else
			warn("Didnt find ui matching slot: ", slotIndex)
		end
	end
end)
