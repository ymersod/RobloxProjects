local players = game:GetService("Players")
local runner = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")
local collectionService = game:GetService("CollectionService")

local ServerScriptService = game:GetService("ServerScriptService")
local Boostmanager = require(ServerScriptService.Server.ServerModuleScripts.Boostmanager)

local hatsFolder = serverStorage:WaitForChild("Hats"):WaitForChild("KingCrowns")

local rankRequirementId = "RANK_REQUIREMENT"

type Boost = {
	Name: string,
	Value: number,
}

type CrownEntry = {
	itemPrefab: Instance,
	item: Instance?,
	speedBoost: number,
	jumpBoost: number,
	expBoost: number,
	currentPlayer: Player?,
	enabled: boolean,
}
local crowns: { [number]: CrownEntry } = {}

local keyTable: { [string]: { key: string } } = {}

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
			speedBoost = speedBoost,
			jumpBoost = jumpBoost,
			expBoost = expBoost,
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

local function applyModifiers(crownEntry: CrownEntry): { string }
	local player = crownEntry.currentPlayer
	local cancellationTokens = {}
	if not player then
		return cancellationTokens
	end
	local callbackExp = Boostmanager.AddBoost(player, "ExpBoost", "callback", crownEntry.expBoost)
	local callbackSpeed = Boostmanager.AddBoost(player, "SpeedValue", "callback", crownEntry.speedBoost)
	local callbackJump = Boostmanager.AddBoost(player, "JumpValue", "callback", crownEntry.jumpBoost)

	table.insert(cancellationTokens, callbackExp)
	table.insert(cancellationTokens, callbackSpeed)
	table.insert(cancellationTokens, callbackJump)

	return cancellationTokens
end

local function removeModifiers(player: Player?)
	if not player then
		return
	end
	local userId = tostring(player.UserId)
	local oldKeys = keyTable[userId]
	if oldKeys then
		for _, key in ipairs(oldKeys) do
			if key then
				print("removing boost")
				Boostmanager.RemoveBoost(key)
			end
		end
		keyTable[userId] = nil
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

		if not player then
			continue
		end

		if player ~= crownEntry.currentPlayer then
			crownEntry.currentPlayer = player
			removeModifiers(crownEntry.currentPlayer)
			local cancellationTokens = applyModifiers(crownEntry)
			local userIdStr = tostring(player.UserId)
			keyTable[userIdStr] = cancellationTokens
		end

		applyCrownToPlayer(crownEntry)
	end
end)
