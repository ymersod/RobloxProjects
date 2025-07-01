local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
local BOMB_SPAWNER_TAG = "BombSpawner"
local bombSpawners = CollectionService:GetTagged(BOMB_SPAWNER_TAG)
local bombCds: { { bombSpawner: Instance, cooldown: number, lastSpawnTime: number, bombReady: boolean } } = {}

for _, bombSpawner in ipairs(bombSpawners) do
	local entry = {
		bombSpawner = bombSpawner,
		cooldown = bombSpawner:GetAttribute("cooldown"),
		lastSpawnTime = os.time(),
		bombReady = true,
	}
	bombSpawner.ChildRemoved:Connect(function(child)
		if child.Name == bombPrefab.Name then
			entry.lastSpawnTime = os.time()
		end
	end)
	table.insert(bombCds, entry)
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

--TODO: Remove func if no use later
--[[task.spawn(function()
	while true do
		local players = game:GetService("Players"):GetPlayers()
		if #players >= 0 then
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
end)--]]

function spawnBomb(bomb: {
	bombSpawner: Instance,
	cooldown: number,
	lastSpawnTime: number,
	bombReady: boolean,
	touched_key: boolean,
})
	local existingGui = bomb.bombSpawner:FindFirstChild("BombCountdownGui")
	if existingGui then
		existingGui:Destroy()
	end

	local bombTool = bombPrefab:Clone()

	if bomb.bombSpawner:IsA("Model") and bomb.bombSpawner.PrimaryPart then
		local basePos = bomb.bombSpawner.PrimaryPart.Position

		local primary = bombTool.PrimaryPart or bombTool:FindFirstChild("Handle") --TODO: find out which one it is
		if not primary then
			warn("Bomb tool has no PrimaryPart or Handle to position")
			return
		end

		-- Anchor the part and set its position, should be turned off when the bomb is taken by a player
		primary.Anchored = true
		primary.Position = basePos
		bombTool.Parent = bomb.bombSpawner

		local bombLogic: Script? = primary:FindFirstChildOfClass("Script")
		if not bombLogic then
			warn("Can't find bomb logic script")
			return
		end

		bombLogic.Enabled = true
	else
		warn("rarrrr can set bomb")
	end
end

task.spawn(function()
	while true do
		local curTime = os.time()

		for _, bomb in ipairs(bombCds) do
			local remainingTime = bomb.cooldown - (curTime - bomb.lastSpawnTime)
			local isBombActive = bomb.bombSpawner:FindFirstChildOfClass(bombPrefab.ClassName)
			if remainingTime <= 0 and not isBombActive then
				spawnBomb(bomb)
			elseif remainingTime >= 0 and not isBombActive then
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
