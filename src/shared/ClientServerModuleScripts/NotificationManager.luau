local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(script.Parent.createTweenFunctions)
local popupPrefab = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Popup")
local outerPopupHolder = Player:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("AccessBar")
	:WaitForChild("ParentOpenClose")
	:WaitForChild("OpenClose")

local popupParent = Instance.new("IntValue")
local popupCounts: { IntValue } = {}
local popups = {}

local function InitPopups()
	local popupClone: Frame = popupPrefab:Clone()
	local popupCloneText = popupClone:FindFirstChildOfClass("TextLabel")

	popupClone.Parent = outerPopupHolder
	local elasticGrow, elasticShrink =
		createTweenFunctions.Elastic(popupClone, 0.2, 0.2, popupClone.Size, UDim2.new(0, 0, 0, 0), true)
	popupClone.Visible = false

	popupParent.Parent = popupClone

	popupParent.Changed:Connect(function()
		if popupParent.Value > 0 then
			popupClone.Visible = true
			elasticGrow:Play()
			popupCloneText.Text = popupParent.Value
		else
			elasticShrink:Play()
			elasticShrink.Completed:Connect(function()
				popupClone.Visible = false
			end)
		end
	end)
end
InitPopups()

function popups.AddNewPopuppable(frameToHavePopup: Frame): IntValue
	local popupClone: Frame = popupPrefab:Clone()
	local popupCloneText = popupClone:FindFirstChildOfClass("TextLabel")

	popupClone.Parent = frameToHavePopup
	local elasticGrow, elasticShrink =
		createTweenFunctions.Elastic(popupClone, 0.2, 0.2, popupClone.Size, UDim2.new(0, 0, 0, 0), true)
	popupClone.Visible = false
	local popupCount = Instance.new("IntValue")
	popupCount.Parent = popupClone
	table.insert(popupCounts, popupCount)

	popupCount.Changed:Connect(function()
		if popupCount.Value > 0 then
			popupClone.Visible = true
			elasticGrow:Play()
			popupCloneText.Text = popupCount.Value
		else
			elasticShrink:Play()
			elasticShrink.Completed:Connect(function()
				popupClone.Visible = false
			end)
		end

		local acc = 0
		for _, p in ipairs(popupCounts) do
			acc = acc + p.Value
		end
		popupParent.Value = acc
	end)

	return popupCount
end

return popups
