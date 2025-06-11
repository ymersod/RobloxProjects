local Players = game:GetService("Players")

local expManagerFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("expManagerFunctions")

local funcs = require(expManagerFunctions)

Players.PlayerAdded:Connect(funcs.onPlayerAdded)
Players.PlayerRemoving:Connect(funcs.onPlayerRemoving)
