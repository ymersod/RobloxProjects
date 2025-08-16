local player = game:GetService("Players").LocalPlayer
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
local groupEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("PlayerInGroup")
local getDevProducts = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("shop")
	:WaitForChild("GetDevProductTable")
local ownsGamePass =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("ownsGamePass")
local buyDevProduct =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("BuyDevProduct")

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local shopGui = screenGui:WaitForChild("Shop") :: Frame
local closeButton: ImageButton = shopGui:WaitForChild("ImageButton")
local scrollingFrame = shopGui:WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local joinGroupFrame: Frame = scrollingFrame:WaitForChild("Join Group")
local groupClaimButton = joinGroupFrame:WaitForChild("ButtonFrame"):WaitForChild("TextButton") :: TextButton

local GROUP_ID = 35951660
local success, restriction = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(player)
end)
if not success then
	restriction = true
	warn("PolicyService error: " .. restriction .. " (client)")
elseif restriction.ArePaidRandomItemsRestricted then
	restriction = restriction.ArePaidRandomItemsRestricted
	warn("Player cannot interact with paid random item generators (client)")
else
	restriction = false
end

local shrinkTween = createTweenFunctions.Shrink2(shopGui, 0.1, UDim2.new(0, 0, 0, 0))

local result: { isInGroup: boolean, claimed: boolean } = groupEvent:InvokeServer(false)
type RewardEffect = "ticket" | "boostself" | "boostall" | "bomball"
type ProductType = "devProduct" | "gamePass"

if result.claimed then
	joinGroupFrame.Visible = false
end

local function updateDevProductFrame(
	productData: {
		id: string,
		price: number,
		devProduct: ProductType,
		paidRandomItem: boolean,
		reward: { effect: RewardEffect, amount: number },
	},
	devProductFrame: Frame
)
	if productData.paidRandomItem and restriction then
		devProductFrame.Visible = false
	end

	local price = devProductFrame:FindFirstChild("Price") :: TextLabel?
	if price then
		price.Text = productData.price .. " robux"
	end

	if productData.devProduct == "gamePass" then
		local gamepassOwned = ownsGamePass:InvokeServer(productData.id)
		if gamepassOwned then
			devProductFrame.Visible = false
		end
	end

	local buyButton = devProductFrame:FindFirstChildOfClass("ImageButton")
	if buyButton then
		buyButton.MouseButton1Click:Connect(function()
			buyDevProduct:InvokeServer(productData.id)
			if productData.devProduct then
				local gamepassOwned = ownsGamePass:InvokeServer(productData.id)
				if gamepassOwned then
					devProductFrame.Visible = false
				end
			end
		end)
	end
end

local devProducts: {
	[string]: {
		id: string,
		price: number,
		devProduct: ProductType,
		paidRandomItem: boolean,
		reward: { effect: RewardEffect, amount: number },
	},
} =
	getDevProducts:InvokeServer()

for _, devProductFrame in ipairs(scrollingFrame:GetDescendants()) do
	local idOnGui = devProductFrame:GetAttribute("DevProductId")

	if devProductFrame:IsA("Frame") and idOnGui then
		for _, productData in pairs(devProducts) do
			if tostring(productData.id) == tostring(idOnGui) then
				updateDevProductFrame(productData, devProductFrame)
			end
		end
	end
end

closeButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.CloseGUI)
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		shopGui.Visible = false
	end)
end)

shopGui.Changed:Connect(function(variable)
	if variable == "Visible" and shopGui.Visible then
		player:IsInGroup(GROUP_ID)
	end
end)

groupClaimButton.MouseButton1Click:Connect(function()
	local res: { isInGroup: boolean, claimed: boolean } = groupEvent:InvokeServer(true)

	if res.claimed then
		joinGroupFrame.Visible = false
	end
end)
