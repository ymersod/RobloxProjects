local ServerScriptService = game:GetService("ServerScriptService")
local compositIntValue = require(ServerScriptService.Server.ServerModuleScripts.CompositIntValue)

local intValue = compositIntValue.new()

intValue += {Name = "XpBoost", Value = 3}
intValue += {Name = "SpeedBoost", Value = 5}
intValue -= {Name = "SpeedBoost", Value = 2}
intValue -= {Name = "SpeedBoost", Value = 3}
print(intValue.Value)

local intValue2 = compositIntValue.new(2)

intValue2 += {Name = "Value", Value = 8}
intValue2 -= {Name = "Value2", Value = 5}
print(intValue2.Value)
