local player = game:GetService("Players").LocalPlayer

local CoreGui = game:GetService("StarterGui")
CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- PLAYER GUI
local inventoryGUI = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Inventory")
local slapGUI = inventoryGUI:WaitForChild("ActiveSlapStyle"):WaitForChild("Active")
local activeSlapInfoGUI = slapGUI:WaitForChild("SlapStyle"):WaitForChild("Info")

local backpackGUI: Frame = inventoryGUI:WaitForChild("InventoryOutline")
local openCloseImgButton: ImageButton =
	slapGUI:WaitForChild("OpenClose"):WaitForChild("OpenContainer"):WaitForChild("OpenCloseButton")
local icon: ImageLabel = activeSlapInfoGUI:WaitForChild("SlapstyleIcon")
local damageImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Damage"):WaitForChild("Fill")
local rangeImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Range"):WaitForChild("Fill")
local speedImg: ImageLabel = activeSlapInfoGUI:WaitForChild("Stats"):WaitForChild("Speed"):WaitForChild("Fill")

-- OTHER VARS
local colors = {
	DarkRed = Color3.fromRGB(139, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(128, 0, 128),
}
local openImg = "rbxassetid://108893418916619"
local closeImg = "rbxassetid://82931248911040"

player.Backpack.Changed:Connect(function()
	-- add to inventory
end)

function extractDataFromTool(tool: Tool)
	local primaryPart = tool.PrimaryPart
	return {
		Damage = primaryPart:GetAttribute("Damage") :: number?,
		Range = primaryPart:GetAttribute("Range") :: number?,
		Speed = primaryPart:GetAttribute("Speed") :: number?,
		Icon = primaryPart:GetAttribute("InventoryImageID") :: string?,
	}
end

function updateStatBar(bar: ImageLabel, val: number)
	if val >= 1 and val <= 4 then
		local scale, color

		if val == 1 then
			color = colors.DarkRed
			scale = 0.25
		elseif val == 2 then
			color = colors.Yellow
			scale = 0.5
		elseif val == 3 then
			color = colors.Blue
			scale = 0.75
		elseif val == 4 then
			color = colors.Purple
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

function updateGUI(data: { Damage: number, Range: number, Speed: number, Icon: string })
	icon.Image = data.Icon
	updateStatBar(damageImg, data.Damage)
	updateStatBar(rangeImg, data.Range)
	updateStatBar(speedImg, data.Speed)
end

function trackBackPack()
	local playerChar = player.Character
	if not playerChar then
		warn("Character not in scene")
		return
	end

	for _, child in ipairs(playerChar:GetChildren()) do
		if child:IsA("Tool") then
			local data = extractDataFromTool(child)
			updateGUI(data)
		end
	end

	player.Character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child.PrimaryPart then
			local data = extractDataFromTool(child)
			if data.Icon == nil or data.Damage == nil or data.Range == nil or data.Speed == nil then
				warn("Some attributtes were nil")
				return
			end
			updateGUI(data)
		end
	end)
end
trackBackPack()

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
