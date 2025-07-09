local inputSevice = game:GetService("UserInputService")
local players = game:GetService("Players")

inputSevice.InputBegan:Connect(function(iObj,bool)
	if iObj.KeyCode == Enum.KeyCode.KeypadZero then
		local list = players.LocalPlayer.Character:GetDescendants()
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
		local humanoid = players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			--humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
			humanoid.PlatformStand = true
		end
		local moters = {}
		for i, p in pairs(itemPairs) do
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = p.item1
			socket.Attachment1 = p.item2
			socket.Parent = p.item1

			local moter = p.item1.Parent:FindFirstChildOfClass("Motor6D")

			if moter then
				table.insert(moters,moter)
				moter.Enabled = false
			end
		end

		task.wait(2)
		for i, m in ipairs(moters) do
			m.Enabled = true
		end
		humanoid.PlatformStand = false
	end
end)