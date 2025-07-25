local offsets = {
	Head = {
		CFrame = {
			-- Attachment on UpperTorso (parent)
			CFrame.new(0, 1.5, 0),
			-- Attachment on Head (child)
			CFrame.new(0, -0.5, 0),
		},
	},

	HumanoidRootPart = {
		CFrame = {
			CFrame.new(0, 0, 0),
			CFrame.new(0, 0, 0),
		},
	},

	UpperTorso = {
		CFrame = {
			-- Parent is HumanoidRootPart
			CFrame.new(0, 0.5, 0),
			-- Child is UpperTorso
			CFrame.new(0, -0.5, 0),
		},
	},

	LowerTorso = {
		CFrame = {
			-- Parent UpperTorso
			CFrame.new(0, -0.5, 0),
			-- Child LowerTorso
			CFrame.new(0, 0.5, 0),
		},
	},

	RightUpperArm = {
		CFrame = {
			-- Parent UpperTorso
			CFrame.new(1.5, 0.5, 0),
			-- Child RightUpperArm
			CFrame.new(-0.5, 0.5, 0),
		},
	},

	RightLowerArm = {
		CFrame = {
			-- Parent RightUpperArm
			CFrame.new(0, -0.5, 0),
			-- Child RightLowerArm
			CFrame.new(0, 0.5, 0),
		},
	},

	RightHand = {
		CFrame = {
			-- Parent RightLowerArm
			CFrame.new(0, -0.5, 0),
			-- Child RightHand
			CFrame.new(0, 0.25, 0),
		},
	},

	LeftUpperArm = {
		CFrame = {
			-- Parent UpperTorso
			CFrame.new(-1.5, 0.5, 0),
			-- Child LeftUpperArm
			CFrame.new(0.5, 0.5, 0),
		},
	},

	LeftLowerArm = {
		CFrame = {
			-- Parent LeftUpperArm
			CFrame.new(0, -0.5, 0),
			-- Child LeftLowerArm
			CFrame.new(0, 0.5, 0),
		},
	},

	LeftHand = {
		CFrame = {
			-- Parent LeftLowerArm
			CFrame.new(0, -0.5, 0),
			-- Child LeftHand
			CFrame.new(0, 0.25, 0),
		},
	},

	RightUpperLeg = {
		CFrame = {
			-- Parent LowerTorso
			CFrame.new(0.5, -1, 0),
			-- Child RightUpperLeg
			CFrame.new(0, 0.5, 0),
		},
	},

	RightLowerLeg = {
		CFrame = {
			-- Parent RightUpperLeg
			CFrame.new(0, -0.5, 0),
			-- Child RightLowerLeg
			CFrame.new(0, 0.5, 0),
		},
	},

	RightFoot = {
		CFrame = {
			-- Parent RightLowerLeg
			CFrame.new(0, -0.5, 0),
			-- Child RightFoot
			CFrame.new(0, 0.25, 0),
		},
	},

	LeftUpperLeg = {
		CFrame = {
			-- Parent LowerTorso
			CFrame.new(-0.5, -1, 0),
			-- Child LeftUpperLeg
			CFrame.new(0, 0.5, 0),
		},
	},

	LeftLowerLeg = {
		CFrame = {
			-- Parent LeftUpperLeg
			CFrame.new(0, -0.5, 0),
			-- Child LeftLowerLeg
			CFrame.new(0, 0.5, 0),
		},
	},

	LeftFoot = {
		CFrame = {
			-- Parent LeftLowerLeg
			CFrame.new(0, -0.5, 0),
			-- Child LeftFoot
			CFrame.new(0, 0.25, 0),
		},
	},
}

return offsets
