local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local shopGui = screenGui:WaitForChild("Shop") :: Frame
local closeButton: ImageButton = shopGui:WaitForChild("OpenContainer"):WaitForChild("CloseButton")

closeButton.MouseButton1Click:Connect(function()
	shopGui.Visible = false
end)
