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

function findRandomPlayer(players)
	if #players == 0 then
		return nil
	end

	local random = Random.new()
	local randomIndex = random:NextInteger(1, #players)
	local randomPlayer: Player = players[randomIndex]

	if randomPlayer and randomPlayer.Character and randomPlayer.Character:FindFirstChild("Bomb") then
		print(randomPlayer, "already has bomb")
		table.remove(players, randomIndex)
		return findRandomPlayer(players) -- use current players list
	end

	return randomPlayer
end

while true do
	local players = game:GetService("Players"):GetPlayers()
	if #players >= 2 then
		local randomPlayer = findRandomPlayer(players)
		if randomPlayer then
			giveBombToPlayer(randomPlayer)
		end
	else
		warn("Need 5 players, only have:", #players)
	end
	task.wait(BOMB_TIMER)
end
