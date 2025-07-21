local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local concealedBridges = CollectionService:GetTagged("ConcealBridge")
local bridgeState = {} -- track if bridge is currently hidden

local CHECK_INTERVAL = 0.1

local function getPlayerFromPart(part)
	local model = part:FindFirstAncestorOfClass("Model")
	if model then
		return Players:GetPlayerFromCharacter(model)
	end
	return nil
end

local function toggleBridge(bridge, shouldHide)
	local toToggle = bridge:GetChildren()
	for _, obj in toToggle do
		if obj:IsA("ObjectValue") and obj.Value and obj.Value:IsA("BasePart") then
			local objRef = obj.Value
			if shouldHide then
				objRef.CanCollide = false
				objRef.Transparency = 0.7
			else
				objRef.CanCollide = true
				objRef.Transparency = 0
			end
		end
	end
end

for _, bridge in ipairs(concealedBridges) do
	local trigger = bridge:FindFirstChild("Trigger")
	if not (trigger and trigger:IsA("BasePart")) then
		warn("Missing or invalid Trigger part in", bridge:GetFullName())
		continue
	end

	bridgeState[bridge] = false

	-- Use a thread for each bridge
	task.spawn(function()
		while true do
			local playersInZone = false
			local parts = workspace:GetPartsInPart(trigger)

			for _, part in ipairs(parts) do
				local player = getPlayerFromPart(part)
				if player then
					playersInZone = true
					break
				end
			end

			if playersInZone and not bridgeState[bridge] then
				-- Hide bridge
				toggleBridge(bridge, true)
				bridgeState[bridge] = true
			elseif not playersInZone and bridgeState[bridge] then
				-- Show bridge
				toggleBridge(bridge, false)
				bridgeState[bridge] = false
			end

			task.wait(CHECK_INTERVAL)
		end
	end)
end
