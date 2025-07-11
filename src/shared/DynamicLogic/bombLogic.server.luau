local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local bomb = script.Parent :: Part
local hitBox = bomb:FindFirstChild("HitBox")
local FUSE_TIME = 30
local Explosion_Radius = 10
local touched_key: boolean = false
local explosionSphere = game:GetService("Workspace"):WaitForChild("ExplosionSphere")

local replicatedStorage = game:GetService("ReplicatedStorage")
local explosionSphereAnimationScript: Script =
	replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombSphereExplosion")

local ServerStorage = game:GetService("ServerStorage")

local kingCoin = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin") :: Part

local inventoryFunctions = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local killPlayerServer = require(ServerScriptService.Server.ServerModuleScripts.killPlayerServer)

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

local COIN_VALUE = 10
local DROP_VARIANTS = 3

function spawnKingCoin(value, player)
	local SPAWN_RADIUS = 10
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

local function playExplosion(position: Vector3)
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = 0
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = workspace
end

function explode()
	--TODO: Generalize this to a func, similar to the func in SafeZone server. Make a func that return players who is within a sphere
	for _, player in pairs(Players:GetPlayers()) do
		local char = player.Character
		if not char or (curOwnerPlayer ~= player and player.States.Safe.Value) then
			continue
		end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end

		local origin = bomb.Position
		if (root.Position - origin).Magnitude <= Explosion_Radius then
			killPlayerServer.killPlayer(char, player)
			local leaderstats = player:FindFirstChild("leaderstats")
			local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")
			if kingScore then
				for i = COIN_VALUE, kingScore.Value * 0.3, COIN_VALUE do
					local randomVariants = math.round(math.random(-DROP_VARIANTS, DROP_VARIANTS))
					spawnKingCoin(COIN_VALUE + randomVariants, player)
					i += randomVariants
				end
			end
		end
	end
	local sphere = explosionSphere:Clone()
	sphere.Position = bomb.Position
	sphere.Parent = workspace
	sphere.Size = Vector3.new(Explosion_Radius * 2, Explosion_Radius * 2, Explosion_Radius * 2)
	local expScript = explosionSphereAnimationScript:Clone()
	expScript.Parent = sphere

	playExplosion(bomb.Position)
	local sound = bomb:FindFirstChildOfClass("Sound")

	--TODO: Might want the part on the bomb, and then decouple it when the sound should play instead of copy and instance
	if sound then
		local tempPart = Instance.new("Part")
		tempPart.Size = Vector3.new(1, 1, 1)
		tempPart.Transparency = 1
		tempPart.Anchored = true
		tempPart.CanCollide = false
		tempPart.CFrame = bomb.CFrame
		tempPart.Parent = workspace

		sound.Parent = tempPart
		sound:Play()
		sound.Ended:Once(function()
			tempPart:Destroy()
		end)
	end
	bomb.Parent:Destroy()
end

function BombTouched(hit: BasePart)
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
	inventoryFunctions.EquipBomb(playerHit, bombTool, 0)
end

hitBox.Touched:Connect(function(hit: BasePart)
	if touched_key then
		return
	end

	touched_key = true
	BombTouched(hit)
	touched_key = false
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
