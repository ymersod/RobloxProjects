local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.ClientServerModuleScripts.Types)
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
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
local rewardTypeIcons = {
	Ticket = "rbxassetid://111009728990078",
	SlotUpgrade = "rbxassetid://80456559529773",
}
-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local levelUpRewardsGui = screenGui:WaitForChild("LevelUpRewards") :: Frame
local closeButton: ImageButton = levelUpRewardsGui:WaitForChild("ImageButton")
local levels: { Frame } = {}

local count = 1
local lastClaimedLevelCache = 0

-- TWEENS
local shrinkTween = createTweenFunctions.Shrink2(levelUpRewardsGui, 0.1, UDim2.new(0, 0, 0, 0))

local uiStates = {
	NotClaimable = 1,
	Claimed = 2,
	Claimable = 3,
}

local updateGUI

local function setStars(starChildren: { Frame }, locked: boolean)
	local foundStar = nil
	for _, starChild: Frame in starChildren do
		local chosenStars = starChild:GetAttribute("ChosenStars") :: boolean?

		if locked then
			if chosenStars == nil then
				starChild.Visible = true
			else
				starChild.Visible = false
			end
		end

		if not locked then
			if chosenStars ~= nil and chosenStars == true then
				starChild.Visible = true
				foundStar = starChild
			else
				starChild.Visible = false
			end
		end
	end

	return foundStar
end

function setForState(element: Frame, state)
	local bg = element:FindFirstChild("bg") :: Frame
	local bgGradient = bg:FindFirstChildOfClass("UIGradient") :: UIGradient
	local bgBackGlow = bg:FindFirstChild("backglow") :: ImageLabel

	local stars = element:FindFirstChild("Stars") :: Frame
	local starChildren = stars:GetChildren() :: { Frame }
	local claimButton = element:FindFirstChildOfClass("ImageButton") :: ImageButton

	local curUiState = element:GetAttribute("UiState")

	if state == uiStates.Claimable and curUiState ~= uiStates.Claimable then
		local starChild = setStars(starChildren, false)

		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.RewardsColors.Claimed),
			ColorSequenceKeypoint.new(1, enums.Colors.RewardsColors.Claimable),
		})
		bgBackGlow.Visible = true

		for _, starImg: ImageLabel in starChild:GetChildren() do
			local starGradient = starImg:FindFirstChildOfClass("UIGradient")
			local backGlow = starImg:FindFirstChildOfClass("ImageLabel")

			starGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, enums.Colors.RewardsColors.Claimed),
				ColorSequenceKeypoint.new(1, enums.Colors.RewardsColors.Claimable),
			})
			backGlow.Visible = true
		end

		claimButton.Visible = true
		claimButton.MouseButton1Click:Once(function()
			print("Claiming levelupreward!!")
			local response = progressRewards:InvokeServer() :: { sucess: boolean, payload: string }

			if not response.success then
				warn("Something went wrong with claim reward")
				return
			end
			updateGUI()
		end)
		element:SetAttribute("UiState", uiStates.Claimable)
	elseif state == uiStates.Claimed then
		local starChild = setStars(starChildren, false)
		claimButton.Visible = false

		bgGradient.Color = ColorSequence.new(enums.Colors.RewardsColors.Claimed)
		bgBackGlow.Visible = false

		for _, starImg: ImageLabel in starChild:GetChildren() do
			local starGradient = starImg:FindFirstChildOfClass("UIGradient")
			local backGlow = starImg:FindFirstChildOfClass("ImageLabel")

			starGradient.Color = ColorSequence.new(enums.Colors.RewardsColors.Claimed)
			backGlow.Visible = false
		end
		element:SetAttribute("UiState", uiStates.Claimed)
	elseif state == uiStates.NotClaimable then
		setStars(starChildren, true)
		claimButton.Visible = false
		bgBackGlow.Visible = false

		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.RewardsColors.NotClaimableGradient.Start),
			ColorSequenceKeypoint.new(1, enums.Colors.RewardsColors.NotClaimableGradient.End),
		})
		element:SetAttribute("UiState", uiStates.NotClaimable)
	end
end

function init()
	for _, item in ipairs(levelUpRewardsGui:WaitForChild("BottomClip"):WaitForChild("ScrollingFrame"):GetChildren()) do
		if item:IsA("Frame") then
			local rewardTable = levelUpRewards[count]

			local rewardIcon: ImageLabel = item:WaitForChild("Reward"):WaitForChild("RewardType")
			local rewardAmount: TextLabel = item:WaitForChild("Reward"):WaitForChild("RewardAmount")
			local stars: { Frame } = item:WaitForChild("Stars"):GetChildren()

			local starAmount = rewardTable.Stars
			for _, starFrame in stars do
				local starFrameStarsAmount = starFrame:GetAttribute("stars")
				if starFrameStarsAmount == starAmount then
					starFrame:SetAttribute("ChosenStars", true)
				end
			end

			rewardIcon.Image = rewardTypeIcons[rewardTable.rewardType]
			rewardAmount.Text = rewardTable.Amount

			table.insert(levels, item)
			count += 1
			setForState(item, uiStates.NotClaimable)
		end
	end
end
init()

updateGUI = function()
	local curLevel = math.floor(level.Value / 10) * 10 -- In increments of 10

	if curLevel <= lastClaimedLevelCache then
		return
	end

	local result: { success: boolean, payload: { lastClaimedLevel: string, count: string } } =
		getProgress:InvokeServer()
	if not result.success then
		warn("Something went wrong fetching current progress on leveluprewards")
	end

	local count = tonumber(result.payload.count)
	local lastClaimedLevel = tonumber(result.payload.lastClaimedLevel)

	if count and lastClaimedLevel then
		for i = 1, count do
			setForState(levels[i], uiStates.Claimed)
		end
		if curLevel > tonumber(result.payload.lastClaimedLevel) then
			setForState(levels[count + 1], uiStates.Claimable)
		end
	end

	lastClaimedLevelCache = lastClaimedLevel
end
updateGUI()

closeButton.MouseButton1Click:Connect(function()
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		levelUpRewardsGui.Visible = false
	end)
end)

level.Changed:Connect(updateGUI)
