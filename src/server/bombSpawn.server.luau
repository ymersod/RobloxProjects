local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
local inventoryFuncs = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local BOMB_SPAWNER_TAG = "BombSpawner"
local BOMB_TIMER = 20
local bombSpawners = CollectionService:GetTagged(BOMB_SPAWNER_TAG)
local bombCds: { { bombSpawner: Instance, cooldown: number, lastSpawnTime: number } } = {}

for _, bombSpawner in ipairs(bombSpawners) do
	local entry =
		{ bombSpawner = bombSpawner, cooldown = bombSpawner:GetAttribute("cooldown"), lastSpawnTime = os.time() }
	table.insert(bombCds, entry)
end

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

-- //////////////////////////////////////////////////////////////
-- LOGIC FOR GIVING TO RANDOM PLAYER MIGHT BE USEFUL LATER
-- //////////////////////////////////////////////////////////////

function findRandomPlayer(players)
	if #players == 0 then
		return nil
	end
	print("here")
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
--FOR TEST
-- task.wait(5)

task.spawn(function()
	while true do
		local players = game:GetService("Players"):GetPlayers()
		if #players >= 3 then
			--Filter for if players are in safeZone
			local unsafePlayers = {}
			for _, player in ipairs(players) do
				if not player.States.Safe.Value then
					table.insert(unsafePlayers, player)
				end
			end
			if #unsafePlayers == 0 then
				print("All players are in a safezone!")
			end

			local randomPlayer = findRandomPlayer(unsafePlayers)
			if randomPlayer then
				giveBombToPlayer(randomPlayer)
			end
		else
			warn("Need 5 players, only have:", #players)
		end
		task.wait(BOMB_TIMER)
	end
end)

task.spawn(function()
	while true do
		local curTime = os.time()

		for _, bomb in ipairs(bombCds) do
			if curTime - bomb.lastSpawnTime >= bomb.cooldown then
			else
			end
		end

		task.wait(1)
	end
end)
