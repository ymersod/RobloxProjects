local ServerScriptService = game:GetService("ServerScriptService")
local speedBoostBind = ServerScriptService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("BindableEvents")
	:WaitForChild("speedBoostBind")
local tool = script.Parent
local remote = tool:FindFirstChild("ActivateAbility")
local lastUse = 0

if not remote then
	return
end

remote.OnServerEvent:Connect(function(player: Player, abilityVals: Instance, slotToolId:string)
	local curTime = os.time()
	local cd = abilityVals:GetAttribute("cooldown") :: number?
	if cd and curTime - lastUse >= cd then
		speedBoostBind:Fire(player, abilityVals, slotToolId)
	else
		warn("Ability on cooldown or abilityvals broken")
	end
end)
