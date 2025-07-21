-- ModuleScript: PlatformEnum.lua
local enums = {}

enums.Platforms = {
	PC = "PC",
	Mobile = "Mobile",
	Console = "Console",
	Gamepad = "Gamepad",
	Unknown = "Unknown",
}

enums.RewardTypes = {
	Ticket = "Ticket",
}

enums.Login = {
	NotInitYet = "NotInitYet",
	FirstTimeLogin = "FirstTimeLogin",
	ConcurrentLogin = "ConcurrentLogin",
}

enums.Colors = {
	ActiveToolBgGradient = {
		Start = Color3.fromRGB(10, 147, 150),
		End = Color3.fromRGB(0, 95, 115),
	},
	NotUnlockedBpSpace = {
		Color = Color3.fromRGB(155, 34, 38),
	},
	ActiveMenuOption = {
		Color = Color3.fromRGB(10, 147, 150),
	},
	InactiveMenuOption = {
		Color = Color3.fromRGB(238, 155, 0),
	},
	RewardsColors = {
		Claimed = Color3.fromRGB(233, 216, 166),
		NotClaimableGradient = {
			Start = Color3.fromRGB(10, 147, 150),
			End = Color3.fromRGB(0, 95, 115),
		},
		Claimable = Color3.fromRGB(238, 155, 0),
	},
	RarityColor = {
		UnequippedOpacity = 0.4,
		-- Rarities below should match the exact names of possible rarities
		common = {
			Start = Color3.fromRGB(10, 147, 150),
			End = Color3.fromRGB(0, 95, 115),
		},
		uncommon = {
			Start = Color3.fromRGB(148, 210, 189),
			End = Color3.fromRGB(10, 147, 150),
		},
		rare = {
			Start = Color3.fromRGB(174, 32, 18),
			End = Color3.fromRGB(155, 34, 38),
		},
		legendary = {
			Start = Color3.fromRGB(238, 155, 0),
			End = Color3.fromRGB(202, 103, 2),
		},
	},
}

return enums
