local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ticketStore = DataStoreService:GetDataStore("PlayerTickets")
local TicketFuncs = {}

local playerTickets = {}

local function updateTickets(playerId)
	local player = Players:GetPlayerByUserId(playerId)
	local tickets: IntValue = player and player:FindFirstChild("LocalStats"):FindFirstChild("Tickets")
	if tickets then
		tickets.Value = playerTickets[playerId]
	else
		warn("Couldnt update player tickets in localstats - VERY BAD")
	end
end

function TicketFuncs.SetTickets(playerId, amount)
	print("setting Tickets for player with id: " .. playerId)
	if playerTickets[playerId] then
		playerTickets[playerId] = amount
		updateTickets(playerId)
	end
end

function TicketFuncs.AddTickets(playerId, amount)
	print("incrementing Tickets for player with id: " .. playerId)
	if playerTickets[playerId] then
		playerTickets[playerId] += amount
		updateTickets(playerId)
	end
	print("Tickets : " .. playerTickets[playerId])
end

function TicketFuncs.SpendTickets(playerId, amount)
	print("spending Tickets for player with id: " .. playerId)
	local f = playerTickets[playerId]
	if playerTickets[playerId] and playerTickets[playerId] >= amount then
		playerTickets[playerId] -= amount
		updateTickets(playerId)
		return true
	end
	return false
end

function TicketFuncs.onPlayerAdded(player: Player)
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
		updateTickets(player.UserId)
		print(currentTickets)
	end

	-- local bindablePlayerLevel: IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level") :: IntValue
	-- bindablePlayerLevel.Changed:Connect(function(newLevel)
	-- 	-- TODO: Leveluprewards instead
	-- 	warn("errr")
	-- 	TicketFuncs.AddTickets(player.UserId, 1)
	-- end)
end

function TicketFuncs.onPlayerRemoving(player: Player)
	if player.UserId <= 0 then
		playerTickets[player.UserId] = nil
		return
	end

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
