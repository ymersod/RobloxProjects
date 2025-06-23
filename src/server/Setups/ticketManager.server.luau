local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ticketFunctions =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("rollTickets")
local funcs = require(ticketFunctions)

Players.PlayerAdded:Connect(funcs.onPlayerAdded)
Players.PlayerRemoving:Connect(funcs.onPlayerRemoving)
