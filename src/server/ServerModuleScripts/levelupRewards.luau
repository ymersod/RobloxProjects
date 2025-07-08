local DataStoreService = game:GetService("DataStoreService")
local expManagerFunctions = require(script.Parent.expManagerFunctions)
local rollTickets = require(script.Parent.rollTickets)
local rewardsStore = DataStoreService:GetDataStore("LevelupRewards")

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

	local success, err = pcall(function()
		return rewardsStore:SetAsync(
			playerId,
			(tonumber(rewardprogress.payload.lastClaimedLevel) :: number + 10)
				.. ";"
				.. (tonumber(rewardprogress.payload.count) :: number + 1)
		)
	end)
	if success then
		--TODO: needs a some form of data to read rewards from
		--TODO: can only get tickets with this apporach
		rollTickets.AddTickets(playerId, 1)
		return { success = true, payload = "Success" }
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
-- TODO: resetplayerlevel should also reset leveluprewards

return levelupRewardsFunctions
