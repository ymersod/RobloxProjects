local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
local jumpEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("JumpPadClient")

jumpEvent.OnClientEvent:Connect(function(pad: BasePart, isAngular: boolean, momentumFactor: number, launchSpeed: number)
	SoundService:PlayLocalSound(sounds.Jumppads)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	local launchDirection: Vector3
	if isAngular then
		launchDirection = pad.CFrame.UpVector -- or LookVector if needed
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		task.delay(0.5, function()
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
	else
		launchDirection = Vector3.new(0, 1, 0)
	end

	local newVelocity = launchDirection.Unit * launchSpeed
	rootPart.AssemblyLinearVelocity = newVelocity
end)
