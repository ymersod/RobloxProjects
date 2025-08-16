local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ServerScripService = game:GetService("ServerScriptService")
local ServerScriptService = game:GetService("ServerScriptService")
local kingCoinFuncsScript =
	ServerScripService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("KingCoinFunctions")
local slapBind = ServerScripService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("BindableEvents")
	:WaitForChild("slapBind")
local IsSafeUtil = require(ServerScriptService.Server.ServerModuleScripts.IsSafeUtil)
local abilityUtils = require(ServerScriptService.Server.ServerModuleScripts.abilityUtils)
local kingCoinFuncs = require(kingCoinFuncsScript)

local slapAnimation = ServerStorage:WaitForChild("Animations"):WaitForChild("SlapAni")
local part = script:FindFirstAncestorOfClass("Tool"):FindFirstChildOfClass("MeshPart") :: MeshPart
local tool = part.Parent :: Tool
local abilityVals = tool:WaitForChild("StatVals")

local characterRoot = script:FindFirstAncestorOfClass("Model") :: Model?
local humanoid = characterRoot and characterRoot:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid and humanoid:WaitForChild("Animator") :: Animator
local loadedAnim = animator:LoadAnimation(slapAnimation)

local POWER_MULT = 50 * abilityVals:GetAttribute("Damage")
local COOLDOWN = 3 / abilityVals:GetAttribute("Speed")
local canActivate = true

-- local COIN_VALUE_MIN = 7
-- local COIN_VALUE_MAX = 15
-- local COIN_SPAWN_RADIUS = 10
local KING_SCORE_DRAIN_PERCENT = 0.05

tool.Activated:Connect(function()
	if not canActivate then
		return
	end
	if loadedAnim and loadedAnim.IsPlaying then
		return
	end

	if tool.PrimaryPart then
		local sound = tool.PrimaryPart:FindFirstChild("Slap Sound Effect")
		if sound then
			sound:Play()
		end
	end
	local handle = tool.PrimaryPart

	local statVals = tool:FindFirstChild("StatVals")

	if not statVals or not statVals:GetAttribute("Range") then
		return
	end

	local char = tool.Parent
	local player = char and Players:GetPlayerFromCharacter(char)
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
	local aniDur = loadedAnim.Length / 1.5
	local _, size = tool:GetBoundingBox()

	if player and char.PrimaryPart then
		canActivate = false
		loadedAnim:Play()

		task.delay(COOLDOWN, function()
			canActivate = true
		end)

		local hitPlayers = {}
		local endTime = tick() + aniDur

		local connection
		connection = RunService.Heartbeat:Connect(function()
			if tick() > endTime then
				connection:Disconnect()
				return
			end

			local playersInCone =
				abilityUtils.getPlayersInCone(player, hrp.Position, hrp.CFrame.LookVector, 80, size.Z + 2.5)
			for _, target in ipairs(playersInCone) do
				if not hitPlayers[target] then
					hitPlayers[target] = true
					local _ = player and kingCoinFuncs.StealKingScore(target, player, KING_SCORE_DRAIN_PERCENT, tool)

					local ownerAbilitVals = tool:FindFirstChild("AbilityVals") :: StringValue?

					slapBind:Fire(target, player, hrp.CFrame.LookVector * POWER_MULT, ownerAbilitVals, tool)
				end
			end
		end)
	end
end)
