local ServerScriptService = game:GetService("ServerScriptService")
local collectionService = game:GetService("CollectionService")

local expZoneScript = ServerScriptService:WaitForChild("Server"):WaitForChild("DynamicLogic"):WaitForChild("expZone")

for _, p in ipairs(collectionService:GetTagged("ExpZone")) do
	local scriptClone = expZoneScript:Clone()
	scriptClone.Parent = p
	scriptClone.Enabled = true
end
