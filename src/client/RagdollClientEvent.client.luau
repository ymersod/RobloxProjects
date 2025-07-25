local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")

ragdollClientEvent.OnClientEvent:Connect(function(toRagdoll: boolean)
	local player = game.Players.LocalPlayer
	local char = player and player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if toRagdoll then
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
	else
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)
