local ReplicatedStorage = game:GetService("ReplicatedStorage")
local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local emoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("playEmoteEventClient")
local AbilityUIClientEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("AbilityUIClientEvent")
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

AbilityUIClientEvent.OnClientInvoke = function(type: string, duration: number)
	if type == enums.abilityTypes.brainrot then
		local brainrot =
			player:FindFirstChild("PlayerGui"):FindFirstChild("ScreenGui"):FindFirstChild("Brainrot") :: Frame

		brainrot.Visible = true
		local originalSize = brainrot.Size
		local growSize = UDim2.new(
			originalSize.X.Scale * 1.2,
			originalSize.X.Offset * 1.2,
			originalSize.Y.Scale * 1.2,
			originalSize.Y.Offset * 1.2
		)
		task.spawn(function()
			local startTime = tick()

			while tick() - startTime < tonumber(duration) and brainrot.Parent do
				-- Grow + rotate
				local growTween = createTweenFunctions.SizeTween(brainrot, growSize, 0.5)
				local rotateTween = createTweenFunctions.RotationTween(brainrot, brainrot.Rotation + 45, 0.5)
				growTween:Play()
				rotateTween:Play()
				growTween.Completed:Wait()

				-- Shrink + rotate
				local shrinkTween = createTweenFunctions.SizeTween(brainrot, originalSize, 0.5)
				local rotateTween2 = createTweenFunctions.RotationTween(brainrot, brainrot.Rotation + 45, 0.5)
				shrinkTween:Play()
				rotateTween2:Play()
				shrinkTween.Completed:Wait()
			end

			-- Reset to default state after loop ends
			brainrot.Size = originalSize
			brainrot.Visible = false
		end)
	end
end
