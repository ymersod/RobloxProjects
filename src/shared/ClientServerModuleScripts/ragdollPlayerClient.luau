local ragdollModule = {}

function AddForce(char: Model, hrp: BasePart, hitPosition: Vector3, direction: Vector3)
	if char and hrp then
		local list = char:GetDescendants()
		local itemPairs : {[string]:{item1:Instance,item2: Instance}} = {}
		for i, p in ipairs(list) do
			if p.Name:match("RigAttachment") == nil then
				continue
			end
			if not itemPairs[p.Name] then
				itemPairs[p.Name] = {item1=p,item2=nil}
			else
				itemPairs[p.Name].item2 = p
			end
		end
		print(itemPairs)
		local humanoid = char:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = true
		end
		local moters = {}
		for i, p in pairs(itemPairs) do
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = p.item1
			socket.Attachment1 = p.item2
			socket.Parent = p.item1
			socket.TwistLimitsEnabled = true
			socket.LimitsEnabled = true

			local moter = p.item1.Parent:FindFirstChildOfClass("Motor6D")

			if moter then
				table.insert(moters,moter)
				moter.Enabled = false
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
