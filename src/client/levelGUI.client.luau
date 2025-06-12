local player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local levelText: TextLabel =
	player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("LevelBar"):WaitForChild("LevelText")
local expFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("LevelBar")
	:WaitForChild("Frame")
	:WaitForChild("Exp")

levelText.Text = 'Level: <font color="rgb(255, 221, 0)">2</font>'

expLevelClient.OnClientEvent:Connect(function(level:{ lvl:number, lvlProgress:{ progress:number, goal:number }})
	expFrame.Size = UDim2.new(level.lvlProgress.progress/level.lvlProgress.goal,0,1,0)
levelText.Text = 'Level: <font color="rgb(255, 221, 0)">'.. level.lvl ..'</font>'
end)