local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rollEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("RollFunctions")
	:WaitForChild("RollServer")
local addToInventoryServer = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("InventoryFunctions")
	:WaitForChild("AddToInventoryServer")

-- GUI LOCALS
local activeSlapSlotUIPrefab =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("Gacha"):WaitForChild("SlapStyle")
local slotUIPrefab =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("Gacha"):WaitForChild("SlotUI")

local screenGui = player.PlayerGui:WaitForChild("ScreenGui")
local gachaGUIParent = screenGui:WaitForChild("Gacha") :: Frame
local closeButton: ImageButton = gachaGUIParent:WaitForChild("OpenContainer"):WaitForChild("CloseButton")
local rollButton: ImageButton = gachaGUIParent:WaitForChild("Roll"):WaitForChild("RollButton")
local backpackGUI: Frame = gachaGUIParent:WaitForChild("InventoryReplica")
local activeChoice = backpackGUI:WaitForChild("ActiveChoice") :: Frame
local slotArr: { Frame } = {}
for _, child in ipairs(backpackGUI:WaitForChild("InventoryOpen"):GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)
	end
end
table.insert(slotArr, activeChoice)

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
local activeRollSlot: number? = nil

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
	local primaryPart = tool.PrimaryPart
	return {
		Damage = primaryPart:GetAttribute("Damage") :: number?,
		Range = primaryPart:GetAttribute("Range") :: number?,
		Speed = primaryPart:GetAttribute("Speed") :: number?,
		Icon = primaryPart:GetAttribute("InventoryImageID") :: string?,
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

function updateActiveRollSlot()
	for _, slot in ipairs(slotArr) do
		local curSlot: number? = slot:GetAttribute("SlotNumber")
		if curSlot < 0 then
			continue
		end

		local buttonToUpdate = slot and slot:FindFirstChild("EquipButton", true)

		if buttonToUpdate and curSlot and activeRollSlot and tostring(curSlot) == tostring(activeRollSlot) then
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Equipped

			local curActiveChoiceUI = activeChoice:FindFirstChildOfClass("Frame")

			if curActiveChoiceUI then
				curActiveChoiceUI:Destroy()

				local chosenGUIClone = slot:Clone()
				chosenGUIClone.Parent = activeChoice
			else
				warn("Cant find data on GUI elements")
			end
		elseif not buttonToUpdate then
			continue
		else
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Backpack
		end
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
					print("saveslot: ", saveSlot, " toolslot: ", toolSlot)
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
					local slotNumber = curSlot and curSlot:GetAttribute("SlotNumber")

					activeRollSlot = slotNumber

					print("Activeslot is: ", activeRollSlot)
					updateActiveRollSlot()
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

	updateSlotsOpenGUI(openSlots)
	updateActiveRollSlot()
end

function trackBackpack()
	local inventory = player:FindFirstChild("Inventory")

	if not inventory then
		warn("inventory not initialized")
		return
	end
	updateBackpackGUI()

	inventory.ChildAdded:Connect(function(child)
		print("Adding tool")
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

closeButton.MouseButton1Click:Connect(function()
	gachaGUIParent.Visible = false
end)

rollButton.MouseButton1Click:Connect(function()
	local recieved: Tool? = rollEvent:InvokeServer(activeRollSlot)

	if recieved and recieved:IsA("Tool") then
		addToInventoryServer:InvokeServer(recieved, activeRollSlot)
		recieved:Destroy()
	else
		warn("Didnt recieve a new slapstyle ")
	end
end)
