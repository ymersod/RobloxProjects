local players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")

local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance)
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

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId.."SpeedValue")
	compIntVal += { Name = "SpeedAmp", Value = speedAmp }
	humanoid.WalkSpeed = compIntVal.Value

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")
	
		if newHumanoid:IsDescendantOf(game) then
			compIntVal -= { Name = "SpeedAmp", Value = speedAmp }
			newHumanoid.WalkSpeed = compIntVal.Value
		else newPlayer.CharacterAdded:Once(function()
				compIntVal -= { Name = "SpeedAmp", Value = speedAmp }
				newHumanoid.WalkSpeed = compIntVal.Value
			end
		)end
	end)
end)

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance)
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

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId.."JumpValue")
	compIntVal += { Name = "JumpAmp", Value = jumpAmp }
	humanoid.JumpHeight = compIntVal.Value

	delayUtil.Delay(boostTime, function()
		local newPlayer = players:GetPlayerByUserId(playerUserId)
		local newCharacter = newPlayer.Character
		local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

		if newHumanoid:IsDescendantOf(game) then
			compIntVal -= { Name = "JumpAmp", Value = jumpAmp }
			newHumanoid.JumpHeight = compIntVal.Value
			print("Jump reset")
		else newPlayer.CharacterAdded:Once(function()
				local newCharacter = player.Character
				local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")
				compIntVal -= { Name = "JumpAmp", Value = jumpAmp }
				newHumanoid.WalkSpeed = compIntVal.Value
			end
		)end
	end)
end)
