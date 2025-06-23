local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local expManagerFunctions = require(ServerScriptService.Server.ServerModuleScripts.expManagerFunctions)

Players.PlayerAdded:Connect(expManagerFunctions.onPlayerAdded)
Players.PlayerRemoving:Connect(expManagerFunctions.onPlayerRemoving)
