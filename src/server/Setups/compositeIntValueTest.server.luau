local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValue = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValue)

local intValue = compositeIntValue.new()

intValue += {Name = "XpBoost", Value = 3}
intValue += {Name = "SpeedBoost", Value = 5}
intValue -= {Name = "SpeedBoost", Value = 2}
intValue -= {Name = "SpeedBoost", Value = 3}
print(intValue.Value)

local intValue2 = compositeIntValue.new(2)

intValue2 += {Name = "Value", Value = 8}
intValue2 -= {Name = "Value2", Value = 5}
print(intValue2.Value)
