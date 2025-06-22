local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local bomb = script.Parent :: Part
local FUSE_TIME = 5
local killModule = require(ReplicatedStorage.Shared.ModuleScripts.killPlayerServer)
local inventoryFuncs = require(ReplicatedStorage.Shared.ModuleScripts.inventoryFunctions)

local curOwnerModel = script:FindFirstAncestorOfClass("Model")
local curOwnerPlayer = Players:GetPlayerFromCharacter(curOwnerModel)

-- Create a BillboardGui for the bomb
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "BombTimer"
billboardGui.Adornee = bomb
billboardGui.Size = UDim2.new(4, 0, 2, 0) -- Width, Height
billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the bomb
billboardGui.AlwaysOnTop = true
billboardGui.Parent = bomb

-- Add a TextLabel for the countdown
local countdownText = Instance.new("TextLabel")
countdownText.Name = "Countdown"
countdownText.Size = UDim2.new(1, 0, 1, 0)
countdownText.BackgroundTransparency = 1
countdownText.TextColor3 = Color3.new(1, 0, 0) -- Red text
countdownText.TextScaled = true
countdownText.Font = Enum.Font.FredokaOne
countdownText.Text = FUSE_TIME
countdownText.Parent = billboardGui

local GRACE_PERIOD = 2 -- seconds

local lastTransferTime = 0
local previousOwnerUserId = nil

function explode()
	killModule.killPlayer(curOwnerModel, curOwnerPlayer)
	bomb:Destroy()
end

bomb.Touched:Connect(function(hit: BasePart)
	local now = tick()

	local hitPlayerChar = hit:FindFirstAncestorOfClass("Model")
	if not hitPlayerChar then
		return
	end

	if hit.Parent and hit.Parent:IsA("Tool") then
		-- print("Hitting tool")
		return
	end

	local playerHit = Players:GetPlayerFromCharacter(hitPlayerChar)
	if not playerHit then
		return
	end

	-- Prevent re-passing during grace period
	if previousOwnerUserId and playerHit.UserId == previousOwnerUserId and (now - lastTransferTime) < GRACE_PERIOD then
		-- print("Grace period active — can't pass back yet")
		return
	end

	-- Prevent giving bomb to current owner
	if curOwnerPlayer and playerHit.UserId == curOwnerPlayer.UserId then
		return
	end

	-- Prevent giving bomb to player in safezone
	if playerHit.States.Safe.Value then
		return
	end

	lastTransferTime = now
	previousOwnerUserId = curOwnerPlayer and curOwnerPlayer.UserId or nil

	curOwnerModel = hitPlayerChar
	curOwnerPlayer = playerHit

	local bombTool = bomb.Parent
	inventoryFuncs.EquipBomb(playerHit, bombTool, 0)
end)

for timeLeft = FUSE_TIME, 0, -1 do
	countdownText.Text = timeLeft
	task.wait(1)

	if timeLeft <= 2 then
		countdownText.TextColor3 = Color3.new(1, 1, 0) -- Yellow
		task.wait(0.1)
		countdownText.TextColor3 = Color3.new(1, 0, 0) -- Red
	end
end

explode()
