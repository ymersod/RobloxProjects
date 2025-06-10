local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local bombPrefab = serverStorage:WaitForChild("Tools"):WaitForChild("Bomb") :: Tool
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")

local BOMB_TIMER = 30

function giveBombToPlayer(player: Player)
	if player and player.Character then
		local bombClone = bombPrefab:Clone()
		local bombScriptClone = bombScript:Clone()
		bombScriptClone.Parent = bombClone
		bombClone.Parent = player.Character
	end
end

function findRandomPlayer(playerCount, players)
	local random = Random.new()
	local randomIndex = random.NextInteger(random, 1, playerCount)
	local randomPlayer: Player = players[randomIndex]
	local playerChar = randomPlayer.Character

	if playerChar and playerChar:FindFirstChild("Bomb") then
		print("Player already ha bomb")
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
			giveBombToPlayer(randomPlayer)
		end
	else
		warn("0 players in game")
	end

	task.wait(BOMB_TIMER)
end
