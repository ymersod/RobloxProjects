local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bombPrefab = ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Bomb") :: Tool
local equipEvent = require(ReplicatedStorage.Shared.ModuleScripts.equipItemPlayer)

local BOMB_TIMER = 15

function giveBombToPlayer(player: Player)
	if player and player.Character then
		local bombClone = bombPrefab:Clone()

		equipEvent.EquipTool(player, bombClone)
	end
end

function findRandomPlayer(playerCount, players)
	local random = Random.new()
	local randomIndex = random.NextInteger(random, 1, playerCount)
	local randomPlayer: Player = players[randomIndex]
	local playerChar = randomPlayer.Character

	if playerChar and playerChar:FindFirstChild("Bomb") then
		print(randomPlayer, " already have bomb")
		table.remove(players, randomIndex)
		if #players > 0 then
			return findRandomPlayer(playerCount, players)
		else
			return nil
		end
	end
	return randomPlayer
end

while true do
	local players = game:GetService("Players"):GetPlayers()
	local playerCount = #players
	if playerCount > 0 then
		local randomPlayer = findRandomPlayer(playerCount, players)

		if randomPlayer then
			-- TODO: ADD BACK WHEN PROD OR TESTING BOMBING
			-- giveBombToPlayer(randomPlayer)
		end
	else
		warn("0 players in game")
	end

	task.wait(BOMB_TIMER)
end
