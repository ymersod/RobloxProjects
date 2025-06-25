local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local kingZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")
local kingCoinScript =
	replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingCoinLogic")
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")
local slapScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")
local safezoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("Safezone")
local abilityScripts: { Script } =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("AbilityEvents"):GetChildren()
for _, abilityScript in ipairs(abilityScripts) do
	abilityScript.Enabled = false
end

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

	-- Ability setup
	local ability = slapPrefab:FindFirstChild("AbilityVals")
	local abilityName = ability and ability:GetAttribute("ability")
	local matchedAbility = false

	for _, abilityScript in ipairs(abilityScripts) do
		if abilityScript.Name == abilityName then
			local abilityClone = abilityScript:Clone()
			abilityClone.Parent = slapPrefab
			matchedAbility = true
			continue
		end
	end

	if not matchedAbility then
		warn("No ability found for slapstyle: ", slapPrefab)
	end
end
