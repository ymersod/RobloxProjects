local DataStoreService = game:GetService("DataStoreService")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")

local players = game:GetService("Players")

local slapStyleFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")

local inventoryFunctionsScript = game:GetService("ServerScriptService")
	:WaitForChild("Server")
	:WaitForChild("ServerModuleScripts")
	:WaitForChild("inventoryFunctions")
local inventoryFunctions = require(inventoryFunctionsScript)

backpackPersistenceClone = {}

players.PlayerAdded:Connect(function(player)
	backpackPersistenceClone[player.UserId] = {}
	player:WaitForChild("Inventory").ChildAdded:Connect(function(instance)
		if not instance:IsA("Tool") then
			return
		end
		if not instance:GetAttribute("ToolId") and not instance:GetAttribute("SaveSlot") then
			return
		end

		print("adding tool: " .. instance:GetAttribute("ToolId"))
		backpackPersistenceClone[player.UserId][#backpackPersistenceClone[player.UserId] + 1] = instance:GetAttribute(
			"SaveSlot"
		) .. "," .. instance:GetAttribute("ToolId")
	end)
	player:WaitForChild("Inventory").ChildRemoved:Connect(function(instance)
		if not instance:IsA("Tool") then
			return
		end
		if not instance:GetAttribute("ToolId") and not instance:GetAttribute("SaveSlot") then
			return
		end

		for i, toolId in ipairs(backpackPersistenceClone[player.UserId]) do
			print("trying to remove tool: " .. toolId)
			if
				tonumber(toolId:split(",")[1]) == instance:GetAttribute("SaveSlot")
				and toolId:split(",")[2] == instance:GetAttribute("ToolId")
			then
				backpackPersistenceClone[player.UserId][i] = nil
			end
			if
				backpackPersistenceClone[player.UserId][i] == nil
				and backpackPersistenceClone[player.UserId][i + 1] ~= nil
			then
				backpackPersistenceClone[player.UserId][i] = backpackPersistenceClone[player.UserId][i + 1]
				backpackPersistenceClone[player.UserId][i + 1] = nil
			end
		end
	end)

	local success, storedInventory = pcall(function()
		return inventoryStore:GetAsync(player.UserId)
	end)
	if success then
		local currentInventory: string
		if storedInventory then
			currentInventory = storedInventory
		else
			currentInventory = ""
		end
		print(currentInventory)
		local slapstyles = slapStyleFolder:GetDescendants()
		local split = currentInventory:split("--")
		if #split > 1 and split[2] then
			print("amount of slots")
			local inventory = player:FindFirstChild("Inventory") :: Folder?
			local value = inventory:FindFirstChildOfClass("IntValue")
			value.Value = tonumber(split[2])
		end
		for i, itemId in ipairs(split[1]:split(";")) do
			print("trying to instantiate tool:" .. itemId)
			local itemValues = itemId:split(",")
			for j, style in ipairs(slapstyles) do
				if #itemValues > 1 and itemValues[2] == style:GetAttribute("ToolId") then
					inventoryFunctions.AddToInventory(player, style, tonumber(itemValues[1]) :: number)
				end
			end
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	if player.UserId <= 0 then
		backpackPersistenceClone[player.UserId] = nil
		return
	end

	local success, err = pcall(function()
		print("saving: " .. table.concat(backpackPersistenceClone[player.UserId], ";"))

		local inventory = player:FindFirstChild("Inventory") :: Folder?
		local value = inventory:FindFirstChildOfClass("IntValue")

		-- saving as: {SaveSlot},{ToolId};{SaveSlot},{ToolId}...--{inventorySlots}
		inventoryStore:SetAsync(player.UserId, table.concat(backpackPersistenceClone[player.UserId], ";") .. if value then "--" .. value.Value else "")
	end)
	if not success then
		warn(err)
	end
	-- Clean up entry so that the table doesn't grow for the lifespan of the server
	backpackPersistenceClone[player.UserId] = nil
end)
