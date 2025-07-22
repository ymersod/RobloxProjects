local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Gravity = workspace.Gravity -- usually 196.2
local CHECK_INTERVAL = 0.1
local movingPlatforms = CollectionService:GetTagged("MovingPlatform")

for _, platform in movingPlatforms do
	local to = platform:FindFirstChild("To")
	local from = platform:FindFirstChild("From")
	local MOVE_SPEED = platform:GetAttribute("Speed")

	if to and from and MOVE_SPEED then
		-- Cache world positions so they don't move with the platform
		local toPosition = to.Position
		local fromPosition = from.Position

		-- Setup: Unanchor and give server control
		platform.Anchored = false
		platform:SetNetworkOwner(nil)

		-- 🔧 Anti-Gravity Setup
		local gravityAttachment = Instance.new("Attachment")
		gravityAttachment.Name = "AntiGravityAttachment"
		gravityAttachment.Parent = platform

		local antiGravityForce = Instance.new("VectorForce")
		antiGravityForce.Name = "AntiGravityForce"
		antiGravityForce.Attachment0 = gravityAttachment
		antiGravityForce.Force = Vector3.new(0, platform:GetMass() * Gravity, 0)
		antiGravityForce.ApplyAtCenterOfMass = true
		antiGravityForce.RelativeTo = Enum.ActuatorRelativeTo.World
		antiGravityForce.Parent = platform

		-- 🔒 Lock orientation
		local alignAttachment = Instance.new("Attachment")
		alignAttachment.Name = "RotationLockAttachment"
		alignAttachment.Parent = platform

		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Attachment0 = alignAttachment
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.RigidityEnabled = true
		alignOrientation.Responsiveness = 200
		alignOrientation.CFrame = CFrame.new()
		alignOrientation.Parent = platform

		-- 🚀 Movement logic
		task.spawn(function()
			local currentTarget = toPosition
			local nextTarget = fromPosition

			while true do
				local pos = platform.Position
				local direction = (currentTarget - pos)
				local distance = direction.Magnitude

				if distance < 1 then
					platform.AssemblyLinearVelocity = Vector3.zero
					task.wait(0.5)
					currentTarget, nextTarget = nextTarget, currentTarget
				else
					local velocity = direction.Unit * MOVE_SPEED
					platform.AssemblyLinearVelocity = velocity
				end

				task.wait(CHECK_INTERVAL)
			end
		end)
	else
		warn("To and From not set or Speed missing for", platform:GetFullName())
	end
end
