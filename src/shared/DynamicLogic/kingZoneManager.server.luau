print("got here fam co2")
local kingZoneScript =
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

local this = script.Parent
local kingZones = {}
local waitTime = this:GetAttribute("swapActiveZoneSeconds")
local currentSelectedZone = nil

for _, kingZone in ipairs(this:GetChildren()) do
	if kingZone.Name ~= "Kingzone" then
		continue
	end
	kingZone:SetAttribute("isActive", false)
	kingZoneScript:Clone().Parent = kingZone
	table.insert(kingZones, kingZone)
end

task.spawn(function()
	while true do
		if currentSelectedZone then
			currentSelectedZone:SetAttribute("isActive", false)
		end

		local selectIndex = math.random(1, #kingZones)
		currentSelectedZone = kingZones[selectIndex]
		currentSelectedZone:SetAttribute("isActive", true)

		task.wait(waitTime)
	end
end)
