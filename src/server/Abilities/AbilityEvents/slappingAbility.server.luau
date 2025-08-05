local ServerScriptService = game:GetService("ServerScriptService")
local tool = script.Parent
local ability = tool:FindFirstChild("AbilityVals")
local abilityName = ability and ability:GetAttribute("ability")
if not abilityName then
	return
end
local bind = ServerScriptService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("BindableEvents")
	:WaitForChild(abilityName)
local remote = tool:FindFirstChild("ActivateAbility")
local lastUse = 0

if not remote then
	return
end

remote.OnServerEvent:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	local curTime = os.time()
	local cd = abilityVals:GetAttribute("cooldown") :: number?
	if cd and curTime - lastUse >= cd then
		bind:Fire(player, abilityVals, slotToolId, tool)
	else
		warn("Ability on cooldown or abilityvals broken")
	end
end)
