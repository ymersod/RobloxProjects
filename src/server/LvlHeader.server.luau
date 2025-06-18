local billboardGUI = game:GetService("ReplicatedStorage"):WaitForChild("UI"):WaitForChild("LevelBillboard")

--TODO: Need some better naming, both in file name and variables(eg. levelTest)

function setupBB(player: Player, char, levelTest: IntValue)
	local newBBGUi = billboardGUI:Clone()
	newBBGUi.UsernameLabel.Text = player.DisplayName
	newBBGUi.LevelLabel.Text = "Level: " .. levelTest.Value
	newBBGUi.Parent = char.Head
end
game.Players.PlayerAdded:Connect(function(player: Player)
	local levelTest = player:WaitForChild("LocalStats"):WaitForChild("Level") :: IntValue

	local playerChar = player.Character
	if playerChar then
		setupBB(player, playerChar, levelTest)
	end

	player.CharacterAdded:Connect(function(char)
		setupBB(player, char, levelTest)
	end)

	levelTest.Changed:Connect(function()
		local playerCharCur = player.Character
		local pLevelTest = player:WaitForChild("LocalStats"):WaitForChild("Level") :: IntValue
		if playerCharCur then
			playerCharCur.Head.LevelBillboard.LevelLabel.Text = "Level: " .. pLevelTest.Value
		end
	end)
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end)
	if player.Character then
		local humanoid = player.Character:WaitForChild("Humanoid")
		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end
	end
end)
