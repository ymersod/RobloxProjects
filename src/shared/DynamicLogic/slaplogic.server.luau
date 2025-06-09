local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local part = script.Parent :: Part
local ragdollModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("ragdollPlayer"))
local killModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("killPlayer"))

part.Touched:Connect(function(col: BasePart)
	local char = col:FindFirstAncestorOfClass("Model")
	if not char then
		return
	end

	local player = players:GetPlayerFromCharacter(char)

	if player then
		ragdollModule.Ragdoll(char, player)
		-- killModule.killPlayer(char, player)
	else
		print("Didnt touch player")
	end
end)
