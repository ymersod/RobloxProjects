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

local slapStyleShapes : Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("SlapStyleShapes")

local toolToolingFunctions =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("toolToolingFunctions")
local toolToolingFuncs = require(toolToolingFunctions)

kingZoneScript.Parent = workspace:FindFirstChild("Kingzone")
safezoneScript.Parent = workspace:FindFirstChild("Safezone")

local kingCoinScriptClone = kingCoinScript:Clone()
kingCoinScriptClone.Parent = kingCoinPrefab

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab.PrimaryPart

for _, slapPrefab in ipairs(slapPrefabs:GetChildren()) do
	-- setup shape
	local shapeStrValue: StringValue? = slapPrefab:FindFirstChild("Shape")
	if shapeStrValue then
		local shape = slapStyleShapes:FindFirstChild(shapeStrValue.Value)
		if shape then
			for i, p in ipairs(shape:Clone():GetChildren()) do
				-- local shapePartClone = p:Clone()
				p.Parent = slapPrefab
				if p.Name == "Handle" then
					(slapPrefab :: Tool).PrimaryPart = p
				end
			end
		end
	end
	
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

	-- Setup handle length
	local statVal = slapPrefab:FindFirstChild("StatVals")
	if statVal then
		local function mapStatToLength(num:number)
			return num
		end
		if statVal:GetAttribute("Range") then
			toolToolingFuncs.changeHandleLength(slapPrefab, mapStatToLength(statVal:GetAttribute("Range")))
		end
	end

	if not matchedAbility then
		warn("No ability found for slapstyle: ", slapPrefab)
	end
end
