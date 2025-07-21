local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jumpPadEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("JumpPadClient")
local bouncePads = CollectionService:GetTagged("JumpPad")
local playerDebounce = {} -- [Player] = true if recently jumped

local DEBOUNCE_TIME = 0.5

local function getPlayerFromHit(hit: BasePart): Player?
	local model = hit:FindFirstAncestorOfClass("Model")
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

	if typeof(useAngular) == "boolean" and typeof(playerMomentum) == "number" and typeof(velocity) == "number" then
		local clampedMomentum = math.clamp(playerMomentum, 0, 1)
		pad.Touched:Connect(function(hit)
			local player = getPlayerFromHit(hit)
			if not player then
				return
			end

			-- Debounce check
			if playerDebounce[player] then
				return
			end
			playerDebounce[player] = true
			task.delay(DEBOUNCE_TIME, function()
				playerDebounce[player] = nil
			end)

			jumpPadEvent:FireClient(player, pad, useAngular, clampedMomentum, velocity)
			-- jumpLogic(hit, pad, useAngular, clampedMomentum, velocity)
		end)
	else
		warn(`JumpPad {pad:GetFullName()} is missing required attributes`)
	end
end
