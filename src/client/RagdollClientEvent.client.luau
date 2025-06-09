local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")

local ragdollModule = require(ReplicatedStorage.Shared.ModuleScripts.ragdollPlayer)

ragdollClientEvent.OnClientEvent:Connect(function()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()

	ragdollModule.Ragdoll(character)
end)
