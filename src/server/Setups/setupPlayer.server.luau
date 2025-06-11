--TODO: Script might be needed down the line
local replicatedStorage = game:GetService("ReplicatedStorage")

local tool = replicatedStorage:WaitForChild("Tools"):WaitForChild("SlapTool")

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
	if not tool then
		print("Tool or slaplogic is not in storage")
		return
	end

	local toolClone = tool:Clone()
	-- local slapLogicClone = slapLogic:Clone()

	-- local handle = toolClone.PrimaryPart
	-- slapLogicClone.Parent = handle
	toolClone.Parent = player.Backpack

	-- Might be usefull later - not good for now
	-- SetupPhysics(char, toolClone)
	-- ignorePhysicsOnOwner(char, handle)
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
