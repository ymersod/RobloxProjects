local getAllBackpack = {}

function getAllBackpack.GetItems(player: Player)
	local backpackTools = {}
	local pChar = player.Character
	if not player then
		return
	end
	if pChar then
		local heldTool = pChar:FindFirstChildOfClass("Tool")
		if heldTool then
			table.insert(backpackTools, heldTool)
		end
	end

	for _, item in ipairs(player.Backpack:GetChildren()) do
		if item:IsA("Tool") then
			table.insert(backpackTools, item)
		end
	end

	return backpackTools
end

return getAllBackpack
