local ServerScriptService = game:GetService("ServerScriptService")
local Boostmanager = require(ServerScriptService.Server.ServerModuleScripts.Boostmanager)
local bombBind = ServerScriptService:WaitForChild("Server")
	:WaitForChild("serverEvents")
	:WaitForChild("binds")
	:WaitForChild("bombDestroyingBind")

local function removeBoosts(player: Player, keyTable)
	if not player then
		warn("player not found, cant remove boosts")
		return
	end
	print(player)
	print(keyTable)
	local userId = tostring(player.UserId)
	local oldKeys = keyTable[userId]
	if oldKeys then
		for _, key in ipairs(oldKeys) do
			if key then
				Boostmanager.RemoveBoost(key)
			end
		end
		keyTable[userId] = nil
	end
end
bombBind.Event:Connect(function(curownerplayer: Player, keyTable)
	curownerplayer.CharacterAdded:Once(function()
		print("removing boosts")
		removeBoosts(curownerplayer, keyTable)
	end)
end)
