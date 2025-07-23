local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local rollTickets = require(ServerScriptService.Server.ServerModuleScripts.rollTickets)
local spendTicketEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("TicketFunctions")
	:WaitForChild("SpendTickets")

local addTicketsEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("TicketFunctions")
	:WaitForChild("AddTickets")

spendTicketEvent.OnServerInvoke = function(player: Player, amount: number)
	-- print(player.UserId .. " AAA " .. amount)
	return rollTickets.SpendTickets(player.UserId, amount)
end

addTicketsEvent.OnServerInvoke = function(player: Player, amount: number)
	return rollTickets.AddTickets(player.UserId, amount)
end
