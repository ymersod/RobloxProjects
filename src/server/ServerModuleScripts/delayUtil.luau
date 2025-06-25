local DelayUtil = {}

function DelayUtil.Delay(seconds: number, callback: () -> (), cancelCheck: (() -> boolean)?)
	task.spawn(function()
		local start = tick()
		while tick() - start < seconds do
			if cancelCheck and cancelCheck() then
				return -- stop early
			end
			task.wait()
		end

		-- Only run if not canceled
		if not (cancelCheck and cancelCheck()) then
			callback()
		end
	end)
end

return DelayUtil
