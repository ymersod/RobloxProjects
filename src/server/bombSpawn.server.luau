local itemSphere = workspace:FindFirstChild("ItemSphere")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local inventoryFuncs = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool
--These are for scaling
local prefabHandle = bombPrefab:FindFirstChild("Handle")
local prefabMesh = prefabHandle and prefabHandle:FindFirstChildOfClass("SpecialMesh")
--These are for scaling
local BOMB_SPAWNER_TAG = "BombSpawner"
local bombSpawners = CollectionService:GetTagged(BOMB_SPAWNER_TAG)
local bombCds: { { bombSpawner: Instance, cooldown: number, lastSpawnTime: number, bombReady: boolean, bomb: Tool? } } =
	{}

local BOMB_FALL_ZONE_TAG = "BombFallZone"
local bombFallZones = CollectionService:GetTagged(BOMB_FALL_ZONE_TAG)
local rng = Random.new()
local TweenService = game:GetService("TweenService")

for _, bombSpawner in ipairs(bombSpawners) do
	local entry = {
		bombSpawner = bombSpawner,
		cooldown = bombSpawner:GetAttribute("cooldown"),
		lastSpawnTime = os.time(),
		bombReady = true,
		bomb = nil,
	}
	table.insert(bombCds, entry)
end

local bombFallData: {
	{
		zone: Instance,
		radius: number,
		height: number,
		floorWorldHeight: number,
		capacityDependedCooldown: number,
		bombCapacity: number,
		fallTime: number,
		itemHoverHeight: number,
		lastCallTime: number,
	}
} =
	{}

for _, bombFallZone in ipairs(bombFallZones) do
	local entry = {
		zone = bombFallZone,
		radius = bombFallZone.Size.y / 2,
		height = bombFallZone.Size.x,
		floorWorldHeight = bombFallZone.position.y - (bombFallZone.Size.x / 2),
		capacityDependedCooldown = bombFallZone:GetAttribute("CapacityDependedCooldown"),
		bombCapacity = bombFallZone:GetAttribute("BombCapacity"),
		fallTime = bombFallZone:GetAttribute("FallTime"),
		itemHoverHeight = bombFallZone:GetAttribute("ItemHoverHeight"),
		lastCallTime = os.time(),
	}
	print(entry)
	table.insert(bombFallData, entry)
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

function giveBombToPlayer(player: Player, bomb: Tool)
	if player and player.Character then
		inventoryFuncs.EquipBomb(player, bomb, 0.1)
	end
end

function createBombItem(bomb: Tool, startingPostition: Vector3, parent)
	local item = itemSphere:Clone()
	if not item then
		warn("can't clone itemSphere")
	end
	item.Position = startingPostition
	item.Parent = parent

	local primary = bomb.PrimaryPart or bomb:FindFirstChild("Handle") --TODO: find out which one it is
	if not primary then
		warn("Bomb tool has no PrimaryPart or Handle to position")
		return
	end

	local bombLogic: Script? = primary:FindFirstChildOfClass("Script")
	if not bombLogic then
		warn("Can't find bomb logic script")
		return
	end

	bombLogic.Enabled = true
	primary.Anchored = true
	primary.Position = startingPostition
	primary.CanTouch = false
	bomb.Parent = item

	-- Making the mesh of the item fit within the itemSphere
	local mesh = primary:FindFirstChildOfClass("SpecialMesh")
	local worldSize
	if mesh then -- Right now its a cube, but someday we might need to calculate on the mesh... hope this is how one would do it
		worldSize =
			Vector3.new(primary.Size.X * mesh.Scale.X, primary.Size.Y * mesh.Scale.Y, primary.Size.Z * mesh.Scale.Z)
	else
		worldSize = primary.Size
	end
	local boundingRadius = (worldSize / 2).Magnitude
	local scaleFactor = (itemSphere.Size.y / 2) / boundingRadius
	if mesh then
		mesh.Scale = mesh.Scale * scaleFactor
	else
		primary.Size = primary.Size * scaleFactor
	end

	item.Touched:Connect(
		function(hit) --TODO: Might need to introduce the keys back so a weird bug doesn't happen in multiplayer
			--if bomb.touched_key then
			--	return
			--end
			--bomb.touched_key = true
			local playerChar = hit:FindFirstAncestorOfClass("Model")
			local player = playerChar and Players:GetPlayerFromCharacter(playerChar)

			local hasBomb = playerChar:FindFirstChild("Bomb")
			if player and not hasBomb then
				-- Setting bomb setting back to normal
				primary.Anchored = false
				primary.CanTouch = true
				giveBombToPlayer(player, bomb)
				item:Destroy()
			end
			--bomb.touched_key = false
		end
	)

	item.Destroying:Connect(function()
		if not bomb then
			return
		end
		if prefabMesh then
			primary:FindFirstChildOfClass("SpecialMesh").Scale = prefabMesh.Scale
		else
			primary.Size = prefabHandle.Size
		end
	end)
	print("I got made")
	return item
end

local function randomPosOnCylinderTop(origin: Vector3, radius: number, height: number): Vector3
	local topCenter = origin + Vector3.new(0, height / 2, 0) --This could be done in the setup phase now that i think about it

	local r = radius * math.sqrt(rng:NextNumber())
	local theta = rng:NextNumber() * 2 * math.pi

	local offset = Vector3.new(r * math.cos(theta), 0, r * math.sin(theta))

	return topCenter + offset
end

function spawnBomb(bomb: {
	bombSpawner: Instance,
	cooldown: number,
	lastSpawnTime: number,
	bombReady: boolean,
	bomb: Tool?,
})
	local existingGui = bomb.bombSpawner:FindFirstChild("BombCountdownGui")
	if existingGui then
		existingGui:Destroy()
	end

	if bomb.bombSpawner:IsA("Model") and bomb.bombSpawner.PrimaryPart then
		local basePos = bomb.bombSpawner.PrimaryPart.Position
		local bombTool = bombPrefab:Clone()
		bombTool.Parent = bomb.bombSpawner

		local bombItem = createBombItem(bombTool, basePos, bomb.bombSpawner)
		bomb.bomb = bombTool

		bombTool.Destroying:Connect(function()
			if bomb.bomb == bombTool then
				bombItem:Destroy()
			end
		end)
		bombItem.Destroying:Connect(function()
			bomb.bomb = nil
			bomb.lastSpawnTime = os.time()
		end)
	else
		warn("rarrrr can set bomb")
	end
end

local function animateToPosition(part: BasePart, targetPos: Vector3, duration: number, followingTool: Tool): Tween
	local tweenInfo = TweenInfo.new(duration)
	local goal = { Position = targetPos }
	local tween = TweenService:Create(part, tweenInfo, goal)
	part:GetPropertyChangedSignal("CFrame"):Connect(function()
		local primary = followingTool.PrimaryPart or followingTool:FindFirstChild("Handle") --TODO: find out which one it is
		if not primary then
			warn("Bomb tool has no PrimaryPart or Handle to position")
			return
		end
		primary.Position = part.Position
	end)
	return tween
end

task.spawn(function()
	while true do
		local curTime = os.time()

		for _, bomb in ipairs(bombCds) do
			local remainingTime = bomb.cooldown - (curTime - bomb.lastSpawnTime)
			local isBombActive = bomb.bombSpawner:FindFirstChild(itemSphere.Name)
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

		for _, data in pairs(bombFallData) do
			local remainingTime = data.capacityDependedCooldown - (curTime - data.lastCallTime)
			if remainingTime > 0 then
				continue
			end
			local activeBombs = data.zone:GetChildren() -- Needs filtering if we add more things to the zones
			data.lastCallTime = os.time() -- Don't just want a bomb to spawn directly after something has been taken, which is why its before the next if statement
			if #activeBombs >= data.bombCapacity then
				continue
			end

			local bombTool = bombPrefab:Clone()
			local bombItem = createBombItem(
				bombTool,
				randomPosOnCylinderTop(data.zone.Position, data.radius, data.height),
				data.zone
			)
			local animation = animateToPosition(
				bombItem,
				bombItem.position - Vector3.new(0, data.height - data.itemHoverHeight, 0),
				data.fallTime,
				bombTool
			)
			bombTool.Destroying:Connect(function() --TODO: Should be generalized in the createBombItem
				if bombItem then
					bombItem:Destroy()
				end
			end)
			bombItem.Destroying:Connect(function()
				animation:Destroy()
			end)
			animation:Play()
		end

		task.wait(1)
	end
end)
