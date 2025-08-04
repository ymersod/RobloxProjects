local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hideUIEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("HideUIClient")

local playerUIContainer: ScreenGui = players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

hideUIEvent.OnClientEvent:Connect(function()
	playerUIContainer.Enabled = not playerUIContainer.Enabled
end)