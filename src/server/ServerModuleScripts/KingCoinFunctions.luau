local ServerStorage = game:GetService("ServerStorage")

local kingCoin = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin") :: Part
if not kingCoin then
	error("Missing KingCoin in ServerStorage.Pickups")
end

local funcs = {}

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

	local leaderstats = player and player:FindFirstChild("leaderstats")
	local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")

	if kingScore and coinScore then
		coinScore.Value = value
		kingScore.Value -= coinScore.Value
	end

	coinLogic.Enabled = true
end

function funcs.spawnMultipleKingCoinOfSizeRangesFromPlayer(
	player: Player,
	SPAWN_RADIUS: number,
	DRAIN_PERCENT: number,
	VALUE_MIN: number,
	VALUE_MAX: number
)
	local leaderstats = player:FindFirstChild("leaderstats")
	local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")
	if kingScore then
		local totalToDrop = math.round(kingScore.Value * DRAIN_PERCENT)
		local dropped = 0

		while dropped < totalToDrop do
			local randomVariants = math.round(math.random(VALUE_MIN, VALUE_MAX))

			if dropped + randomVariants > totalToDrop then
				randomVariants = totalToDrop - dropped
			end

			dropped += randomVariants
			funcs.spawnKingCoinFromPlayer(randomVariants, player, SPAWN_RADIUS)
		end
	end
end

return funcs
