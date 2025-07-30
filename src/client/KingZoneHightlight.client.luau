local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local kingZoneActivateClient =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("KingZoneActivateClient")
local createTweenFunctionsScript = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("ClientServerModuleScripts")
	:WaitForChild("createTweenFunctions")
local KingZoneHighligt = require(ReplicatedStorage.Shared.ClientServerModuleScripts.KingZoneHighligt)
local createTweenFunctions = require(createTweenFunctionsScript)

local rootFrame: Frame =
	player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("KingZoneHighlightTestFrame")
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

local spinnerTween = createTweenFunctions.Pulse2(spinnerFrame, 0.05, -1, 1)
local glowTween = createTweenFunctions.Pulse2(backglowImage, 0.1, -1, 1)

spinnerTween:Play()
glowTween:Play()

-- TODO: change it to work for more than one kingzone, when/if ever needed
local zonePos: Vector3 = Vector3.zero

local tagged = CollectionService:GetTagged("KingZoneManager")
local kingZoneManager: Part = tagged[1]

local function setupKingZone(kingzone: Instance)
	if kingzone:IsA("Part") then
		local initIsActive = kingzone:GetAttribute("isActive")
		if initIsActive then
			local kingZoneModel = kingzone:WaitForChild("KingZoneModel") :: UnionOperation
			zonePos = kingZoneModel and kingZoneModel.Position or zonePos
		end

		-- Handle future changes to 'isActive'
		kingzone:GetAttributeChangedSignal("isActive"):Connect(function()
			local newValue = kingzone:GetAttribute("isActive")
			if newValue then
				local kingZoneModel = kingzone:FindFirstChild("KingZoneModel") :: UnionOperation
				zonePos = kingZoneModel and kingZoneModel.Position or zonePos
			end
		end)
	end
end
function setup()
	for _, kingzone in ipairs(kingZoneManager:GetChildren()) do
		setupKingZone(kingzone)
	end

	kingZoneManager.ChildAdded:Connect(function(child)
		setupKingZone(child)
	end)

	kingZoneActivateClient.OnClientEvent:Connect(function(dur: number)
		KingZoneHighligt.Highlight(spinnerFrame, backglowImage, dur)
		print("Zonepos is: ", zonePos)
	end)
end
setup()

RunService.Heartbeat:Connect(function()
	if spinnerFrame.Visible then
		local screenPos, isOnScreen = workspace.CurrentCamera:WorldToScreenPoint(zonePos)
		local theta = math.atan(
			(
				screenPos.X
				- (spinnerFrame.AbsolutePosition.X + (spinnerFrame.AbsoluteSize.X / 2) - rootFrame.AbsolutePosition.X)
			)
				/ (
					screenPos.Y
					- (
						spinnerFrame.AbsolutePosition.Y
						+ (spinnerFrame.AbsoluteSize.Y / 2)
						- rootFrame.AbsolutePosition.Y
					)
				)
		)

		if
			screenPos.Y
			> (spinnerFrame.AbsolutePosition.Y + (spinnerFrame.AbsoluteSize.Y / 2) - rootFrame.AbsolutePosition.Y)
		then
			theta += math.pi
		end

		if isOnScreen then
			backglowImage.Position =
				UDim2.fromOffset(screenPos.X - rootFrame.AbsolutePosition.X, screenPos.Y - rootFrame.AbsolutePosition.Y)
			backglowImage.Visible = true
		else
			backglowImage.Visible = false
		end
		--print("theta is " .. (theta * (180/math.pi)) .. " degrees")
		spinnerFrame.Rotation = -(theta * (180 / math.pi))
	end
end)
