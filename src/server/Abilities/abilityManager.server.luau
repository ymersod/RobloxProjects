local players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")
local slapBind = bindableEvents:WaitForChild("slapBind")

local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local ragdollUtils = require(ServerScriptService.Server.ServerModuleScripts.ragdollUtils)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	print("SpeedVals: ", abilityVals)
	local playerUserId = player.UserId

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local speedAmp = abilityVals:GetAttribute("boostAmp") :: number?
	local boostTime = abilityVals:GetAttribute("boostTime") :: number?

	if not speedAmp or not boostTime then
		warn("Cant find vars on abilityvals")
		return
	end

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "SpeedValue")
	compIntVal += { Name = slotToolId .. "SpeedAmp", Value = speedAmp }

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

		if newHumanoid:IsDescendantOf(game) then
			compIntVal.removeModifier(slotToolId .. "SpeedAmp")
		else
			newPlayer.CharacterAdded:Once(function()
				compIntVal.removeModifier(slotToolId .. "SpeedAmp")
			end)
		end
	end)
end)

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string)
	print("Yump vals: ", abilityVals)
	local playerUserId = player.UserId

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local jumpAmp = abilityVals:GetAttribute("boostAmp") :: number?
	local boostTime = abilityVals:GetAttribute("boostTime") :: number?

	if not jumpAmp or not boostTime then
		warn("Cant find vars on abilityvals")
		return
	end

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "JumpValue")
	compIntVal += { Name = slotToolId .. "JumpAmp", Value = jumpAmp }

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

		if newHumanoid:IsDescendantOf(game) then
			compIntVal.removeModifier(slotToolId .. "JumpAmp")
		else
			newPlayer.CharacterAdded:Once(function()
				compIntVal.removeModifier(slotToolId .. "JumpAmp")
			end)
		end
	end)
end)

slapBind.Event:Connect(function(targetPlayer, direction)
	ragdollUtils.ragdoll(targetPlayer, direction)
end)
