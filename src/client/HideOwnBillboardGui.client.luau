local Players = game:GetService("Players")
local player = Players.LocalPlayer
local deactivated = false

local function hideOwnBillboardGui(character)
	if deactivated then
		return
	end
	local head = character:WaitForChild("Head")
	local billboardGui = head:WaitForChild("LevelBillboard")
	if billboardGui then
		billboardGui.Enabled = false
	end
end

if player.Character then
	hideOwnBillboardGui(player.Character)
end

player.CharacterAdded:Connect(function(character)
	hideOwnBillboardGui(character)
end)
