local player = game:GetService("Players").LocalPlayer
local abilityGUI =
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Ability")
local pressE: Frame = abilityGUI:WaitForChild("Press_E")
local uiButton: ImageButton = abilityGUI:WaitForChild("ActivateAbility")
local cooldownGUI: Frame = abilityGUI:WaitForChild("Cooldown")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local platformEnums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local ContextActionService = game:GetService("ContextActionService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local cd = 2 -- TODO: Should be set from slapstyle
local canActivate = true

-- Tweens
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

local tweenGrowCD = createTweenFunctions.Grow(cooldownGUI, cd)
local pulseTween = createTweenFunctions.Pulse(abilityGUI, scaleFactor, duration)

function UpdateUIToPlatform()
	local newPlatform = player:GetAttribute("Platform")
	if newPlatform == platformEnums.Mobile then
		pressE.Visible = false
	else
		pressE.Visible = true
	end
end
UpdateUIToPlatform()

UserInputService:GetAttributeChangedSignal("Platform"):Connect(function()
	UpdateUIToPlatform()
end)

local function activateAbility(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin and canActivate then
		canActivate = false -- Prevent reactivation

		-- Start cooldown animation

		tweenGrowCD.Completed:Once(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				cooldownGUI.Size = UDim2.new(0, 0, 0, 0)
				canActivate = true -- Cooldown over, ability can be used again
			end
		end)
		pulseTween:Play()
		tweenGrowCD:Play()

		-- Add your ability logic here (e.g., effects, damage, etc.)
		print("Ability activated!")
	end
end

uiButton.MouseButton1Click:Connect(function()
	activateAbility("useAbility", Enum.UserInputState.Begin, nil)
end)

ContextActionService:BindAction("useAbility", activateAbility, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
