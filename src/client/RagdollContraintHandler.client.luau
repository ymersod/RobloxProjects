local players = game:GetService("Players")
local player = players.LocalPlayer

player.CharacterAdded:Connect(function(character)
	print("adding Ball Sockets")
	local list = character:GetDescendants()
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
	for i, p in pairs(itemPairs) do
		local socket = Instance.new("BallSocketConstraint")
		socket.Attachment0 = p.item1
		socket.Attachment1 = p.item2
		socket.Parent = p.item1
		socket.TwistLimitsEnabled = true
		socket.LimitsEnabled = true
	end
end)

