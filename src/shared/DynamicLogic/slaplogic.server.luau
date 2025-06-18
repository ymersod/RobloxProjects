local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local part = script.Parent :: Part
local tool = part.Parent :: Tool

local animationId = "rbxassetid://121694662752238"
local animation = Instance.new("Animation")
animation.AnimationId = animationId

local characterRoot = script:FindFirstAncestorOfClass("Model") :: Model?
local humanoid = characterRoot and characterRoot:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid and humanoid:WaitForChild("Animator") :: Animator

local loadedAnim -- so we can stop it later if needed

local POWER_MULT = 1000

local debounce = {}

part.Touched:Connect(function(hit: BasePart)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return
	end

	local targetPlayer = game.Players:GetPlayerFromCharacter(character)
	if not targetPlayer then
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
	if loadedAnim then
		loadedAnim:Stop()
	end
	loadedAnim = animator:LoadAnimation(animation)
	loadedAnim:Play()
end)
