local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.ClientServerModuleScripts.Types)
local player = game:GetService("Players").LocalPlayer
local level: IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level")
local progressRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("LevelupRewardsFunctions")
	:WaitForChild("progressRewards")
local getProgress = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("LevelupRewardsFunctions")
	:WaitForChild("getRewardProgress")
local getLevelUpRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DataFunctions")
	:WaitForChild("getLevelUpRewards")

local levelUpRewards: { Types.LevelUpReward } = getLevelUpRewards:InvokeServer()

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local levelUpRewardsGui = screenGui:WaitForChild("LevelUpRewards") :: Frame
local closeButton: ImageButton = levelUpRewardsGui:WaitForChild("OpenContainer"):WaitForChild("CloseButton")
local buttonPrefab: ImageButton =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("DailyRewards"):WaitForChild("Button")
local rewardPrefab: ImageButton =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("RewardFrame")
local levels: { ImageLabel } = {}
local count = 1
for _, item in ipairs(levelUpRewardsGui:WaitForChild("Info"):WaitForChild("GridParent"):GetChildren()) do
	if item:IsA("ImageLabel") then
		local rewardFrame = rewardPrefab:Clone()
		rewardFrame.Parent = item

		local typeText: TextLabel = rewardFrame:FindFirstChild("RewardType")
		local amountText: TextLabel = rewardFrame:FindFirstChild("RewardAmount")

		local rewardTable = levelUpRewards[count]
		typeText.Text = rewardTable.rewardType
		amountText.Text = rewardTable.Amount

		table.insert(levels, item)
		count += 1
	end
end
local colors = {
	Yellow = Color3.fromRGB(255, 255, 0),
	Red = Color3.fromRGB(255, 0, 0),
	Green = Color3.fromRGB(0, 255, 0),
}

function claimReward(self: ImageButton)
	local response = progressRewards:InvokeServer() :: { sucess: boolean, payload: string }

	if not response.success then
		warn("Something went wrong with claim reward")
		return
	end

	self:Destroy()
	updateGUI()
end

function updateGUI()
	local curLevel = math.floor(level.Value / 10) * 10 -- In increments of 10

	local result: { success: boolean, payload: { lastClaimedLevel: string, count: string } } =
		getProgress:InvokeServer()
	if not result.success then
		warn("Something went wrong fetching current progress on leveluprewards")
	end

	local count = tonumber(result.payload.count)
	local lastClaimedLevel = tonumber(result.payload.lastClaimedLevel)

	if count and lastClaimedLevel then
		for i = 1, count do
			levels[i].BackgroundColor3 = colors.Yellow
			local button = levels[i]:FindFirstChildOfClass("ImageButton")
			if button then
				button:Destroy()
			end
		end
		if curLevel > tonumber(result.payload.lastClaimedLevel) then
			local curBut = levels[count + 1]:FindFirstChildOfClass("ImageButton")
			if not curBut then
				local buttonClone = buttonPrefab:Clone()
				buttonClone.Parent = levels[count + 1]

				levels[count + 1].BackgroundColor3 = colors.Green
				buttonClone.MouseButton1Click:Connect(function()
					claimReward(buttonClone)
				end)
			end
		end
	end
end
updateGUI()

closeButton.MouseButton1Click:Connect(function()
	levelUpRewardsGui.Visible = false
end)

level.Changed:Connect(updateGUI)
