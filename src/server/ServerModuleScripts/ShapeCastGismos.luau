local funcs = {}

funcs.enabled = false

function funcs.drawBlockCast(origin:CFrame, Size:Vector3, direction:Vector3)
	if not funcs.enabled then
		return
	end
	local startPart = Instance.new("Part")
	startPart.CFrame = origin
	startPart.Size = Vector3.one
	startPart.Transparency = 0.5
	startPart.Anchored = true
	startPart.CanCollide = false
	startPart.Parent = workspace
	
	local endPart = Instance.new("Part")
	endPart.CFrame = origin
	endPart.Position = origin.Position + direction
	endPart.Size = Size
	endPart.Transparency = 0.5
	endPart.Anchored = true
	endPart.CanCollide = false
	endPart.Parent = workspace

	--task.wait(2)
	task.delay(2, function()
		startPart:Destroy()
		endPart:Destroy()
	end)
end

return funcs