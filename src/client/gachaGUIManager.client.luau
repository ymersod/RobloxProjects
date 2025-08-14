local player = game:GetService("Players").LocalPlayer
local localStats = player:WaitForChild("LocalStats")
local tickets: IntValue = localStats:WaitForChild("Tickets")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
local uiUtils = require(ReplicatedStorage.Shared.ClientServerModuleScripts.uiUtils)
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")
local spendTicketsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("TicketFunctions")
	:WaitForChild("SpendTickets")
local incrementSlotsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("IncrementSlots")

-- GUI LOCALS
local screenGui = player.PlayerGui:WaitForChild("ScreenGui")
local gachaGUIParent = screenGui:WaitForChild("Gacha") :: Frame
local leftClip = gachaGUIParent:WaitForChild("ClipAll"):WaitForChild("LeftClip") :: CanvasGroup
local rightClip = gachaGUIParent:WaitForChild("ClipAll"):WaitForChild("RightClip") :: CanvasGroup
local closeButton: ImageButton = gachaGUIParent:FindFirstChildOfClass("ImageButton")
local topFrame = rightClip:WaitForChild("TopFrame") :: Frame
local activeSlotUI: Frame = topFrame:WaitForChild("ActiveParent")
local defaultActive = activeSlotUI:FindFirstChildOfClass("Frame") :: Frame
local defaultActiveClone = defaultActive:Clone()
local abiltiy = topFrame:WaitForChild("AbilityRef") :: Frame
local abilityImage = abiltiy:WaitForChild("ImageLabel") :: ImageLabel
local abilityText = abiltiy:WaitForChild("AbilityName") :: TextLabel
local rollButton: ImageButton = rightClip:WaitForChild("Buttons"):WaitForChild("RollFrame"):WaitForChild("RollButton")
local rollText = rollButton:WaitForChild("RollsLeft") :: TextLabel

local defaultAbility = abilityImage.Image
local defaultabilityText = abilityText.Text

local slotArr: { Frame } = {}
local tweens: {
	[number]: {
		bg: {
			Grow: Tween,
			Shrink: Tween,
		},
	},
} = {}

local scaleFactor = 0.1
local duration = 0.1

for _, child in ipairs(leftClip:GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)

		local pulseGrow, shrinkPulse = createTweenFunctions.Pulse(child, scaleFactor, duration)
		tweens[child:GetAttribute("SlotNumber")] = {
			bg = {
				Grow = pulseGrow,
				Shrink = shrinkPulse,
			},
		}
	end
end
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

local rarities = {
	Common = enums.Colors.RarityColor.common,
	Uncommon = enums.Colors.RarityColor.uncommon,
	Rare = enums.Colors.RarityColor.rare,
	Legendary = enums.Colors.RarityColor.legendary,
}

local slotStateEnums = {
	Locked = 0,
	UnlockedNoTool = 1,
	UnlockedWithTool = 2,
	UnlockedWithEquippedTool = 3,
	UnlockedWithEquippedNoTool = 4,
}
local setSetActiveButton

local stateConfigs = {
	[slotStateEnums.Locked] = {
		visible = {
			slapIcon = false,
			setActiveButton = false,
			buyButton = true,
			statsFrame = false,
			bgImg = true,
			bgBackGlow = false,
		},
		bgTransparency = enums.Colors.RarityColor.UnequippedOpacity,
		bgGradient = ColorSequence.new(enums.Colors.NotUnlockedBpSpace.Color),
		slotState = slotStateEnums.Locked,
		setup = function(buyButton)
			if not buyButton:GetAttribute("ConnectionsSet") then
				buyButton:SetAttribute("ConnectionsSet", true)
				buyButton.MouseButton1Click:Once(function()
					incrementSlotsEvent:InvokeServer(player)
				end)
			end
		end,
	},

	[slotStateEnums.UnlockedNoTool] = {
		visible = {
			slapIcon = false,
			setActiveButton = true,
			buyButton = false,
			statsFrame = false,
			bgImg = false,
			bgBackGlow = false,
		},
		bgTransparency = enums.Colors.RarityColor.UnequippedOpacity,
		bgGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		}),
		slotState = slotStateEnums.UnlockedNoTool,
		setup = function(buyButton, slotUI, setActiveButton, grow, shrink)
			setSetActiveButton(setActiveButton, slotUI, grow, shrink)
		end,
	},

	[slotStateEnums.UnlockedWithEquippedNoTool] = {
		visible = {
			slapIcon = false,
			setActiveButton = true,
			buyButton = false,
			statsFrame = false,
			bgImg = false,
			bgBackGlow = true,
		},
		bgTransparency = 0,
		bgGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.ActiveToolBgGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.ActiveToolBgGradient.End),
		}),
		slotState = slotStateEnums.UnlockedWithEquippedNoTool,
		setup = function(buyButton, slotUI, setActiveButton, grow, shrink)
			setSetActiveButton(setActiveButton, slotUI, grow, shrink)
		end,
	},

	[slotStateEnums.UnlockedWithTool] = {
		visible = {
			slapIcon = true,
			setActiveButton = true,
			buyButton = false,
			statsFrame = true,
			bgImg = false,
			bgBackGlow = false,
		},
		bgTransparency = enums.Colors.RarityColor.UnequippedOpacity,
		slotState = slotStateEnums.UnlockedWithTool,
		usesRarityColors = true,
		setup = function(buyButton, slotUI, setActiveButton, grow, shrink)
			setSetActiveButton(setActiveButton, slotUI, grow, shrink)
		end,
	},

	[slotStateEnums.UnlockedWithEquippedTool] = {
		visible = {
			slapIcon = true,
			setActiveButton = true,
			buyButton = false,
			statsFrame = true,
			bgImg = false,
			bgBackGlow = true,
		},
		bgTransparency = 0,
		slotState = slotStateEnums.UnlockedWithEquippedTool,
		usesRarityColors = true,
		setup = function(buyButton, slotUI, setActiveButton, grow, shrink)
			setSetActiveButton(setActiveButton, slotUI, grow, shrink)
		end,
	},
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

function setActiveRollSlotUI(slotUI)
	local toolIdRef = slotUI.Parent and slotUI.Parent:GetAttribute("ToolIdRef")

	if toolIdRef ~= 0 then
		local inventory = player:FindFirstChild("Inventory"):GetChildren()
		for _, tool in inventory do
			if tool:IsA("Tool") then
				local toolId = tool:GetAttribute("ToolId")

				if toolId and tostring(toolId) == tostring(toolIdRef) then
					local abilityVals = tool:FindFirstChild("AbilityVals")
					local abilityName = abilityVals and abilityVals:GetAttribute("name")

					if abilityName then
						abilityText.Text = abilityName
						-- TODO: Connect icon to image
					end
				end
			end
		end
	else
		abilityImage.Image = defaultAbility
		abilityText.Text = defaultabilityText
	end

	local curActive = activeSlotUI:FindFirstChildOfClass("Frame")
	curActive:Destroy()

	local slotUIClone = slotUI:Clone()
	slotUIClone.Parent = activeSlotUI
end

setSetActiveButton = function(button, slotUI, growPulse, shrinkPulse)
	if button:GetAttribute("ConnectionsSet") then
		return
	end
	-- Mark the connection as set
	button:SetAttribute("ConnectionsSet", true)

	button.MouseButton1Click:Connect(function()
		SoundService:PlayLocalSound(sounds.Click)
		selectedSlot.Value = slotUI.Parent and slotUI.Parent:GetAttribute("SlotNumber")

		updateGachaBackpackGUI()
		setActiveRollSlotUI(slotUI)

		growPulse:Play()
		growPulse.Completed:Connect(function()
			shrinkPulse:Play()
		end)
	end)
end

function setStateOfSlotUI(state, slotUI: Frame, tool)
	local slapIcon = slotUI:FindFirstChild("IconParent")
	local setActiveButton = slotUI:FindFirstChild("SetRoll") :: ImageButton
	local buyButton = slotUI:FindFirstChild("Buy") :: ImageButton
	local statsFrame = slotUI:FindFirstChild("Stats") :: Frame
	local statsNameFrame = statsFrame and statsFrame:FindFirstChild("Name") :: Frame
	local bg = slotUI:FindFirstChild("Bg") :: Frame
	local bgGradient = bg:FindFirstChildOfClass("UIGradient") :: UIGradient
	local bgImg = bg:FindFirstChild("bgimg") :: ImageLabel
	local bgBackGlow = bg:FindFirstChild("backglow") :: ImageLabel

	local rarity = tool and tool:GetAttribute("Rarity")
	local rarityColors = enums.Colors.RarityColor
	local parent = slotUI.Parent
	if not parent then
		warn("SlotSpace gone??")
		return
	end

	local slotNumber = parent:GetAttribute("SlotNumber")
	local localTweens = tweens[slotNumber]
	local config = stateConfigs[state]
	if not config then
		warn("Missing config for state", state)
		return
	end

	-- Visibility
	slapIcon.Visible = config.visible.slapIcon
	setActiveButton.Visible = config.visible.setActiveButton
	buyButton.Visible = config.visible.buyButton
	statsFrame.Visible = config.visible.statsFrame
	bgImg.Visible = config.visible.bgImg
	bgBackGlow.Visible = config.visible.bgBackGlow

	-- Transparency and gradient
	bg.Transparency = config.bgTransparency
	bgBackGlow.ImageTransparency = config.visible.bgBackGlow and enums.Colors.RarityColor.ActiveBackGlowOpacity or 1

	-- Color
	if config.bgGradient then
		bgGradient.Color = config.bgGradient
	end

	if config.usesRarityColors and rarity and rarityColors[rarity] then
		local color = rarityColors[rarity]
		if color.Start and color.End then
			bgGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Start),
				ColorSequenceKeypoint.new(1, color.End),
			})
			bgBackGlow.ImageColor3 = color.End
			if statsNameFrame then
				statsNameFrame.BackgroundColor3 = color.End
			end
		end
	end

	parent:SetAttribute("SlotState", config.slotState)

	if config.setup then
		config.setup(buyButton, slotUI, setActiveButton, localTweens.bg.Grow, localTweens.bg.Shrink)
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
		local inventoryIcon = inventoryIconRef and inventoryIconRef.Value :: Frame?
		if foundTool and inventoryIcon then
			local iconParent = slotUI:FindFirstChild("IconParent")

			local iconHolder = iconParent:FindFirstChildOfClass("Frame")
			local curChild = iconHolder:FindFirstChildOfClass("Frame")
			if not curChild or curChild.Name ~= inventoryIcon.Name then
				iconHolder:ClearAllChildren()
				local iconClone = inventoryIcon:Clone()
				iconClone.Parent = iconHolder
				uiUtils.raiseZIndex(iconHolder, 11)
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

			-- local slotState = slotUI.Parent:GetAttribute("SlotState")

			if selectedSlot.Value == saveSlot then
				setStateOfSlotUI(slotStateEnums.UnlockedWithEquippedTool, slotUI, foundTool)
			else
				setStateOfSlotUI(slotStateEnums.UnlockedWithTool, slotUI, foundTool)
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
	for _, slot in slotArr do
		local slotUI = slot:FindFirstChildOfClass("Frame")
		local saveSlot: number = slot:GetAttribute("SlotNumber")

		if saveSlot == selectedSlot.Value then
			print("NewSelected")
			selectedSlotUI = slotUI
		end
		updateGachaBackpackGUI()
	end
end)

closeButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.CloseGUI)
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

local function getRandomRarityColor(): { End: Color3, Start: Color3 }
	local keys = {}
	for k in pairs(rarities) do
		table.insert(keys, k)
	end
	local randomKey = keys[math.random(1, #keys)]
	return rarities[randomKey]
end

local function RollAnimation(duration: number, callback: ((Instance) -> ())?)
	SoundService:PlayLocalSound(sounds.Gacha)
	local topFrameClone = topFrame:Clone()
	topFrame.Visible = false

	topFrameClone.Parent = rightClip
	topFrameClone:FindFirstChild("AbilityRef"):Destroy()

	local activeParentClone = topFrameClone:FindFirstChild("ActiveParent") :: Frame
	local activeClone = activeParentClone:FindFirstChild("Active") :: Frame
	local bgClone = activeClone:FindFirstChild("Bg") :: Frame
	local bgGradientClone = bgClone:FindFirstChildOfClass("UIGradient")
	local bgBackGlowClone = bgClone:FindFirstChild("backglow") :: ImageLabel
	local bgImgClone = bgClone:FindFirstChild("bgimg") :: ImageLabel

	local statsClone = activeClone:FindFirstChild("Stats")
	statsClone.Visible = true
	local nameClone = statsClone:FindFirstChild("Name") :: Frame
	local nameLabelClone = nameClone:FindFirstChildOfClass("TextLabel")

	local fillClones: { Frame } = {}
	table.insert(fillClones, statsClone:FindFirstChild("Power"):FindFirstChild("Fill"))
	table.insert(fillClones, statsClone:FindFirstChild("Range"):FindFirstChild("Fill"))
	table.insert(fillClones, statsClone:FindFirstChild("Speed"):FindFirstChild("Fill"))

	-- 🔹 Create full-screen click-blocker
	local blocker = Instance.new("ImageButton")
	blocker.BackgroundTransparency = 1
	blocker.ImageTransparency = 1
	blocker.Size = UDim2.new(1, 0, 1, 0)
	blocker.Position = UDim2.new(0, 0, 0, 0)
	blocker.ZIndex = 100
	blocker.ScaleType = Enum.ScaleType.Stretch
	blocker.AutoButtonColor = false
	blocker.Image = "" -- blank image
	blocker.Parent = screenGui -- or the main UI container
	blocker.Active = true
	blocker.Visible = true

	-- ANIMATION
	task.spawn(function()
		bgClone.Transparency = 0
		bgBackGlowClone.Visible = true
		if bgImgClone then
			bgImgClone.Visible = false
		end
		nameLabelClone.Text = "??"

		-- Slowdown setup
		local startInterval = 0.05
		local growth = 0.01
		local elapsed = 0
		local intervals = {}

		-- Precompute intervals that fit within duration
		while true do
			local nextInterval = startInterval + #intervals * growth
			if elapsed + nextInterval > duration then
				break
			end
			table.insert(intervals, nextInterval)
			elapsed += nextInterval
		end

		-- Animate
		for _, interval in ipairs(intervals) do
			local rolls = {}
			for _ = 1, 3 do
				table.insert(rolls, math.random(1, 4))
			end
			for j, fillClone in ipairs(fillClones) do
				updateStatBar(fillClone, rolls[j])
			end

			local rColor = getRandomRarityColor()
			bgGradientClone.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, rColor.Start),
				ColorSequenceKeypoint.new(1, rColor.End),
			})
			nameClone.BackgroundColor3 = rColor.End
			bgBackGlowClone.ImageColor3 = rColor.End

			task.wait(interval)
		end

		-- Final values
		local finalRolls = {}
		for _ = 1, 3 do
			table.insert(finalRolls, math.random(1, 4))
		end
		for j, fillClone in ipairs(fillClones) do
			updateStatBar(fillClone, finalRolls[j])
		end

		local finalColor = getRandomRarityColor()
		bgGradientClone.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, finalColor.Start),
			ColorSequenceKeypoint.new(1, finalColor.End),
		})
		nameClone.BackgroundColor3 = finalColor.End
		bgBackGlowClone.ImageColor3 = finalColor.End

		task.wait(0.3)

		-- 🔹 Remove blocker after animation
		blocker:Destroy()

		if callback then
			callback(topFrameClone)
		end
	end)
end

local isRolling = false
rollButton.MouseButton1Click:Connect(function()
	if isRolling then
		return
	end
	if tickets.Value < 1 then
		return
	end
	if selectedSlot.Value == 0 then
		return
	end

	isRolling = true

	growRoll:Play()
	growRoll.Completed:Connect(function()
		shrinkRoll:Play()
	end)

	RollAnimation(2, function(topFrameClone)
		local rollResult = rollEvent:InvokeServer(selectedSlot.Value)
		if rollResult then
			local resultTickets = spendTicketsEvent:InvokeServer(1)
			if resultTickets then
				if selectedSlotUI then
					updateGachaBackpackGUI()
					setActiveRollSlotUI(selectedSlotUI)
				end
			end
		else
			warn("Something went wrong with rolling & adding to inventory")
		end

		isRolling = false
		topFrameClone:Destroy()
		topFrame.Visible = true
	end)
end)
