local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getProgress = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("getRewardProgress")
local progressRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("progressRewards")
local player = game:GetService("Players").LocalPlayer

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local dailyLoginRewards = screenGui:WaitForChild("DailyLoginRewards") :: Frame
local closeButton: ImageButton = dailyLoginRewards:WaitForChild("OpenContainer"):WaitForChild("CloseButton")
local buttonPrefab: ImageButton =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("DailyRewards"):WaitForChild("Button")
local daysLeft: TextLabel = dailyLoginRewards:WaitForChild("Info"):WaitForChild("DaysLeft")
local timeLeft: TextLabel = dailyLoginRewards:WaitForChild("Info"):WaitForChild("TimeLeft")

local days: { ImageLabel } = {}
for _, item in ipairs(dailyLoginRewards:WaitForChild("Info"):WaitForChild("GridParent"):GetChildren()) do
	if item:IsA("ImageLabel") then
		table.insert(days, item)
	end
end
local colors = {
	Yellow = Color3.fromRGB(255, 255, 0),
	Red = Color3.fromRGB(255, 0, 0),
	Green = Color3.fromRGB(0, 255, 0),
}

local nextAvailableReward: number = -1

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
	-- call server for progress
	local response = getProgress:InvokeServer() :: {
		success: boolean,
		payload: {
			lastClaimedDate: string,
			count: string, -- or number
		},
	}
	print("Response: ", response)
	if not response.success then
		warn("Something went wrong getting progress of daily")
		return
	end

	for i = 1, response.payload.count do
		days[i].BackgroundColor3 = colors.Yellow
	end

	local now = os.time()
	local days_since_epoch = math.floor(now / 86400)
	local lastClaimedDate = tonumber(response.payload.lastClaimedDate)

	if days_since_epoch > lastClaimedDate then
		local buttonClone = buttonPrefab:Clone()
		local today = days[response.payload.count + 1]
		buttonClone.Parent = today
		days[response.payload.count + 1].BackgroundColor3 = colors.Green

		buttonClone.MouseButton1Click:Connect(function()
			claimReward(buttonClone)
		end)
	end

	nextAvailableReward = lastClaimedDate + 1
end
updateGUI()

closeButton.MouseButton1Click:Connect(function()
	dailyLoginRewards.Visible = false
end)

while true do
	if not nextAvailableReward then
		return
	end

	local nextRewardSeconds = nextAvailableReward * 86400
	local curTime = os.time()
	local timeLeftSec = nextRewardSeconds - curTime

	local daysSinceEpoch = math.floor(curTime / 86400)
	local dayInCycle = daysSinceEpoch % 28
	local daysLeftInCycle = 28 - dayInCycle
	daysLeft.Text = "Days left in cycle: " .. daysLeftInCycle

	if timeLeftSec < 0 then
		timeLeftSec = 0
		timeLeft.Text = "Next reward: " .. "READY"
		updateGUI()
	else
		local hours = math.floor(timeLeftSec / 3600)
		local minutes = math.floor((timeLeftSec % 3600) / 60)
		local seconds = timeLeftSec % 60

		local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
		timeLeft.Text = "Next reward: " .. formattedTime
	end

	task.wait(1)
end
