--TODO: Script might be needed down the line
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local tool1 = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles"):WaitForChild("CommonStyle0")
local tool2 = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles"):WaitForChild("CommonStyle1")
local inventoryFunctions = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

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

function SetupStarterTools(player)
	if not tool1 and tool2 then
		print("Tool or slaplogic is not in storage")
		return
	end

	inventoryFunctions.EquipTool(player, tool1)
	inventoryFunctions.AddToInventory(player, tool1)

	inventoryFunctions.AddToInventory(player, tool2)
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		SetupStarterTools(player)

		if not char:FindFirstChildOfClass("Humanoid") then
			return
		end
		local humanoidLoaded = char:WaitForChild("Humanoid")
		humanoidLoaded.MaxSlopeAngle = 45
	end)
end)
