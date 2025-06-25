local tool = script.Parent
local remote = tool:FindFirstChild("ActivateAbility")
local coolDown = remote:GetAttribute("cooldown")

if not remote then
	return
end
remote.OnServerEvent:Connect(function(player)
	-- 🔐 Add validation if needed
	print(player.Name .. " activated the jumpnoost using E")
	-- Your server-side logic goes here
end)
