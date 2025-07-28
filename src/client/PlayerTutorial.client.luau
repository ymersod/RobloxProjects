local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local player = Players.LocalPlayer
local loginData: StringValue = player:WaitForChild("LocalStats"):WaitForChild("FirstTimeLogin")
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")

-- Point to GUI
local openInventoryButton: ImageButton = screenGui
	:WaitForChild("Inventory")
	:WaitForChild("ActiveSlapStyle")
	:WaitForChild("Active")
	:WaitForChild("OpenClose")
	:WaitForChild("OpenContainer")
	:WaitForChild("OpenCloseButton")

local accessGuiOpenClose: Frame = screenGui:WaitForChild("AccessBar"):WaitForChild("OpenClose")
local rollAccessGui: Frame = screenGui:WaitForChild("AccessBar"):WaitForChild("AccessParent"):WaitForChild("Roll")
local rollButton: ImageButton = screenGui:WaitForChild("Gacha"):WaitForChild("Roll"):WaitForChild("RollButton")

local slotSpacesGacha: { Frame } =
	screenGui:WaitForChild("Gacha"):WaitForChild("InventoryReplica"):WaitForChild("InventoryOpen"):GetChildren()
local slotSpace2Gacha = nil
for _, element in ipairs(slotSpacesGacha) do
	local slotNumber = element:GetAttribute("SlotNumber")

	if slotNumber and tostring(slotNumber) == "2" then
		slotSpace2Gacha = element
	end
end
if not slotSpace2Gacha then
	warn("Couldnt find slot")
	return
end

local slotSpaces: { Frame } =
	screenGui:WaitForChild("Inventory"):WaitForChild("InventoryOutline"):WaitForChild("InventoryOpen"):GetChildren()
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

local overlay: Frame? = nil

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
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 28
	label.Text = text
	label.Parent = parent

	return label
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

local function Step7()
	local label = createText(
		screenGui,
		"That's it for now! Climb the tower, become KING OF THE SLAP and flex on others",
		UDim2.new(0.5, 0, 0.9, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	label.ZIndex = 51

	task.wait(5)

	label:Destroy()
end

local function Step6RollForSlapStyle()
	local label = createText(
		screenGui,
		"Seems you have 1 slap-ticket left! Every roll costs 1 ticket, you get more tickets by getting levelup rewards & claiming daily login prizes. now rolllllll :>",
		UDim2.new(0.5, 0, 0.9, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	raiseZIndex(rollButton, 50)
	label.ZIndex = 51

	local glow = createGlow(rollButton)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	local originalSize = rollButton.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(rollButton, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

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
	rollButton.MouseButton1Click:Once(function()
		if overlay then
			overlay:Destroy()
		end
		label:Destroy()
		glow:Destroy()
		raiseZIndex(rollButton, -50)
		Step7()
	end)
end

local function Step5PickRollSlot()
	local label = createText(
		screenGui,
		"In king of the slap - when you roll you lose your current slap-style in that inventory slot... lets roll slot2!",
		UDim2.new(0.5, 0, 0.9, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	local slotGachaUi2 = slotSpace2Gacha:FindFirstChildOfClass("Frame")
	raiseZIndex(slotGachaUi2, 50)
	label.ZIndex = 51

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
	local button = slotGachaUi2:FindFirstChildOfClass("TextButton", true)
	if not button then
		button = slotGachaUi2:FindFirstChildOfClass("ImageButton", true)
	end
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(slotGachaUi2, -50)

		Step6RollForSlapStyle()
	end)
end

local function Step4OpenGacha()
	local label = createText(
		screenGui,
		"This is the menu, there are a lot of things to do here - but for now press the rolling menu",
		UDim2.new(0.5, 0, 0.75, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	raiseZIndex(rollAccessGui, 50)
	label.ZIndex = 51

	local glow = createGlow(rollAccessGui)
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	local originalSize = rollAccessGui.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(rollAccessGui, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

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
	local button = rollAccessGui:FindFirstChildOfClass("ImageButton")
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(rollAccessGui, -50)
		Step5PickRollSlot()
	end)
end
local function Step3OpenAccessBar()
	local label = createText(
		screenGui,
		"Very nice! Let's try to get a new slap-style - open the menu to the left",
		UDim2.new(0.5, 0, 0.75, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	raiseZIndex(accessGuiOpenClose, 50)
	label.ZIndex = 51

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
	local label = createText(
		screenGui,
		"Click the glowing slapstyle in your inventory to equip it!",
		UDim2.new(0.5, 0, 0.75, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	local slotUi1 = slotSpace1:FindFirstChildOfClass("Frame")
	raiseZIndex(slotUi1, 50)
	label.ZIndex = 51

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
	local button = slotUi1:FindFirstChildOfClass("ImageButton")
	button.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(slotUi1, -50)

		Step3OpenAccessBar()
	end)
end

local function Step1OpenInventory()
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

	-- Tutorial label
	local label = createText(
		screenGui,
		"Click the glowing button to open your inventory!",
		UDim2.new(0.5, 0, 0.75, 0),
		UDim2.new(0.5, 0, 1, 0)
	)

	overlay.ZIndex = 50
	raiseZIndex(openInventoryButton.Parent, 50)
	label.ZIndex = 51

	local glow = createGlow(openInventoryButton.Parent)

	-- Pulse tween for glow
	local pulseTweenIn, pulseTweenOut = createTweenFunctions.PulseTransparency(glow, 0.3, 0, 0.6)

	-- Zoom effect
	local originalSize = openInventoryButton.Size
	local zoomIn, zoomOut = createTweenFunctions.Zoom(openInventoryButton, originalSize, 0.6, UDim2.new(0, 4, 0, 4))

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

	-- Cleanup when clicked
	openInventoryButton.MouseButton1Click:Once(function()
		label:Destroy()
		glow:Destroy()
		raiseZIndex(openInventoryButton.Parent, -50)

		Step2EquipSlapStyle()
	end)
end

function start()
	if loginData.Value == enums.Login.FirstTimeLogin then
		Step1OpenInventory()
	end

	loginData.Changed:Once(function(val)
		if val == enums.Login.FirstTimeLogin then
			Step1OpenInventory()
		end
	end)
end
-- start()
