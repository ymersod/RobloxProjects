local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local soundService = game:GetService("SoundService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local levelUpSound = workspace:FindFirstChild("NonSpacialSounds"):FindFirstChild("Level_up")
local xpGainSound = workspace:FindFirstChild("NonSpacialSounds"):FindFirstChild("Magic_Sprinkle")

local levelText: TextLabel = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("TopBarInside")
	:WaitForChild("leveltext")
local progressText: TextLabel = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("Bar")
	:WaitForChild("MiddleBar")
	:WaitForChild("exptext")

local expFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("Bar")
	:WaitForChild("MiddleBar")
	:WaitForChild("Xp")

local oldLvl = 0
expLevelClient.OnClientEvent:Connect(function(level: { lvl: number, lvlProgress: { progress: number, goal: number } })
	soundService:PlayLocalSound(xpGainSound)
	local elasticGrow, elasticShrink = createTweenFunctions.Elastic(
		expFrame,
		0.2,
		0.1,
		UDim2.new(math.min(level.lvlProgress.progress / level.lvlProgress.goal, 1), 0, 1, 0),
		UDim2.new(1, 0, 1, 0),
		false
	)
	if oldLvl == level.lvl then
		elasticGrow:Play()
	else
		elasticShrink:Play()
		elasticShrink.Completed:Connect(function()
			expFrame.Size = UDim2.new(0, 0, 1, 0)
			elasticGrow:Play()
			oldLvl = level.lvl
			soundService:PlayLocalSound(levelUpSound)
		end)
	end

	levelText.Text = "LVL : " .. level.lvl

	local flooredProgress = math.floor(level.lvlProgress.progress)
	progressText.Text = flooredProgress .. " / " .. level.lvlProgress.goal
end)
