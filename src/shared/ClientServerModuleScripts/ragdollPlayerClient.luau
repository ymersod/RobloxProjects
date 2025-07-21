local ragdollModule = {}

function AddForce(char: Model, hrp: BasePart, hitPosition: Vector3, direction: Vector3)
	if char and hrp then
		local list = char:GetDescendants()
		local humanoid = char:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = true
		end
		local moters: { Motor6D } = {}
		for i, p in pairs(list) do
			if p:IsA("Motor6D") then
				table.insert(moters, p)
				p.Enabled = false
			end
		end

		print("Applying impulse at: ", hitPosition)
		hrp:ApplyImpulseAtPosition(direction, hitPosition)

		task.wait(2)
		print("event fired")
		for i, m in ipairs(moters) do
			m.Enabled = true
		end
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

function ragdollModule.Ragdoll(char: Model, hitPosition: Vector3, direction: Vector3)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		AddForce(char, hrp, hitPosition, direction)
	end
end

return ragdollModule
