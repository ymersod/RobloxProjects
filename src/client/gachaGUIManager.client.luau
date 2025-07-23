local player = game:GetService("Players").LocalPlayer
local localStats = player:WaitForChild("LocalStats")
local tickets: IntValue = localStats:WaitForChild("Tickets")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")
local spendTicketsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("TicketFunctions")
	:WaitForChild("SpendTickets")
local addToInventoryServer = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("AddToInventoryServer")
local incrementSlotsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("IncrementSlots")
local addTicketsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("TicketFunctions")
	:WaitForChild("AddTickets")

-- GUI LOCALS
local screenGui = player.PlayerGui:WaitForChild("ScreenGui")
local gachaGUIParent = screenGui:WaitForChild("Gacha") :: Frame
local leftClip = gachaGUIParent:WaitForChild("ClipAll"):WaitForChild("LeftClip") :: CanvasGroup
local rightClip = gachaGUIParent:WaitForChild("ClipAll"):WaitForChild("RightClip") :: CanvasGroup
local closeButton: ImageButton = gachaGUIParent:FindFirstChildOfClass("ImageButton")
local activeSlotUI: Frame = rightClip:WaitForChild("TopFrame"):WaitForChild("ActiveParent")
local defaultActive = activeSlotUI:FindFirstChildOfClass("Frame") :: Frame
local defaultActiveClone = defaultActive:Clone()
local rollButton: ImageButton = rightClip:WaitForChild("Buttons"):WaitForChild("RollButton")
local rollText = rollButton:WaitForChild("RollsLeft") :: TextLabel

local slotArr: { Frame } = {}
for _, child in ipairs(leftClip:GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)
	end
end
local scaleFactor = 0.1
local duration = 0.1

-- TWEENS
local shrinkTween = createTweenFunctions.Shrink2(gachaGUIParent, scaleFactor, UDim2.new(0, 0, 0, 0))
local growRoll, shrinkRoll = createTweenFunctions.Pulse(rollButton, scaleFactor, duration)

-- OTHER VARS
local statBarColors = {
	DarkRed = Color3.fromRGB(139, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(128, 0, 128),
}

local slotStateEnums = {
	Locked = 0,
	UnlockedNoTool = 1,
	UnlockedWithTool = 2,
	UnlockedWithEquippedTool = 3,
	UnlockedWithEquippedNoTool = 4,
}

local selectedSlot = Instance.new("IntValue")
selectedSlot.Parent = script
selectedSlot.Value = 0
local selectedSlotUI: Frame? = nil

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

function updateStatBar(bar: ImageLabel, val: number)
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

function setActiveRollSlotUI(slotUI)
	local curActive = activeSlotUI:FindFirstChildOfClass("Frame")
	curActive:Destroy()

	local slotUIClone = slotUI:Clone()
	slotUIClone.Parent = activeSlotUI
end

function setSetActiveButton(button, slotUI, tool)
	if button:GetAttribute("ConnectionsSet") then
		return
	end
	-- Mark the connection as set
	button:SetAttribute("ConnectionsSet", true)

	button.MouseButton1Click:Connect(function()
		local curState = slotUI.Parent and slotUI.Parent:GetAttribute("SlotState")
		selectedSlot.Value = slotUI.Parent and slotUI.Parent:GetAttribute("SlotNumber")

		if curState == slotStateEnums.UnlockedNoTool then
			setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedNoTool, slotUI, tool)
		elseif curState == slotStateEnums.UnlockedWithTool then
			setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI, tool)
		else
			warn("States went wrong")
		end
		setActiveRollSlotUI(slotUI)

		local pulseGrow, shrinkPulse = createTweenFunctions.Pulse(slotUI, scaleFactor, duration)
		pulseGrow:Play()
		pulseGrow.Completed:Connect(function()
			shrinkPulse:Play()
		end)
	end)
end

function setStateOfSlotUI(state, slotUI: Frame, tool)
	local slapIcon = slotUI:FindFirstChildOfClass("ImageLabel") :: ImageLabel
	local setActiveButton = slotUI:FindFirstChild("SetRoll") :: ImageButton
	local buyButton = slotUI:FindFirstChild("Buy") :: ImageButton
	local statsFrame = slotUI:FindFirstChild("Stats") :: Frame
	local statsNameFrame = statsFrame:FindFirstChild("Name") :: Frame
	local bg = slotUI:FindFirstChild("Bg") :: Frame
	local bgGradient = bg:FindFirstChildOfClass("UIGradient") :: UIGradient
	local bgImg = bg:FindFirstChild("bgimg") :: ImageLabel
	local bgBackGlow = bg:FindFirstChild("backglow") :: ImageLabel

	local rarity = tool and tool:GetAttribute("Rarity") :: string?
	local rarityColors = enums.Colors.RarityColor

	-- local curState = slotUI.Parent and slotUI.Parent:GetAttribute("SlotState")

	if state == slotStateEnums.Locked then
		slapIcon.Visible = false
		setActiveButton.Visible = false
		buyButton.Visible = true
		statsFrame.Visible = false
		bgImg.Visible = true
		bgGradient.Color = ColorSequence.new(enums.Colors.NotUnlockedBpSpace.Color)
		bg.Transparency = enums.Colors.RarityColor.UnequippedOpacity
		bgBackGlow.ImageTransparency = 1

		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.Locked)

		if buyButton:GetAttribute("ConnectionsSet") then
			return
		end
		-- Mark the connection as set
		buyButton:SetAttribute("ConnectionsSet", true)

		buyButton.MouseButton1Click:Once(function()
			print("Increment slots!")
			incrementSlotsEvent:InvokeServer(player)
		end)
		--
		--
	elseif state == slotStateEnums.UnlockedNoTool then
		slapIcon.Visible = false
		setActiveButton.Visible = true
		buyButton.Visible = false
		statsFrame.Visible = false
		bgImg.Visible = false
		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})
		bg.Transparency = enums.Colors.RarityColor.UnequippedOpacity
		bgBackGlow.ImageTransparency = 1

		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.UnlockedNoTool)

		setSetActiveButton(setActiveButton, slotUI, tool)
		--
		--
	elseif state == slotStateEnums.UnlockedWithEquippedNoTool then
		slapIcon.Visible = false
		setActiveButton.Visible = true
		buyButton.Visible = false
		statsFrame.Visible = false
		bgImg.Visible = false
		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		})
		bg.Transparency = 0
		bgBackGlow.ImageTransparency = enums.Colors.RarityColor.ActiveBackGlowOpacity
		bgBackGlow.ImageColor3 = enums.Colors.ActiveToolBgGradient.End

		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.UnlockedNoTool)

		setSetActiveButton(setActiveButton, slotUI, tool)
		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.UnlockedWithEquippedNoTool)
		--
		--
	elseif state == slotStateEnums.UnlockedWithEquippedTool then
		slapIcon.Visible = true
		setActiveButton.Visible = true
		buyButton.Visible = false
		statsFrame.Visible = true
		bgImg.Visible = false
		bg.Transparency = 0
		bgBackGlow.ImageTransparency = enums.Colors.RarityColor.ActiveBackGlowOpacity

		local colorScheme = rarityColors and rarityColors[rarity]
		if colorScheme and typeof(colorScheme) == "table" and colorScheme.Start and colorScheme.End then
			bgGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorScheme.Start),
				ColorSequenceKeypoint.new(1, colorScheme.End),
			})
			bgBackGlow.ImageColor3 = colorScheme.End
			statsNameFrame.BackgroundColor3 = colorScheme.End
		end

		setSetActiveButton(setActiveButton, slotUI, tool)

		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.UnlockedWithEquippedTool)
		--
		--
	elseif state == slotStateEnums.UnlockedWithTool then
		slapIcon.Visible = true
		setActiveButton.Visible = true
		buyButton.Visible = false
		statsFrame.Visible = true
		bgImg.Visible = false
		bg.Transparency = rarityColors.UnequippedOpacity
		bgBackGlow.ImageTransparency = 1

		local colorScheme = rarityColors and rarityColors[rarity]
		if colorScheme and typeof(colorScheme) == "table" and colorScheme.Start and colorScheme.End then
			bgGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colorScheme.Start),
				ColorSequenceKeypoint.new(1, colorScheme.End),
			})
			statsNameFrame.BackgroundColor3 = colorScheme.End
		end

		setSetActiveButton(setActiveButton, slotUI, tool)

		_ = slotUI.Parent and slotUI.Parent:SetAttribute("SlotState", slotStateEnums.UnlockedWithTool)
	end
end

function updateGachaBackpackGUI()
	local playerInventory = player:FindFirstChild("Inventory")
	local openSlots = playerInventory:FindFirstChildOfClass("IntValue").Value
	local inventoryArr = playerInventory:GetChildren()

	for _, slot in slotArr do
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
				or slotState == slotStateEnums.UnlockedWithEquippedNoTool
			then
				setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI, foundTool)
			elseif slotState == slotStateEnums.UnlockedWithEquippedTool then
				setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI, foundTool)
			end
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
	updateGachaBackpackGUI()

	inventory.ChildAdded:Connect(function(child)
		if child.Name == "Bomb" then
			return
		end
		updateGachaBackpackGUI()
	end)

	inventory.ChildRemoved:Connect(function(child)
		if child.Name == "Bomb" then
			return
		end
		updateGachaBackpackGUI()
	end)

	availableSlot.Changed:Connect(function()
		updateGachaBackpackGUI()
	end)
end
trackBackpack()

selectedSlot.Changed:Connect(function()
	local playerInventory = player:FindFirstChild("Inventory")
	local inventoryArr = playerInventory:GetChildren()

	for _, slot in slotArr do
		local slotUI = slot:FindFirstChildOfClass("Frame")
		local saveSlot: number = slot:GetAttribute("SlotNumber")
		local slotState = slot:GetAttribute("SlotState")

		if saveSlot == selectedSlot.Value then
			print("NewSelected")
			selectedSlotUI = slotUI
		end

		local foundTool = nil
		for _, inventoryTool in ipairs(inventoryArr) do
			if inventoryTool:IsA("Tool") then
				local toolSlot: number? = inventoryTool:GetAttribute("SaveSlot")
				if toolSlot and tostring(toolSlot) == tostring(saveSlot) then
					foundTool = inventoryTool
					break
				end
			end
		end

		if
			saveSlot
			and slotState
			and saveSlot ~= selectedSlot.Value
			and slotState == slotStateEnums.UnlockedWithEquippedTool
		then
			setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI, foundTool)
		elseif
			saveSlot
			and slotState
			and saveSlot ~= selectedSlot.Value
			and slotState == slotStateEnums.UnlockedWithEquippedNoTool
		then
			setStateOfSlotUI(slotStateEnums.UnlockedNoTool, slotUI, foundTool)
		else
			print("Dont update slot: ", selectedSlot.Value)
		end
	end
end)

closeButton.MouseButton1Click:Connect(function()
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		gachaGUIParent.Visible = false
	end)
	selectedSlot.Value = 0
	selectedSlotUI = defaultActiveClone:Clone()
	setActiveRollSlotUI(selectedSlotUI)
end)

-- ROLL STUFF
local function trackRolls()
	rollText.Text = "x" .. tickets.Value
	if tickets then
		tickets.Changed:Connect(function()
			rollText.Text = "x" .. tickets.Value
		end)
	else
		warn("Tickets under localstats not found brrr")
	end
end
trackRolls()

rollButton.MouseButton1Click:Connect(function()
	growRoll:Play()
	growRoll.Completed:Connect(function()
		shrinkRoll:Play()
	end)

	if tickets.Value < 1 then
		warn("No more tickets (client check)")
		return
	end
	local rollResult = rollEvent:InvokeServer(selectedSlot.Value)

	if rollResult then
		local resultTickets = spendTicketsEvent:InvokeServer(1)
		if resultTickets then
			if selectedSlotUI then
				updateGachaBackpackGUI()
				setActiveRollSlotUI(selectedSlotUI)
			end
		else
			warn("No more tickets (server check)")
		end
	else
		warn("Something went wrong with rolling & adding to inventory")
	end
end)
