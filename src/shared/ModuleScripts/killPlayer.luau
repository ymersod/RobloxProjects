local killPlayerModule = {}

function killPlayerModule.killPlayer(char: Model, player: Player)
	local activeTool = char:FindFirstChildOfClass("Tool")
	if activeTool then
		activeTool.Parent = player.Backpack
	end

	for _, motor in char:GetDescendants() do
		if motor:IsA("Motor6D") then
			motor.Enabled = false
		end
	end
end

return killPlayerModule
