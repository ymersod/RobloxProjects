local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pushBackClientEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("PushBackClient")
local velocityUtils = require(ReplicatedStorage.Shared.ClientServerModuleScripts.velocityUtils)
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
	velocityUtils.applyKnockback(rootPart, velocity)
end)
