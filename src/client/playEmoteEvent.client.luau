local ReplicatedStorage = game:GetService("ReplicatedStorage")
local emoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("playEmoteEventClient")
local player = game:GetService("Players").LocalPlayer

local currentTrack: AnimationTrack?

emoteEvent.OnClientInvoke = function(emote: string, start: boolean, speed: number)
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn("Humanoid gone")
		return
	end

	if start then
		-- Stop any currently playing track first
		if currentTrack then
			currentTrack:Stop()
			currentTrack:Destroy()
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = emote
		local track = humanoid:LoadAnimation(animation) :: AnimationTrack
		currentTrack = track
		track.Priority = Enum.AnimationPriority.Action

		while track.Length == 0 do
			task.wait()
		end

		track:Play()
		track:AdjustSpeed(speed)

		return track.Length / speed
	else
		if currentTrack then
			currentTrack:Stop()
			currentTrack:Destroy()
			currentTrack = nil
		end
	end
	return nil
end
