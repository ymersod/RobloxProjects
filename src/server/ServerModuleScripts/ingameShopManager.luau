local ReplicatedStorage = game:GetService("ReplicatedStorage")
local groupEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("PlayerInGroup")
local getDevProducts = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("shop")
	:WaitForChild("GetDevProductTable")
local buyDevProduct =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("BuyDevProduct")
local ownsGamePass =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("shop"):WaitForChild("ownsGamePass")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ServerStorage = game:GetService("ServerStorage")
local Boostmanager = require(script.Parent.Boostmanager)
local bombUtils = require(script.Parent.bombUtils)
local inventoryFunctions = require(script.Parent.inventoryFunctions)
local rollTickets = require(script.Parent.rollTickets)
local shopStore = DataStoreService:GetDataStore("ShopStore")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
local shop = {}

local GROUP_ID = 35951660
local GROUP_REWARD = {
	XP_BOOST = {
		BOOST_AMP = 2,
		BOOST_TIME = 1800,
	},
	TICKETS = 20,
}
type RewardEffect = "ticket" | "boostself" | "boostall" | "bomball" | "backpack"
type ProductType = "devProduct" | "gamePass"

local devProducts: {
	[string]: {
		id: string,
		price: number,
		devProduct: ProductType,
		paidRandomItem: boolean,
		reward: { effect: RewardEffect, amount: number },
	},
} =
	{
		["1slap"] = {
			id = "3371429809",
			price = 5,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 1 },
		},
		["5slap"] = {
			id = "3371431317",
			price = 19,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 5 },
		},
		["10slap"] = {
			id = "3371431667",
			price = 29,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 10 },
		},
		["20slap"] = {
			id = "3371431925",
			price = 45,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 20 },
		},
		["50slap"] = {
			id = "3371432388",
			price = 79,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 50 },
		},
		["100slap"] = {
			id = "3371433008",
			price = 149,
			devProduct = "devProduct",
			paidRandomItem = true,
			reward = { effect = "ticket", amount = 100 },
		},
		["xpboostself"] = {
			id = "3371434602",
			price = 79,
			devProduct = "devProduct",
			paidRandomItem = false,
			reward = { effect = "boost", amount = 3600 },
		},
		["xpboostall"] = {
			id = "3371435310",
			price = 179,
			devProduct = "devProduct",
			paidRandomItem = false,
			reward = { effect = "boostall", amount = 3600 },
		},
		["bomball"] = {
			id = "3371433642",
			price = 199,
			devProduct = "devProduct",
			paidRandomItem = false,
			reward = { effect = "bomball", amount = 0 },
		},
		["bpUpgrade"] = {
			id = "1404903177",
			price = 199,
			devProduct = "gamePass",
			paidRandomItem = false,
			reward = { effect = "backpack", amount = 1 },
		},
	}

local function claimRewards(player: Player)
	Boostmanager.AddBoost(
		player,
		"ExpBoost",
		"delay",
		GROUP_REWARD.XP_BOOST.BOOST_AMP,
		GROUP_REWARD.XP_BOOST.BOOST_TIME
	)
	rollTickets.AddTickets(player.UserId, 20)
end

groupEvent.OnServerInvoke = function(player: Player, claim: boolean): { isInGroup: boolean, claimed: boolean }
	local checkIsInGroup = player:IsInGroup(GROUP_ID)
	local userId = player.UserId

	local successGet, claimed = pcall(function()
		return shopStore:GetAsync(userId)
	end)

	if not successGet then
		claimed = true
	end

	if claim and not claimed and checkIsInGroup then
		local successSet, err = pcall(function()
			return shopStore:SetAsync(userId, true)
		end)

		if successSet then
			claimed = true
			claimRewards(player)
		else
			warn("Failed to save claim status:", err)
		end
	end

	return { isInGroup = checkIsInGroup, claimed = claimed or false }
end

getDevProducts.OnServerInvoke = function(_): {
	[string]: {
		id: string,
		price: number,
		devProduct: ProductType,
		paidRandomItem: boolean,
		reward: { effect: RewardEffect, amount: number },
	},
}
	return devProducts
end

local function PlayerOwnsGamePass(player, gamePassId)
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	print(result)
	if success then
		return result
	else
		warn("Error checking gamepass ownership for", player, gamePassId)
		return false
	end
end

local function tryBuy(
	player,
	product: {
		id: string,
		price: number,
		devProduct: ProductType,
		paidRandomItem: boolean,
		reward: { effect: RewardEffect, amount: number },
	}
)
	local productId = tonumber(product.id)
	if not productId then
		warn("Invalid product ID:", product.id)
		return
	end

	if product.devProduct == "devProduct" then
		MarketplaceService:PromptProductPurchase(player, productId)
	elseif product.devProduct == "gamePass" then
		if PlayerOwnsGamePass(player, product.id) then
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, productId)
	end
end

buyDevProduct.OnServerInvoke = function(player, id)
	local success, restriction = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)
	if not success then
		restriction = true
		warn("PolicyService error: " .. restriction .. " (server)")
	elseif restriction.ArePaidRandomItemsRestricted then
		restriction = restriction.ArePaidRandomItemsRestricted
		warn("Player cannot interact with paid random item generators (server)")
	else
		restriction = false
	end

	for _, product in devProducts do
		if tostring(product.id) == tostring(id) then
			if product.paidRandomItem and restriction then
				warn("naa")
				return
			else
				tryBuy(player, product)
			end
		end
	end
end

ownsGamePass.OnServerInvoke = function(player, gamePassId)
	return PlayerOwnsGamePass(player, gamePassId)
end

function shop.ResetGroupRewards(player: Player)
	local userId = player.UserId
	local _, _ = pcall(function()
		return shopStore:SetAsync(userId, false)
	end)
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	print("process")
	local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = tostring(receiptInfo.ProductId)
	local product

	for _, data in pairs(devProducts) do
		if data.id == productId then
			product = data
			break
		end
	end

	if not product then
		warn("Unknown product bought:", productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if product.reward.effect == "ticket" then
		rollTickets.AddTickets(player.UserId, product.reward.amount)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif product.reward.effect == "boost" then
		Boostmanager.AddBoost(player, "ExpBoost", "delay", 2, product.reward.amount)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif product.reward.effect == "boostall" then
		for _, onlinePlayer in Players:GetChildren() do
			if onlinePlayer then
				Boostmanager.AddBoost(onlinePlayer, "ExpBoost", "delay", 2, product.reward.amount)
			end
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif product.reward.effect == "bomball" then
		for _, onlinePlayer: Player? in Players:GetChildren() do
			if onlinePlayer and onlinePlayer.UserId ~= player.UserId then
				local bombClone = bombPrefab:Clone()
				bombUtils.giveBombToPlayer(onlinePlayer, bombClone)
			end
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassId, wasPurchased)
	if wasPurchased then
		if purchasedPassId == 1404903177 then
			inventoryFunctions.IncrementSlotSpace(player)
		end
	end
end)

return shop
