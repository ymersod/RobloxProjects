local players = game:GetService("Players")

local expManagerFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("expManagerFunctions")

local funcs = require(expManagerFunctions)

local part = script.Parent

local kingCandidates = {}

local function getPlayer(col: { name: string, Parent: Model }): Player?
	local char = col.Parent
	if not char or col.name ~= "HumanoidRootPart" then
		return nil
	end

	local player = players:GetPlayerFromCharacter(char)

	return player
end

local function tryToAddPlayer(userId)
	kingCandidates[#kingCandidates + 1] = userId
	print(kingCandidates)
end

local function updateKingZone(list)
	table.clear(kingCandidates)
	for _, p in ipairs(list) do
		local player = getPlayer(p)
		local playerChar = player and player.Character
		local humanoid = playerChar and playerChar:FindFirstChildOfClass("Humanoid")
		if player and humanoid and humanoid.Health > 0 then
			tryToAddPlayer(player.UserId)
		end
	end
end

function scoreKing()
	local king = players:GetPlayerByUserId(kingCandidates[1])
	local leaderstats = king and king:FindFirstChild("leaderstats")
	local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")

	if kingScore then
		kingScore.Value += 1
		funcs.incrementExp(king.UserId,5)
	end
end

local function kingZoneMainLoop()
	while true do
		local partsInZone = workspace:GetPartsInPart(part)
		updateKingZone(partsInZone)
		if #kingCandidates > 0 then
			if #kingCandidates == 1 then
				part.Color = Color3.fromRGB(9, 255, 0)
				scoreKing()
			end
			part.Color = Color3.fromRGB(255, 0, 0)
		else
			part.Color = Color3.fromRGB(163, 162, 165)
		end
		task.wait(1)
	end
end
kingZoneMainLoop()
