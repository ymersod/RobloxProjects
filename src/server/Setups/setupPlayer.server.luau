--TODO: Script might be needed down the line
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local firstTimePlayerStore = DataStoreService:GetDataStore("FirstTimeLogin")
local ServerScriptService = game:GetService("ServerScriptService")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local inventoryFunctions = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local rollTickets = require(ServerScriptService.Server.ServerModuleScripts.rollTickets)

local tool1 = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles"):WaitForChild("CommonStyle0")

local HUMANOID_ROOT_PART_COLLISION_GROUP = "PlayerRootPart"

-- function ignorePhysicsOnOwner(char: Model, hitBox: Part)
-- 	for _, charPart in char:GetDescendants() do
-- 		if charPart:IsA("BasePart") and hitBox:IsA("BasePart") then
-- 			local ncc = Instance.new("NoCollisionConstraint")
-- 			ncc.Part0 = charPart
-- 			ncc.Part1 = hitBox
-- 			ncc.Parent = hitBox -- keep constraints organized
-- 		end
-- 	end
-- end

-- function SetupPhysics(char: Model, toolClone: Tool)
-- 	for _, part in char:GetDescendants() do
-- 		if part:IsA("BasePart") then
-- 			part.CollisionGroup = "Players"
-- 		end
-- 	end

-- 	for _, part in toolClone:GetDescendants() do
-- 		if part:IsA("BasePart") then
-- 			part.CollisionGroup = "MeeleTools"
-- 		end
-- 	end
-- end

function GiveStarterSlapStyle(player: Player)
	inventoryFunctions.AddToInventory(player, tool1, 1)
end

function SetupStarterTools(player: Player)
	if not tool1 then
		print("Tool or slaplogic is not in storage")
		return
	end
	local inventory = player:WaitForChild("Inventory")
	local login = player:WaitForChild("LocalStats"):WaitForChild("FirstTimeLogin") :: StringValue

	local success, loginData = pcall(function()
		return firstTimePlayerStore:GetAsync(player.UserId)
	end)

	local function SetDataStore(enum: string)
		local successI, err = pcall(function()
			return firstTimePlayerStore:SetAsync(player.UserId, enum)
		end)

		if successI then
			if enum == enums.Login.FirstTimeLogin then
				GiveStarterSlapStyle(player)
				rollTickets.AddTickets(player.UserId, 1)
				print("First time player, initializing starter slap-style")
			end
			login.Value = enum
		else
			warn("Error in setting FirstTimeLogin: ", err)
		end
	end

	if inventory and success then
		print("Logindata is: ", loginData)
		if loginData == nil then
			SetDataStore(enums.Login.FirstTimeLogin)
		elseif loginData == enums.Login.FirstTimeLogin or loginData == enums.Login.ConcurrentLogin then
			SetDataStore(enums.Login.ConcurrentLogin)
		end
	else
		warn("Inventory or getting data went wrong in init")
	end
	--inventoryFunctions.EquipTool(player, tool1)
	--inventoryFunctions.AddToInventory(player, tool1)

	--inventoryFunctions.AddToInventory(player, tool2)
end

--TODO: This should be in a setup file for players together with other set ups... well at least the folders i think
game.Players.PlayerAdded:Connect(function(player)
	local playerState = Instance.new("Folder")
	playerState.Name = "States"
	playerState.Parent = player

	local safeState = Instance.new("BoolValue")
	safeState.Name = "Safe"
	safeState.Value = false
	safeState.Parent = playerState

	local jumpState = Instance.new("BoolValue")
	jumpState.Name = "CanJump"
	jumpState.Value = true
	jumpState.Parent = playerState

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	local slotAccess = Instance.new("IntValue")
	slotAccess.Name = "AvailableSlots"
	slotAccess.Value = 1
	slotAccess.Parent = inventory

	local localStats = Instance.new("Folder")
	localStats.Name = "LocalStats"
	localStats.Parent = player
	local levelTest = Instance.new("IntValue")
	levelTest.Name = "Level"
	levelTest.Value = 0
	levelTest.Parent = localStats
	local expBoost = Instance.new("IntValue")
	expBoost.Name = "ExpBoost"
	expBoost.Value = 100
	expBoost.Parent = localStats

	local speedBoost = Instance.new("IntValue")
	speedBoost.Name = "SpeedValue"
	speedBoost.Value = 16
	speedBoost.Parent = localStats
	local jumpBoost = Instance.new("IntValue")
	jumpBoost.Name = "JumpValue"
	jumpBoost.Value = 7.2
	jumpBoost.Parent = localStats
	local tickets = Instance.new("IntValue")
	tickets.Name = "Tickets"
	tickets.Value = 0
	tickets.Parent = localStats

	local login = Instance.new("StringValue")
	login.Name = "FirstTimeLogin"
	login.Value = enums.Login.NotInitYet
	login.Parent = localStats

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "ExpBoost", "sum", 100)
	compIntVal.setBoundTarget(expBoost)
	compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "SpeedValue", "mul", 16)
	compIntVal.setBoundTarget(speedBoost)
	compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "JumpValue", "mul", 7.2)
	compIntVal.setBoundTarget(jumpBoost)

	local character = player.Character or player.CharacterAdded:Wait()
	SetupStarterTools(player)
end)

-- SETUP SERVER SIDE PLAYER CHARACTER
local PhysicsService = game:GetService("PhysicsService")
game.Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character)
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name == "HumanoidRootPart" then
					PhysicsService:SetPartCollisionGroup(part, HUMANOID_ROOT_PART_COLLISION_GROUP)
				else
					PhysicsService:SetPartCollisionGroup(part, "Players")
				end
			end
		end
	end)
end)
