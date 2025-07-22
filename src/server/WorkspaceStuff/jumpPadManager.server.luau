local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jumpPadEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("JumpPadClient")
local bouncePads = CollectionService:GetTagged("JumpPad")
local playerDebounce = {} -- [Player] = true if recently jumped

local DEBOUNCE_TIME = 0.5
local CHECK_INTERVAL = 0.1

-- local function getPlayerFromHit(hit: BasePart): Player?
-- 	local model = hit:FindFirstAncestorOfClass("Model")
-- 	if model then
-- 		return Players:GetPlayerFromCharacter(model)
-- 	end
-- 	return nil
-- end

local function getPlayerFromPart(part)
	local model = part:FindFirstAncestorOfClass("Model")
	if model then
		return Players:GetPlayerFromCharacter(model)
	end
	return nil
end

-- Set up bounce pads
for _, pad in ipairs(bouncePads) do
	local useAngular: boolean? = pad:GetAttribute("UseAngularVelocity")
	local playerMomentum: number? = pad:GetAttribute("UsePlayerMomentum")
	local velocity: number? = pad:GetAttribute("Velocity")
	local padHitBox: Part? = pad:FindFirstChild("HitBox")

	if
		typeof(useAngular) == "boolean"
		and typeof(playerMomentum) == "number"
		and typeof(velocity) == "number"
		and padHitBox
	then
		local clampedMomentum = math.clamp(playerMomentum, 0, 1)

		task.spawn(function()
			while true do
				local parts = workspace:GetPartsInPart(padHitBox)
				for _, part in parts do
					local player = getPlayerFromPart(part)

					if player then
						if playerDebounce[player.UserId] then
							continue
						end
						playerDebounce[player.UserId] = true
						task.delay(DEBOUNCE_TIME, function()
							playerDebounce[player.UserId] = nil
						end)

						jumpPadEvent:FireClient(player, pad, useAngular, clampedMomentum, velocity)
					end
				end
				task.wait(CHECK_INTERVAL)
			end
		end)
	else
		warn(`JumpPad {pad:GetFullName()} is missing required attributes`)
	end
end

-- for _, pad in ipairs(bouncePads) do
-- 	local useAngular: boolean? = pad:GetAttribute("UseAngularVelocity")
-- 	local playerMomentum: number? = pad:GetAttribute("UsePlayerMomentum")
-- 	local velocity: number? = pad:GetAttribute("Velocity")
-- 	local padHitBox: Part? = pad:FindFirstChild("HitBox")

-- 	if
-- 		typeof(useAngular) == "boolean"
-- 		and typeof(playerMomentum) == "number"
-- 		and typeof(velocity) == "number"
-- 		and padHitBox
-- 	then
-- 		local clampedMomentum = math.clamp(playerMomentum, 0, 1)

-- 		padHitBox.Touched:Connect(function(hit)
-- 			local player = getPlayerFromHit(hit)

-- 			if player then
-- 				if playerDebounce[player.UserId] then
-- 					return
-- 				end
-- 				playerDebounce[player.UserId] = true
-- 				task.delay(DEBOUNCE_TIME, function()
-- 					playerDebounce[player.UserId] = nil
-- 				end)

-- 				jumpPadEvent:FireClient(player, pad, useAngular, 0, velocity)
-- 			end
-- 		end)
-- 	else
-- 		warn(`JumpPad {pad:GetFullName()} is missing required attributes`)
-- 	end
-- end
