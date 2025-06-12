local player = game:GetService("Players").LocalPlayer

local levelText: TextLabel =
	player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("LevelBar"):WaitForChild("LevelText")
local expFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("Frame")
	:WaitForChild("Exp")

levelText.Text = 'Level: <font color="rgb(255, 221, 0)">2</font>'
