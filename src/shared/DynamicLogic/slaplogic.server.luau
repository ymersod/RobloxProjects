local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local part = script.Parent :: Part

local POWER_MULT = 1000

local debounce = {}

part.Touched:Connect(function(hit: BasePart)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return
	end

	local targetPlayer = game.Players:GetPlayerFromCharacter(character)
	if not targetPlayer then
		return
	end

	if debounce[targetPlayer] then
		return
	end
	debounce[targetPlayer] = true
	task.delay(1, function()
		debounce[targetPlayer] = nil
	end)

	local rootPart: Part = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local hitDirection = (rootPart.Position - part.Position).Unit * POWER_MULT
	print("Hitting from direction: ", hitDirection)
	ragdollClientEvent:FireClient(targetPlayer, hit.Position, hitDirection)
end)
