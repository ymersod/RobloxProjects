local players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")

local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId:string)
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
	humanoid.WalkSpeed = compIntVal.Value

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

		if newHumanoid:IsDescendantOf(game) then
			compIntVal.removeModifier(slotToolId .. "SpeedAmp")
			newHumanoid.WalkSpeed = compIntVal.Value
		else
			newPlayer.CharacterAdded:Once(function()
				compIntVal.removeModifier(slotToolId .. "SpeedAmp")
				newHumanoid.WalkSpeed = compIntVal.Value
			end)
		end
	end)
end)

local function setJumpHeight(val, player, humanoid)
	if player.States.CanJump.Value then
		humanoid.JumpHeight = val
	end
end

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId:string)
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
	setJumpHeight(compIntVal.Value, player, humanoid)

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

		if newHumanoid:IsDescendantOf(game) then
			compIntVal.removeModifier(slotToolId .. "JumpAmp")
			setJumpHeight(compIntVal.Value, player, newHumanoid)
			print("Jump reset")
		else
			newPlayer.CharacterAdded:Once(function()
				local newCharacter = player.Character
				local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")
				compIntVal.removeModifier(slotToolId .. "JumpAmp")
				setJumpHeight(compIntVal.Value, player, newHumanoid)
			end)
		end
	end)
end)
