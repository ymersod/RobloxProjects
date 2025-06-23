local Player = game:GetService("Players").LocalPlayer
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local platformEnums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)

Player:SetAttribute("Platform", "Unknown")

local function DetectPlatform()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		Player:SetAttribute("Platform", platformEnums.Mobile)
	elseif GuiService:IsTenFootInterface() then
		Player:SetAttribute("Platform", platformEnums.Console)
	else
		Player:SetAttribute("Platform", platformEnums.PC)
	end
end

-- Platform Detection
DetectPlatform()

UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
	if lastInputType == Enum.UserInputType.Touch then
		Player:SetAttribute("Platform", platformEnums.Mobile)
	elseif string.find(lastInputType.Name, platformEnums.Gamepad) then
		Player:SetAttribute("Platform", platformEnums.Console)
	elseif lastInputType == Enum.UserInputType.Keyboard or string.find(lastInputType.Name, "Mouse") then
		Player:SetAttribute("Platform", platformEnums.PC)
	end
end)

UserInputService.GamepadConnected:Connect(function()
	Player:SetAttribute("Platform", platformEnums.Console)
end)

UserInputService.GamepadDisconnected:Connect(function()
	if not GuiService:IsTenFootInterface() then
		Player:SetAttribute("Platform", platformEnums.PC)
	end
end)
