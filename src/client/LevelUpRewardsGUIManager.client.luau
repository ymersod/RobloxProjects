local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local level: IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level")

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local levelUpRewardsGui = screenGui:WaitForChild("LevelUpRewards") :: Frame
local closeButton: ImageButton = levelUpRewardsGui:WaitForChild("OpenContainer"):WaitForChild("CloseButton")
local buttonPrefab: ImageButton =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("DailyRewards"):WaitForChild("Button")
local levels: { ImageLabel } = {}
for _, item in ipairs(levelUpRewardsGui:WaitForChild("Info"):WaitForChild("GridParent"):GetChildren()) do
	if item:IsA("ImageLabel") then
		table.insert(levels, item)
	end
end
local colors = {
	Yellow = Color3.fromRGB(255, 255, 0),
	Red = Color3.fromRGB(255, 0, 0),
	Green = Color3.fromRGB(0, 255, 0),
}

function updateGUI()
	local curLevel = level.Value

	local rewardsToBeClaimed = math.floor(curLevel / 10)
	print("Available rewards: ", rewardsToBeClaimed)
	-- TODO: Should be a return by server with what rewards are available
	local response = nil

	for i = 1, rewardsToBeClaimed do
		levels[i].BackgroundColor3 = colors.Yellow
	end
end
updateGUI()

closeButton.MouseButton1Click:Connect(function()
	levelUpRewardsGui.Visible = false
end)

level.Changed:Connect(updateGUI)
