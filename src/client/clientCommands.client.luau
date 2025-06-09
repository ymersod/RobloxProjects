local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("ragdollPlayer"))

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message == "/ragdoll" then
			ragdollModule.Ragdoll(player.Character)
		end
	end)
end)
