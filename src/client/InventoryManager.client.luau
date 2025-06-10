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

realGui:WaitForChild("Toolslot"):Destroy() --Remove initial slot

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

function addToInventory(tools: { Tool })
	for _, tool in tools do
		local inventoryImageID = tool:GetAttribute("InventoryImageID")
		if not inventoryImageID then
			continue
		end

		toolSlotPrefab:Clone()
		toolSlotPrefab.Parent = realGui
		local toolImage: ImageLabel = toolSlotPrefab:FindFirstChild("ToolImage")
		toolImage.Image = inventoryImageID
		toolImage.Visible = true

		local count = #realGui:GetChildren() - 1 -- -1 because of uiListLayout

		local toolText: TextLabel = toolSlotPrefab:FindFirstChild("ToolName")
		toolText.Text = count
		toolText.Visible = true

		toolMap[count] = tool
		-- now when player presses the number shown on board player should equip that thing
	end
end

function initInventory()
	local items = getItems.GetItems(player) :: { Tool }
	addToInventory(items)
	player.Backpack.Changed:Connect(function()
		-- Add new item to back on change
		-- Dont add bomb
	end)
end

initInventory()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local numberPressed = keyToNumber[input.KeyCode.Name]
		if numberPressed and toolMap[numberPressed] then
			print("Pressed number:", numberPressed)
			equipEvent:FireServer(toolMap[numberPressed])
		end
	end
end)
