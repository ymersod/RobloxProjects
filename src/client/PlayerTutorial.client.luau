local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KingZoneHighligt = require(ReplicatedStorage.Shared.ClientServerModuleScripts.KingZoneHighligt)
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")

-- Point to GUI
local accessGuiOpenClose: Frame =
	screenGui:WaitForChild("AccessBar"):WaitForChild("ParentOpenClose"):WaitForChild("OpenClose")
local rollAccessGui: Frame = screenGui:WaitForChild("AccessBar"):WaitForChild("AccessParent"):WaitForChild("Roll")
local rollFrame: Frame = screenGui
	:WaitForChild("Gacha")
	:WaitForChild("ClipAll")
	:WaitForChild("RightClip")
	:WaitForChild("Buttons")
	:WaitForChild("RollFrame")

local slotSpacesGacha: { Frame } =
	screenGui:WaitForChild("Gacha"):WaitForChild("ClipAll"):WaitForChild("LeftClip"):GetChildren()
local slotSpace2Gacha = nil
for _, element in ipairs(slotSpacesGacha) do
	local slotNumber = element:GetAttribute("SlotNumber")

	if slotNumber and tostring(slotNumber) == "1" then
		slotSpace2Gacha = element
	end
end
if not slotSpace2Gacha then
	warn("Couldnt find slot")
	return
end

local slotSpaces: { Frame } = screenGui:WaitForChild("Inventory"):WaitForChild("CanvasGroup"):GetChildren()
local slotSpace1 = nil
for _, element in ipairs(slotSpaces) do
	local slotNumber = element:GetAttribute("SlotNumber")

	if slotNumber and tostring(slotNumber) == "1" then
		slotSpace1 = element
	end
end
if not slotSpace1 then
	warn("Couldnt find slot")
	return
end

local spinnerFrame: Frame = screenGui:WaitForChild("KingZoneHighlightTestFrame"):WaitForChild("Spinner")
local backglowImage: ImageLabel = screenGui:WaitForChild("KingZoneHighlightTestFrame"):WaitForChild("Backglow")

local overlay: Frame? = nil
local TEXT_SPEED = 0.03
local KINGZONE_HIGHLIGHT_DUR = 4

local function raiseZIndex(root, amount)
	if root:IsA("GuiObject") then
		root.ZIndex += amount
	end
	for _, child in pairs(root:GetDescendants()) do
		if child:IsA("GuiObject") then
			child.ZIndex += amount
		end
	end
end

local function createText(parent, text: string, position: UDim2, size: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 28
	label.Text = text
	label.Parent = parent

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.new(0, 0, 0)
	uiStroke.Thickness = 2
	uiStroke.Parent = label

	return label
end

local function animateText(fullText: string, label: TextLabel, speed: number)
	for i = 1, #fullText do
		label.Text = string.sub(fullText, 1, i)
		task.wait(speed)
	end
end

local function createGlow(parent): UIStroke
	local glow = Instance.new("UIStroke")
	glow.Thickness = 7
	glow.Color = Color3.fromRGB(0, 255, 128) -- Bright green
	glow.Transparency = 0
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = parent

	return glow
end

local function Step8()
	local fullText = "That's it for now! Climb the tower, become KING OF THE SLAP and flex on others"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.9, 0), UDim2.new(0.5, 0, 1, 0))

	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)

	task.wait(3)

	label:Destroy()
end

local function Step7ShowKingzone()
	local fullText = "To get more tickets"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.9, 0), UDim2.new(0.5, 0, 1, 0))
	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)

	KingZoneHighligt.Highlight(spinnerFrame, backglowImage, KINGZONE_HIGHLIGHT_DUR)
	task.wait(KINGZONE_HIGHLIGHT_DUR)

	label:Destroy()
	Step8()
end

local function Step6RollForSlapStyle()
	local fullText = "You roll using tickets! Seems you have 1 left... good luck skibidi slapster"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.9, 0), UDim2.new(0.5, 0, 1, 0))

	label.ZIndex = 51
	animateText(fullText, label, TEXT_SPEED)

	raiseZIndex(rollFrame, 50)

	local glow = createGlow(rollFrame)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	local originalSize = rollFrame.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(rollFrame, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

	local function pulse()
		while glow.Parent do
			pulseTweenIn:Play()
			zoomIn:Play()
			pulseTweenIn.Completed:Wait()

			pulseTweenOut:Play()
			zoomOut:Play()
			pulseTweenOut.Completed:Wait()
		end
	end

	task.spawn(pulse)

	--Cleanup when clicked
	local rollButton = rollFrame:FindFirstChildOfClass("ImageButton")
	rollButton.MouseButton1Click:Once(function()
		task.wait(3)
		if overlay then
			overlay:Destroy()
		end
		label:Destroy()
		glow:Destroy()
		raiseZIndex(rollButton, -50)
		Step7ShowKingzone()
	end)
end

local function Step5PickRollSlot()
	local fullText = "Press the inventory slot you want to roll with!"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.9, 0), UDim2.new(0.5, 0, 1, 0))

	local slotGachaUi2 = slotSpace2Gacha:FindFirstChildOfClass("Frame")
	label.ZIndex = 51
	animateText(fullText, label, TEXT_SPEED)

	raiseZIndex(slotGachaUi2, 50)

	local glow = createGlow(slotGachaUi2)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	-- Zoom effect
	local originalSize = slotGachaUi2.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(slotGachaUi2, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

	local function pulse()
		while glow.Parent do
			pulseTweenIn:Play()
			zoomIn:Play()
			pulseTweenIn.Completed:Wait()

			pulseTweenOut:Play()
			zoomOut:Play()
			pulseTweenOut.Completed:Wait()
		end
	end

	task.spawn(pulse)

	--Cleanup when clicked
	local button = slotGachaUi2:FindFirstChild("SetRoll")

	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(slotGachaUi2, -50)

		Step6RollForSlapStyle()
	end)
end

local function Step4OpenGacha()
	local fullText = "This is the menu, From here you can find many rewards, but for now let's roll a new slap-style"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 1, 0))

	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)
	raiseZIndex(rollAccessGui, 50)

	local glow = createGlow(rollAccessGui)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	local originalSize = rollAccessGui.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(rollAccessGui, originalSize, 0.6, UDim2.new(0, 4, 0, 4)) --wtf? why does this shrink the gui huuhhhh

	local function pulse()
		while glow.Parent do
			pulseTweenIn:Play()
			-- zoomIn:Play()
			pulseTweenIn.Completed:Wait()

			pulseTweenOut:Play()
			-- zoomOut:Play()
			pulseTweenOut.Completed:Wait()
		end
	end

	task.spawn(pulse)

	--Cleanup when clicked
	local button = rollAccessGui:FindFirstChildOfClass("ImageButton")
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(rollAccessGui, -50)
		Step5PickRollSlot()
	end)
end
local function Step3OpenAccessBar()
	local fullText = "Let's try to get a better slap-style - open the menu to the left"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 1, 0))

	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)
	raiseZIndex(accessGuiOpenClose, 50)

	local glow = createGlow(accessGuiOpenClose)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	local originalSize = accessGuiOpenClose.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(accessGuiOpenClose, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

	local function pulse()
		while glow.Parent do
			pulseTweenIn:Play()
			zoomIn:Play()
			pulseTweenIn.Completed:Wait()

			pulseTweenOut:Play()
			zoomOut:Play()
			pulseTweenOut.Completed:Wait()
		end
	end

	task.spawn(pulse)

	--Cleanup when clicked
	local button = accessGuiOpenClose:FindFirstChildOfClass("ImageButton")
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(accessGuiOpenClose, -50)
		Step4OpenGacha()
	end)
end

local function Step2EquipSlapStyle()
	local fullText = "Start out by equipping your first slap-style!"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 1, 0))

	local slotUi1 = slotSpace1:FindFirstChildOfClass("Frame")
	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)
	raiseZIndex(slotUi1, 50)

	local glow = createGlow(slotUi1)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	-- Zoom effect
	local originalSize = slotUi1.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(slotUi1, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

	local function pulse()
		while glow.Parent do
			pulseTweenIn:Play()
			zoomIn:Play()
			pulseTweenIn.Completed:Wait()

			pulseTweenOut:Play()
			zoomOut:Play()
			pulseTweenOut.Completed:Wait()
		end
	end

	task.spawn(pulse)

	--Cleanup when clicked
	local button = slotUi1:WaitForChild("Bg"):WaitForChild("EquipButton")
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(slotUi1, -50)

		Step3OpenAccessBar()
	end)
end

local function Step1SetupOverlay()
	-- Dark overlay
	overlay = Instance.new("Frame")
	if not overlay then
		warn("Overlay not found")
		return
	end
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.Parent = screenGui
	overlay.ZIndex = 50

	local overLayButton = Instance.new("ImageButton")
	overLayButton.ImageTransparency = 1
	overLayButton.Transparency = 1
	overLayButton.Size = UDim2.new(1, 0, 1, 0)
	overLayButton.ZIndex = 50
	overLayButton.Parent = overlay

	-- Tutorial label
	local fullText = "Welcome Slapper! Let me show you around"
	local label = createText(screenGui, "", UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 1, 0))
	label.ZIndex = 51

	animateText(fullText, label, TEXT_SPEED)

	task.delay(3, function()
		label:Destroy()
		Step2EquipSlapStyle()
	end)
end

function start()
	local loginData: StringValue = player:WaitForChild("LocalStats"):WaitForChild("FirstTimeLogin")

	if loginData.Value == enums.Login.FirstTimeLogin then
		Step1SetupOverlay()
	end
	loginData.Changed:Once(function(val)
		print(val)
		if val == enums.Login.FirstTimeLogin then
			Step1SetupOverlay()
		end
	end)
end
start()
