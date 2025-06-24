local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)

-- GUI elements
local accessGuis: { Frame } = {}
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local accessBarGui = screenGui:WaitForChild("AccessBar")
local gachaGUI: Frame = screenGui:WaitForChild("Gacha")
table.insert(accessGuis, gachaGUI)
local dailyLoginRewards: Frame = screenGui:WaitForChild("DailyLoginRewards")
table.insert(accessGuis, dailyLoginRewards)
local levelUpRewards: Frame = screenGui:WaitForChild("LevelUpRewards")
table.insert(accessGuis, levelUpRewards)
local accessParentGui: Frame = accessBarGui:WaitForChild("AccessParent")

local openCloseGui = accessBarGui:WaitForChild("OpenClose")
local openCloseButton: ImageButton = accessBarGui:WaitForChild("OpenClose"):WaitForChild("OpenCloseButton")
local openCloseBg: ImageLabel = accessBarGui:WaitForChild("OpenClose"):WaitForChild("OpenCloseIcon")

local openCloseGachaGUI: Frame = accessBarGui:WaitForChild("AccessParent"):WaitForChild("Roll")
local openCloseGachaButton = openCloseGachaGUI:WaitForChild("OpenCloseButton") :: ImageButton

local openCloseDailyGUI: Frame = accessBarGui:WaitForChild("AccessParent"):WaitForChild("DailyRewards")
local openCloseDailyButton = openCloseDailyGUI:WaitForChild("OpenCloseButton") :: ImageButton

local openCloseLevelUpGUI: Frame = accessBarGui:WaitForChild("AccessParent"):WaitForChild("LevelUpRewards")
local openCloseLevelUpButton = openCloseLevelUpGUI:WaitForChild("OpenCloseButton") :: ImageButton

local openImageId = "rbxassetid://93555922850987"
local closeImageId = "rbxassetid://89593175570849"

-- TWEEN SETUPS
-- Access guis
local openTween, closeTween = createTweenFunctions.GoInOut(
	accessParentGui,
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	-0.5,
	0,
	0,
	0
)
-- Pulses
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

-- openClose GUI
local growTweenOpenClose, shrinkTweenOpenClose = createTweenFunctions.Pulse(openCloseGui, scaleFactor, duration)
local growTweenDaily, shrinkTweenDaily = createTweenFunctions.Pulse(openCloseDailyGUI, scaleFactor, duration)
local growTweenGacha, shrinkTweenGacha = createTweenFunctions.Pulse(openCloseGachaGUI, scaleFactor, duration)
local growTweenLevelUp, shrinkTweenLevelUp = createTweenFunctions.Pulse(openCloseLevelUpGUI, scaleFactor, duration)

closeTween:Play()

openCloseButton.MouseButton1Click:Connect(function()
	growTweenOpenClose:Play()
	growTweenOpenClose.Completed:Once(function()
		shrinkTweenOpenClose:Play()
	end)
	if accessParentGui.Visible then
		-- print("Closing...")
		openCloseBg.Image = openImageId
		closeTween:Play()
		closeTween.Completed:Once(function()
			accessParentGui.Visible = false
		end)
	elseif not accessParentGui.Visible then
		-- print("Opening...")
		accessParentGui.Visible = true
		openCloseBg.Image = closeImageId
		openTween:Play()
	end
end)

function closeOtherGuiOnNewOpen()
	for _, gui in ipairs(accessGuis) do
		gui.Visible = false
	end
end

local function handleOpenCloseAccessGUIS(button, growTween, shrinkTween, guiToToggle, closeOthers)
	button.MouseButton1Click:Connect(function()
		growTween:Play()
		growTween.Completed:Once(function()
			shrinkTween:Play()
		end)

		local isVisible = guiToToggle.Visible

		if closeOthers then
			closeOtherGuiOnNewOpen()
		end
		guiToToggle.Visible = not isVisible
	end)
end
handleOpenCloseAccessGUIS(openCloseLevelUpButton, growTweenLevelUp, shrinkTweenLevelUp, levelUpRewards, true)
handleOpenCloseAccessGUIS(openCloseDailyButton, growTweenDaily, shrinkTweenDaily, dailyLoginRewards, true)
handleOpenCloseAccessGUIS(openCloseGachaButton, growTweenGacha, shrinkTweenGacha, gachaGUI, true)
