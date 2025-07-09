local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RewardsData = require(ServerScriptService.Server.DataModules.RewardsData)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local expManagerFunctions = require(script.Parent.expManagerFunctions)
local rollTickets = require(script.Parent.rollTickets)
local rewardsStore = DataStoreService:GetDataStore("LevelupRewards")

local levelUpRewardsData = RewardsData.GetLevelupRewardsData()

local levelupRewardsFunctions = {}

function levelupRewardsFunctions.getRewardProgress(playerId)
	local success, rewardProgress = pcall(function()
		return rewardsStore:GetAsync(playerId)
	end)

	if success then
		if rewardProgress == nil then
			return { success = true, payload = { lastClaimedLevel = "0", count = "0" } }
		end
		local value = {
			success = true,
			payload = { lastClaimedLevel = rewardProgress:split(";")[1], count = rewardProgress:split(";")[2] },
		}

		return value
	end

	return { success = false, payload = { lastClaimedLevel = "-1", count = "-1" } }
end

function levelupRewardsFunctions.progressRewards(playerId)
	if playerId <= 0 then
		return
	end

	local rewardprogress = levelupRewardsFunctions.getRewardProgress(playerId)
	local payload = expManagerFunctions.GetLevel(playerId)
	if not rewardprogress or not payload then
		return { success = false, payload = "Something went wrong" }
	end

	local lastClaimableLevel = math.floor(payload.lvl / 10) * 10
	print(
		"Lastclaimablelevel: " .. lastClaimableLevel .. "LastClaimedLevel: ",
		tonumber(rewardprogress.payload.lastClaimedLevel)
	)
	if lastClaimableLevel <= tonumber(rewardprogress.payload.lastClaimedLevel) then
		return { success = false, payload = "No new claims" }
	end

	local newCount = tonumber(rewardprogress.payload.count :: number + 1)
	local success, err = pcall(function()
		return rewardsStore:SetAsync(
			playerId,
			(tonumber(rewardprogress.payload.lastClaimedLevel) :: number + 10) .. ";" .. newCount
		)
	end)
	if success then
		if levelUpRewardsData[newCount].rewardType == enums.RewardTypes.Ticket then
			rollTickets.AddTickets(playerId, levelUpRewardsData[newCount].Amount)
			return { success = true, payload = "Success" }
		else
			return { success = false, payload = "No corresponding rewardstype" }
		end
	end
	return { success = false, payload = err }
end

function levelupRewardsFunctions.resetPlayer(playerId)
	local success, err = pcall(function()
		return rewardsStore:RemoveAsync(playerId)
	end)
	if success then
		return { success = true, payload = "player reset" }
	end
	return { success = false, payload = err }
end

return levelupRewardsFunctions
