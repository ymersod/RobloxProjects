local players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local expManagerFunctions = require(ServerScriptService.Server.ServerModuleScripts.expManagerFunctions)

local part: Part = script.Parent

part.Touched:Connect(function(humanoidRootPart: BasePart)
	if humanoidRootPart.CollisionGroup ~= "Players" or humanoidRootPart.Name ~= "HumanoidRootPart" then
		return
	end
end)

function ZoneMainLoop()
	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = "Zone"
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	while true do
		task.wait(1)

		local playerParts = workspace:GetPartsInPart(part, overlapParams)

		for i, humanoidRootPart in ipairs(playerParts) do
			local player = players:GetPlayerFromCharacter(humanoidRootPart.Parent)
			if player then
				local xpBoost = 1
				local xpBoostIntValue: IntValue = player:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
				if xpBoostIntValue then
					xpBoost = xpBoostIntValue.Value / 100
				end

				expManagerFunctions.incrementExp(player.UserId, 1 * xpBoost)
			end
		end
	end
end

ZoneMainLoop()
