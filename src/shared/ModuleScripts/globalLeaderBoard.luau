local DataStoreService = game:GetService("DataStoreService")
local orderedExpStore = DataStoreService:GetOrderedDataStore("OrderedPlayerExp")

local leaderBoards = {}

function leaderBoards.GetTop10()
	local success, playersSorted = pcall(function()
		return orderedExpStore:GetSortedAsync(false, 10)
	end)
	if success then
		-- print(playersSorted:GetCurrentPage())
		return playersSorted:GetCurrentPage()
	else
		return {}
	end
end

return leaderBoards