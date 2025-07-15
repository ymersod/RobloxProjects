local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local soundService = game:GetService("SoundService")
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
	if oldLvl == level.lvl then
		local tween = TweenService:Create(
			expFrame,
			TweenInfo.new(1, Enum.EasingStyle.Linear),
			{ Size = UDim2.new(math.min(level.lvlProgress.progress / level.lvlProgress.goal, 1), 0, 1, 0) }
		)
		tween:Play()
	else
		local tween =
			TweenService:Create(expFrame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) })
		tween:Play()
		task.wait(0.5)
		expFrame.Size = UDim2.new(0, 0, 1, 0)
		local subtween = TweenService:Create(
			expFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear),
			{ Size = UDim2.new(math.min(level.lvlProgress.progress / level.lvlProgress.goal, 1), 0, 1, 0) }
		)
		subtween:Play()
		oldLvl = level.lvl
		soundService:PlayLocalSound(levelUpSound)
	end
	--expFrame.Size = UDim2.new(level.lvlProgress.progress/level.lvlProgress.goal,0,1,0)

	levelText.Text = "LVL : " .. level.lvl

	progressText.Text = level.lvlProgress.progress .. " / " .. level.lvlProgress.goal
end)
