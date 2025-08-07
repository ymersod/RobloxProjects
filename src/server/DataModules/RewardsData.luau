local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.ClientServerModuleScripts.Types)
-- DATA IS PASTED FROM THE DATA FOLDER

local rewards = {}

local rewardsData = [[
{
 "daily": {
    "1":  { "day": 1,  "rewardType": "Ticket", "Amount": 3 },
    "2":  { "day": 2,  "rewardType": "Ticket", "Amount": 3 },
    "3":  { "day": 3,  "rewardType": "Ticket", "Amount": 3 },
    "4":  { "day": 4,  "rewardType": "Ticket", "Amount": 3 },
    "5":  { "day": 5,  "rewardType": "Ticket", "Amount": 3 },
    "6":  { "day": 6,  "rewardType": "Ticket", "Amount": 3 },
    "7":  { "day": 7,  "rewardType": "Ticket", "Amount": 10 },
    "8":  { "day": 8,  "rewardType": "Ticket", "Amount": 3 },
    "9":  { "day": 9,  "rewardType": "Ticket", "Amount": 3 },
    "10": { "day": 10, "rewardType": "Ticket", "Amount": 3 },
    "11": { "day": 11, "rewardType": "Ticket", "Amount": 3 },
    "12": { "day": 12, "rewardType": "Ticket", "Amount": 3 },
    "13": { "day": 13, "rewardType": "Ticket", "Amount": 3 },
    "14": { "day": 14, "rewardType": "Ticket", "Amount": 10 },
    "15": { "day": 15, "rewardType": "Ticket", "Amount": 3 },
    "16": { "day": 16, "rewardType": "Ticket", "Amount": 3 },
    "17": { "day": 17, "rewardType": "Ticket", "Amount": 3 },
    "18": { "day": 18, "rewardType": "Ticket", "Amount": 3 },
    "19": { "day": 19, "rewardType": "Ticket", "Amount": 3 },
    "20": { "day": 20, "rewardType": "Ticket", "Amount": 3 },
    "21": { "day": 21, "rewardType": "Ticket", "Amount": 10 },
    "22": { "day": 22, "rewardType": "Ticket", "Amount": 3 },
    "23": { "day": 23, "rewardType": "Ticket", "Amount": 3 },
    "24": { "day": 24, "rewardType": "Ticket", "Amount": 3 },
    "25": { "day": 25, "rewardType": "Ticket", "Amount": 3 },
    "26": { "day": 26, "rewardType": "Ticket", "Amount": 3 },
    "27": { "day": 27, "rewardType": "Ticket", "Amount": 3 },
    "28": { "day": 28, "rewardType": "Ticket", "Amount": 10 }
  },
"levelUp": {
  "1":  { "level": 10,  "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "2":  { "level": 20,  "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "3":  { "level": 30,  "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "4":  { "level": 40,  "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "5":  { "level": 50,  "rewardType": "Ticket", "Amount": 5, "Stars": 3 },
  "6":  { "level": 60,  "rewardType": "SlotUpgrade", "Amount": 1, "Stars": 3 },
  "7":  { "level": 70,  "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "8":  { "level": 80,  "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "9":  { "level": 90,  "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "10": { "level": 100, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "11": { "level": 110, "rewardType": "Ticket", "Amount": 5, "Stars": 3 },
  "12": { "level": 120, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "13": { "level": 130, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "14": { "level": 140, "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "15": { "level": 150, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "16": { "level": 160, "rewardType": "Ticket", "Amount": 5, "Stars": 3 },
  "17": { "level": 170, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "18": { "level": 180, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "19": { "level": 190, "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "20": { "level": 200, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "21": { "level": 210, "rewardType": "Ticket", "Amount": 5, "Stars": 3 },
  "22": { "level": 220, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "23": { "level": 230, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "24": { "level": 240, "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "25": { "level": 250, "rewardType": "SlotUpgrade", "Amount": 1, "Stars": 3 },
  "26": { "level": 260, "rewardType": "Ticket", "Amount": 5, "Stars": 3 },
  "27": { "level": 270, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "28": { "level": 280, "rewardType": "Ticket", "Amount": 1, "Stars": 1 },
  "29": { "level": 290, "rewardType": "Ticket", "Amount": 3, "Stars": 2 },
  "30": { "level": 300, "rewardType": "Ticket", "Amount": 5, "Stars": 3 }
}
}
]]

local allRewards: Types.RewardsData = HttpService:JSONDecode(rewardsData)

local function convertDictToArray(dict)
	local array = {}
	local keys = {}

	for key in pairs(dict) do
		table.insert(keys, tonumber(key))
	end
	table.sort(keys)

	for _, index in ipairs(keys) do
		array[#array + 1] = dict[tostring(index)]
	end

	return array
end

function rewards.GetDailyRewardsData(): { Types.DailyReward }
	local dailyRewards = convertDictToArray(allRewards.daily)
	return dailyRewards
end

function rewards.GetLevelupRewardsData(): { Types.LevelUpReward }
	local levelupRewards = convertDictToArray(allRewards.levelUp)
	return levelupRewards
end

return rewards
