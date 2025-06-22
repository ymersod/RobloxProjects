local safezone = script.Parent
local playersTouching = {}

safezone.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and not playersTouching[player] then
		player.States.Safe.Value = true
		playersTouching[player] = true
	end
end)

safezone.TouchEnded:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and playersTouching[player] then
		player.States.Safe.Value = false
		playersTouching[player] = nil
	end
end)
