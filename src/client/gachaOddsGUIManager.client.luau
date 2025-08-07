local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
local uiUtils = require(ReplicatedStorage.Shared.ClientServerModuleScripts.uiUtils)
local player = game:GetService("Players").LocalPlayer

local getOddsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("GetOddsServer")

local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local gachaGUI = screenGui:WaitForChild("Gacha")
local gachaInfoButton = gachaGUI:WaitForChild("GachaInfoParent"):WaitForChild("GachaInfo") :: ImageButton
local odds = gachaGUI:WaitForChild("Odds") :: Frame
local rarityParentFrames = odds:WaitForChild("ParentFrame"):WaitForChild("ScrollingFrame"):GetChildren()

local oddsCloseButton = odds:FindFirstChildOfClass("ImageButton") :: ImageButton
local elementPrefab = ReplicatedStorage:WaitForChild("UI")
	:WaitForChild("DynamicGUI")
	:WaitForChild("Gacha")
	:WaitForChild("GachaInfoElement") :: Frame
local slapstyleIcons = ReplicatedStorage:WaitForChild("UI")
	:WaitForChild("DynamicGUI")
	:WaitForChild("Inventory")
	:WaitForChild("Icons")
	:GetChildren() :: { Frame }

local elasticGrowDur = 0.3
local elasticShrinkDur = 0.1

local growOdds, shrinkOdds =
	createTweenFunctions.Elastic(odds, elasticGrowDur, elasticShrinkDur, odds.Size, UDim2.new(0, 0, 0, 0), true)

local serverOddsNumbers: { common: number, uncommon: number, rare: number, legendary: number } =
	getOddsEvent:InvokeServer(player)

local rarities = {
	common = "Common",
	uncommon = "Uncommon",
	rare = "Rare",
	legendary = "Legendary",
}

local function init()
	for _, child in ipairs(rarityParentFrames) do
		if not child:IsA("Frame") then
			continue
		end

		local frameRarity = child:GetAttribute("rarity")
		-- SETTING TEXT
		local childText = child:FindFirstChildOfClass("TextLabel")
		childText.Text = rarities[frameRarity] .. " (" .. serverOddsNumbers[frameRarity] * 100 .. "%)"
		local gradient = childText:FindFirstChildOfClass("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.RarityColor[frameRarity].Start),
			ColorSequenceKeypoint.new(1, enums.Colors.RarityColor[frameRarity].End),
		})

		-- SETTING BG
		local bgFrame = child:FindFirstChildOfClass("Frame")
		local bgGradient = bgFrame:FindFirstChildOfClass("UIGradient")
		bgGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, enums.Colors.RarityColor[frameRarity].Start),
			ColorSequenceKeypoint.new(1, enums.Colors.RarityColor[frameRarity].End),
		})

		local iconsOfCorrRarity: { Frame } = {}
		for _, icon in ipairs(slapstyleIcons) do
			local iconRarity = icon:GetAttribute("rarity")

			if iconRarity == frameRarity then
				table.insert(iconsOfCorrRarity, icon)
			end
		end

		local elementParent = bgFrame:FindFirstChildOfClass("ScrollingFrame")
		for _, corrIcon in ipairs(iconsOfCorrRarity) do
			local elementPrefabClone = elementPrefab:Clone()
			local iconHolder = elementPrefabClone:FindFirstChildOfClass("Frame")
			local text = elementPrefabClone:FindFirstChildOfClass("TextLabel")

			text.Text = corrIcon.Name

			local iconClone = corrIcon:Clone()
			iconClone.Parent = iconHolder

			uiUtils.raiseZIndex(iconClone, 30)

			elementPrefabClone.Parent = elementParent
		end
	end
end

init()

local function setVisibility()
	local isVisible = odds.Visible
	if isVisible then
		shrinkOdds:Play()
		shrinkOdds.Completed:Connect(function()
			odds.Visible = false
		end)
	else
		odds.Visible = true
		growOdds:Play()
	end
end
gachaInfoButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.Click)
	setVisibility()
end)

oddsCloseButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.CloseGUI)
	setVisibility()
end)
