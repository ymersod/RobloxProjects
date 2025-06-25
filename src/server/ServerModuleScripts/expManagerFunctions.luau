local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local expStore = DataStoreService:GetDataStore("PlayerExp")
local orderedExpStore = DataStoreService:GetOrderedDataStore("OrderedPlayerExp")
local orderedExpMemoryStore = MemoryStoreService:GetSortedMap("OrderedPlayerExp")

local OpenFunctions = {}

-- Add Exp values for each player to a local table to avoid hitting the data
-- store repeatedly.
local playerExp = {}

local function calcLevelAndExpWindow(exp: number): { lvl: number, lvlProgress: { progress: number, goal: number } }
	local lvl = math.max(0, math.floor(-95.04 + 20.25 * math.log(exp + 109)))
	local oldGoal = math.floor(math.pow(2.718, (lvl + 95.04) / 20.25)) - 109
	local goal = math.floor(math.pow(2.718, ((lvl + 1) + 95.04) / 20.25)) - 109

	-- print("lvl: " .. lvl)
	-- print("lvl goal: " .. oldGoal)
	-- print("next lvl goal: " .. goal)
	-- print("progress: " .. (exp-oldGoal)/(goal-oldGoal))

	return { lvl = lvl, lvlProgress = { progress = exp - oldGoal, goal = goal - oldGoal } }
end

function OpenFunctions.incrementExp(playerId, amount)
	print("incrementing score for player with id: " .. playerId)
	if playerExp[playerId] then
		playerExp[playerId] += amount

		local success, player = pcall(function()
			return Players:GetPlayerByUserId(playerId)
		end)
		if success then
			local bindableLvl:IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level")
			local level = calcLevelAndExpWindow(playerExp[playerId])
			if bindableLvl.Value ~= level.lvl then
				bindableLvl.Value = level.lvl
			end
			
			expLevelClient:FireClient(player, level)
		end
	end
end

function OpenFunctions.setExp(playerId, amount)
	if playerExp[playerId] then
		playerExp[playerId] = amount
		local success, player = pcall(function()
			return Players:GetPlayerByUserId(playerId)
		end)
		if success then
			local bindableLvl:IntValue = player:WaitForChild("LocalStats"):WaitForChild("Level")
			local level = calcLevelAndExpWindow(playerExp[playerId])
			if bindableLvl.Value ~= level.lvl then
				bindableLvl.Value = level.lvl
			end

			expLevelClient:FireClient(player, level)
		end
	end
end

function OpenFunctions.getExp(playerId)
	return playerExp[playerId]
end

function OpenFunctions.onPlayerAdded(player : Player)
	print("player added exp function")
	-- Read data store key
	local success, storedExp = pcall(function()
		return expStore:GetAsync(player.UserId)
	end)
	if success then
		local currentExp
		if storedExp then
			currentExp = storedExp
		else
			currentExp = 0
		end
		playerExp[player.UserId] = currentExp
		print(currentExp)

		local level = calcLevelAndExpWindow(currentExp)

		local success, err = pcall(function()
			return orderedExpMemoryStore:SetAsync(player.UserId, level.lvl, 38e5, level.lvl)
		end)
		if not success then
			warn(err)
		end

		local levelTest = player:WaitForChild("LocalStats"):WaitForChild("Level")
		
		if levelTest then
			levelTest.Value = level.lvl
			levelTest.Changed:Connect(function(level)
				if player.UserId > 0 then
					local success, err = pcall(function()
						-- orderedExpStore:SetAsync(player.UserId, level)
						orderedExpMemoryStore:SetAsync(player.UserId, level, 38e5, level)
					end)
					if not success then
						warn(err)
					end
				end
			end)
		end
		expLevelClient:FireClient(player, level)
	end
end

function OpenFunctions.onPlayerRemoving(player)
	-- Set data store key
	if player.UserId > 0 then
		local success, err = pcall(function()
			expStore:SetAsync(player.UserId, playerExp[player.UserId])
			orderedExpStore:SetAsync(player.UserId, calcLevelAndExpWindow(playerExp[player.UserId]).lvl)
		end)
		if not success then
			warn(err)
		end
	end
	-- Clean up entry so that the table doesn't grow for the lifespan of the server
	playerExp[player.UserId] = nil
end

return OpenFunctions
