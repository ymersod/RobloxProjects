local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local dynamicLogicFolder = ServerScriptService:WaitForChild("Server"):WaitForChild("DynamicLogic")
local sounds = ServerStorage:WaitForChild("Sounds")
local abilitySounds = sounds:WaitForChild("AbilitySounds")
local toolSounds = sounds:WaitForChild("Slap"):GetChildren()
local kingZoneManagerScript = dynamicLogicFolder:WaitForChild("kingZoneManager")
local kingCoinScript = dynamicLogicFolder:WaitForChild("kingCoinLogic")
local bombScript = dynamicLogicFolder:WaitForChild("bombLogic")
local slapScript = dynamicLogicFolder:WaitForChild("slaplogic")
local abilityScript: Script = ServerScriptService:WaitForChild("Server")
	:WaitForChild("Abilities")
	:WaitForChild("AbilityEvents")
	:WaitForChild("slappingAbility")
abilityScript.Enabled = false

local kingCoinPrefab: Part = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin")
local bombPrefab: Tool = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb")
local slapPrefabs: Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles")

local slapStyleShapes: Folder = ServerStorage:WaitForChild("Tools"):WaitForChild("SlapStyleShapes")

local toolToolingFunctions =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("toolToolingFunctions")
local toolToolingFuncs = require(toolToolingFunctions)

local kingCoinScriptClone = kingCoinScript:Clone()
kingCoinScriptClone.Parent = kingCoinPrefab
kingCoinScriptClone.Enabled = true

local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local ingameShopManager = require(ServerScriptService.Server.ServerModuleScripts.ingameShopManager) -- DONT DELETE

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab.PrimaryPart
bombScriptClone.Enabled = true

for _, kingZoneManager in ipairs(game:GetService("CollectionService"):GetTagged("KingZoneManager")) do
	local kingZoneManagerClone = kingZoneManagerScript:Clone()
	kingZoneManagerClone.Parent = kingZoneManager
	kingZoneManagerClone.Enabled = true
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
	slapScriptClone.Enabled = true

	-- Ability setup
	local abilityClone = abilityScript:Clone()
	abilityClone.Parent = slapPrefab

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

	-- Setup sounds
	local handle = slapPrefab.Handle
	local abilityVals = slapPrefab:FindFirstChild("AbilityVals")
	local abilitySoundStart = abilityVals and abilityVals:GetAttribute("AbilitySoundStart")
	local abilitySoundEnd = abilityVals and abilityVals:GetAttribute("AbilitySoundEnd")
	local abilitySoundOnHit = abilityVals and abilityVals:GetAttribute("AbilitySoundOnHit")

	if not handle then
		warn("Cant find handle something went wrong in setup")
		continue
	end
	if abilitySoundStart then
		local sound = abilitySounds:FindFirstChild(abilitySoundStart) :: Sound
		local soundClone = sound:Clone()
		soundClone.Parent = handle
		soundClone:SetAttribute("PlayOnUse", true)
	end
	if abilitySoundEnd then
		local sound = abilitySounds:FindFirstChild(abilitySoundEnd) :: Sound
		local soundClone = sound:Clone()
		soundClone.Parent = handle
		soundClone:SetAttribute("PlayOnUse", false)
	end
	if abilitySoundOnHit then
		local sound = abilitySounds:FindFirstChild(abilitySoundOnHit) :: Sound
		local soundClone = sound:Clone()
		soundClone.Parent = handle
		soundClone:SetAttribute("OnHit", true)
	end
	for _, sound in ipairs(toolSounds) do
		if sound:IsA("Sound") then
			local soundClone = sound:Clone()
			soundClone.Parent = handle
		end
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
		if not character then
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

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

		delayUtil.Delay(0.5, function()
			player.States.CanJump.Value = true
		end)
	end)
end
