local DataStoreService = game:GetService("DataStoreService")
local ticketStore = DataStoreService:GetDataStore("PlayerTickets")

local TicketFuncs = {}

local playerTickets = {}

function TicketFuncs.AddTickets(playerId, amount)
	print("incrementing Tickets for player with id: " .. playerId)
	if playerTickets[playerId] then
		playerTickets[playerId] += amount
	end
	print("Tickets : " .. playerTickets[playerId])
end

function TicketFuncs.SpendTickets(playerId, amount)
	print("incrementing Tickets for player with id: " .. playerId)
	if playerTickets[playerId] and playerTickets[playerId] > amount then
		playerTickets[playerId] -= amount
		return true
	end
	return false
end

function TicketFuncs.onPlayerAdded(player:Player)
	-- Read data store key
	local success, storedTickets = pcall(function()
		return ticketStore:GetAsync(player.UserId)
	end)
	if success then
		local currentTickets
		if storedTickets then
			currentTickets = storedTickets
		else
			currentTickets = 0
		end
		playerTickets[player.UserId] = currentTickets
		print(currentTickets)
	end

	local bindablePlayerLevel:IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level") :: IntValue
	bindablePlayerLevel.Changed:Connect(function(newLevel)
		TicketFuncs.AddTickets(player.UserId, 1)
	end)
end

function TicketFuncs.onPlayerRemoving(player:Player)
	-- Set data store key
	local success, err = pcall(function()
		ticketStore:SetAsync(player.UserId, playerTickets[player.UserId])
	end)
	if not success then
		warn(err)
	end
	-- Clean up entry so that the table doesn't grow for the lifespan of the server
	playerTickets[player.UserId] = nil
end

return TicketFuncs