local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local equipServerEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("EquipServer")
local CoreGui = game:GetService("StarterGui")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local activeSlapSlotUIPrefab =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("Inventory"):WaitForChild("SlapStyle")
local slotUIPrefab =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("Inventory"):WaitForChild("SlotUI")

-- PLAYER GUI
local inventoryGUI = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Inventory")
local slapGUI = inventoryGUI:WaitForChild("ActiveSlapStyle"):WaitForChild("Active")
local activeSlapInfoGUI = slapGUI:WaitForChild("SlapStyle"):WaitForChild("Info")
local backpackGUI = inventoryGUI:WaitForChild("InventoryOutline") :: Frame

local openCloseImgButton: ImageButton =
	slapGUI:WaitForChild("OpenClose"):WaitForChild("OpenContainer"):WaitForChild("OpenCloseButton")
local icon: ImageLabel = activeSlapInfoGUI:WaitForChild("SlapstyleIcon")
local damageImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Damage"):WaitForChild("Fill")
local rangeImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Range"):WaitForChild("Fill")
local speedImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Speed"):WaitForChild("Fill")
local slayStyleParentFrame: Frame = slapGUI:WaitForChild("SlapStyle")
local slotArr: { Frame } = {}
for _, child in ipairs(backpackGUI:WaitForChild("InventoryOpen"):GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)
	end
end

-- Tween Setups
local scaleFactor = 0.05 -- 5% increase
local duration = 0.1
local pulseGrowTween, pulseShrinkTween = createTweenFunctions.Pulse(
	slapGUI:WaitForChild("OpenClose"):WaitForChild("OpenContainer") :: Frame,
	scaleFactor,
	duration
)
local openTween, closeTween = createTweenFunctions.GoInOut(
	backpackGUI,
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	-0.4,
	0.5,
	0,
	0
)
local shrinkedSize = UDim2.new(0, 0, 0, 0)
local shrinkTween = createTweenFunctions.Shrink(backpackGUI, 0.5, backpackGUI.Size, shrinkedSize)
local growTween = createTweenFunctions.Grow(backpackGUI, 0.5, shrinkedSize, backpackGUI.Size)

-- OTHER VARS
local statBarColors = {
	DarkRed = Color3.fromRGB(139, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(128, 0, 128),
}
local equippedSlapStyleTransparency = {
	Equipped = 0.15,
	Backpack = 0.75,
}
local openImg = "rbxassetid://108893418916619"
local closeImg = "rbxassetid://82931248911040"

function updateSlotsOpenGUI(newValue: number)
	for _, frame in ipairs(slotArr) do
		local slotUI = frame:FindFirstChild("SlotUI")
		local img: ImageLabel? = slotUI and slotUI:FindFirstChild("UnlockedBG")
		local slot = frame:GetAttribute("SlotNumber")
		if slotUI and img and slot <= newValue then
			img.Transparency = 0
		elseif slotUI and img then
			img.Transparency = 1
		end
	end
end

function extractDataFromTool(tool: Tool)
	local statVals = tool:FindFirstChild("StatVals")
	return {
		Damage = statVals:GetAttribute("Damage") :: number?,
		Range = statVals:GetAttribute("Range") :: number?,
		Speed = statVals:GetAttribute("Speed") :: number?,
		Icon = tool:GetAttribute("InventoryImageID") :: string?,
		ToolId = tool:GetAttribute("ToolId") :: string?,
	}
end

function updateStatBar(bar: ImageLabel, val: number)
	if val >= 1 and val <= 4 then
		local scale, color

		if val == 1 then
			color = statBarColors.DarkRed
			scale = 0.25
		elseif val == 2 then
			color = statBarColors.Yellow
			scale = 0.5
		elseif val == 3 then
			color = statBarColors.Blue
			scale = 0.75
		elseif val == 4 then
			color = statBarColors.Purple
			scale = 1
		else
			warn(bar.Name .. " value of: " .. val .. " is not 1, 2, 3 or 4")
		end

		if color and scale then
			bar.BackgroundColor3 = color
			bar.Size = UDim2.new(scale, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
		end
	else
		warn(bar.Name .. " value of: " .. val .. " is out of the 1–4 range")
	end
end

function updateActiveGUI(
	data: { Damage: number, Range: number, Speed: number, Icon: string, id: string },
	imgArr: { damageImgRef: ImageLabel, rangeImgRef: ImageLabel, speedImgRef: ImageLabel },
	iconRef: ImageLabel
)
	iconRef.Image = data.Icon
	updateStatBar(imgArr.damageImgRef, data.Damage)
	updateStatBar(imgArr.rangeImgRef, data.Range)
	updateStatBar(imgArr.speedImgRef, data.Speed)
end

function updateEquippedInInventoryGUI()
	local playerChar = player.Character
	if not playerChar then
		warn("Player character not found")
		return
	end

	local equippedToolNew = playerChar:FindFirstChildOfClass("Tool")
	local equippedToolIdRef = equippedToolNew and equippedToolNew:GetAttribute("ToolId")
	local equippedToolSlot = equippedToolNew and equippedToolNew:GetAttribute("SaveSlot")
	for _, slot in ipairs(slotArr) do
		local inventoryToolIdRef = slot:GetAttribute("ToolIdRef")
		local inventorySaveSlot = slot:GetAttribute("SlotNumber")
		local slapFrame = slot:FindFirstChild("SlapStyle")
		local buttonToUpdate = slapFrame and slapFrame:FindFirstChildOfClass("ImageButton")
		-- print("EquippedToolSlot: ", equippedToolSlot, " SlotChecking: ", inventorySaveSlot)
		if not buttonToUpdate then
			continue
		end

		if
			buttonToUpdate
			and equippedToolIdRef
			and equippedToolSlot
			and inventorySaveSlot
			and inventoryToolIdRef ~= nil
			and equippedToolIdRef == inventoryToolIdRef
			and tostring(inventorySaveSlot) == tostring(equippedToolSlot)
		then
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Equipped
		else
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Backpack
		end
	end

	if equippedToolNew then
		local data = extractDataFromTool(equippedToolNew)
		if data.Icon == nil or data.Damage == nil or data.Range == nil or data.Speed == nil then
			warn("Some attributtes were nil")
			return
		end
		slayStyleParentFrame.BackgroundTransparency = 1
		updateActiveGUI(data, { damageImgRef = damageImg, rangeImgRef = rangeImg, speedImgRef = speedImg }, icon)
	else
		slayStyleParentFrame.BackgroundTransparency = 0
	end
end

function onEquip(curSlot: Frame?)
	local id = curSlot and curSlot:GetAttribute("ToolIdRef") :: string?
	local inventorySaveSlot = curSlot and curSlot:GetAttribute("SlotNumber") :: number?
	if not id then
		warn("Cant find id of weap to equip")
		return
	end
	local curPlayerInventory = player:FindFirstChild("Inventory")
	local toolToEquip: Tool? = nil
	for _, toolInBp in ipairs(curPlayerInventory:GetChildren()) do
		local bpId = toolInBp:GetAttribute("ToolId") :: string?
		local toolSaveSlot = toolInBp:GetAttribute("SaveSlot") :: number?
		if
			bpId
			and toolSaveSlot
			and id
			and inventorySaveSlot
			and bpId == id
			and tostring(inventorySaveSlot) == tostring(toolSaveSlot)
		then
			toolToEquip = toolInBp
			break
		end
	end
	if not toolToEquip then
		warn("No bp-tool mathcing UI Slot")
		return
	end

	local playerChar = player.Character
	if not playerChar then
		warn("Playerchar not existing")
		return
	end
	local result = equipServerEvent:InvokeServer(toolToEquip) -- equip tool
	-- print("Now equipped: ", result)
	if result and result ~= "Bomb" then
		updateEquippedInInventoryGUI()
	end
end

function updateBackpackGUI()
	local playerInventory = player:FindFirstChild("Inventory")
	local openSlots = playerInventory:FindFirstChildOfClass("IntValue").Value
	local inventoryArr = playerInventory:GetChildren()

	for _, slot in ipairs(slotArr) do
		local slotUI = slot:FindFirstChildOfClass("Frame")
		local saveSlot: number = slot:GetAttribute("SlotNumber")

		local foundTool = nil
		for _, inventoryTool in ipairs(inventoryArr) do
			if inventoryTool:IsA("Tool") then
				local toolSlot: number? = inventoryTool:GetAttribute("SaveSlot")
				if toolSlot and tostring(toolSlot) == tostring(saveSlot) then
					foundTool = inventoryTool
					-- print("saveslot: ", saveSlot, " toolslot: ", toolSlot)
					break
				end
			end
		end
		if foundTool then
			if not foundTool then
				warn("No slot for tool found")
				return
			end
			slotUI:Destroy()
			local newSlotGUI = activeSlapSlotUIPrefab:Clone()
			local slotText: { TextLabel } = newSlotGUI:FindFirstChild("SlotText"):GetChildren()
			for _, text in ipairs(slotText) do
				text.Text = tostring(saveSlot)
			end
			newSlotGUI.Parent = slot

			local statsFrame = newSlotGUI:FindFirstChild("Info"):FindFirstChild("Stats")
			local dmgRef: ImageLabel? = statsFrame:FindFirstChild("Damage"):FindFirstChild("Fill")
			local rangeRef: ImageLabel? = statsFrame:FindFirstChild("Range"):FindFirstChild("Fill")
			local speedRef: ImageLabel? = statsFrame:FindFirstChild("Speed"):FindFirstChild("Fill")
			local newIcon: ImageLabel? = newSlotGUI:FindFirstChild("Info"):FindFirstChild("SlapstyleIcon")
			local equipButton: ImageButton? = newSlotGUI:FindFirstChildOfClass("ImageButton")
			local chosenSlotToolIdRef: string? = slot:GetAttribute("ToolIdRef")
			local playerChar = player.Character
			if dmgRef and rangeRef and speedRef and newIcon and equipButton and playerChar and chosenSlotToolIdRef then
				local data = extractDataFromTool(foundTool)
				slot:SetAttribute("ToolIdRef", data.ToolId)
				updateActiveGUI(
					data,
					{ damageImgRef = dmgRef, rangeImgRef = rangeRef, speedImgRef = speedRef },
					newIcon
				)
				equipButton.MouseButton1Click:Connect(function()
					local curSlot = equipButton:FindFirstAncestor("SlotSpace") :: Frame?
					onEquip(curSlot)
				end)
			else
				warn("1 or more of the prefab images were not found")
			end
		else
			slotUI:Destroy()
			local newSlotGUI = slotUIPrefab:Clone()
			newSlotGUI.Parent = slot
		end
	end

	updateEquippedInInventoryGUI()
	updateSlotsOpenGUI(openSlots)
end

function trackBackpack()
	local inventory = player:FindFirstChild("Inventory")

	if not inventory then
		warn("inventory not initialized")
		return
	end
	updateBackpackGUI()

	inventory.ChildAdded:Connect(function(child)
		-- print("Adding tool")
		if child.Name == "Bomb" then
			return
		end
		updateBackpackGUI()
	end)

	inventory.ChildRemoved:Connect(function(child)
		if child.Name == "Bomb" then
			return
		end
		updateBackpackGUI()
	end)
end
trackBackpack()

closeTween:Play()
openCloseImgButton.MouseButton1Click:Connect(function()
	pulseGrowTween:Play()
	pulseGrowTween.Completed:Once(function()
		pulseShrinkTween:Play()
	end)
	if backpackGUI.Visible then
		openCloseImgButton.Image = openImg
		closeTween:Play()
		shrinkTween:Play()

		closeTween.Completed:Once(function()
			backpackGUI.Visible = false
		end)
	else
		backpackGUI.Visible = true
		openCloseImgButton.Image = closeImg
		growTween:Play()
		openTween:Play()
	end
end)

player.CharacterAdded:Connect(updateEquippedInInventoryGUI)

local inventory: Folder = player:FindFirstChild("Inventory")
local slotsOpen = inventory:FindFirstChildOfClass("IntValue")

if inventory and slotsOpen then
	updateSlotsOpenGUI(slotsOpen.Value)
	slotsOpen.Changed:Connect(function(newValue)
		updateSlotsOpenGUI(newValue)
	end)
else
	warn("Inventory or slotsopen not found")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if not slotsOpen or typeof(slotsOpen.Value) ~= "number" then
		return
	end

	local keyMap = {
		[Enum.KeyCode.One] = 1,
		[Enum.KeyCode.Two] = 2,
		[Enum.KeyCode.Three] = 3,
		[Enum.KeyCode.Four] = 4,
		[Enum.KeyCode.Five] = 5,
		[Enum.KeyCode.Six] = 6,
		[Enum.KeyCode.Seven] = 7,
		[Enum.KeyCode.Eight] = 8,
		[Enum.KeyCode.Nine] = 9,
		[Enum.KeyCode.Zero] = 10,
	}

	local slotIndex = keyMap[input.KeyCode]
	if slotIndex and slotIndex <= slotsOpen.Value then
		local slotUIFound: Frame? = nil
		for _, slotSpace in ipairs(slotArr) do
			local slotSpaceVal = slotSpace:GetAttribute("SlotNumber")
			if tostring(slotIndex) == tostring(slotSpaceVal) then
				slotUIFound = slotSpace
			end
		end
		if slotUIFound then
			onEquip(slotUIFound)
		else
			warn("Didnt find ui matching slot: ", slotIndex)
		end
	end
end)
