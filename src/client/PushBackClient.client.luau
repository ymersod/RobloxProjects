local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pushBackClientEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("PushBackClient")

local hitVector = Vector3.new(0, 0.3, 0.7)

local function rotateVectorToDirection(baseVector, direction)
	local rotation = CFrame.lookAt(Vector3.zero, -direction)
	return rotation:VectorToWorldSpace(baseVector)
end

pushBackClientEvent.OnClientEvent:Connect(function(fromPosition: Vector3, impulseMagnitude: number)
	local player = game.Players.LocalPlayer
	local character = player.Character
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local direction = (rootPart.Position - fromPosition)
	local flatDirection = Vector3.new(direction.X, 0, direction.Z)

	if flatDirection.Magnitude == 0 then
		return
	end
	local finalDirection = rotateVectorToDirection(hitVector, flatDirection.Unit)

	local velocity = finalDirection * impulseMagnitude

	local knockBackVelocity = Instance.new("BodyVelocity")
	knockBackVelocity.Velocity = velocity
	knockBackVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e5
	knockBackVelocity.P = 1e4
	knockBackVelocity.Parent = rootPart

	game:GetService("Debris"):AddItem(knockBackVelocity, 0.1)
end)
