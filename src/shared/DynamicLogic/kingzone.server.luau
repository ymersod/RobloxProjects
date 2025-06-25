local ServerScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")

local expManagerFunctions = require(ServerScriptService.Server.ServerModuleScripts.expManagerFunctions)

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

	local xpBoost = 1
	local xpBoostIntValue : IntValue = king and king:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
	if xpBoostIntValue then
		xpBoost = xpBoostIntValue.Value/100
	end

	if kingScore then
		kingScore.Value += 1
		expManagerFunctions.incrementExp(king.UserId, 5 * xpBoost)
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
			else
				part.Color = Color3.fromRGB(255, 0, 0)
			end
		else
			part.Color = Color3.fromRGB(163, 162, 165)
		end
		task.wait(1)
	end
end
kingZoneMainLoop()
