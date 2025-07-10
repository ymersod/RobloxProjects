local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local soundService = game:GetService("SoundService")
local levelUpSound = workspace:FindFirstChild("NonSpacialSounds"):FindFirstChild("Level_up")

local levelTexts = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("TextParent")
	:GetChildren()
local progressText: TextLabel =
	player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("LevelBar"):WaitForChild("Progress")
local expFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("Frame")
	:WaitForChild("Exp")

local oldLvl = 0
expLevelClient.OnClientEvent:Connect(function(level: { lvl: number, lvlProgress: { progress: number, goal: number } })
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

	for _, text in ipairs(levelTexts) do
		-- if text.Name == "LevelText" then
		-- 	text.Text = 'Slap LV: <font color="rgb(255, 221, 0)">' .. level.lvl .. "</font>"
		-- else
		-- 	text.Text = "Slap LV:" .. level.lvl
		-- end

		text.Text = "Slap LV:" .. level.lvl
	end

	progressText.Text = level.lvlProgress.progress .. " / " .. level.lvlProgress.goal
end)
