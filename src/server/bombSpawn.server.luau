local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)
local BOMB_TIMER = 15

function giveBombToPlayer(player: Player)
	if player and player.Character then
		local bombClone = bombPrefab:Clone()
		local bombLogic: Script? = bombClone.PrimaryPart:FindFirstChildOfClass("Script")
		if not bombLogic then
			warn("Cant find bomblogic")
			return
		end
		bombLogic.Enabled = true
		inventoryFuncs.EquipBomb(player, bombClone, 0.1)
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
		-- print(randomPlayer, "already has bomb")
		table.remove(players, randomIndex)
		return findRandomPlayer(players) -- use current players list
	end

	return randomPlayer
end

while true do
	local players = game:GetService("Players"):GetPlayers()
	if #players >= 1 then
		local randomPlayer = findRandomPlayer(players)
		if randomPlayer then
			giveBombToPlayer(randomPlayer)
		end
	else
		warn("Need 5 players, only have:", #players)
	end
	task.wait(BOMB_TIMER)
end
