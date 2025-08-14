local Players = game:GetService("Players")
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
local lastUsePerPlayerSlot = {}
if not remote then
	return
end

Players.PlayerRemoving:Connect(function(player)
	lastUsePerPlayerSlot[player.UserId] = nil
end)

remote.OnServerEvent:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	local curTime = os.clock()
	local cd = abilityVals:GetAttribute("cooldown") :: number?

	local userId = player.UserId
	lastUsePerPlayerSlot[userId] = lastUsePerPlayerSlot[userId] or {}

	local lastUse = lastUsePerPlayerSlot[userId][slotToolId] or 0

	if cd and curTime - lastUse >= cd then
		lastUsePerPlayerSlot[userId][slotToolId] = curTime
		bind:Fire(player, abilityVals, slotToolId, tool)
	else
		warn(`Ability for slot "{slotToolId}" is on cooldown for {player.Name} or abilityVals broken`)
	end
end)
