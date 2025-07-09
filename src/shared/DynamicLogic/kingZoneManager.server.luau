print("got here fam co2")
local kingZoneScript =
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

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

		task.wait(waitTime)
	end
end)
