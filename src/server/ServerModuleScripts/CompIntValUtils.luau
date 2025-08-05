local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)
local types = require(ServerScriptService.Server.ServerModuleScripts.CompIntValTypes)
local Utils = {}

function Utils.makeKey(player, suffix)
	local playerId = player and player.UserId
	if not playerId then
		print("No playerId or player found on " .. player)
		return
	end
	return playerId .. suffix
end

function Utils.makeKeyForCompIntNaming(player, suffix: types.CompIntIdSuffixes)
	Utils.makeKey(player, suffix)
end

function Utils.applyModifier(player, suffix: types.CompIntIdSuffixes, boost: types.CompModifier)
	local compIntValue = compositeIntValueMultiton.getCompositeIntValue(Utils.makeKey(player, suffix))
	print(compIntValue)
	if compIntValue and not compIntValue.containsMod(boost.Name) then
		compIntValue.addModifier(boost)
	end
end

function Utils.removeModifier(player, suffix: types.CompIntIdSuffixes, boost: types.CompModifier)
	local compIntValue = compositeIntValueMultiton.getCompositeIntValue(Utils.makeKey(player, suffix))
	if compIntValue and compIntValue.containsMod(boost.Name) then
		compIntValue.removeModifier(boost.Name)
	end
end

return Utils
