local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)

-- GUI elements
local accessGuisKvPs: { { ToOpenGui: Frame, AccessGuiBg: ImageLabel, AccessGuiGlow: ImageLabel } } = {}
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
table.insert(accessGuisKvPs, {
	ToOpenGui = gachaGUI,
	AccessGuiBg = openCloseGachaGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseGachaGUI:WaitForChild("backglow"),
})

local openCloseDailyGUI = accessParentGui:WaitForChild("Daily") :: Frame
local openCloseDailyButton = openCloseDailyGUI:WaitForChild("OpenCloseButton") :: ImageButton
table.insert(accessGuisKvPs, {
	ToOpenGui = dailyLoginRewards,
	AccessGuiBg = openCloseDailyGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseDailyGUI:WaitForChild("backglow"),
})

local openCloseLevelUpGUI = accessParentGui:WaitForChild("LevelUp") :: Frame
local openCloseLevelUpButton = openCloseLevelUpGUI:WaitForChild("OpenCloseButton") :: ImageButton
table.insert(accessGuisKvPs, {
	ToOpenGui = levelUpRewards,
	AccessGuiBg = openCloseLevelUpGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseLevelUpGUI:WaitForChild("backglow"),
})

local openCloseShopGUI: Frame = accessParentGui:WaitForChild("Shop") :: Frame
local openCloseShopButton = openCloseShopGUI:WaitForChild("OpenCloseButton") :: ImageButton
table.insert(accessGuisKvPs, {
	ToOpenGui = shopGUI,
	AccessGuiBg = openCloseShopGUI:WaitForChild("bg"),
	AccessGuiGlow = openCloseShopGUI:WaitForChild("backglow"),
})

print(accessGuisKvPs)

-- TWEEN SETUPS
-- Access guis

-- Pulses
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

-- openClose GUI
local growTweenOpenClose, shrinkTweenOpenClose = createTweenFunctions.Pulse(openCloseGui, scaleFactor, duration)
local growTweenDaily, shrinkTweenDaily = createTweenFunctions.Pulse(openCloseDailyGUI, scaleFactor, duration)
local growTweenGacha, shrinkTweenGacha = createTweenFunctions.Pulse(openCloseGachaGUI, scaleFactor, duration)
local growTweenLevelUp, shrinkTweenLevelUp = createTweenFunctions.Pulse(openCloseLevelUpGUI, scaleFactor, duration)
local growTweenShop, shrinkTweenShop = createTweenFunctions.Pulse(openCloseShopGUI, scaleFactor, duration)

openCloseButton.MouseButton1Click:Connect(function()
	growTweenOpenClose:Play()
	growTweenOpenClose.Completed:Once(function()
		shrinkTweenOpenClose:Play()
	end)
	if accessParentGui.Visible then
		accessParentGui.Visible = false
		openCloseBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
		openCloseBackGlow.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
	elseif not accessParentGui.Visible then
		accessParentGui.Visible = true
		openCloseBg.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
		openCloseBackGlow.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
	end
end)

function closeOtherGuiOnNewOpen()
	for _, gui in ipairs(accessGuisKvPs) do
		gui.ToOpenGui.Visible = false
		gui.AccessGuiBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
		gui.AccessGuiGlow.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
	end
end

local function handleOpenCloseAccessGUIS(button, growTween, shrinkTween, guiToToggle, closeOthers)
	button.MouseButton1Click:Connect(function()
		growTween:Play()
		growTween.Completed:Once(function()
			shrinkTween:Play()
		end)

		if closeOthers then
			closeOtherGuiOnNewOpen()
		end
		local isVisible = guiToToggle.Visible
		guiToToggle.Visible = not isVisible
	end)
end
handleOpenCloseAccessGUIS(openCloseLevelUpButton, growTweenLevelUp, shrinkTweenLevelUp, levelUpRewards, true)
handleOpenCloseAccessGUIS(openCloseDailyButton, growTweenDaily, shrinkTweenDaily, dailyLoginRewards, true)
handleOpenCloseAccessGUIS(openCloseGachaButton, growTweenGacha, shrinkTweenGacha, gachaGUI, true)
handleOpenCloseAccessGUIS(openCloseShopButton, growTweenShop, shrinkTweenShop, shopGUI, true)

for _, gui in ipairs(accessGuisKvPs) do
	gui.ToOpenGui.Changed:Connect(function()
		if gui.ToOpenGui.Visible == true then
			gui.AccessGuiBg.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
			gui.AccessGuiGlow.BackgroundColor3 = enums.Colors.ActiveMenuOption.Color
		else
			gui.AccessGuiBg.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
			gui.AccessGuiGlow.BackgroundColor3 = enums.Colors.InactiveMenuOption.Color
		end
	end)
end
