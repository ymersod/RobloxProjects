local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValue = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValue)

local functions = {}

local intValueInstances = {}

function functions.getCompositeIntValue(key:string, initValue:number?)
	if not intValueInstances[key] then
		if initValue then
			intValueInstances[key] = compositeIntValue.new(initValue)
		else
			intValueInstances[key] = compositeIntValue.new()
		end
	end

	return intValueInstances[key]
end

function functions.removeCompositeIntValue(key:string)
	if intValueInstances[key] then
		intValueInstances[key] = nil
	end
end

return functions