local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local expManagerFunctions = require(ServerScriptService.Server.ServerModuleScripts.expManagerFunctions)

local coin = script.Parent :: Part
local meshPart = coin:FindFirstChild("CoinMesh")
local attachment = meshPart and meshPart:FindFirstChildWhichIsA("Attachment")
local coinScore: IntValue = coin and coin:FindFirstChild("Coin score")
local hitBox = coin:WaitForChild("HitBox")

local DESPAWN_TIME_SECONDS = coin:GetAttribute("DESPAWN_TIME_SECONDS")
local ROTATION_SPEED = coin:GetAttribute("ROTATION_SPEED")

-- Create a BillboardGui for the coin
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "ScoreBillboard"
billboardGui.Adornee = coin
billboardGui.Size = UDim2.new(4, 0, 2, 0) -- Width, Height
billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the coin
billboardGui.AlwaysOnTop = true
billboardGui.Parent = coin

-- Add a TextLabel for the score label
local scoreText = Instance.new("TextLabel")
scoreText.Name = "Score label"
scoreText.Size = UDim2.new(1, 0, 1, 0)
scoreText.BackgroundTransparency = 1
scoreText.TextColor3 = Color3.fromHex("#FFC200") -- yellow text
scoreText.TextScaled = true
scoreText.Font = Enum.Font.FredokaOne
scoreText.Text = 0
scoreText.Parent = billboardGui

if coinScore then
	scoreText.Text = coinScore.Value
end

local baseX = 0
local baseZ = 0

if attachment then
	local baseRot = attachment.Rotation
	baseX = baseRot.X
	baseZ = baseRot.Z
end

hitBox.Touched:Connect(function(other)
	local hitPlayerChar = other:FindFirstAncestorOfClass("Model")
	if not hitPlayerChar then
		return
	end

	local playerHit = Players:GetPlayerFromCharacter(hitPlayerChar)
	if not playerHit then
		return
	end

	local humanoid = playerHit.Character and playerHit.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health < 1 then
		return
	end

	local leaderstats = playerHit and playerHit:FindFirstChild("leaderstats")
	local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")

	if kingScore and coinScore then
		kingScore.Value += coinScore.Value
		local xpBoost = 1

		local xpBoostIntValue: IntValue = playerHit:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
		if xpBoostIntValue and xpBoostIntValue.Value then
			xpBoost = xpBoostIntValue.Value / 100
		end

		expManagerFunctions.incrementExp(playerHit.UserId, 50 * xpBoost)
	end

	coin:Destroy()
end)
local angle = 0

RunService.Heartbeat:Connect(function(dt)
	angle += (ROTATION_SPEED * dt) % 360
	if attachment then
		attachment.Rotation = Vector3.new(baseX, angle, baseZ)
	end
end)

task.delay(DESPAWN_TIME_SECONDS, function()
	if script and coin then
		coin:Destroy()
	end
end)
