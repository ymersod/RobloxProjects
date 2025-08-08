local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)

-- GUI elements
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local shopGui = screenGui:WaitForChild("Shop") :: Frame
local closeButton: ImageButton = shopGui:WaitForChild("OpenContainer"):WaitForChild("CloseButton")
local groupClaimButton: TextButton = 
	shopGui:WaitForChild("Frame")
		:WaitForChild("ScrollingFrame")
		:WaitForChild("Frame")
		:WaitForChild("ButtonFrame")
		:WaitForChild("TextButton")

local GROUP_ID = 35951660

closeButton.MouseButton1Click:Connect(function()
	shopGui.Visible = false
end)

shopGui.Changed:Connect(function(variable)
	if variable == "Visible" and shopGui.Visible then
		player:IsInGroup(GROUP_ID)
	end
end)

groupClaimButton.MouseButton1Click:Connect(function()
	print(player.Name .. " is in the group? " .. (if player:IsInGroup(GROUP_ID) then "true" else "false"))
end)