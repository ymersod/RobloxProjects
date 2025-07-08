local funcs = {}

function funcs.changeHandleLength(tool:Tool,length)
	local part : Part = tool:FindFirstChild("Part") :: Part
	if not part then
		warn("Tool doesn't have a 'Part'")
		return
	end

	local attachment = part:FindFirstChildOfClass("Attachment")
	if not attachment then
		warn("Tool doesn't have an Attachment")
		return
	end
	local posV3 = Vector3.new(part.CFrame.Position.X,part.CFrame.Position.Y,part.CFrame.Position.Z + (part.Size.X - length))
	part.Position = posV3
	local sV3 = Vector3.new(length,part.Size.Y, part.Size.Z)
	part.Size = sV3
	local aPosV3 = Vector3.new(-length/2,attachment.CFrame.Position.Y, attachment.CFrame.Position.Z)
	attachment.Position = aPosV3
end

return funcs