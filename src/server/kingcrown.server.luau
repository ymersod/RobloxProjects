local players = game:GetService("Players")
local runner = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")
local collectionService = game:GetService("CollectionService")

local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)

local hatsFolder = serverStorage:WaitForChild("Hats"):WaitForChild("KingCrowns")

local rankRequirementId = "RANK_REQUIREMENT"

suffixBoostExpId = "ExpBoost"
suffixBoostSpeedId = "SpeedValue"
suffixBoostJumpId = "JumpValue"

prefixCrownSpeedBoostName = "KingSpeedBoost"
prefixCrownJumpBoostName = "KingJumpBoost"
prefixCrownExpBoosName = "KingExpBoost"

type Boost = {
	Name: string,
	Value: number,
}

type CrownEntry = {
	itemPrefab: Instance,
	item: Instance?,
	speedBoost: Boost,
	jumpBoost: Boost,
	expBoost: Boost,
	currentPlayer: Player?,
	enabled: boolean,
}
local crowns: { [number]: CrownEntry } = {}

for _, item in ipairs(hatsFolder:GetChildren()) do
	if collectionService:HasTag(item, "KingCrown") then
		local rank = item:GetAttribute(rankRequirementId)
		if not rank then
			warn("Missing or invalid RankRequirement attribute on:", item.Name)
			continue
		end
		if crowns[rank] then
			warn("Duplicate RankRequirement value:", rank, "on crown:", item.Name)
			continue
		end
		local speedBoost = item:GetAttribute("CROWN_SPEED_BOOST")
		if not speedBoost then
			warn("No speedBoost given on ", item.Name, " default to 1")
			speedBoost = 1
		end

		local jumpBoost = item:GetAttribute("CROWN_JUMP_BOOST")
		if not jumpBoost then
			warn("No jumpBoost given on ", item.Name, " default to 1")
			jumpBoost = 1
		end

		local expBoost = item:GetAttribute("CROWN_EXP_BOOST")
		if not expBoost then
			warn("No expBoost given on ", item.Name, " default to 0")
			expBoost = 0
		end

		crowns[rank] = {
			itemPrefab = item,
			item = item:Clone(),
			speedBoost = { Name = prefixCrownSpeedBoostName .. rank .. item.Name, Value = speedBoost },
			jumpBoost = { Name = prefixCrownJumpBoostName .. rank .. item.Name, Value = jumpBoost },
			expBoost = { Name = prefixCrownExpBoosName .. rank .. item.Name, Value = expBoost },
			currentPlayer = nil,
			enabled = true,
		}
	end
end

local function getTopPlayersWithScore()
	local topPlayers = {}

	for _, child in ipairs(players:GetChildren()) do
		if child:IsA("Player") then
			local leaderstats = child:FindFirstChild("leaderstats")
			local kingScore = leaderstats and leaderstats:FindFirstChild("King Score")
			if kingScore and kingScore.Value > 0 then
				table.insert(topPlayers, child)
			end
		end
	end

	table.sort(topPlayers, function(a, b)
		local aScore = a.leaderstats:FindFirstChild("King Score").Value
		local bScore = b.leaderstats:FindFirstChild("King Score").Value
		return aScore > bScore
	end)

	return topPlayers
end

local function applyModifier(crownEntry: CrownEntry)
	if not crownEntry.currentPlayer then
		return
	end
	local userId = crownEntry.currentPlayer.UserId
	local expCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostExpId)
	if not expCompIntValue.containsMod(crownEntry.expBoost.Name) then
		expCompIntValue += crownEntry.expBoost
	end
	local speedCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostSpeedId)
	if not speedCompIntValue.containsMod(crownEntry.speedBoost.Name) then
		speedCompIntValue += crownEntry.speedBoost
	end
	local jumpCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostJumpId)
	if not jumpCompIntValue.containsMod(crownEntry.jumpBoost.Name) then
		jumpCompIntValue += crownEntry.jumpBoost
	end
end

local function removeModifier(crownEntry: CrownEntry)
	if not crownEntry.currentPlayer then
		return
	end
	local userId = crownEntry.currentPlayer.UserId
	local expCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostExpId)
	if expCompIntValue.containsMod(crownEntry.expBoost.Name) then
		expCompIntValue.removeModifier(crownEntry.expBoost.Name)
	end
	local speedCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostSpeedId)
	if speedCompIntValue.containsMod(crownEntry.speedBoost.Name) then
		speedCompIntValue.removeModifier(crownEntry.speedBoost.Name)
	end
	local jumpCompIntValue = compositeIntValueMultiton.getCompositeIntValue(userId .. suffixBoostJumpId)
	if jumpCompIntValue.containsMod(crownEntry.jumpBoost.Name) then
		jumpCompIntValue.removeModifier(crownEntry.jumpBoost.Name)
	end
end

local function positionCrownOverPlayer(crown, char: Model)
	local hrp = char:WaitForChild("HumanoidRootPart")
	crown.Position = hrp.Position + Vector3.yAxis * 6
	crown.Rotation = hrp.Rotation
end

local function disableCrown(crownEntry: CrownEntry)
	if not crownEntry.item and not crownEntry.enabled then
		return
	end

	crownEntry.enabled = false

	local crown = crownEntry.item
	local weld = crown:FindFirstChildOfClass("WeldConstraint")
	if weld then
		weld:Destroy()
	end

	crown.Transparency = 1 --Don't think I have to set trans.... but whatever
	crown.Parent = nil
end

local function enableCrown(crownEntry: CrownEntry)
	if not crownEntry.item then
		return
	end

	crownEntry.enabled = true

	local crown = crownEntry.item
	crown.Transparency = 0
end

local function applyCrownToPlayer(crownEntry: CrownEntry)
	local player = crownEntry.currentPlayer
	local char = player and player.Character
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		disableCrown(crownEntry)
		return
	end

	local crown = crownEntry.item

	if not crown then
		crown = crown:Clone()
		crownEntry.item = crown
	end

	enableCrown(crownEntry)

	local weld = crown:FindFirstChildOfClass("WeldConstraint")
	if not weld then
		positionCrownOverPlayer(crown, char)
		weld = Instance.new("WeldConstraint")
		weld.Name = crown.Name .. "Weld"
		weld.Part0 = rootPart
		weld.Part1 = crown
		weld.Parent = crown
		crown.Parent = char
	elseif weld.Part0 ~= rootPart then
		positionCrownOverPlayer(crown, char)
		weld.Part0 = rootPart
		crown.Parent = char
	end
end

runner.Heartbeat:Connect(function()
	local topPlayers = getTopPlayersWithScore()
	for rank, crownEntry in ipairs(crowns) do
		local player = topPlayers[rank]

		-- Skip if same player: modifier functions handle nil internally.
		if player ~= crownEntry.currentPlayer then
			removeModifier(crownEntry)
			crownEntry.currentPlayer = player
			applyModifier(crownEntry)
		end

		applyCrownToPlayer(crownEntry)
	end
end)
