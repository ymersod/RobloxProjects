local ServerStorage = game:GetService("ServerStorage")

local kingCoin = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin") :: Part
if not kingCoin then
	error("Missing KingCoin in ServerStorage.Pickups")
end

local funcs = {}

local MAX_AMOUNT_OF_COIN_DROP_ON_INTERACT: number = 50
local COIN_DROP_OFF_PERCENT: number = 0.50

local function adjustValueRangeForMaxCoins(valueMin: number, valueMax: number, totalDropAmount: number)
	local maxPossibleAmountOfCoins = math.ceil(totalDropAmount / valueMin)
	if maxPossibleAmountOfCoins > MAX_AMOUNT_OF_COIN_DROP_ON_INTERACT then
		local dif = valueMax - valueMin
		valueMin = math.floor(totalDropAmount / MAX_AMOUNT_OF_COIN_DROP_ON_INTERACT)
		valueMax = valueMin + dif
	end
	return { valueMin = valueMin, valueMax = valueMax }
end

function funcs.processKingCoinDrainAmount(kingScore: IntValue, drainPercent: number): number
	local totalToDrain = math.round(kingScore.Value * drainPercent)
	kingScore.Value -= totalToDrain
	local dropAmount = math.round(totalToDrain * COIN_DROP_OFF_PERCENT)
	return dropAmount
end

function funcs.spawnKingCoinFromPlayer(value: number, player: Player, SPAWN_RADIUS: number)
	if not (player.Character and player.Character.PrimaryPart) then
		return
	end
	local coinClone = kingCoin:Clone()
	coinClone.Parent = workspace
	coinClone.Position = player.Character.PrimaryPart.Position
		+ Vector3.new(math.random(-SPAWN_RADIUS, SPAWN_RADIUS), 0, math.random(-SPAWN_RADIUS, SPAWN_RADIUS))
	local coinLogic: Script? = coinClone:FindFirstChildOfClass("Script")
	local coinScore: IntValue? = coinClone:FindFirstChild("Coin score")
	if not coinLogic then
		warn("Cant find coin logic")
		return
	end
	if not coinScore then
		warn("Cant find coin score")
		return
	end

	if coinScore then
		coinScore.Value = value
	end

	coinLogic.Enabled = true
end

function funcs.spawnKingCoinFromRandomPlayer(
	players: { Player },
	totalToDrop: number,
	valueMin: number,
	valueMax: number,
	spawnRadius: number
)
	if totalToDrop < 1 then
		print("Total coin amount is no acceptable for spawn: " .. totalToDrop)
	end
	local dropped = 0

	while dropped < totalToDrop do
		local randomVariants = math.round(math.random(valueMin, valueMax))

		if dropped + randomVariants > totalToDrop then
			randomVariants = totalToDrop - dropped
		end

		dropped += randomVariants
		funcs.spawnKingCoinFromPlayer(randomVariants, players[math.random(1, #players)], spawnRadius)
	end
end

function funcs.spawnMultipleKingCoinOfSizeRangesFromPlayer(
	player: Player,
	spawnRadius: number,
	drainPercent: number,
	valueMin: number,
	valueMax: number
)
	funcs.spawnMultipleKingCoinOfSizeRangesFromPlayers({ player }, spawnRadius, drainPercent, valueMin, valueMax)
end

function funcs.spawnMultipleKingCoinOfSizeRangesFromPlayers(
	players: { Player },
	spawnRadius: number,
	drainPercent: number,
	valueMin: number,
	valueMax: number
)
	if #players == 0 then
		return
	end
	local totalDropAmount = 0
	for _, player in ipairs(players) do
		local leaderstats = player:FindFirstChild("leaderstats")
		local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")
		if kingScore then
			totalDropAmount += funcs.processKingCoinDrainAmount(kingScore, drainPercent)
		end
	end
	local constraints = adjustValueRangeForMaxCoins(valueMin, valueMax, totalDropAmount)
	funcs.spawnKingCoinFromRandomPlayer(
		players,
		totalDropAmount,
		constraints.valueMin,
		constraints.valueMax,
		spawnRadius
	)
end

return funcs
