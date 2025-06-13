local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local expLevelClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpLevelClient")

local expStore = DataStoreService:GetDataStore("PlayerExp")

local OpenFunctions = {}

-- Add Exp values for each player to a local table to avoid hitting the data
-- store repeatedly.
local playerExp = {}

local function calcLevelAndExpWindow(exp:number):{lvl:number,lvlProgress:{progress:number,goal:number}}
    local lvl = math.max(0, math.floor(-95.04+20.25*math.log(exp+109)))
    local oldGoal = math.floor(math.pow(2.718, ((lvl)+95.04)/20.25))-109
    local goal = math.floor(math.pow(2.718, ((lvl+1)+95.04)/20.25))-109

    -- print("lvl: " .. lvl)
    -- print("lvl goal: " .. oldGoal)
    -- print("next lvl goal: " .. goal)
    -- print("progress: " .. (exp-oldGoal)/(goal-oldGoal))

    return { lvl = lvl, lvlProgress = { progress = exp-oldGoal, goal = goal-oldGoal }}
end

function OpenFunctions.incrementExp(playerId, amount)
    print("incrementing score for player with id: " .. playerId)
    if playerExp[playerId] then
        playerExp[playerId] += amount

        local success, player = pcall(function()
            return Players:GetPlayerByUserId(playerId)
        end)
        if success then
            expLevelClient:FireClient(player,calcLevelAndExpWindow(playerExp[playerId]))
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
            expLevelClient:FireClient(player,calcLevelAndExpWindow(playerExp[playerId]))
        end
    end
end

function OpenFunctions.getExp(playerId)
    return playerExp[playerId]
end

function OpenFunctions.onPlayerAdded(player)
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
    end

    -- Test incrementing Exp
    OpenFunctions.incrementExp(player.UserId, 5)
end

function OpenFunctions.onPlayerRemoving(player)
    -- Set data store key
    local success, err = pcall(function()
        expStore:SetAsync(player.UserId, playerExp[player.UserId])
    end)
    if not success then
        warn(err)
    end
    -- Clean up entry so that the table doesn't grow for the lifespan of the server
    playerExp[player.UserId] = nil
end

return OpenFunctions
