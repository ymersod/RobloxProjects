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
local uiButton: ImageButton = abilityGUI:WaitForChild("Center"):WaitForChild("ActivateAbility")
local titleText: TextLabel = abilityGUI:WaitForChild("Center"):WaitForChild("AbilityName")
local backGlow: ImageLabel = abilityGUI:WaitForChild("Center"):WaitForChild("Backglow")
local icon: ImageLabel = abilityGUI:WaitForChild("Center"):WaitForChild("ImageLabel")
local defaultImg = icon.Image
local glow = uiButton:WaitForChild("glow") :: ImageLabel
local center = abilityGUI:WaitForChild("Center") :: Frame
local pressE: Frame = center:WaitForChild("PressIndicator")

local individualCdsFrame: Frame = abilityGUI:WaitForChild("IndividualCds")
local defaultCd = individualCdsFrame:WaitForChild("cd") :: Frame
local defaultCdClone = defaultCd:Clone()
defaultCd:Destroy()

-- Tweens
local SCALE_FACTOR = 0.75
local DURATION = 0.2

-- local pulseGrowTween, pulseShrinkTween =
-- 	createTweenFunctions.Pulse(abilityGUI:WaitForChild("Center") :: Frame, SCALE_FACTOR, DURATION)
local elasticGrow, elasticShrink = createTweenFunctions.Elastic(
	center,
	DURATION,
	DURATION,
	center.Size,
	UDim2.new(SCALE_FACTOR, 0, SCALE_FACTOR, 0),
	false
)

local function createLocalCooldown(cd: number)
	local newCd = defaultCdClone:Clone()
	local coolDownGUI = newCd:WaitForChild("Cooldown")
	local tweenGrowCD = coolDownGUI and createTweenFunctions.Grow(coolDownGUI, cd)
	local text = newCd:WaitForChild("cdText") :: TextLabel
	local localIcon = newCd:WaitForChild("Icon") :: ImageLabel
	local iconRef = abilityValsT and abilityValsT:GetAttribute("AbilityIcon")

	localIcon.Image = iconRef

	newCd.BackgroundColor3 = enums.Colors.abilitiy.Inactive
	newCd.Parent = individualCdsFrame

	tweenGrowCD:Play()
	tweenGrowCD.Completed:Connect(function()
		newCd:Destroy()
	end)
	task.spawn(function()
		for i = cd, 0, -1 do
			text.Text = i
			task.wait(1)
		end
	end)
end

local function toolActivationCooldown(cd: number, index: number)
	activationTable[index].canActivate = false

	task.delay(cd, function()
		if activationTable[index] then
			activationTable[index].canActivate = true
		end
		updateGui()
	end)
	updateGui()
	createLocalCooldown(cd)
end

function setAbility(equippedTool: Tool?, isAdded: boolean?)
	if equippedTool then
		local abilityValsRef = equippedTool:FindFirstChild("AbilityVals")
		local abilityEventRef = equippedTool:FindFirstChildOfClass("RemoteEvent")
		local isPassive = abilityValsRef:GetAttribute("passiveType")

		abilityValsT = abilityValsRef
		abilityEvent = abilityEventRef
		if isAdded and abilityValsT then
			local iconRef = abilityValsT:GetAttribute("AbilityIcon")
			icon.Image = iconRef
			local chargeTime = abilityValsT:GetAttribute("chargeTimeSeconds")

			if isPassive and abilityEvent then
				local curSaveSlot = equippedTool:GetAttribute("SaveSlot")
				local toolId = equippedTool:GetAttribute("ToolId")
				if toolId and curSaveSlot then
					abilityEvent:FireServer(abilityValsT, curSaveSlot .. "" .. toolId)
				end
			end

			if chargeTime and chargeTime > 0 then
				local entry = {
					canActivate = true,
					saveSlot = 0,
				}
				table.insert(activationTable, entry)
				local index = table.find(activationTable, entry)
				toolActivationCooldown(chargeTime, index)
			end
		end
	else
		abilityValsT = nil
		abilityEvent = nil
		icon.Image = defaultImg
	end
	-- canActivate = true
end

function updateGui()
	if not abilityValsT then
		titleText.Text = "???"
		elasticShrink:Play()
		backGlow.Visible = false
		glow.Visible = false
		uiButton.BackgroundColor3 = enums.Colors.abilitiy.Inactive
		return
	end

	local curSaveSlot = abilityValsT.Parent and abilityValsT.Parent:GetAttribute("SaveSlot")
	local curSlotStr = tostring(curSaveSlot)
	local activationPairMatch: { canActivate: boolean, saveSlot: number }? = nil
	for _, activationPair in ipairs(activationTable) do
		local slotStr = tostring(activationPair.saveSlot)
		if slotStr == curSlotStr or slotStr == "0" then
			activationPairMatch = activationPair
			break
		end
	end

	if not activationPairMatch then
		if not curSaveSlot then
			local entry = { canActivate = false, saveSlot = curSaveSlot }
			table.insert(activationTable, entry)
			activationPairMatch = entry
		else
			local entry = { canActivate = true, saveSlot = curSaveSlot }
			table.insert(activationTable, entry)
			activationPairMatch = entry
		end
	end
	if activationPairMatch and activationPairMatch.canActivate then
		elasticGrow:Play()
		backGlow.Visible = true
		glow.Visible = true
		uiButton.BackgroundColor3 = enums.Colors.abilitiy.Active
	else
		elasticShrink:Play()
		backGlow.Visible = false
		glow.Visible = false
		uiButton.BackgroundColor3 = enums.Colors.abilitiy.Inactive
	end

	local curText = abilityValsT and abilityValsT:GetAttribute("name")
	titleText.Text = curText
end

function onCharChanges(isAdded: boolean?)
	local playerChar = player.Character
	local equippedTool = playerChar and playerChar:FindFirstChildOfClass("Tool")

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
		local isPassive = abilityValsT:GetAttribute("passiveType")

		if isPassive then
			return
		end

		local curSaveSlot = abilityValsT.Parent and abilityValsT.Parent:GetAttribute("SaveSlot")
		local curSlotStr = tostring(curSaveSlot)
		if not curSaveSlot then
			curSaveSlot = " "
		end

		local activationPairMatch: { canActivate: boolean, saveSlot: number }? = nil
		for _, activationPair in ipairs(activationTable) do
			local slotStr = tostring(activationPair.saveSlot)
			if slotStr == curSlotStr or slotStr == "0" then
				activationPairMatch = activationPair
				break
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
				return
			end

			toolActivationCooldown(cd, index)

			local toolId = abilityValsT.Parent and abilityValsT.Parent:GetAttribute("ToolId")
			if not toolId then
				toolId = " "
			end

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
