local velocityUtils = {}

function velocityUtils.applyKnockback(parent, knockVelocity: Vector3, duration: number?)
	duration = duration or 0.1

	local knockBackVelocity = Instance.new("BodyVelocity")
	knockBackVelocity.Velocity = knockVelocity
	knockBackVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e5
	knockBackVelocity.P = 1e4
	knockBackVelocity.Parent = parent
	game:GetService("Debris"):AddItem(knockBackVelocity, duration)
end

return velocityUtils
