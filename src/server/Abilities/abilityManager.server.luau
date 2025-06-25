local ServerScriptService = game:GetService("ServerScriptService")
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local speedBoostBind = ServerScriptService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("BindableEvents")
	:WaitForChild("speedBoostBind")

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Object)
	print(abilityVals)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	print("SpeedUp")
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * 2

	delayUtil.Delay(3, function()
		if humanoid:IsDescendantOf(game) then
			humanoid.WalkSpeed = originalSpeed
			print("Speedreset")
		end
	end)
end)
