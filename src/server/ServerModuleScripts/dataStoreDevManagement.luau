local DataStoreService = game:GetService("DataStoreService")
local expStore = DataStoreService:GetDataStore("PlayerExp")
local orderedExpStore = DataStoreService:GetOrderedDataStore("OrderedPlayerExp")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")
local ticketStore = DataStoreService:GetDataStore("PlayerTickets")
local dailyRewardStore = DataStoreService:GetDataStore("DailyRewards")
local levelUpRewardStore = DataStoreService:GetDataStore("LevelupRewards")
local firstTimePlayerStore = DataStoreService:GetDataStore("FirstTimeLogin")
local volumeSettingsStore = DataStoreService:GetDataStore("VolumeSettings")
local MemoryStoreService = game:GetService("MemoryStoreService")
local orderedExpMemoryStore = MemoryStoreService:GetSortedMap("OrderedPlayerExp")


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

function dataStoreManagementFunctions.removePlayerVolumeSettingsStore(playerId)
	local success, err = pcall(function()
		return volumeSettingsStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player " .. playerId .. " removed from VolumeSettings" }
	end
	return { success = false, payload = err }
end

function dataStoreManagementFunctions.clearExpStore()
	local success, keys = pcall(function()
		return expStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return expStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "expStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in ExpStore" }
end

function dataStoreManagementFunctions.clearOrderedExpStore()
	local success, keys = pcall(function()
		return orderedExpStore:GetSortedAsync(true, 100)
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return orderedExpStore:RemoveAsync(k.key)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "orderedExpStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in orderedExpStore" }
end

function dataStoreManagementFunctions.clearOrderedExpMemoryStore()
	local success, keys = pcall(function()
		return orderedExpMemoryStore:GetRangeAsync(Enum.SortDirection.Ascending, 100)
	end)
	if success then
		for i, k in ipairs(keys) do
			local success2, err = pcall(function()
				return orderedExpMemoryStore:RemoveAsync(k.key)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "orderedExpMemoryStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in orderedExpMemoryStore" }
end

function dataStoreManagementFunctions.clearInventoryStore()
	local success, keys = pcall(function()
		return inventoryStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return inventoryStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "InventoryStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in InventoryStore" }
end

function dataStoreManagementFunctions.clearTicketStore()
	local success, keys = pcall(function()
		return ticketStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return ticketStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "TicketStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in TicketStore" }
end

function dataStoreManagementFunctions.clearDailyRewardStore()
	local success, keys = pcall(function()
		return dailyRewardStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return dailyRewardStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "DailyRewardStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in DailyRewardStore" }
end

function dataStoreManagementFunctions.clearLevelupRewardStore()
	local success, keys = pcall(function()
		return levelUpRewardStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return levelUpRewardStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "LevelupRewardStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in LevelupRewardStore" }
end

function dataStoreManagementFunctions.clearFirstTimeLoginStore()
	local success, keys = pcall(function()
		return firstTimePlayerStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return firstTimePlayerStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "FirstTimeLoginStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in FirstTimeLoginStore" }
end

function dataStoreManagementFunctions.clearVolumeSettingsStore()
	local success, keys = pcall(function()
		return volumeSettingsStore:ListKeysAsync()
	end)
	if success then
		for i, k in ipairs(keys:GetCurrentPage()) do
			local success2, err = pcall(function()
				return volumeSettingsStore:RemoveAsync(k.KeyName)
			end)
			if not success2 then
				return { success = false, payload = err }
			end
		end
		return { success = true, payload = "VolumeSettingsStore was cleared of keys" }
	end
	return { success = false, payload = "Something when wrong while searching for keys in VolumeSettingsStore" }
end

function dataStoreManagementFunctions.clearAllKeysInDataStores()
	local clearSuccessObj = dataStoreManagementFunctions.clearDailyRewardStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearExpStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearOrderedExpStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearOrderedExpMemoryStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearFirstTimeLoginStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearInventoryStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearLevelupRewardStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearTicketStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end

	clearSuccessObj = dataStoreManagementFunctions.clearVolumeSettingsStore()
	if not clearSuccessObj.success then
		warn(clearSuccessObj.payload)
	end
end

return dataStoreManagementFunctions
