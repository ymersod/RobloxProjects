local DataStoreService = game:GetService("DataStoreService")
local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")

local players = game:GetService("Players")

local slapStyleFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")

local inventoryFunctionsScript = game:GetService("ServerScriptService")
	:WaitForChild("Server")
	:WaitForChild("ServerModuleScripts")
	:WaitForChild("inventoryFunctions")
local inventoryFunctions = require(inventoryFunctionsScript)

local backpackPersistenceClone = {}

players.PlayerAdded:Connect(function(player)
	backpackPersistenceClone[player.UserId] = {}

	player:WaitForChild("Inventory").ChildAdded:Connect(function(instance)
		local bp = inventoryFunctions.GetInventory(player)
		if not instance:IsA("Tool") then
			return
		end
		if not instance:GetAttribute("ToolId") and not instance:GetAttribute("SaveSlot") then
			return
		end

		-- Rebuild backpackPersistenceClone from bp
		backpackPersistenceClone[player.UserId] = {}
		for _, tool in ipairs(bp) do
			if tool:IsA("Tool") and tool:GetAttribute("ToolId") and tool:GetAttribute("SaveSlot") then
				local entry = tool:GetAttribute("SaveSlot") .. "," .. tool:GetAttribute("ToolId")
				table.insert(backpackPersistenceClone[player.UserId], entry)
			end
		end
	end)

	player:WaitForChild("Inventory").ChildRemoved:Connect(function(instance)
		local bp = inventoryFunctions.GetInventory(player)
		if not instance:IsA("Tool") then
			warn("Not a tool?: ", instance)
			return
		end

		if not instance:GetAttribute("ToolId") and not instance:GetAttribute("SaveSlot") then
			warn("Tool doesn't have correct attributes?: ", instance)
			return
		end

		-- Rebuild backpackPersistenceClone from bp
		backpackPersistenceClone[player.UserId] = {}
		for _, tool in ipairs(bp) do
			if tool:IsA("Tool") and tool:GetAttribute("ToolId") and tool:GetAttribute("SaveSlot") then
				local entry = tool:GetAttribute("SaveSlot") .. "," .. tool:GetAttribute("ToolId")
				table.insert(backpackPersistenceClone[player.UserId], entry)
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
		local slapstyles = slapStyleFolder:GetDescendants()
		local split = currentInventory:split("--")
		if #split > 1 and split[2] then
			local inventory = player:FindFirstChild("Inventory") :: Folder?
			local value = inventory:FindFirstChildOfClass("IntValue")
			value.Value = tonumber(split[2])
		end
		for _, itemId in ipairs(split[1]:split(";")) do
			local itemValues = itemId:split(",")
			for _, style in ipairs(slapstyles) do
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
		local inventory = player:FindFirstChild("Inventory") :: Folder?
		local value = inventory:FindFirstChildOfClass("IntValue")

		print(
			"saving: "
				.. table.concat(backpackPersistenceClone[player.UserId], ";")
				.. if value then "--" .. value.Value else ""
		)

		-- saving as: {SaveSlot},{ToolId};{SaveSlot},{ToolId}...--{inventorySlots}
		inventoryStore:SetAsync(
			player.UserId,
			table.concat(backpackPersistenceClone[player.UserId], ";") .. if value then "--" .. value.Value else ""
		)
	end)
	if not success then
		warn(err)
	end
	-- Clean up entry so that the table doesn't grow for the lifespan of the server
	backpackPersistenceClone[player.UserId] = nil
end)
