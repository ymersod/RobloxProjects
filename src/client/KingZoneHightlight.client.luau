local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer

local kingZoneActivateClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("KingZoneActivateClient")

local rootFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("KingZoneHighlightTestFrame")
local spinnerFrame: Frame = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("KingZoneHighlightTestFrame")
	:WaitForChild("Spinner")
local backglowImage: ImageLabel = player
	:WaitForChild("PlayerGui")
	:WaitForChild("ScreenGui")
	:WaitForChild("KingZoneHighlightTestFrame")
	:WaitForChild("Backglow")

-- TODO change it to work for more than one kingzone, when/if ever needed
local zonePos: Vector3 = Vector3.zero

kingZoneActivateClient.OnClientEvent:Connect(function(pos:Vector3)
	zonePos = pos
	spinnerFrame.Visible = true
	
	task.delay(3, function()
		spinnerFrame.Visible = false
		backglowImage.Visible = false
	end)
end)


RunService.Heartbeat:Connect(function()
	if spinnerFrame.Visible then
		local screenPos, isOnScreen = workspace.CurrentCamera:WorldToScreenPoint(zonePos)
		local theta = math.atan(
			(screenPos.X - (spinnerFrame.AbsolutePosition.X + (spinnerFrame.AbsoluteSize.X/2) - rootFrame.AbsolutePosition.X))
			/(screenPos.Y - (spinnerFrame.AbsolutePosition.Y + (spinnerFrame.AbsoluteSize.Y/2) - rootFrame.AbsolutePosition.Y))
		)

		if screenPos.Y > (spinnerFrame.AbsolutePosition.Y + (spinnerFrame.AbsoluteSize.Y/2) - rootFrame.AbsolutePosition.Y) then
			theta += math.pi
		end

		if isOnScreen then
			backglowImage.Position = UDim2.fromOffset(
				screenPos.X - rootFrame.AbsolutePosition.X,
				screenPos.Y - rootFrame.AbsolutePosition.Y
			)
			backglowImage.Visible = true
		else
			backglowImage.Visible = false
		end
		--print("theta is " .. (theta * (180/math.pi)) .. " degrees")
		spinnerFrame.Rotation = -(theta * (180/math.pi))
	end
end)
