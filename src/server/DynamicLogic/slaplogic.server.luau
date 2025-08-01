local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScripService = game:GetService("ServerScriptService")
local kingCoinFuncsScript =
	ServerScripService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("KingCoinFunctions")
local slapBind = ServerScripService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("BindableEvents")
	:WaitForChild("slapBind")
local kingCoinFuncs = require(kingCoinFuncsScript)
local expManagerFuncsScript =
	ServerScripService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("expManagerFunctions")
local expManagerFuncs = require(expManagerFuncsScript)

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

local COIN_VALUE_MIN = 7
local COIN_VALUE_MAX = 15
local COIN_SPAWN_RADIUS = 10
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

	canActivate = false -- Begin cooldown
	loadedAnim:Play()

	-- Start cooldown timer
	task.delay(COOLDOWN, function()
		canActivate = true
	end)

	local statVals = tool:FindFirstChild("StatVals")

	if not statVals or not statVals:GetAttribute("Range") then
		return
	end

	if tool.Parent and tool.Parent:IsA("Model") and tool.Parent.PrimaryPart then
		local directionV3 = tool.Parent.PrimaryPart.CFrame.LookVector

		if
			tool.Parent:FindFirstChildOfClass("Humanoid")
			and tool.Parent:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0
		then
			directionV3 = tool.Parent:FindFirstChildOfClass("Humanoid").MoveDirection
		end

		local castParams = RaycastParams.new()
		castParams.CollisionGroup = "MeeleTools"
		castParams.FilterType = Enum.RaycastFilterType.Exclude

		local shapeCastResults = workspace:Blockcast(
			tool.Parent.PrimaryPart.CFrame,
			Vector3.new(30, 10, 1),
			directionV3 * (statVals:GetAttribute("Range") + 6),
			castParams
		)

		if
			shapeCastResults
			and shapeCastResults.Instance:FindFirstAncestorOfClass("Model")
			and game.Players:GetPlayerFromCharacter(shapeCastResults.Instance:FindFirstAncestorOfClass("Model"))
		then
			local targetPlayer =
				Players:GetPlayerFromCharacter(shapeCastResults.Instance:FindFirstAncestorOfClass("Model"))
			if targetPlayer.States.Safe.Value then
				print(targetPlayer.Name, " is safe!")
				return
			end

			kingCoinFuncs.spawnMultipleKingCoinOfSizeRangesFromPlayer(
				targetPlayer,
				COIN_SPAWN_RADIUS,
				KING_SCORE_DRAIN_PERCENT,
				COIN_VALUE_MIN,
				COIN_VALUE_MAX
			)

			local xpBoost = 1
			local xpBoostIntValue: IntValue = targetPlayer
				and targetPlayer:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
			if xpBoostIntValue then
				xpBoost = xpBoostIntValue.Value / 100
			end

			if Players:GetPlayerFromCharacter(tool.Parent) then
				expManagerFuncs.incrementExp(Players:GetPlayerFromCharacter(tool.Parent).UserId, 2 * xpBoost)
			end
			local attackerHRP = tool.Parent:FindFirstChild("HumanoidRootPart")
			local hitDirection = (shapeCastResults.Instance.Position - attackerHRP.Position).Unit * POWER_MULT
			slapBind:Fire(targetPlayer, hitDirection)
		end
	end
end)
