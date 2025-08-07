local uiUtils = {}

function uiUtils.raiseZIndex(root, amount)
	if root:IsA("GuiObject") then
		root.ZIndex += amount
	end
	for _, child in pairs(root:GetDescendants()) do
		if child:IsA("GuiObject") then
			child.ZIndex += amount
		end
	end
end

return uiUtils
