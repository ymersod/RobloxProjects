local ragdollModule = {}

function ragdollModule.Ragdoll(char: Model, player: Player)
	local activeTool = char:FindFirstChildOfClass("Tool")
	if activeTool then
		activeTool.Parent = player.Backpack
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		humanoid.PlatformStand = true
	end
end

return ragdollModule
