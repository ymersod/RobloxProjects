local ragdollUtils = require(script.Parent.ragdollUtils)

local killPlayerModule = {}

function killPlayerModule.killPlayer(player: Player)
	local char = player.Character
	if not char then
		return
	end

	ragdollUtils.ragdoll(player, Vector3.zero, 5)

	local hum = char:FindFirstChildOfClass("Humanoid")
	hum.Health = 0
end

return killPlayerModule
