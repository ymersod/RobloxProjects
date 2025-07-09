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

	local attachmentHand = part:FindFirstChild("AttachmentHand")
	local attachmentHandle = part:FindFirstChild("AttachmentHandle")
	
	if not attachmentHand or not attachmentHandle then
		warn("Couldn't find all required handles")
		return
	end

	local sV3 = Vector3.new(length,part.Size.Y, part.Size.Z)
	part.Size = sV3
	local aHandPosV3 = Vector3.new(-length/2,attachment.CFrame.Position.Y, attachment.CFrame.Position.Z)
	attachmentHand.Position = aHandPosV3
	local aHandlePosV3 = Vector3.new(length/2,attachment.CFrame.Position.Y, attachment.CFrame.Position.Z)
	attachmentHandle.Position = aHandlePosV3
end

return funcs