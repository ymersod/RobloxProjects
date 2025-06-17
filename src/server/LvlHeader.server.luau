local Gui = game:GetService("ReplicatedStorage"):WaitForChild("UI"):WaitForChild("LevelBillboard")

game.Players.PlayerAdded:Connect(function(player)
	local levelTest = player:WaitForChild("Level")

	player.CharacterAdded:Connect(function(char)
		local newGui = Gui:Clone()
		newGui.LevelLabel.Text = "Level: " .. levelTest.Value
		newGui.Parent = char.Head
	end)
	levelTest.Changed:Connect(function()
		player.Character.Head.LevelBillboard.LevelLabel.Text = "Level: " .. player.Level.Value
	end)
end)
