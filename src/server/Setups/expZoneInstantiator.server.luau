local collectionService = game:GetService("CollectionService")

local replicatedStorage = game:GetService("ReplicatedStorage")
local expZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("expZone")
expZoneScript.Enabled = false

for i, p in ipairs(collectionService:GetTagged("ExpZone")) do
	local scriptClone = expZoneScript:Clone()
	scriptClone.Parent = p
	scriptClone.Enabled = true
end
