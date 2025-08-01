local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local player = game:GetService("Players").LocalPlayer
local NotificationManager = require(ReplicatedStorage.Shared.ClientServerModuleScripts.NotificationManager)
local Types = require(ReplicatedStorage.Shared.ClientServerModuleScripts.Types)
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)

local getProgress = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("getRewardProgress")
local progressRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DailyRewardsFunctions")
	:WaitForChild("progressRewards")
local getDailyRewards = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("DataFunctions")
	:WaitForChild("getDailyRewards")
local dailyRewards: { Types.DailyReward } = getDailyRewards:InvokeServer()
-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local dailyLoginRewards = screenGui:WaitForChild("DailyLoginRewards") :: Frame
local closeButton: ImageButton = dailyLoginRewards:WaitForChild("ImageButton")
local daysLeft: TextLabel = dailyLoginRewards
	:WaitForChild("ClipAll")
	:WaitForChild("TopFrameClip")
	:WaitForChild("TopLeftClip")
	:WaitForChild("DaysLeftText")
local timeLeft: TextLabel = dailyLoginRewards
	:WaitForChild("ClipAll")
	:WaitForChild("TopFrameClip")
	:WaitForChild("TopRightClip")
	:WaitForChild("NextRewardText")
local popupCount = NotificationManager.AddNewPopuppable(
	screenGui:WaitForChild("AccessBar"):WaitForChild("AccessParent"):WaitForChild("Daily")
)

local days: { Frame } = {}
local count = 1
local updateGUI -- forward declaration

local rewardTypeIcons = {
	Ticket = "rbxassetid://111009728990078",
}

--TWEENS
local shrinkTween = createTweenFunctions.Shrink2(dailyLoginRewards, 0.1, UDim2.new(0, 0, 0, 0))

for _, itemParent in
	ipairs(
		dailyLoginRewards
			:WaitForChild("ClipAll")
			:WaitForChild("BottomFrameClip")
			:WaitForChild("GridHolder")
			:GetChildren()
	)
do
	if itemParent:IsA("Frame") then
		local dayFrame = itemParent:FindFirstChildOfClass("Frame")
		local rewardTable = dailyRewards[count]

		-- local rewardTypeText = item:WaitForChild("RewardTypeText")
		local rewardIcon = dayFrame:WaitForChild("RewardIcon") :: ImageLabel
		local rewardAmountText = dayFrame:WaitForChild("RewardAmountText") :: TextLabel
		rewardIcon.Image = rewardTypeIcons[rewardTable.rewardType]
		rewardAmountText.Text = rewardTable.Amount

		table.insert(days, dayFrame)
		count += 1
	end
end

local guiStates = {
	NotClaimable = 1,
	Claimable = 2,
	AlreadyClaimed = 3,
}

local nextAvailableReward: number = -1

function claimReward()
	local response = progressRewards:InvokeServer() :: { sucess: boolean, payload: string }

	if not response.success then
		warn("Something went wrong with claim reward")
		return
	end
end

function setForState(dayFrame: Frame, state)
	local claimButton = dayFrame:FindFirstChildOfClass("ImageButton")
	local colorGradient = dayFrame:FindFirstChildOfClass("UIGradient")
	local glow = dayFrame:FindFirstChild("glow") :: ImageLabel
	local backGlow = dayFrame:FindFirstChild("backglow") :: ImageLabel
	local dayState = dayFrame:GetAttribute("State")

	if state == guiStates.NotClaimable then
		claimButton.Visible = false
		colorGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.RewardsColors.NotClaimableGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.RewardsColors.NotClaimableGradient.End),
		})
		glow.Visible = false
		backGlow.Visible = false
		dayFrame:SetAttribute("State", guiStates.NotClaimable)
	elseif state == guiStates.Claimable and dayState ~= guiStates.Claimable then
		popupCount.Value = popupCount.Value + 1
		claimButton.Visible = true
		colorGradient.Color = ColorSequence.new(enums.Colors.RewardsColors.Claimable)
		glow.Visible = true
		backGlow.Visible = true

		claimButton.MouseButton1Click:Once(function()
			popupCount.Value = popupCount.Value - 1
			SoundService:PlayLocalSound(sounds.Claim)
			local grow, shrink = createTweenFunctions.Pulse(dayFrame, 0.1, 0.1)
			grow:Play()
			grow.Completed:Connect(function()
				shrink:Play()
			end)
			claimReward()
			setForState(dayFrame, guiStates.AlreadyClaimed)
			updateGUI()
		end)
		dayFrame:SetAttribute("State", guiStates.Claimable)
	elseif state == guiStates.AlreadyClaimed then
		claimButton.Visible = false
		colorGradient.Color = ColorSequence.new(enums.Colors.RewardsColors.Claimed)
		glow.Visible = false
		backGlow.Visible = false
		dayFrame:SetAttribute("State", guiStates.AlreadyClaimed)
	end
end

function initGUI()
	for _, day in days do
		setForState(day, guiStates.NotClaimable)
	end
end
initGUI()

updateGUI = function()
	-- call server for progress
	local response = getProgress:InvokeServer() :: {
		success: boolean,
		payload: {
			lastClaimedDate: string,
			count: string, -- or number
		},
	}
	if not response.success then
		warn("Something went wrong getting progress of daily")
		return
	end

	for i = 1, response.payload.count do
		setForState(days[i], guiStates.AlreadyClaimed)
	end

	local now = os.time()
	local days_since_epoch = math.floor(now / 86400)
	local lastClaimedDate = tonumber(response.payload.lastClaimedDate)

	if days_since_epoch > lastClaimedDate then
		setForState(days[response.payload.count + 1], guiStates.Claimable)
	end

	nextAvailableReward = lastClaimedDate + 1
end
updateGUI()

closeButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.CloseGUI)
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		dailyLoginRewards.Visible = false
	end)
end)

timeLeft.TextTransparency = 0
local rewardReadyTriggered = false
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
		if not rewardReadyTriggered then
			timeLeft.Text = "Next reward: READY"
			updateGUI()
			rewardReadyTriggered = true
		end
	else
		rewardReadyTriggered = false
		local hours = math.floor(timeLeftSec / 3600)
		local minutes = math.floor((timeLeftSec % 3600) / 60)
		local seconds = timeLeftSec % 60
		local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
		timeLeft.Text = "Next reward: " .. formattedTime
	end

	daysLeft.Size = timeLeft.Size
	task.wait(1)
end
