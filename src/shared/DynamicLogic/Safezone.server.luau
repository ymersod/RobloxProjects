local safezone = script.Parent
local playersTouching = {}

safezone.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and not playersTouching[player] then
		player.States.Safe.Value = true
		playersTouching[player] = true
		print(player.Name .. " has entered this realm of safety")
	elseif player then
		print(player.Name .. " is still in the realm of safety")
	end
end)

safezone.TouchEnded:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player and playersTouching[player] then
		player.States.Safe.Value = false
		playersTouching[player] = nil
		print(player.Name .. " entered the realm of CHAOS")
	end
end)
