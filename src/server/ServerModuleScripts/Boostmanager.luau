local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local BoostTypes = require(script.Parent.BoostTypes)

-- should not be set like this
local baseTable = {
	SpeedValue = 16,
	JumpValue = 7,
	ExpBoost = 100,
}
local boostManager = {}

local callBacks: { [string]: { (() -> ())? } } = {}

local function applyBoostWithDelay(statName: BoostTypes.BoostTypes, amount: number, delayTime: number, localStats)
	local stat: IntValue? = localStats and localStats:FindFirstChild(statName)
	if not stat then
		warn(statName:upper() .. " NOT FOUND ERR")
		return
	end

	if amount < 1 then
		local newValue = math.floor(stat.Value * amount)
		local diff = stat.Value - newValue
		stat.Value = newValue

		task.delay(delayTime, function()
			print("Setting: " .. statName .. " to " .. stat.Value + diff)
			stat.Value = stat.Value + diff
		end)
	else
		local baseVal = baseTable[statName]
		local diff = math.floor(baseVal * amount) - baseVal
		local newValue = stat.Value + diff
		print("Setting: " .. statName .. " to " .. newValue)
		stat.Value = newValue

		task.delay(delayTime, function()
			print("Setting: " .. statName .. " to " .. stat.Value - diff)
			stat.Value = stat.Value - diff
		end)
	end
end

local function applyBoostWithCallback(statName: BoostTypes.BoostTypes, amount: number, localStats): (() -> ())?
	local stat: IntValue? = localStats and localStats:FindFirstChild(statName)
	if not stat then
		warn(statName:upper() .. " NOT FOUND ERR")
		return
	end

	if amount < 1 then
		local newValue = math.floor(stat.Value * amount)
		local diff = stat.Value - newValue
		stat.Value = newValue
		return function()
			print("Setting: " .. statName .. " to " .. stat.Value - diff)
			stat.Value = stat.Value + diff
		end
	else
		local baseVal = baseTable[statName]
		local diff = math.floor(baseVal * amount) - baseVal
		local newValue = stat.Value + diff
		print("Setting: " .. statName .. " to " .. newValue)
		stat.Value = newValue
		return function()
			print("Setting: " .. statName .. " to " .. stat.Value - diff)
			stat.Value = stat.Value - diff
		end
	end
end

function boostManager.RemoveBoost(key: string)
	print("brr")
	local funcs = callBacks[key]
	if funcs then
		for _, callback in ipairs(funcs) do
			if callback then
				callback()
			end
		end
		callBacks[key] = nil
	end
end

function boostManager.AddBoost(
	player: Player,
	type: BoostTypes.BoostTypes,
	method: BoostTypes.BoostMethod,
	amount: number,
	delay: number?
): string?
	local localStats = player:FindFirstChild("LocalStats")
	if method == "delay" then
		if delay then
			applyBoostWithDelay(type, amount, delay, localStats)
		else
			warn("Delay not set")
		end
	elseif method == "callback" then
		local callBack = applyBoostWithCallback(type, amount, localStats)

		if callBack then
			local key = HttpService:GenerateGUID(false) .. "-" .. player.UserId .. "-" .. type
			callBacks[key] = { callBack }

			return key
		end
	else
		warn("Method for boosts not found")
	end

	return nil
end

-- Cleanup if player left
local function onPlayerRemoving(player: Player)
	local userIdStr = tostring(player.UserId)

	for key, _ in pairs(callBacks) do
		if key:sub(-#userIdStr) == userIdStr then
			print("Player " .. userIdStr .. " left, removing key: " .. key)
			callBacks[key] = nil
		end
	end
end

Players.PlayerRemoving:Connect(onPlayerRemoving)

return boostManager
