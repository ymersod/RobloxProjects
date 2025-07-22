local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local RewardsData = require(ServerScriptService.Server.DataModules.RewardsData)
local rollTickets = require(script.Parent.rollTickets)
local rewardsStore = DataStoreService:GetDataStore("DailyRewards")

local dailyRewardData = RewardsData.GetDailyRewardsData()

dailyRewardFunctions = {}

function dailyRewardFunctions.getAllRewards()
	return "lots a things"
end

function dailyRewardFunctions.getRewardProgress(playerId)
	local success, rewardProgress = pcall(function()
		return rewardsStore:GetAsync(playerId)
	end)
	if success then
		if rewardProgress == nil then
			return { success = true, payload = { lastClaimedDate = "-1", count = "0" } }
		end
		local value = {
			success = true,
			payload = { lastClaimedDate = rewardProgress:split(";")[1], count = rewardProgress:split(";")[2] },
		}
		if
			((tonumber(value.payload.lastClaimedDate) :: number) % 28) + 1 == 0
			or math.floor((tonumber(value.payload.lastClaimedDate) :: number) / 28)
				< math.floor(math.floor(os.time() / 86400) / 28)
		then
			value.payload.count = "0"
		end
		return value
	end
	return { success = false, payload = { lastClaimedDate = "n/a", count = "-1" } }
end

function dailyRewardFunctions.progressRewards(playerId)
	if playerId <= 0 then
		return
	end

	local rewardprogress = dailyRewardFunctions.getRewardProgress(playerId)

	local unixDateToday = math.floor(os.time() / 86400)

	if not rewardprogress.success then
		return { success = false, payload = "Something went wrong" }
	else
		if tonumber(rewardprogress.payload.lastClaimedDate) >= unixDateToday then
			return { success = false, payload = "Already claimed" }
		end
	end

	local newCount = tonumber(rewardprogress.payload.count :: number + 1)
	local success, err = pcall(function()
		return rewardsStore:SetAsync(playerId, unixDateToday .. ";" .. newCount)
	end)
	if success and newCount then
		if dailyRewardData[newCount].rewardType == enums.RewardTypes.Ticket then
			rollTickets.AddTickets(playerId, dailyRewardData[newCount].Amount)
			print("Adding tickets to: ", playerId)
			return { success = true, payload = "Success" }
		else
			return { success = false, payload = "No corresponding rewardstype" }
		end
	end
	return { success = false, payload = err }
end

function dailyRewardFunctions.resetPlayer(playerId)
	local success, err = pcall(function()
		return rewardsStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player reset" }
	end
	return { success = false, payload = err }
end

return dailyRewardFunctions
