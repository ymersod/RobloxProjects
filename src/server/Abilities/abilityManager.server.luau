local players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")
local speedJumpBoostBind = bindableEvents:WaitForChild("speedJumpBoostBind")
local slapBind = bindableEvents:WaitForChild("slapBind")

local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local ragdollUtils = require(ServerScriptService.Server.ServerModuleScripts.ragdollUtils)

local function handleBoost(player: Player, abilityVals: Instance, slotToolId: string, boostType: "Speed" | "Jump")
	local playerUserId = player.UserId

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local amp = abilityVals:GetAttribute("boostAmp") :: number?
	local timer = abilityVals:GetAttribute("boostTime") :: number?

	if not amp or not timer then
		warn("Cant find vars on abilityVals for " .. boostType)
		return
	end

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(playerUserId .. boostType .. "Value")
	local modifierName = slotToolId .. boostType .. "Amp"

	compIntVal += { Name = modifierName, Value = amp }

	delayUtil.Delay(timer, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer and newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:FindFirstChildOfClass("Humanoid")

		if newHumanoid and newHumanoid:IsDescendantOf(game) then
			compIntVal.removeModifier(modifierName)
		else
			newPlayer.CharacterAdded:Once(function()
				compIntVal.removeModifier(modifierName)
			end)
		end
	end)
end

speedJumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	handleBoost(player, abilityVals, slotToolId, "Speed")
	handleBoost(player, abilityVals, slotToolId, "Jump")
end)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	handleBoost(player, abilityVals, slotToolId, "Speed")
end)

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	handleBoost(player, abilityVals, slotToolId, "Jump")
end)

slapBind.Event:Connect(function(targetPlayer, direction)
	ragdollUtils.ragdoll(targetPlayer, direction, 2)
end)
