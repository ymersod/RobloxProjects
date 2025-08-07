local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local equipServerEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")
local CoreGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
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
local iconTargetPrefab = equippedSlapstylePrefab:WaitForChild("IconParent")

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
		local icon: Frame = slotUI:FindFirstChild("IconParent")

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
local slotUIStateConfigs = {
	[slotStateEnums.Locked] = {
		visible = {
			bg = true,
			stats = false,
			button = false,
			img = false,
		},
		transparency = 0.4,
		gradient = ColorSequence.new(enums.Colors.NotUnlockedBpSpace.Color),
		setState = slotStateEnums.Locked,
		tween = function() end,
	},

	[slotStateEnums.UnlockedNoTool] = {
		visible = {
			bg = true,
			stats = false,
			button = false,
			img = false,
		},
		transparency = 0.4,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		}),
		setState = slotStateEnums.UnlockedNoTool,
		tween = function() end,
	},

	[slotStateEnums.UnlockedWithEquippedTool] = {
		visible = {
			bg = true,
			stats = true,
			button = true,
			img = true,
		},
		transparency = 0,
		useRarityGradient = true,
		setState = slotStateEnums.UnlockedWithEquippedTool,
		tween = function(tweenRefs)
			tweenRefs.bg.Grow:Play()
			tweenRefs.name.Grow:Play()
			tweenRefs.name.MoveOut:Play()
			tweenRefs.power.Grow:Play()
			tweenRefs.power.MoveOut:Play()
			tweenRefs.speed.Grow:Play()
			tweenRefs.speed.MoveOut:Play()
			tweenRefs.range.Grow:Play()
			tweenRefs.range.MoveOut:Play()
			tweenRefs.img.MoveOut:Play()
		end,
	},

	[slotStateEnums.UnlockedWithTool] = {
		visible = {
			bg = true,
			stats = true,
			button = true,
			img = false,
		},
		transparency = 0.4,
		useRarityGradient = true,
		setState = slotStateEnums.UnlockedWithTool,
		tween = function(tweenRefs)
			tweenRefs.bg.Shrink:Play()
			tweenRefs.name.Shrink:Play()
			tweenRefs.name.MoveIn:Play()
			tweenRefs.power.Shrink:Play()
			tweenRefs.power.MoveIn:Play()
			tweenRefs.speed.Shrink:Play()
			tweenRefs.speed.MoveIn:Play()
			tweenRefs.range.Shrink:Play()
			tweenRefs.range.MoveIn:Play()
			tweenRefs.img.MoveIn:Play()
		end,
	},
}

-- OTHER VARS
-- TODO: Should find new colors and put them in enums.Colors
local statBarColors = {
	DarkRed = Color3.fromRGB(139, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(128, 0, 128),
}

function onEquip(curSlot: Frame)
	SoundService:PlayLocalSound(sounds.Equip)
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
		warn("No bp-tool matching UI Slot")
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
			warn(bar.Name .. " value of: " .. val .. " is out of the 1–4 range")
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
	local SlotNrGUI = stats:FindFirstChild("Name"):FindFirstChild("SlotNr"):FindFirstChildOfClass("TextLabel")
	local iconP = slotUI:FindFirstChild("IconParent") :: Frame
	local button = bg:FindFirstChild("EquipButton") :: ImageButton
	local gradient = bg:FindFirstChildOfClass("UIGradient")
	local nameFrame = stats:WaitForChild("Name") :: Frame

	local parent = slotUI.Parent
	if not parent then
		warn("SlotSpace gone??")
		return
	end

	local slotNumber = parent:GetAttribute("SlotNumber")
	local localTweens = tweens[slotNumber]
	local rarity = tool and tool:GetAttribute("Rarity")
	local rarityColors = enums.Colors.RarityColor

	local config = slotUIStateConfigs[state]
	if not config then
		warn("Unknown UI state:", state)
		return
	end

	-- Apply visibility
	bg.Visible = config.visible.bg
	stats.Visible = config.visible.stats
	button.Visible = config.visible.button
	iconP.Visible = config.visible.img

	SlotNrGUI.Text = slotNumber

	-- Apply gradient
	if config.useRarityGradient and rarity and rarityColors[rarity] then
		local color = rarityColors[rarity]
		if color.Start and color.End then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Start),
				ColorSequenceKeypoint.new(1, color.End),
			})
			nameFrame.BackgroundColor3 = color.End
		end
	elseif config.gradient then
		gradient.Color = config.gradient
	end

	-- Transparency
	bg.Transparency = config.transparency

	-- Tween execution
	if config.tween then
		config.tween(localTweens)
	end

	-- Set state attribute
	parent:SetAttribute("SlotState", config.setState)
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
			--print("On saveslot:" .. saveSlot .. " Open slots: " .. openSlots)
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
		local inventoryIconRef: ObjectValue? = foundTool and foundTool:FindFirstChild("InventoryIcon")
		local invetoryIcon = inventoryIconRef and inventoryIconRef.Value :: Frame?
		if foundTool and invetoryIcon then
			local equipButton = slotUI:FindFirstChild("Bg"):FindFirstChildOfClass("ImageButton")
			local iconParent = slotUI:FindFirstChild("IconParent")

			local curChild = iconParent:FindFirstChildOfClass("Frame")

			if not curChild or curChild.Name ~= invetoryIcon.Name then
				iconParent:ClearAllChildren()
				local iconClone = invetoryIcon:Clone()
				iconClone.Parent = iconParent
			end

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
			if
				slotState == ""
				or slotState == slotStateEnums.Locked
				or slotState == slotStateEnums.UnlockedNoTool
				or slotState == slotStateEnums.UnlockedWithTool
			then
				setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI, foundTool)
			elseif slotState == slotStateEnums.UnlockedWithEquippedTool then
				setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI, foundTool)
			end

			if equipButton:GetAttribute("ConnectionsSet") then
				continue
			end
			equipButton:SetAttribute("ConnectionsSet", true)

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
