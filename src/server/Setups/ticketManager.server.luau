local Players = game:GetService("Players")

local ticketFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("rollTickets")

local funcs = require(ticketFunctions)

Players.PlayerAdded:Connect(funcs.onPlayerAdded)
Players.PlayerRemoving:Connect(funcs.onPlayerRemoving)
