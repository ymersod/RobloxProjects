print("got here fam co2")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local kingZoneScript =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
	
local this = script.Parent
local kingZones = {}
local waitTime = this:GetAttribute("swapActiveZoneSeconds")
local numberOfZonesActive = this:GetAttribute("NumberOfActiveZones")
local currentSelectedZones = {}

for _, kingZone in ipairs(this:GetChildren()) do
	if kingZone.Name ~= "Kingzone" then
		continue
	end
	kingZone:SetAttribute("isActive", false)
	kingZoneScript:Clone().Parent = kingZone
	table.insert(kingZones, kingZone)
end

if #kingZones < numberOfZonesActive then
	numberOfZonesActive = #kingZones
end

task.spawn(function()
	local initialSizes : {{Model:UnionOperation, Size:Vector3}} = {}
	while true do
		if #currentSelectedZones > 0 then
			for _, kingZone in ipairs(currentSelectedZones) do
				kingZone:SetAttribute("isActive", false)
			end
		end
		local newActiveZones = {}
		local selectIndex = math.random(1, #kingZones)
		for i = 1, numberOfZonesActive do
			local selected = kingZones[selectIndex]
			local endIndex = #kingZones - (i - 1)
			local switch = kingZones[endIndex]
			kingZones[selectIndex] = switch
			kingZones[endIndex] = selected
			table.insert(newActiveZones, selected)
			selected:SetAttribute("isActive", true)
			selectIndex = math.random(1, #kingZones - i)
		end

		currentSelectedZones = newActiveZones

		for i, zone in ipairs(initialSizes) do
			zone.Model.Size = zone.Size
		end
		for i, zone in ipairs(currentSelectedZones) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model then
				local blowUpSizeTween = createTweenFunctions.BlowToSize(model, model.Size, 2)
				model.Size = Vector3.zero
				blowUpSizeTween:Play()
			end
		end
		table.clear(initialSizes)

		task.wait(waitTime)

		local pulseTweens : {Tween} = {}
		local implodeTweens : {Tween} = {}
		for i, zone in ipairs(currentSelectedZones) do
			local model = zone:FindFirstChildOfClass("UnionOperation")
			if model then
				local pulseTween = createTweenFunctions.PulseSize(model, model.Size*0.9, 4, 2)
				local implodeTween = createTweenFunctions.Implode(model, 2)
				table.insert(pulseTweens,pulseTween)
				table.insert(implodeTweens,implodeTween)
				table.insert(initialSizes, { Model=model, Size = model.Size })
			end
		end
		for i, t in ipairs(pulseTweens) do
			t:Play()
		end
		pulseTweens[1].Completed:Wait()
		for i, t in ipairs(implodeTweens) do
			t:Play()
		end
		implodeTweens[1].Completed:Wait()
	end
end)
