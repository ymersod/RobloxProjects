local ragdollModule = {}

function ragdollModule.Ragdoll(char: Model)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if humanoid then
		humanoid.UnequipTools(humanoid)

		if humanoid and hrp then
			humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
			local mass = hrp.AssemblyMass

			local force = Vector3.new(1000, 1000, 0) * mass
			local vf2 = Instance.new("VectorForce")
			vf2.ApplyAtCenterOfMass = true
			vf2.Attachment0 = hrp.RootAttachment
			vf2.Force = force
			vf2.Parent = hrp
			task.wait(0.1)
			vf2:Destroy()
			task.wait(2)
		end
	end
end

return ragdollModule
