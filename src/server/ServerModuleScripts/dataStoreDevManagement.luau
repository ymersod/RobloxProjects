local DataStoreService = game:GetService("DataStoreService")
local expStore = DataStoreService:GetDataStore("PlayerExp")
local orderedExpStore = DataStoreService:GetOrderedDataStore("OrderedPlayerExp")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")
local ticketStore = DataStoreService:GetDataStore("PlayerTickets")
local dailyRewardStore = DataStoreService:GetDataStore("DailyRewards")
local levelUpRewardStore = DataStoreService:GetDataStore("LevelupRewards")
local firstTimePlayerStore = DataStoreService:GetDataStore("FirstTimeLogin")

dataStoreManagementFunctions = {}

function dataStoreManagementFunctions.removePlayerExpStore(playerId)
	local success, err = pcall(function()
		return expStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from expStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerOrderedExpStore(playerId)
	local success, err = pcall(function()
		return orderedExpStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from orderedExpStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerInventoryStore(playerId)
	local success, err = pcall(function()
		return inventoryStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from inventoryStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerTicketStore(playerId)
	local success, err = pcall(function()
		return ticketStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from ticketStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerDailyRewardStore(playerId)
	local success, err = pcall(function()
		return dailyRewardStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from dailyRewardStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerLevelupRewardStore(playerId)
	local success, err = pcall(function()
		return levelUpRewardStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from levelUpRewardStore" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.removePlayerFirstTimeLoginStore(playerId)
	local success, err = pcall(function()
		return firstTimePlayerStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from firstTimePlayer" }
	end
	return { success = false, payload = err }
end

return dataStoreManagementFunctions
