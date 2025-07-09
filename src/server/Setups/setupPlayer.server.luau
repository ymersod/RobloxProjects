--TODO: Script might be needed down the line
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local inventoryFunctions = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)

local tool1 = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles"):WaitForChild("CommonStyle0")

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

-- TODO: This should only be done if player is a first time login (has no saved slapstyles)

function GiveStarterSlapStyle(player: Player)
	inventoryFunctions.AddToInventory(player, tool1, 1)
end

function SetupStarterTools(player: Player)
	if not tool1 then
		print("Tool or slaplogic is not in storage")
		return
	end
	local inventory = player:WaitForChild("Inventory")
	if inventory then
		local inventoryList = inventory:GetChildren()

		if #inventoryList == 1 then
			GiveStarterSlapStyle(player)
			print("First time player, initializing starter slap-style")
		else
			print("Player already has inventory, brrrr")
		end
	else
		GiveStarterSlapStyle(player)
		warn("Inventory not found, initializing starter slap-style")
	end
	--inventoryFunctions.EquipTool(player, tool1)
	--inventoryFunctions.AddToInventory(player, tool1)

	--inventoryFunctions.AddToInventory(player, tool2)
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	local character = player.Character or player.CharacterAdded:Wait()
	SetupStarterTools(player)

	-- if not character:FindFirstChildOfClass("Humanoid") then
	-- 	return
	-- end
	-- local humanoidLoaded = character:WaitForChild("Humanoid")
	-- humanoidLoaded.MaxSlopeAngle = 45
end)

--TODO: This should be in a setup file for players together with other set ups... well at least the folders i think
game.Players.PlayerAdded:Connect(function(player)
	local playerState = Instance.new("Folder")
	playerState.Name = "States"
	playerState.Parent = player
	local safeState = Instance.new("BoolValue")
	safeState.Name = "Safe"
	safeState.Value = false
	safeState.Parent = playerState

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player
	local slotAccess = Instance.new("IntValue")
	slotAccess.Name = "AvailableSlots"
	slotAccess.Value = 2
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

	local compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "ExpBoost", "sum", 100)
	compIntVal.setBoundTarget(expBoost)
	compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "SpeedValue", "mul", 16)
	compIntVal.setBoundTarget(speedBoost)
	compIntVal = compositeIntValueMultiton.getCompositeIntValue(player.UserId .. "JumpValue", "mul", 7.2)
	compIntVal.setBoundTarget(jumpBoost)
end)
