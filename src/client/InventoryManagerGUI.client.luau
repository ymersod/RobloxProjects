local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inventoryFunctionsServerEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("InventoryFunctionsServer")
local CoreGui = game:GetService("StarterGui")
CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local activeSlapSlotUIPrefab = ReplicatedStorage:WaitForChild("UI"):WaitForChild("DynamicGUI"):WaitForChild("SlapStyle")

-- PLAYER GUI
local inventoryGUI = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Inventory")
local slapGUI = inventoryGUI:WaitForChild("ActiveSlapStyle"):WaitForChild("Active")
local activeSlapInfoGUI = slapGUI:WaitForChild("SlapStyle"):WaitForChild("Info")
local backpackGUI = inventoryGUI:WaitForChild("InventoryOutline")

local openCloseImgButton: ImageButton =
	slapGUI:WaitForChild("OpenClose"):WaitForChild("OpenContainer"):WaitForChild("OpenCloseButton")
local icon: ImageLabel = activeSlapInfoGUI:WaitForChild("SlapstyleIcon")
local damageImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Damage"):WaitForChild("Fill")
local rangeImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Range"):WaitForChild("Fill")
local speedImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Speed"):WaitForChild("Fill")
local slotArr: { Frame } = {}
for _, child in ipairs(backpackGUI:WaitForChild("InventoryOpen"):GetChildren()) do
	if child:HasTag("InventorySlot") then
		table.insert(slotArr, child)
	end
end

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

----------------------------------------------------------------
-- >> Section: Track and update active tool
----------------------------------------------------------------
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

function trackActiveTool()
	local playerChar = player.Character
	if not playerChar then
		warn("Character not spawned")
		return
	end

	for _, child in ipairs(playerChar:GetChildren()) do
		if child:IsA("Tool") then
			local data = extractDataFromTool(child)
			updateActiveGUI(data, { damageImgRef = damageImg, rangeImgRef = rangeImg, speedImgRef = speedImg }, icon)
		end
	end

	playerChar.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child.PrimaryPart then
			local data = extractDataFromTool(child)
			if data.Icon == nil or data.Damage == nil or data.Range == nil or data.Speed == nil then
				warn("Some attributtes were nil")
				return
			end
			updateActiveGUI(data, { damageImgRef = damageImg, rangeImgRef = rangeImg, speedImgRef = speedImg }, icon)
		end
	end)
end
trackActiveTool()

----------------------------------------------------------------
-- >> Section: Track and update backpack GUI
----------------------------------------------------------------

function updateEquippedInInventoryGUI()
	local playerChar = player.Character
	if not playerChar then
		warn("Player character not found")
		return
	end

	local equippedToolNew = playerChar:FindFirstChildOfClass("Tool")
	local equippedToolIdRef = equippedToolNew and equippedToolNew:GetAttribute("ToolId")
	for _, slot in ipairs(slotArr) do
		local inventoryToolIdRef = slot:GetAttribute("ToolIdRef")
		local slapFrame = slot:FindFirstChild("SlapStyle")
		local buttonToUpdate = slapFrame and slapFrame:FindFirstChildOfClass("ImageButton")

		if not buttonToUpdate then
			continue
		end

		if
			buttonToUpdate
			and equippedToolIdRef
			and inventoryToolIdRef ~= nil
			and equippedToolIdRef == inventoryToolIdRef
		then
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Equipped
		else
			buttonToUpdate.Transparency = equippedSlapStyleTransparency.Backpack
		end
	end
end

function updateBackpackGUI(tool: Tool?)
	if tool and tool:IsA("Tool") then
		local chosenSlot = nil
		local chosenSlotUi = nil
		for _, slot in ipairs(slotArr) do
			local slotUI = slot:FindFirstChild("SlotUI")
			local toolIdRef: string? = slotUI and slot:GetAttribute("ToolIdRef")
			-- print("idref = nil: ", toolIdRef ~= nil)
			-- print("toolIdRef val: ", toolIdRef)
			-- print("Toolidref == 0: ", toolIdRef == "0")
			if toolIdRef ~= nil and toolIdRef == "0" then
				chosenSlot = slot
				chosenSlotUi = slotUI
				break
			end
		end

		if not chosenSlot or not chosenSlotUi then
			warn("No slot for tool found")
			return
		end

		chosenSlotUi:Destroy()
		local newSlotGUI = activeSlapSlotUIPrefab:Clone()
		newSlotGUI.Parent = chosenSlot

		local statsFrame = newSlotGUI:FindFirstChild("Info"):FindFirstChild("Stats")
		local dmgRef: ImageLabel? = statsFrame:FindFirstChild("Damage"):FindFirstChild("Fill")
		local rangeRef: ImageLabel? = statsFrame:FindFirstChild("Range"):FindFirstChild("Fill")
		local speedRef: ImageLabel? = statsFrame:FindFirstChild("Speed"):FindFirstChild("Fill")
		local newIcon: ImageLabel? = newSlotGUI:FindFirstChild("Info"):FindFirstChild("SlapstyleIcon")
		local equipButton: ImageButton? = newSlotGUI:FindFirstChildOfClass("ImageButton")
		local chosenSlotToolIdRef: string? = chosenSlot:GetAttribute("ToolIdRef")
		local playerChar = player.Character

		if dmgRef and rangeRef and speedRef and newIcon and equipButton and playerChar and chosenSlotToolIdRef then
			local data = extractDataFromTool(tool)
			chosenSlot:SetAttribute("ToolIdRef", data.ToolId)
			updateActiveGUI(data, { damageImgRef = dmgRef, rangeImgRef = rangeRef, speedImgRef = speedRef }, newIcon)

			updateEquippedInInventoryGUI()

			equipButton.MouseButton1Click:Connect(function()
				local result = inventoryFunctionsServerEvent:InvokeServer(tool) -- equip tool
				if result == "Success" then
					updateEquippedInInventoryGUI()
				end
			end)
		else
			warn("1 or more of the prefab images were not found")
		end
	end
end

function trackBackpack()
	local backpack = player.Backpack

	if not backpack then
		warn("backpack not initialized")
		return
	end
	for _, tool in ipairs(backpack:GetChildren()) do
		updateBackpackGUI(tool)
	end

	backpack.ChildAdded:Connect(function(child)
		updateBackpackGUI(child)
	end)
end
trackBackpack()

openCloseImgButton.MouseButton1Click:Connect(function()
	-- CLOSE BACKPACK
	if backpackGUI.Visible then
		backpackGUI.Visible = false
		openCloseImgButton.Image = openImg

	-- OPEN BACKPACK
	else
		backpackGUI.Visible = true
		openCloseImgButton.Image = closeImg
	end
end)
