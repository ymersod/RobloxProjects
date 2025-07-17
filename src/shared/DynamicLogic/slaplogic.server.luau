local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local slapAnimation = ServerStorage:WaitForChild("Animations"):WaitForChild("SlapAni")
local part = script:FindFirstAncestorOfClass("Tool"):FindFirstChildOfClass("MeshPart") :: MeshPart
local tool = part.Parent :: Tool
local abilityVals = tool:WaitForChild("StatVals")

local characterRoot = script:FindFirstAncestorOfClass("Model") :: Model?
local humanoid = characterRoot and characterRoot:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid and humanoid:WaitForChild("Animator") :: Animator
local loadedAnim = animator:LoadAnimation(slapAnimation)

local POWER_MULT = 1000 * abilityVals:GetAttribute("Damage")
local COOLDOWN = 3 / abilityVals:GetAttribute("Speed")
local canActivate = true

tool.Activated:Connect(function()
	if not canActivate then
		return
	end
	if loadedAnim and loadedAnim.IsPlaying then
		return
	end

	if tool.PrimaryPart then
		local sound = tool.PrimaryPart:FindFirstChildOfClass("Sound")
		if sound then sound:Play() end
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
		
		if tool.Parent:FindFirstChildOfClass("Humanoid") and tool.Parent:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0 then
			directionV3 = tool.Parent:FindFirstChildOfClass("Humanoid").MoveDirection
		end

		local shapeCastResults = workspace:Blockcast(tool.Parent.PrimaryPart.CFrame, Vector3.new(20,10,10), directionV3*(statVals:GetAttribute("Range")+1))

		if shapeCastResults and shapeCastResults.Instance:FindFirstAncestorOfClass("Model") and game.Players:GetPlayerFromCharacter(shapeCastResults.Instance:FindFirstAncestorOfClass("Model")) then
			local targetPlayer = game.Players:GetPlayerFromCharacter(shapeCastResults.Instance:FindFirstAncestorOfClass("Model"))
			if targetPlayer.States.Safe.Value then
				print(targetPlayer.Name, " is safe!")
				return
			end

			local hitDirection = (shapeCastResults.Instance.Position - part.Position).Unit * POWER_MULT
			ragdollClientEvent:FireClient(targetPlayer, shapeCastResults.Position, hitDirection)
		end
	end
end)
