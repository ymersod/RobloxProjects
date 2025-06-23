local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")

local ragdollModule = require(ReplicatedStorage.Shared.ClientServerModuleScripts.ragdollPlayerClient)

ragdollClientEvent.OnClientEvent:Connect(function(hitPosition: Vector3, direction: Vector3)
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()

	ragdollModule.Ragdoll(character, hitPosition, direction)
end)
