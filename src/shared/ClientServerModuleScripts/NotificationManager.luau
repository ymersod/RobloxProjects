local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	popupClone.Visible = false

	popupParent.Parent = popupClone

	popupParent.Changed:Connect(function()
		if popupParent.Value > 0 then
			popupClone.Visible = true
			popupCloneText.Text = popupParent.Value
		else
			popupClone.Visible = false
		end
	end)
end
InitPopups()

function popups.AddNewPopuppable(frameToHavePopup: Frame): IntValue
	local popupClone: Frame = popupPrefab:Clone()
	local popupCloneText = popupClone:FindFirstChildOfClass("TextLabel")

	popupClone.Parent = frameToHavePopup
	popupClone.Visible = false
	local popupCount = Instance.new("IntValue")
	popupCount.Parent = popupClone
	table.insert(popupCounts, popupCount)

	popupCount.Changed:Connect(function()
		if popupCount.Value > 0 then
			popupClone.Visible = true
			popupCloneText.Text = popupCount.Value
		else
			popupClone.Visible = false
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
