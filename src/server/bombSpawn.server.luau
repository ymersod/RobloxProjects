local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
local inventoryFuncs = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local BOMB_SPAWNER_TAG = "BombSpawner"
local BOMB_TIMER = 20
local bombSpawners = CollectionService:GetTagged(BOMB_SPAWNER_TAG)
local bombCds: { { bombSpawner: Instance, cooldown: number, lastSpawnTime: number, bombReady: boolean } } = {}

for _, bombSpawner in ipairs(bombSpawners) do
	local entry = {
		bombSpawner = bombSpawner,
		cooldown = bombSpawner:GetAttribute("cooldown"),
		lastSpawnTime = os.time(),
		bombReady = true,
	}
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

function spawnBomb(bomb: { bombSpawner: Instance, cooldown: number, lastSpawnTime: number, bombReady: boolean })
	local existingGui = bomb.bombSpawner:FindFirstChild("BombCountdownGui")
	if existingGui then
		existingGui:Destroy()
	end

	local part = Instance.new("Part")
	part.Parent = bomb.bombSpawner
	part.CanCollide = false
	part.CanTouch = true
	part.Size = Vector3.new(1, 1, 1) -- Adjust as needed
	part.Anchored = true
	part.Name = "BombPickup"
	if bomb.bombSpawner:IsA("Model") and bomb.bombSpawner.PrimaryPart then
		local basePos = bomb.bombSpawner.PrimaryPart.Position
		part.Position = basePos
	else
		warn("rarrrr can set bomb")
	end

	part.Touched:Connect(function(hit)
		local playerChar = hit:FindFirstAncestorOfClass("Model")
		local player = playerChar and Players:GetPlayerFromCharacter(playerChar)

		local hasBomb = playerChar:FindFirstChild("Bomb")
		if player and not hasBomb then
			giveBombToPlayer(player)
			part:Destroy()
			bomb.lastSpawnTime = os.time()
			bomb.bombReady = true
		end
	end)
end

task.spawn(function()
	while true do
		local curTime = os.time()

		for _, bomb in ipairs(bombCds) do
			local remainingTime = bomb.cooldown - (curTime - bomb.lastSpawnTime)
			if remainingTime <= 0 and bomb.bombReady then
				bomb.bombReady = false
				spawnBomb(bomb)
			elseif remainingTime >= 0 and bomb.bombReady then
				-- Billboard GUI
				local gui = bomb.bombSpawner:FindFirstChild("BombCountdownGui")

				if not gui then
					-- Create the BillboardGui
					gui = Instance.new("BillboardGui")
					gui.Name = "BombCountdownGui"
					gui.Size = UDim2.new(0, 200, 0, 50)
					gui.StudsOffset = Vector3.new(0, 5, 0)
					gui.AlwaysOnTop = true
					gui.Parent = bomb.bombSpawner

					-- Create the TextLabel
					local label = Instance.new("TextLabel")
					label.Name = "CountdownLabel"
					label.Size = UDim2.new(1, 0, 1, 0)
					label.BackgroundTransparency = 1
					label.TextScaled = true
					label.Font = Enum.Font.GothamBold
					label.TextColor3 = Color3.fromRGB(255, 100, 100)
					label.Parent = gui
				end

				-- Update the label text
				local label = gui:FindFirstChild("CountdownLabel")
				if label then
					label.Text = tostring(remainingTime)
				end
			end
		end

		task.wait(1)
	end
end)
