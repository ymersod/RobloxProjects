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
local nameTargetPrefab: Frame = statsTargetPrefab:WaitForChild("Name")
local powerTargetPrefab: Frame = statsTargetPrefab:WaitForChild("Power")
local rangeTargetPrefab: Frame = statsTargetPrefab:WaitForChild("Range")
local speedTargetPrefab: Frame = statsTargetPrefab:WaitForChild("Speed")
local iconTargetPrefab: ImageLabel = equippedSlapstylePrefab:WaitForChild("Img")

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
local tweens: {
	[number]: {
		bg: {
			Grow: Tween,
			Shrink: Tween,
		},
		name: {
			Grow: Tween,
			Shrink: Tween,
			MoveOut: Tween,
			MoveIn: Tween,
		},
		power: {
			Grow: Tween,
			Shrink: Tween,
			MoveOut: Tween,
			MoveIn: Tween,
		},
		range: {
			Grow: Tween,
			Shrink: Tween,
			MoveOut: Tween,
			MoveIn: Tween,
		},
		speed: {
			Grow: Tween,
			Shrink: Tween,
			MoveOut: Tween,
			MoveIn: Tween,
		},
		img: {
			MoveOut: Tween,
			MoveIn: Tween,
		},
	},
} =
	{}
for _, child in ipairs(inventorySlotsParent:GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)

		local slotUI = child:FindFirstChildOfClass("Frame")
		local bg: Frame = slotUI:FindFirstChild("Bg")
		local statsFrame = slotUI:FindFirstChild("Stats")
		local name: Frame = statsFrame:FindFirstChild("Name")
		local power: Frame = statsFrame:FindFirstChild("Power")
		local range: Frame = statsFrame:FindFirstChild("Range")
		local speed: Frame = statsFrame:FindFirstChild("Speed")
		local icon: ImageLabel = slotUI:FindFirstChild("Img")

		local growBgTween = createTweenFunctions.Grow2(bg, 0.1, bgTargetPrefab.Size)
		local shrinkBgTween = createTweenFunctions.Shrink2(bg, 0.1, bg.Size)

		local growNameTween = createTweenFunctions.Grow2(name, 0.1, nameTargetPrefab.Size)
		local moveNameTweenOut = createTweenFunctions.MoveTo(name, 0.1, nameTargetPrefab.Position)
		local shrinkNameTween = createTweenFunctions.Shrink2(name, 0.1, name.Size)
		local moveNameTweenIn = createTweenFunctions.MoveTo(name, 0.1, name.Position)

		local growPowerTween = createTweenFunctions.Grow2(power, 0.1, powerTargetPrefab.Size)
		local movePowerTweenOut = createTweenFunctions.MoveTo(power, 0.1, powerTargetPrefab.Position)
		local shrinkPowerTween = createTweenFunctions.Shrink2(power, 0.1, power.Size)
		local movePowerTweenIn = createTweenFunctions.MoveTo(power, 0.1, power.Position)

		local growRangeTween = createTweenFunctions.Grow2(range, 0.1, rangeTargetPrefab.Size)
		local moveRangeTweenOut = createTweenFunctions.MoveTo(range, 0.1, rangeTargetPrefab.Position)
		local shrinkRangeTween = createTweenFunctions.Shrink2(range, 0.1, range.Size)
		local moveRangeTweenIn = createTweenFunctions.MoveTo(range, 0.1, range.Position)

		local growSpeedTween = createTweenFunctions.Grow2(speed, 0.1, speedTargetPrefab.Size)
		local moveSpeedTweenOut = createTweenFunctions.MoveTo(speed, 0.1, speedTargetPrefab.Position)
		local shrinkSpeedTween = createTweenFunctions.Shrink2(speed, 0.1, speed.Size)
		local moveSpeedTweenIn = createTweenFunctions.MoveTo(speed, 0.1, speed.Position)

		local moveImgOut = createTweenFunctions.MoveTo(icon, 0.1, iconTargetPrefab.Position)
		local moveImgIn = createTweenFunctions.MoveTo(icon, 0.1, icon.Position)

		tweens[child:GetAttribute("SlotNumber")] = {
			bg = {
				Grow = growBgTween,
				Shrink = shrinkBgTween,
			},
			name = {
				Grow = growNameTween,
				Shrink = shrinkNameTween,
				MoveOut = moveNameTweenOut,
				MoveIn = moveNameTweenIn,
			},
			power = {
				Grow = growPowerTween,
				Shrink = shrinkPowerTween,
				MoveOut = movePowerTweenOut,
				MoveIn = movePowerTweenIn,
			},
			range = {
				Grow = growRangeTween,
				Shrink = shrinkRangeTween,
				MoveOut = moveRangeTweenOut,
				MoveIn = moveRangeTweenIn,
			},
			speed = {
				Grow = growSpeedTween,
				Shrink = shrinkSpeedTween,
				MoveOut = moveSpeedTweenOut,
				MoveIn = moveSpeedTweenIn,
			},
			img = {
				MoveOut = moveImgOut,
				MoveIn = moveImgIn,
			},
		}
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

function onEquip(curSlot: Frame)
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
	print("Returned slapStyle: ", result)
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

function setStateOfSlotUI(state, slotUI: Frame, tool)
	local bg = slotUI:FindFirstChild("Bg") :: Frame
	local stats = slotUI:FindFirstChild("Stats") :: Frame
	local img = slotUI:FindFirstChild("Img") :: ImageLabel
	local button = bg:FindFirstChild("EquipButton") :: ImageButton
	local gradient = bg:FindFirstChildOfClass("UIGradient")
	local nameFrame = stats:WaitForChild("Name") :: Frame

	local rarity = tool and tool:GetAttribute("Rarity") :: string?
	local rarityColors = enums.Colors.RarityColor

	local parent = slotUI.Parent

	if not parent then
		warn("SlotSpace gone??")
		return
	end
	local slotNumber = parent and parent:GetAttribute("SlotNumber")

	if state == slotStateEnums.Locked then
		bg.Visible = true
		gradient.Color = ColorSequence.new(enums.Colors.NotUnlockedBpSpace.Color)

		stats.Visible = false
		button.Visible = false
		img.Visible = false

		parent:SetAttribute("SlotState", slotStateEnums.Locked)
	elseif state == slotStateEnums.UnlockedNoTool then
		bg.Visible = true
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})

		stats.Visible = false
		button.Visible = false
		img.Visible = false

		parent:SetAttribute("SlotState", slotStateEnums.UnlockedNoTool)
	elseif state == slotStateEnums.UnlockedWithEquippedTool then
		local colorScheme = rarityColors and rarityColors[rarity]
		if colorScheme and typeof(colorScheme) == "table" and colorScheme.Start and colorScheme.End then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorScheme.Start),
				ColorSequenceKeypoint.new(1, colorScheme.End),
			})
			nameFrame.BackgroundColor3 = colorScheme.End
		end
		bg.Transparency = 0

		bg.Visible = true

		stats.Visible = true
		button.Visible = true
		img.Visible = true

		local localTweens = tweens[slotNumber]
		localTweens.bg.Grow:Play()
		localTweens.name.Grow:Play()
		localTweens.name.MoveOut:Play()
		localTweens.power.Grow:Play()
		localTweens.power.MoveOut:Play()
		localTweens.speed.Grow:Play()
		localTweens.speed.MoveOut:Play()
		localTweens.range.Grow:Play()
		localTweens.range.MoveOut:Play()
		localTweens.img.MoveOut:Play()

		parent:SetAttribute("SlotState", slotStateEnums.UnlockedWithEquippedTool)
	elseif state == slotStateEnums.UnlockedWithTool then
		local colorScheme = rarityColors and rarityColors[rarity]
		if colorScheme and typeof(colorScheme) == "table" and colorScheme.Start and colorScheme.End then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorScheme.Start),
				ColorSequenceKeypoint.new(1, colorScheme.End),
			})
			nameFrame.BackgroundColor3 = colorScheme.End
		end
		bg.Transparency = 0.4

		bg.Visible = true

		stats.Visible = true
		button.Visible = true
		img.Visible = false

		local localTweens = tweens[slotNumber]
		localTweens.bg.Shrink:Play()
		localTweens.name.Shrink:Play()
		localTweens.name.MoveIn:Play()
		localTweens.power.Shrink:Play()
		localTweens.power.MoveIn:Play()
		localTweens.speed.Shrink:Play()
		localTweens.speed.MoveIn:Play()
		localTweens.range.Shrink:Play()
		localTweens.range.MoveIn:Play()
		localTweens.img.MoveIn:Play()

		parent:SetAttribute("SlotState", slotStateEnums.UnlockedWithTool)
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

			local slotState = slotUI.Parent:GetAttribute("SlotState")
			if slotState == "" or slotState == slotStateEnums.Locked or slotState == slotStateEnums.UnlockedNoTool then
				setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI, foundTool)
			end

			equipButton.MouseButton1Click:Connect(function()
				onEquip(slotUI.Parent)
			end)
		else
			setStateOfSlotUI(slotStateEnums.UnlockedNoTool, slotUI)
		end
	end
end

function trackBackpack()
	local inventory = player:FindFirstChild("Inventory")
	local availableSlot = inventory:FindFirstChildOfClass("IntValue")

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

	availableSlot.Changed:Connect(function()
		updateBackpackGUI()
	end)

	local function updateEquippedGUI()
		local tool = player.Character:FindFirstChildOfClass("Tool")
		local toolSlot = tool and tool:GetAttribute("SaveSlot")

		if not toolSlot then
			warn("Tool not found")
		end

		for _, slot in ipairs(slotArr) do
			local slotNumber = slot:GetAttribute("SlotNumber")
			local slotGUI = slot:FindFirstChildOfClass("Frame")
			local state = slot:GetAttribute("SlotState")
			-- print("state: ", state)
			if tostring(slotNumber) == tostring(toolSlot) then -- Equip
				setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotGUI, tool)
			elseif state == slotStateEnums.UnlockedWithEquippedTool then --Unequip
				setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotGUI)
			end
		end
	end

	player.Character.ChildAdded:Connect(updateEquippedGUI)
	player.Character.ChildRemoved:Connect(updateEquippedGUI)

	player.CharacterAdded:Connect(function()
		player.Character.ChildAdded:Connect(updateEquippedGUI)
		player.Character.ChildRemoved:Connect(updateEquippedGUI)
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

		local character = player.Character
		local bomb = character:FindFirstChild("Bomb")
		local slotState = slotUIFound and slotUIFound:GetAttribute("SlotState")
		if
			slotUIFound
			and slotState
			and (slotState == slotStateEnums.UnlockedWithEquippedTool or slotState == slotStateEnums.UnlockedWithTool)
			and not bomb
		then
			onEquip(slotUIFound)
		else
			warn("Didnt find ui matching slot: ", slotIndex)
		end
	end
end)
