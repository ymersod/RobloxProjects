local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bomb = script.Parent :: Part
local FUSE_TIME = 5
local killModule = require(ReplicatedStorage.Shared.ModuleScripts.killPlayerServer)
local curOwnerModel = script:FindFirstAncestorOfClass("Model")
local curOwnerPlayer = Players:GetPlayerFromCharacter(curOwnerModel)

-- Create a BillboardGui for the bomb
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "BombTimer"
billboardGui.Adornee = bomb
billboardGui.Size = UDim2.new(4, 0, 2, 0) -- Width, Height
billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the bomb
billboardGui.AlwaysOnTop = true
billboardGui.Parent = bomb

-- Add a TextLabel for the countdown
local countdownText = Instance.new("TextLabel")
countdownText.Name = "Countdown"
countdownText.Size = UDim2.new(1, 0, 1, 0)
countdownText.BackgroundTransparency = 1
countdownText.TextColor3 = Color3.new(1, 0, 0) -- Red text
countdownText.TextScaled = true
countdownText.Font = Enum.Font.FredokaOne
countdownText.Text = FUSE_TIME
countdownText.Parent = billboardGui

function explode()
	killModule.killPlayer(curOwnerModel, curOwnerPlayer)
	bomb:Destroy()
end

-- Countdown loop
for timeLeft = FUSE_TIME, 0, -1 do
	countdownText.Text = timeLeft
	task.wait(1)

	-- Optional: Make text flash when close to explosion
	if timeLeft <= 2 then
		countdownText.TextColor3 = Color3.new(1, 1, 0) -- Yellow
		task.wait(0.1)
		countdownText.TextColor3 = Color3.new(1, 0, 0) -- Red
	end
end

-- Boom!
explode()
