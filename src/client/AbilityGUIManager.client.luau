local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local ContextActionService = game:GetService("ContextActionService")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local activationTable: { { canActivate: boolean, saveSlot: number } } = {}
local abilityValsT: Instance? = nil
local abilityEvent: RemoteEvent? = nil

-- GUI
local abilityGUI =
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Ability")
local pressE: Frame = abilityGUI:WaitForChild("PressIndicator")
local uiButton: ImageButton = abilityGUI:WaitForChild("Center"):WaitForChild("ActivateAbility")
local cooldownGUI: Frame = abilityGUI:WaitForChild("Cooldown")
local titleText: TextLabel = abilityGUI:WaitForChild("Center"):WaitForChild("AbilityName")

-- Tweens
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1

local pulseGrowTween, pulseShrinkTween =
	createTweenFunctions.Pulse(abilityGUI:WaitForChild("Center") :: Frame, scaleFactor, duration)

local function toolActivationCooldown(cd: number, index: number)
	activationTable[index].canActivate = false
	local tweenGrowCD = createTweenFunctions.Grow(cooldownGUI, cd)

	tweenGrowCD.Completed:Once(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			cooldownGUI.Size = UDim2.new(0, 0, 0, 0)
		end
	end)
	task.delay(cd, function()
		if activationTable[index] then
			activationTable[index].canActivate = true
		end
	end)
	pulseGrowTween:Play()
	pulseGrowTween.Completed:Once(function()
		pulseShrinkTween:Play()
	end)
	tweenGrowCD:Play()
end

function setAbility(equippedTool: Tool?, isAdded: boolean?)
	if equippedTool then
		local abilityValsRef = equippedTool:FindFirstChild("AbilityVals")
		local abilityEventRef = equippedTool:FindFirstChildOfClass("RemoteEvent")
		abilityValsT = abilityValsRef
		abilityEvent = abilityEventRef
		if isAdded and abilityValsT then
			local chargeTime = abilityValsT:GetAttribute("chargeTimeSeconds")
			if chargeTime and chargeTime > 0 then
				local entry = {
					canActivate = true,
					saveSlot = (abilityValsT.Parent and abilityValsT.Parent:GetAttribute("SaveSlot")) or " ",
				}
				table.insert(activationTable, entry)
				local index = table.find(activationTable, entry)
				toolActivationCooldown(chargeTime, index)
			end
		end
	else
		abilityValsT = nil
		abilityEvent = nil
	end

	if not abilityValsT and not abilityEvent then
		warn("Cant find data on ability")
		return
	end

	-- canActivate = true
end

function updateGui()
	local curText = abilityValsT and abilityValsT:GetAttribute("name")
	if not abilityValsT then
		curText = "???"
	end
	titleText.Text = curText
end

function onCharChanges(isAdded: boolean?)
	local playerChar = player.Character
	local equippedTool = playerChar and playerChar:FindFirstChildOfClass("Tool")

	if not equippedTool then
		warn("Cant set vals")
	end

	setAbility(equippedTool, isAdded)
	updateGui()
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
	if abilityValsT and abilityEvent then
		local curSaveSlot = abilityValsT.Parent and abilityValsT.Parent:GetAttribute("SaveSlot")
		if not curSaveSlot then
			warn("No save slot given")
			curSaveSlot = " "
		end
		local activationPairMatch: { canActivate: boolean, saveSlot: number }? = nil
		for _, acvationPair in ipairs(activationTable) do
			if tostring(acvationPair.saveSlot) == tostring(curSaveSlot) then
				activationPairMatch = acvationPair
				continue
			end
		end

		if not activationPairMatch then
			local entry = { canActivate = true, saveSlot = curSaveSlot }
			table.insert(activationTable, entry)
			activationPairMatch = entry
		end

		print("Trying to activate: ", activationPairMatch)
		if
			inputState == Enum.UserInputState.Begin
			and abilityValsT
			and abilityEvent
			and activationPairMatch
			and activationPairMatch.canActivate
		then
			local index = table.find(activationTable, activationPairMatch)

			local cd = abilityValsT:GetAttribute("cooldown") :: number?
			if not cd then
				warn("Cant find cd")
				return
			end

			toolActivationCooldown(cd, index)

			local toolId = abilityValsT.Parent and abilityValsT.Parent:GetAttribute("ToolId")
			if not toolId then
				warn("No toolId given")
				toolId = " "
			end
			-- Add your ability logic here (e.g., effects, damage, etc.)
			abilityEvent:FireServer(abilityValsT, curSaveSlot .. "" .. toolId)
		end
	end
end

uiButton.MouseButton1Click:Connect(function()
	activateAbility("useAbility", Enum.UserInputState.Begin, nil)
end)

ContextActionService:BindAction("useAbility", activateAbility, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)

local function onCharacter(character: Model)
	onCharChanges()
	character.ChildAdded:Connect(function()
		onCharChanges(true)
	end)
	character.ChildRemoved:Connect(function()
		onCharChanges()
	end)
end

local function Setup()
	if player.Character then
		onCharacter(player.Character)
	end

	player.CharacterAdded:Connect(onCharacter)
end
Setup()
