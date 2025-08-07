local PhysicsService = game:GetService("PhysicsService")
local IsSafeUtil = require(script.Parent.IsSafeUtil)

local killPlayerModule = {}

function killPlayerModule.killPlayer(player: Player)
	if IsSafeUtil.IsSafeFromAll(player) then
		return
	end

	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	hum.Health = 0
	for _, part in char:GetDescendants() do
		if part:IsA("BasePart") and part.Parent == char and not part:HasTag("KingCrown") then
			-- SetCollisionGroupName is a method of PhysicsService
			part.CanCollide = true
			PhysicsService:SetPartCollisionGroup(part, "RagdollCollide")
		end
	end

	for _, motor in char:GetDescendants() do
		if motor:IsA("Motor6D") then
			motor.Enabled = false
		end
	end
	-- ragdollUtils.ragdoll(player, Vector3.zero, 5)
end

return killPlayerModule
