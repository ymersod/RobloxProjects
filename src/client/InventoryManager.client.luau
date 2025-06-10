local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local equipEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("EquipServerEvent")
local getItems = require(ReplicatedStorage.Shared.ModuleScripts.getAllBackpackPlayer)

local toolSlotPrefab = StarterGui:WaitForChild("ScreenGui"):WaitForChild("ToolFrame"):WaitForChild("Toolslot")
local player = game:GetService("Players").LocalPlayer
local realGui = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("ToolFrame")
local CoreGui = game:GetService("StarterGui")

CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
local toolMap = {} -- key: slot number, value: Tool

-- Clear existing UI slots (including the initial one)
for _, child in ipairs(realGui:GetChildren()) do
	if child.Name == "Toolslot" then
		child:Destroy()
	end
end

local keyToNumber = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6,
	Seven = 7,
	Eight = 8,
	Nine = 9,
	Zero = 0,
}

-- Clears the current inventory UI
local function clearInventoryUI()
	for _, child in ipairs(realGui:GetChildren()) do
		if child.Name == "Toolslot" then
			child:Destroy()
		end
	end
	table.clear(toolMap) -- Reset tool mappings
end

-- Updates the inventory UI with current tools
local function updateInventoryUI(tools: { Tool })
	clearInventoryUI() -- Clear old UI first

	for index, tool in ipairs(tools) do
		local inventoryImageID = tool:GetAttribute("InventoryImageID")
		if not inventoryImageID then
			continue
		end

		local newSlot = toolSlotPrefab:Clone()
		newSlot.Parent = realGui

		local toolImage = newSlot:FindFirstChild("ToolImage")
		toolImage.Image = inventoryImageID
		toolImage.Visible = true

		local toolText = newSlot:FindFirstChild("ToolName")
		toolText.Text = tostring(index)
		toolText.Visible = true

		toolMap[index] = tool
	end
end

-- Initialize the inventory and set up listeners
local function initInventory()
	local function refreshInventory()
		local items = getItems.GetItems(player) :: { Tool }
		print("Refresh inventory -  items:", items)
		updateInventoryUI(items)
	end

	-- Initial setup
	refreshInventory()

	-- Track backpack changes
	player.Backpack.ChildAdded:Connect(refreshInventory)

	-- Reset inventory on death
	player.CharacterAdded:Connect(function()
		refreshInventory()
	end)
end

-- Initialize inventory
initInventory()

-- Handle keyboard input for equipping tools
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local numberPressed = keyToNumber[input.KeyCode.Name]
		if numberPressed and toolMap[numberPressed] then
			equipEvent:FireServer(toolMap[numberPressed])
		end
	end
end)
