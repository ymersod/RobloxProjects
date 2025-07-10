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

return enums
