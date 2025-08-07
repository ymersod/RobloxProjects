local isSafeUtil = {}

function isSafeUtil.IsSafeFromAll(player: Player)
	local states = player:FindFirstChild("States")
	local safe: BoolValue? = states:FindFirstChild("Safe")
	local externalSafe: BoolValue? = states:FindFirstChild("ExternalSafe")

	local isSafe = false
	if safe then
		if safe.Value then
			isSafe = true
		end
	end

	if externalSafe then
		if externalSafe.Value then
			isSafe = true
		end
	end

	return isSafe
end

function isSafeUtil.IsSafeFromBombPickup(player: Player)
	local states = player:FindFirstChild("States")
	local bombSafe: BoolValue? = states:FindFirstChild("ExternalBombSafe")

	local isSafe = false
	if bombSafe then
		if bombSafe.Value then
			isSafe = true
		end
	end

	return isSafe
end

return isSafeUtil
