local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jumpEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("JumpPadClient")

jumpEvent.OnClientEvent:Connect(function(pad: BasePart, isAngular: boolean, momentumFactor: number, launchSpeed: number)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	if humanoid.FloorMaterial == Enum.Material.Air then
		return
	end

	print("Launching")
	local launchDirection: Vector3
	if isAngular then
		launchDirection = pad.CFrame.UpVector -- or LookVector if needed
	else
		launchDirection = Vector3.new(0, 1, 0)
	end

	local currentVel = rootPart.AssemblyLinearVelocity
	local newVel = launchDirection.Unit * launchSpeed
	local blendedVel = Vector3.new(
		currentVel.X * momentumFactor + newVel.X * (1 - momentumFactor),
		newVel.Y,
		currentVel.Z * momentumFactor + newVel.Z * (1 - momentumFactor)
	)

	rootPart.AssemblyLinearVelocity = blendedVel
end)
