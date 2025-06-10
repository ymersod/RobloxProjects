local ReplicatedStorage = game:GetService("ReplicatedStorage")
local killModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("killPlayer"))
local ragdollEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message == "/kill" then
			killModule.killPlayer(player.Character, player)
		elseif message == "/ragdoll" then
			ragdollEvent:FireClient(player, player.Character.PrimaryPart.Position, Vector3.new(1000, 1000, 1000))
		end
	end)
end)
