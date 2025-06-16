local DataStoreService = game:GetService("DataStoreService")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")

local players = game:GetService("Players")
-- local player = game:GetService("Players").LocalPlayer

backpackPersistenceClone = {}

players.PlayerAdded:Connect(function(player)
    backpackPersistenceClone[player.UserId] = {}
    player.Backpack.ChildAdded:Connect(function(instance)
        if not instance:IsA("Tool") then return end
        if not instance:GetAttribute("ToolId") then return end

        backpackPersistenceClone[player.UserId][#backpackPersistenceClone[player.UserId]] = instance:GetAttribute("ToolId")
    end)
    player.Backpack.ChildRemoved:Connect(function(instance)
        if not instance:IsA("Tool") then return end
        if not instance:GetAttribute("ToolId") then return end

        for i,toolId in ipairs(backpackPersistenceClone[player.UserId]) do
            if toolId == instance:GetAttribute("ToolId") then
                backpackPersistenceClone[player.UserId][i] = nil
            end
            if backpackPersistenceClone[player.UserId][i] == nil and backpackPersistenceClone[player.UserId][i+1] ~= nil then
                backpackPersistenceClone[player.UserId][i] = backpackPersistenceClone[player.UserId][i+1]
                backpackPersistenceClone[player.UserId][i+1] = nil
            end
        end
    end)

    local success, storedInventory = pcall(function()
        return inventoryStore:GetAsync(player.UserId)
    end)
    if success then
        local currentInventory:string
        if storedInventory then
            currentInventory = storedInventory
        else
            currentInventory = ""
        end
        backpackPersistenceClone[player.UserId] = currentInventory:split(",")
        print(currentInventory)
    end
end)

players.PlayerRemoving:Connect(function(player)
    local success, err = pcall(function()
        inventoryStore:SetAsync(player.UserId, table.concat(backpackPersistenceClone[player.UserId],","))
    end)
    if not success then
        warn(err)
    end
    -- Clean up entry so that the table doesn't grow for the lifespan of the server
    backpackPersistenceClone[player.UserId] = nil
end)