local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local kingZoneScript = ServerScriptService:WaitForChild("Server"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)

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

task.spawn(function()
	local initialSizes: { { Model: UnionOperation, Size: Vector3 } } = {}
	while true do
		local newActiveZones = {}
		local selectIndex = math.random(1, #kingZones)
		for i = 1, numberOfZonesActive do
			local selected = kingZones[selectIndex] -- selects a king zone
			local endIndex = #kingZones - (i - 1) -- gets the index of the last unselected zone
			-- swaps the selected zone with the last unselected zone
			kingZones[selectIndex] = kingZones[endIndex]
			kingZones[endIndex] = selected

			table.insert(newActiveZones, selected) -- adds selected zone to an list
			selectIndex = math.random(1, #kingZones - i) -- selects another zone index
		end

		local unselectedZone = DifferenceOperation(kingZones, newActiveZones) -- gets all zones that won't be active

		-- creates and plays the animations for all zones that won't be active
		local pulseTweens: { Tween } = {}
		local implodeTweens: { Tween } = {}
		for i, zone in ipairs(unselectedZone) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model and zone:GetAttribute("isActive") then
				local pulseTween = createTweenFunctions.PulseSize(model, model.Size * 0.9, 4, 2)
				local implodeTween = createTweenFunctions.Implode(model, 2)
				table.insert(pulseTweens, pulseTween)
				table.insert(implodeTweens, implodeTween)
				table.insert(initialSizes, { Model = model, Size = model.Size })
			end
		end
		for i, t in ipairs(pulseTweens) do
			t:Play()
		end
		if #pulseTweens > 0 then
			pulseTweens[1].Completed:Wait()
		end
		for i, t in ipairs(implodeTweens) do
			t:Play()
		end
		if #implodeTweens > 0 then
			implodeTweens[1].Completed:Wait()
		end

		if #unselectedZone > 0 then
			for _, kingZone in ipairs(unselectedZone) do
				kingZone:SetAttribute("isActive", false)
			end
		end

		-- resets the sizes of all models changed by animations
		for i, zone in ipairs(initialSizes) do
			zone.Model.Size = zone.Size
		end

		-- creates new plays animations that expand new active zones to the normal size
		for i, zone in ipairs(newActiveZones) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model and not zone:GetAttribute("isActive") then
				zone:SetAttribute("isActive", true)
				local blowUpSizeTween = createTweenFunctions.BlowToSize(model, model.Size, 2)
				model.Size = Vector3.zero
				blowUpSizeTween:Play()
			end
		end
		table.clear(initialSizes)

		task.wait(waitTime) -- waits until next zone change window
	end
end)
