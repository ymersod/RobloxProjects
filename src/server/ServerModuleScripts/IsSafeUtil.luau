local isSafeUtil = {}

function isSafeUtil.IsSafe(player: Player)
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

return isSafeUtil
