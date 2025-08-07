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
	SlotUpgrade = "SlotUpgrade",
}

enums.Login = {
	NotInitYet = "NotInitYet",
	FirstTimeLogin = "FirstTimeLogin",
	ConcurrentLogin = "ConcurrentLogin",
}

enums.abilityTypes = {
	gyat = "gyat",
	slimy = "slimy",
	spawnPoop = "spawnPoop",
	hell = "hell",
	bat = "bat",
	bomb = "bomb",
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
		ActiveBackGlowOpacity = 0.1,
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
	abilitiy = {
		InactiveOpacity = 0.5,
		Active = Color3.fromRGB(174, 32, 18),
		Inactive = Color3.fromRGB(59, 56, 56),
	},
	LeaderboardColors = {
		Opacity = 0.7,
		Uneven = Color3.fromRGB(255, 255, 255),
		Even = Color3.fromRGB(130, 130, 130),
	},
}

return enums
