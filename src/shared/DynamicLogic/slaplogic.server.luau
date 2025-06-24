local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local slapAnimation = ServerStorage:WaitForChild("Animations"):WaitForChild("SlapAni")
local part = script:FindFirstAncestorOfClass("Tool"):FindFirstChildOfClass("MeshPart") :: MeshPart
local tool = part.Parent :: Tool

local characterRoot = script:FindFirstAncestorOfClass("Model") :: Model?
local humanoid = characterRoot and characterRoot:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid and humanoid:WaitForChild("Animator") :: Animator

local loadedAnim = animator:LoadAnimation(slapAnimation)

local POWER_MULT = 1000

local debounce = {}

part.Touched:Connect(function(hit: BasePart)
	if not loadedAnim.IsPlaying then
		return
	end

	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return
	end

	local targetPlayer = game.Players:GetPlayerFromCharacter(character)
	if not targetPlayer then
		return
	end

	if targetPlayer.States.Safe.Value then
		print(targetPlayer.Name, " is safe!")
		return
	end

	if debounce[targetPlayer] then
		return
	end
	debounce[targetPlayer] = true
	task.delay(1, function()
		debounce[targetPlayer] = nil
	end)

	local rootPart: Part = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local hitDirection = (rootPart.Position - part.Position).Unit * POWER_MULT
	print("Hitting from direction: ", hitDirection)
	ragdollClientEvent:FireClient(targetPlayer, hit.Position, hitDirection)
end)

tool.Activated:Connect(function()
	if loadedAnim and loadedAnim.IsPlaying then
		-- Animation is already playing, don't play again
		return
	end

	loadedAnim = animator:LoadAnimation(slapAnimation)
	loadedAnim:Play()
end)
