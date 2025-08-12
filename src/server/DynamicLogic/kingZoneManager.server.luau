local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local kingZoneScript = ServerScriptService:WaitForChild("Server"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local kingZoneActivateClient =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("KingZoneActivateClient")
local this = script.Parent
local kingZones = {}
local waitTime = this:GetAttribute("swapActiveZoneSeconds")
local numberOfZonesActive = this:GetAttribute("NumberOfActiveZones")

for _, kingZone in ipairs(this:GetChildren()) do
	if kingZone.Name ~= "Kingzone" then
		continue
	end
	kingZone:SetAttribute("isActive", false)

	local kingZoneScriptClone = kingZoneScript:Clone()
	kingZoneScriptClone.Parent = kingZone
	kingZoneScriptClone.Enabled = true
	table.insert(kingZones, kingZone)
end

if #kingZones < numberOfZonesActive then
	numberOfZonesActive = #kingZones
end

--- Returns all zones from a_1 that aren't in a_2
local function DifferenceOperation(a_1: { Instance }, a_2: { Instance }): { Instance }
	local output = {}
	for i, inst1 in ipairs(a_1) do
		local foundInA_2 = false
		for j, inst2 in ipairs(a_2) do
			if inst1 == inst2 then
				foundInA_2 = true
				break
			end
		end
		if not foundInA_2 then
			table.insert(output, inst1)
		end
	end
	return output
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
end

task.spawn(function()
	local previousActiveZones = {} -- track zones from last cycle

	while true do
		-- Create candidate list excluding previousActiveZones
		local candidates = {}
		for _, zone in ipairs(kingZones) do
			local isPrevActive = false
			for _, prevZone in ipairs(previousActiveZones) do
				if zone == prevZone then
					isPrevActive = true
					break
				end
			end
			if not isPrevActive then
				table.insert(candidates, zone)
			end
		end

		-- Shuffle candidates to randomize selection
		shuffle(candidates)

		local newActiveZones = {}

		-- First fill newActiveZones from candidates (zones not used last time)
		for i = 1, math.min(numberOfZonesActive, #candidates) do
			table.insert(newActiveZones, candidates[i])
		end

		-- If still need more zones, fill from previousActiveZones (allow repeats only if necessary)
		if #newActiveZones < numberOfZonesActive then
			shuffle(previousActiveZones)
			for i = 1, numberOfZonesActive - #newActiveZones do
				if previousActiveZones[i] then
					table.insert(newActiveZones, previousActiveZones[i])
				else
					-- fallback if previousActiveZones too small (just use kingZones)
					table.insert(newActiveZones, kingZones[1])
				end
			end
		end

		-- Now do your animations and attribute updates as before

		local unselectedZone = DifferenceOperation(kingZones, newActiveZones)

		-- Animation code (pulse, implode) for unselected zones
		local pulseTweens = {}
		local implodeTweens = {}
		local initialSizes = {}
		for _, zone in ipairs(unselectedZone) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model and zone:GetAttribute("isActive") then
				table.insert(pulseTweens, createTweenFunctions.PulseSize(model, model.Size * 0.9, 4, 2))
				table.insert(implodeTweens, createTweenFunctions.Implode(model, 2))
				table.insert(initialSizes, { Model = model, Size = model.Size })
			end
		end

		for _, tween in ipairs(pulseTweens) do
			tween:Play()
		end
		if #pulseTweens > 0 then
			pulseTweens[1].Completed:Wait()
		end
		for _, tween in ipairs(implodeTweens) do
			tween:Play()
		end
		if #implodeTweens > 0 then
			implodeTweens[1].Completed:Wait()
		end

		for _, zone in ipairs(unselectedZone) do
			zone:SetAttribute("isActive", false)
		end

		-- Reset sizes
		for _, zoneInfo in ipairs(initialSizes) do
			zoneInfo.Model.Size = zoneInfo.Size
		end

		-- Animate new active zones
		for _, zone in ipairs(newActiveZones) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model and not zone:GetAttribute("isActive") then
				zone:SetAttribute("isActive", true)
				local blowUpSizeTween = createTweenFunctions.BlowToSize(model, model.Size, 2)
				model.Size = Vector3.zero
				blowUpSizeTween:Play()
			end
			kingZoneActivateClient:FireAllClients(zone, 7)
		end

		-- Update previousActiveZones for next cycle
		previousActiveZones = newActiveZones

		task.wait(5)
	end
end)
