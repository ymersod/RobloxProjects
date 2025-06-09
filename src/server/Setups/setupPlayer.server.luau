local replicatedStorage = game:GetService("ReplicatedStorage")

local tool = replicatedStorage:WaitForChild("Tools"):WaitForChild("SlapTool")
local slapLogic = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if not tool and not slapLogic then
			print("Tool or slaplogic is not in storage")
			return
		end

		local toolClone = tool:Clone()
		local slapLogicClone = slapLogic:Clone()

		local handle = toolClone.PrimaryPart
		slapLogicClone.Parent = handle
		toolClone.Parent = player.Backpack
	end)
end)
