local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local CollectionService = game:GetService("CollectionService")

local kingZoneManagerScript =
	replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingZoneManager")
local kingCoinScript =
	replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingCoinLogic")
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")
local slapScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")
local safeZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("Safezone")
local abilityScripts: { Script } =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("AbilityEvents"):GetChildren()
for _, abilityScript in ipairs(abilityScripts) do
	abilityScript.Enabled = false
end
local kingCoinPrefab: Part = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin")
local bombPrefab: Tool = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb")
local slapPrefabs: Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles")

local slapStyleShapes: Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("SlapStyleShapes")

local toolToolingFunctions =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("toolToolingFunctions")
local toolToolingFuncs = require(toolToolingFunctions)

local kingCoinScriptClone = kingCoinScript:Clone()
kingCoinScriptClone.Parent = kingCoinPrefab

local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab.PrimaryPart

for _, safeZone in ipairs(game:GetService("CollectionService"):GetTagged("SafeZone")) do
	safeZoneScript:Clone().Parent = safeZone
end

for _, kingZoneManager in ipairs(game:GetService("CollectionService"):GetTagged("KingZoneManager")) do
	kingZoneManagerScript:Clone().Parent = kingZoneManager
end

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
		local function mapStatToLength(num: number)
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

for _, slipPart in ipairs(game:GetService("CollectionService"):GetTagged("Slippery")) do
	slipPart.CustomPhysicalProperties = PhysicalProperties.new(
		0, -- Density (can be 0 or keep original)
		0, -- Friction set to 0 for slippery
		0, -- Elasticity set to 0
		0, -- FrictionWeight
		0 -- ElasticityWeight
	)
	slipPart.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { character }

		local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -5, 0), rayParams)

		if
			raycastResult
			and raycastResult.Instance
			and not CollectionService:HasTag(raycastResult.Instance, "Slippery")
		then
			return
		end

		local player = game.Players:GetPlayerFromCharacter(character)

		if not player or not player.States.CanJump.Value then
			return
		end

		player.States.CanJump.Value = false
		humanoid.JumpHeight = 0

		delayUtil.Delay(0.5, function()
			player.States.CanJump.Value = true
			local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "JumpValue")
			local newCharacter = player.Character
			local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")

			if newHumanoid:IsDescendantOf(game) then
				newHumanoid.JumpHeight = compIntVal.Value
				print("Jump reset")
			else
				player.CharacterAdded:Once(function()
					local newCharacter = player.Character
					local newHumanoid = newCharacter and newCharacter:WaitForChild("Humanoid")
					newHumanoid.JumpHeight = compIntVal.Value
				end)
			end
		end)
	end)
end
