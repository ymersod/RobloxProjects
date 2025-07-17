local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pushBackClientEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("PushBackClient")

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
	local direction = (rootPart.Position - fromPosition).Unit

	local upwardBias = 0.2

	local impulse = Vector3.new(direction.X, upwardBias, direction.Y).Unit * impulseMagnitude
	rootPart:ApplyImpulseAtPosition(impulse, rootPart.Position)
end)
