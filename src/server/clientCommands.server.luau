local ReplicatedStorage = game:GetService("ReplicatedStorage")
local killModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("killPlayer"))

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message == "/kill" then
			killModule.killPlayer(player.Character, player)
		end
	end)
end)
