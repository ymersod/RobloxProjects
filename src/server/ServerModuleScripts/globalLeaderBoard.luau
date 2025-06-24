local MemoryStoreService = game:GetService("MemoryStoreService")
local orderedExpMemoryStore = MemoryStoreService:GetSortedMap("OrderedPlayerExp")
local DataStoreService = game:GetService("DataStoreService")
local orderedExpStore = DataStoreService:GetOrderedDataStore("OrderedPlayerExp")

local leaderBoards = {}

function leaderBoards.GetTop10()
	local success, playersSorted = pcall(function()
		return orderedExpMemoryStore:GetRangeAsync(Enum.SortDirection.Descending, 10)
	end)
	if success then
		return playersSorted
	else
		return {}
	end
end

local success, playersSorted = pcall(function()
	return orderedExpStore:GetSortedAsync(false, 10)
end)
if success then
	-- print(playersSorted:GetCurrentPage())
	local currentPage = playersSorted:GetCurrentPage()
	for i, player in ipairs(currentPage) do
		local success, memPlayer = pcall(function()
			return orderedExpMemoryStore:GetAsync(player.key)
		end)
		if (not success) or (memPlayer and memPlayer < player.value) then
			local success, err = pcall(function()
				return orderedExpMemoryStore:SetAsync(player.key, player.value, 38e5, player.value)
			end)
			if not success then
				warn(err)
			end
		end
	end
end

return leaderBoards