local ServerScriptService = game:GetService("ServerScriptService")
local CompositeIntValue = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValue)
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")

-- GLOBAL VALS (Found in file -> gamesettings -> World -> ...) they are inaccessible
local OG_SPEED = CompositeIntValue.new(16)
local OG_JUMP_HEIGHT = CompositeIntValue.new(7.2)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance)
	print("SpeedVals: ", abilityVals)
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

	local originalSpeed = humanoid.WalkSpeed
	OG_SPEED += { Name = "SpeedAmp", Value = speedAmp }
	humanoid.WalkSpeed = originalSpeed * speedAmp

	delayUtil.Delay(boostTime, function()
		if humanoid:IsDescendantOf(game) then
			OG_SPEED -= { Name = "SpeedAmp", Value = speedAmp }
			humanoid.WalkSpeed = OG_SPEED.Value
		end
	end)
end)

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance)
	print("Yump vals: ", abilityVals)
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

	local originalJump = humanoid.JumpHeight
	OG_JUMP_HEIGHT += { Name = "JumpAmp", Value = jumpAmp }
	humanoid.JumpHeight = originalJump * jumpAmp

	delayUtil.Delay(boostTime, function()
		if humanoid:IsDescendantOf(game) then
			OG_JUMP_HEIGHT -= { Name = "JumpAmp", Value = jumpAmp }
			humanoid.JumpHeight = OG_JUMP_HEIGHT.Value
			print("Jump reset")
		end
	end)
end)
