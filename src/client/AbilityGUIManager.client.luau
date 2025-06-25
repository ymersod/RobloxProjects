local player = game:GetService("Players").LocalPlayer
local abilityGUI =
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Ability")
local pressE: Frame = abilityGUI:WaitForChild("Press_E")
local uiButton: ImageButton = abilityGUI:WaitForChild("ActivateAbility")
local cooldownGUI: Frame = abilityGUI:WaitForChild("Cooldown")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local ContextActionService = game:GetService("ContextActionService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local canActivate = true
local abilityValsT: Instance? = nil
local abilityEvent: RemoteEvent? = nil

-- Tweens
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

local pulseGrowTween, pulseShrinkTween =
	createTweenFunctions.Pulse(abilityGUI:WaitForChild("MainColor") :: Frame, scaleFactor, duration)

function setAbility()
	print("im boutta set")
	local playerChar = player.Character
	local equippedTool = playerChar and playerChar:FindFirstChildOfClass("Tool")

	if not equippedTool then
		warn("Cant set vals, has bomb")
		return
	elseif equippedTool.Name == "Bomb" then
		warn("No tool equipped")
		return
	end

	local abilityValsRef = equippedTool:FindFirstChild("AbilityVals")
	local abilityEventRef = equippedTool:FindFirstChildOfClass("RemoteEvent")
	abilityValsT = abilityValsRef
	abilityEvent = abilityEventRef

	if not abilityValsT and not abilityEvent then
		warn("Cant find data on ability")
		return
	end
end

function UpdateUIToPlatform()
	local newPlatform = player:GetAttribute("Platform")
	if newPlatform == enums.Platforms.Mobile then
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
	if inputState == Enum.UserInputState.Begin and canActivate and abilityValsT and abilityEvent then
		local cd = abilityValsT:GetAttribute("cooldown") :: number?
		if not cd or not abilityEvent then
			warn("Cant find cd or abilityevent")
			return
		end
		local tweenGrowCD = createTweenFunctions.Grow(cooldownGUI, cd)

		canActivate = false -- Prevent reactivation

		-- Start cooldown animation

		tweenGrowCD.Completed:Once(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				cooldownGUI.Size = UDim2.new(0, 0, 0, 0)
				canActivate = true -- Cooldown over, ability can be used again
			end
		end)
		pulseGrowTween:Play()
		pulseGrowTween.Completed:Once(function()
			pulseShrinkTween:Play()
		end)
		tweenGrowCD:Play()

		-- Add your ability logic here (e.g., effects, damage, etc.)
		abilityEvent:FireServer(abilityValsT)
	end
end

uiButton.MouseButton1Click:Connect(function()
	activateAbility("useAbility", Enum.UserInputState.Begin, nil)
end)

ContextActionService:BindAction("useAbility", activateAbility, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)

local function onCharacter(character: Model)
	setAbility()
	character.ChildAdded:Connect(function()
		setAbility()
	end)
	character.ChildRemoved:Connect(function()
		setAbility()
	end)
end

local function Setup()
	if player.Character then
		onCharacter(player.Character)
	end

	player.CharacterAdded:Connect(onCharacter)
end

Setup()
