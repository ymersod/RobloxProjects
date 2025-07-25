local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)

local elasticGrowDur = 0.3
local elasticShrinkDur = 0.1

-- GUI elements
local accessGuisKvPs: { { ToOpenGui: Frame, Shrink: Tween, AccessGuiBg: ImageLabel, AccessGuiGlow: ImageLabel } } = {}
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local accessBarGui = screenGui:WaitForChild("AccessBar")

local gachaGUI: Frame = screenGui:WaitForChild("Gacha")
local dailyLoginRewards: Frame = screenGui:WaitForChild("DailyLoginRewards")
local levelUpRewards: Frame = screenGui:WaitForChild("LevelUpRewards")
local shopGUI: Frame = screenGui:WaitForChild("Shop")

local accessParentGui: Frame = accessBarGui:WaitForChild("AccessParent")
local accessOpenCloseParent: Frame = accessBarGui:WaitForChild("ParentOpenClose")

local openCloseGui = accessOpenCloseParent:WaitForChild("OpenClose") :: Frame
local openCloseButton = openCloseGui:WaitForChild("OpenCloseButton") :: ImageButton
local openCloseBg = openCloseGui:WaitForChild("bg") :: ImageLabel
local openCloseBackGlow = openCloseGui:WaitForChild("backglow") :: ImageLabel

local openCloseGachaGUI = accessParentGui:WaitForChild("Roll") :: Frame
local openCloseGachaButton = openCloseGachaGUI:WaitForChild("OpenCloseButton") :: ImageButton
local growRealGachaGUI, shrinkRealGachaGUI =
	createTweenFunctions.Elastic(gachaGUI, elasticGrowDur, elasticShrinkDur, gachaGUI.Size, UDim2.new(0, 0, 0, 0), true)
table.insert(accessGuisKvPs, {
	ToOpenGui = gachaGUI,
	Shrink = shrinkRealGachaGUI,
	AccessGuiBg = openCloseGachaGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseGachaGUI:WaitForChild("backglow"),
})

local openCloseDailyGUI = accessParentGui:WaitForChild("Daily") :: Frame
local openCloseDailyButton = openCloseDailyGUI:WaitForChild("OpenCloseButton") :: ImageButton
local growRealDailyGUI, shrinkRealDailyGUI = createTweenFunctions.Elastic(
	dailyLoginRewards,
	elasticGrowDur,
	elasticShrinkDur,
	dailyLoginRewards.Size,
	UDim2.new(0, 0, 0, 0),
	true
)
table.insert(accessGuisKvPs, {
	ToOpenGui = dailyLoginRewards,
	Shrink = shrinkRealDailyGUI,
	AccessGuiBg = openCloseDailyGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseDailyGUI:WaitForChild("backglow"),
})

local openCloseLevelUpGUI = accessParentGui:WaitForChild("LevelUp") :: Frame
local openCloseLevelUpButton = openCloseLevelUpGUI:WaitForChild("OpenCloseButton") :: ImageButton
local growRealLevelUpGUI, shrinkRealLevelUpGUI = createTweenFunctions.Elastic(
	levelUpRewards,
	elasticGrowDur,
	elasticShrinkDur,
	levelUpRewards.Size,
	UDim2.new(0, 0, 0, 0),
	true
)
table.insert(accessGuisKvPs, {
	ToOpenGui = levelUpRewards,
	Shrink = shrinkRealLevelUpGUI,
	AccessGuiBg = openCloseLevelUpGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseLevelUpGUI:WaitForChild("backglow"),
})

local openCloseShopGUI: Frame = accessParentGui:WaitForChild("Shop") :: Frame
local openCloseShopButton = openCloseShopGUI:WaitForChild("OpenCloseButton") :: ImageButton
local growRealShopGUI, shrinkRealShopGUI =
	createTweenFunctions.Elastic(shopGUI, elasticGrowDur, elasticShrinkDur, shopGUI.Size, UDim2.new(0, 0, 0, 0), true)
table.insert(accessGuisKvPs, {
	ToOpenGui = shopGUI,
	Shrink = shrinkRealShopGUI,
	AccessGuiBg = openCloseShopGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseShopGUI:WaitForChild("backglow"),
})

-- TWEEN SETUPS
-- Pulses
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

local growTweenOpenClose, shrinkTweenOpenClose = createTweenFunctions.Pulse(openCloseGui, scaleFactor, duration)
local growTweenDaily, shrinkTweenDaily = createTweenFunctions.Pulse(openCloseDailyGUI, scaleFactor, duration)
local growTweenGacha, shrinkTweenGacha = createTweenFunctions.Pulse(openCloseGachaGUI, scaleFactor, duration)
local growTweenLevelUp, shrinkTweenLevelUp = createTweenFunctions.Pulse(openCloseLevelUpGUI, scaleFactor, duration)
local growTweenShop, shrinkTweenShop = createTweenFunctions.Pulse(openCloseShopGUI, scaleFactor, duration)

-- Go in out
local shopIn, shopOut =
	createTweenFunctions.MoveInOut(openCloseShopGUI, 0.2, openCloseShopGUI.Position, openCloseGui.Position)
local shrinkShop = createTweenFunctions.Shrink2(openCloseShopGUI, 0.2, UDim2.new(0, 0, 0, 0))
local growShop = createTweenFunctions.Grow2(openCloseShopGUI, 0.2, openCloseShopGUI.Size)

local dailyIn, dailyOut =
	createTweenFunctions.MoveInOut(openCloseDailyGUI, 0.2, openCloseDailyGUI.Position, openCloseGui.Position)
local shrinkDaily = createTweenFunctions.Shrink2(openCloseDailyGUI, 0.2, UDim2.new(0, 0, 0, 0))
local growDaily = createTweenFunctions.Grow2(openCloseDailyGUI, 0.2, openCloseDailyGUI.Size)

local levelIn, levelOut =
	createTweenFunctions.MoveInOut(openCloseLevelUpGUI, 0.2, openCloseLevelUpGUI.Position, openCloseGui.Position)
local shrinkLevel = createTweenFunctions.Shrink2(openCloseLevelUpGUI, 0.2, UDim2.new(0, 0, 0, 0))
local growLevel = createTweenFunctions.Grow2(openCloseLevelUpGUI, 0.2, openCloseLevelUpGUI.Size)

local rollIn, rollOut =
	createTweenFunctions.MoveInOut(openCloseGachaGUI, 0.2, openCloseGachaGUI.Position, openCloseGui.Position)
local shrinkRoll = createTweenFunctions.Shrink2(openCloseGachaGUI, 0.2, UDim2.new(0, 0, 0, 0))
local growRoll = createTweenFunctions.Grow2(openCloseGachaGUI, 0.2, openCloseGachaGUI.Size)

local tweensOpen = {
	shopOut,
	growShop,
	dailyOut,
	growDaily,
	levelOut,
	growLevel,
	rollOut,
	growRoll,
}
local tweensClose = {
	shopIn,
	shrinkShop,
	dailyIn,
	shrinkDaily,
	levelIn,
	shrinkLevel,
	rollIn,
	shrinkRoll,
}

local function playTweensAndWait(tweens: { Tween }, onComplete: () -> ())
	local completed = 0
	local total = #tweens

	local function onTweenComplete()
		completed += 1
		if completed == total then
			onComplete()
		end
	end

	for _, tween in ipairs(tweens) do
		tween.Completed:Once(onTweenComplete)
		tween:Play()
	end
end
playTweensAndWait(tweensClose, function() end)

openCloseButton.MouseButton1Click:Connect(function()
	growTweenOpenClose:Play()
	growTweenOpenClose.Completed:Once(function()
		shrinkTweenOpenClose:Play()
	end)
	if accessParentGui.Visible then
		playTweensAndWait(tweensClose, function()
			accessParentGui.Visible = false
		end)

		openCloseBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
		openCloseBackGlow.ImageColor3 = enums.Colors.InactiveMenuOption.Color
	elseif not accessParentGui.Visible then
		accessParentGui.Visible = true

		playTweensAndWait(tweensOpen, function() end)

		openCloseBg.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
		openCloseBackGlow.ImageColor3 = enums.Colors.ActiveMenuOption.Color
	end
end)

function closeOtherGuiOnNewOpen(toggleGui)
	for _, gui in ipairs(accessGuisKvPs) do
		if toggleGui == gui.ToOpenGui then
			continue
		end

		gui.ToOpenGui.Visible = false
		gui.AccessGuiBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
		gui.AccessGuiGlow.ImageColor3 = enums.Colors.InactiveMenuOption.Color
		gui.Shrink:Play()
	end
end

local function handleOpenCloseAccessGUIS(
	button,
	elasticGrow: Tween,
	elasticShrink: Tween,
	growTween,
	shrinkTween,
	guiToToggle,
	closeOthers
)
	button.MouseButton1Click:Connect(function()
		growTween:Play()
		growTween.Completed:Once(function()
			shrinkTween:Play()
		end)

		local isVisible = guiToToggle.Visible

		if not guiToToggle.Visible then
			guiToToggle.Visible = not isVisible
			elasticGrow:Play()
		else
			elasticShrink:Play()
			elasticShrink.Completed:Connect(function()
				guiToToggle.Visible = not isVisible
			end)
		end

		if closeOthers then
			closeOtherGuiOnNewOpen(guiToToggle)
		end
	end)
end
handleOpenCloseAccessGUIS(
	openCloseLevelUpButton,
	growRealLevelUpGUI,
	shrinkRealLevelUpGUI,
	growTweenLevelUp,
	shrinkTweenLevelUp,
	levelUpRewards,
	true
)
handleOpenCloseAccessGUIS(
	openCloseDailyButton,
	growRealDailyGUI,
	shrinkRealDailyGUI,
	growTweenDaily,
	shrinkTweenDaily,
	dailyLoginRewards,
	true
)
handleOpenCloseAccessGUIS(
	openCloseGachaButton,
	growRealGachaGUI,
	shrinkRealGachaGUI,
	growTweenGacha,
	shrinkTweenGacha,
	gachaGUI,
	true
)
handleOpenCloseAccessGUIS(
	openCloseShopButton,
	growRealShopGUI,
	shrinkRealShopGUI,
	growTweenShop,
	shrinkTweenShop,
	shopGUI,
	true
)

for _, gui in ipairs(accessGuisKvPs) do
	gui.ToOpenGui.Changed:Connect(function()
		if gui.ToOpenGui.Visible == true then
			gui.AccessGuiBg.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
			gui.AccessGuiGlow.ImageColor3 = enums.Colors.ActiveMenuOption.Color
		else
			gui.AccessGuiBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
			gui.AccessGuiGlow.ImageColor3 = enums.Colors.InactiveMenuOption.Color
		end
	end)
end
