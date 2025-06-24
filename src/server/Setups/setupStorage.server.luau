local ServerStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local kingZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")
local kingCoinScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingCoinLogic")
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")
local slapScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")
local safezoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("Safezone")

local kingCoinPrefab: Part = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin")
local bombPrefab: Tool = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb")
local slapPrefabs: Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles")

kingZoneScript.Parent = workspace:FindFirstChild("Kingzone")
safezoneScript.Parent = workspace:FindFirstChild("Safezone")

local kingCoinScriptClone = kingCoinScript:Clone()
kingCoinScriptClone.Parent = kingCoinPrefab

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab.PrimaryPart

for _, slapPrefab in ipairs(slapPrefabs:GetChildren()) do
	local slapScriptClone = slapScript:Clone()
	local primaryPart: Part? = slapPrefab.PrimaryPart

	if primaryPart then
		slapScriptClone.Parent = primaryPart
	else
		slapScriptClone.Parent = slapPrefab
	end
end
