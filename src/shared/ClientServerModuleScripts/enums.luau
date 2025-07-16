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
}

return enums
