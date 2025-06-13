local player = game:GetService("Players").LocalPlayer
local abilityGUI =
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Ability")
local pressE: Frame = abilityGUI:WaitForChild("Press_E")
local pressEText: TextLabel = abilityGUI:WaitForChild("Press_E"):WaitForChild("PressText")
local uiButton: ImageButton = abilityGUI:WaitForChild("ActivateAbility")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local platformEnums = require(ReplicatedStorage.Shared.ModuleScripts.enums)
local ContextActionService = game:GetService("ContextActionService")

function UpdateUIToPlatform()
	print("Beepboop")
	local newPlatform = player:GetAttribute("Platform")
	if newPlatform == platformEnums.Mobile then
		pressE.Visible = false
	elseif newPlatform == platformEnums.Gamepad or newPlatform == platformEnums.Console then
		pressEText.Text = "X"
	else
		pressE.Visible = true
	end
end
UpdateUIToPlatform()

UserInputService:GetAttributeChangedSignal("Platform"):Connect(function()
	UpdateUIToPlatform()
end)

local function activateAbility(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		print("POOF")
		-- Do ability logic here
	end
end

uiButton.MouseButton1Click:Connect(function()
	activateAbility("useAbility", Enum.UserInputState.Begin, nil)
end)

ContextActionService:BindAction("useAbility", activateAbility, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
