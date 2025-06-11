local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local expStore = DataStoreService:GetDataStore("PlayerExp")

local OpenFunctions = {}

-- Add Exp values for each player to a local table to avoid hitting the data
-- store repeatedly.
local playerExp = {}

function OpenFunctions.incrementExp(playerId, amount)
    print(playerId)
    if playerExp[playerId] then
        playerExp[playerId] += amount
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
