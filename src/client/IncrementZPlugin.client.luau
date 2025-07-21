local toolbar = plugin:CreateToolbar("UI Tools")
local button = toolbar:CreateButton("Adjust ZIndex", "Add or subtract from ZIndex values", "")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	true, -- Initial enabled
	false, -- Override previous
	200, -- Width
	100, -- Height
	200,
	100
)

local widget = plugin:CreateDockWidgetPluginGui("ZIndexAdjuster", widgetInfo)
widget.Title = "ZIndex Adjuster"

-- Build UI
local textBox = Instance.new("TextBox")
textBox.PlaceholderText = "Enter number (+/-)"
textBox.Size = UDim2.new(1, -10, 0, 30)
textBox.Position = UDim2.new(0, 5, 0, 5)
textBox.Parent = widget
textBox.Text = ""

local applyButton = Instance.new("TextButton")
applyButton.Text = "Apply"
applyButton.Size = UDim2.new(1, -10, 0, 30)
applyButton.Position = UDim2.new(0, 5, 0, 40)
applyButton.Parent = widget

-- Logic
applyButton.MouseButton1Click:Connect(function()
	local delta = tonumber(textBox.Text)
	if not delta then
		warn("Please enter a valid number.")
		return
	end

	local selection = game.Selection:Get()[1]
	if not selection or not selection:IsA("GuiObject") then
		warn("Select a Frame or UI object in Explorer.")
		return
	end

	local count = 0
	for _, obj in ipairs(selection:GetDescendants()) do
		if obj:IsA("GuiObject") then
			obj.ZIndex += delta
			count += 1
		end
	end

	print(string.format("✅ Adjusted ZIndex by %+d for %d UI elements in '%s'", delta, count, selection.Name))
end)

-- Show widget when button clicked
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
