local Gui = game:GetService("ReplicatedStorage"):WaitForChild("UI"):WaitForChild("LevelBillboard")

game.Players.PlayerAdded:Connect(function(player)
	local levelTest = player:WaitForChild("LocalStats"):WaitForChild("Level")

	player.CharacterAdded:Connect(function(char)
		local newGui = Gui:Clone()
		newGui.UsernameLabel.Text = player.DisplayName
		newGui.LevelLabel.Text = "Level: " .. levelTest.Value
		newGui.Parent = char.Head
	end)
	levelTest.Changed:Connect(function()
		player.Character.Head.LevelBillboard.LevelLabel.Text = "Level: " .. player.LocalStats.Level.Value
	end)
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end)
end)
