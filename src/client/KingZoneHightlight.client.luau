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
local spinnerTemplate = rootFrame:WaitForChild("Spinner") :: Frame
local backglowTemplate = rootFrame:WaitForChild("Backglow") :: ImageLabel

-- Active kingzones state table
local activeKingzones = {} -- [kingzoneInstance] = { spinner, backglow, spinnerTween, glowTween, expiration }

-- Create UI clones + tweens but don't show yet
local function createUIForKingzone()
	local spinnerClone = spinnerTemplate:Clone()
	local backglowClone = backglowTemplate:Clone()

	spinnerClone.Parent = rootFrame
	backglowClone.Parent = rootFrame

	spinnerClone.Visible = false
	backglowClone.Visible = false

	local spinnerTween = createTweenFunctions.Pulse2(spinnerClone, 0.05, -1, 1)
	local glowTween = createTweenFunctions.Pulse2(backglowClone, 0.1, -1, 1)

	spinnerTween:Play()
	glowTween:Play()

	return spinnerClone, backglowClone, spinnerTween, glowTween
end

local function cleanupUIForKingzone(uiData)
	if uiData.spinnerTween then
		uiData.spinnerTween:Cancel()
	end
	if uiData.glowTween then
		uiData.glowTween:Cancel()
	end
	if uiData.spinner then
		uiData.spinner:Destroy()
	end
	if uiData.backglow then
		uiData.backglow:Destroy()
	end
end

-- Setup a kingzone's UI tracking (creates UI but does NOT activate it)
local function setupKingZone(kingzone: Instance)
	if kingzone:IsA("Part") and not activeKingzones[kingzone] then
		local spinnerClone, backglowClone, spinnerTween, glowTween = createUIForKingzone()
		activeKingzones[kingzone] = {
			spinner = spinnerClone,
			backglow = backglowClone,
			spinnerTween = spinnerTween,
			glowTween = glowTween,
			expiration = 0, -- initially inactive
		}
	end
end

-- Initialize kingzones under the manager
local function initializeKingZones(kingZoneManager: Part)
	for _, kingzone in ipairs(kingZoneManager:GetChildren()) do
		setupKingZone(kingzone)
	end
	kingZoneManager.ChildAdded:Connect(setupKingZone)
end

kingZoneActivateClient.OnClientEvent:Connect(function(kingzoneActivated: Instance, dur: number)
	local uiData = activeKingzones[kingzoneActivated]
	if not uiData then
		setupKingZone(kingzoneActivated)
		uiData = activeKingzones[kingzoneActivated]
	end
	uiData.expiration = tick() + dur
	uiData.spinner.Visible = true
	uiData.backglow.Visible = true

	KingZoneHighligt.Highlight(uiData.spinner, uiData.backglow, dur)
end)

local function setup()
	local tagged = CollectionService:GetTagged("KingZoneManager")
	if #tagged > 0 then
		initializeKingZones(tagged[1])
	else
		CollectionService:GetInstanceAddedSignal("KingZoneManager"):Wait()
		local newTagged = CollectionService:GetTagged("KingZoneManager")
		if #newTagged > 0 then
			initializeKingZones(newTagged[1])
		else
			warn("Failed to find KingZoneManager after tag added!")
		end
	end
end
setup()

RunService.Heartbeat:Connect(function()
	local now = tick()
	for kingzone, uiData in pairs(activeKingzones) do
		if uiData.expiration > now then
			local kingZoneModel = kingzone:FindFirstChild("KingZoneModel")
			if kingZoneModel then
				local zonePos = kingZoneModel.Position
				local screenPos, isOnScreen = workspace.CurrentCamera:WorldToScreenPoint(zonePos)

				if isOnScreen then
					uiData.backglow.Position = UDim2.fromOffset(
						screenPos.X - rootFrame.AbsolutePosition.X,
						screenPos.Y - rootFrame.AbsolutePosition.Y
					)
					uiData.backglow.Visible = true
					uiData.spinner.Visible = true

					local centerX = uiData.spinner.AbsolutePosition.X
						+ (uiData.spinner.AbsoluteSize.X / 2)
						- rootFrame.AbsolutePosition.X
					local centerY = uiData.spinner.AbsolutePosition.Y
						+ (uiData.spinner.AbsoluteSize.Y / 2)
						- rootFrame.AbsolutePosition.Y

					local theta = math.atan((screenPos.X - centerX) / (screenPos.Y - centerY))
					if screenPos.Y > centerY then
						theta += math.pi
					end

					uiData.spinner.Rotation = -(theta * (180 / math.pi))
				else
					uiData.backglow.Visible = false
					uiData.spinner.Visible = false
				end
			end
		else
			uiData.backglow.Visible = false
			uiData.spinner.Visible = false

			cleanupUIForKingzone(uiData)
			activeKingzones[kingzone] = nil
		end
	end
end)
