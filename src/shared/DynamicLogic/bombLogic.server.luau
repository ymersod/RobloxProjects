local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local explosionSphere = game:GetService("Workspace"):WaitForChild("ExplosionSphere")
if not explosionSphere then
	error("Missing ExplosionSphere in Workspace")
end

local explosionSphereAnimationScript: Script =
	replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombSphereExplosion")
if not explosionSphereAnimationScript then
	error("Missing explosion animation script in ReplicatedStorage.Shared.DynamicLogic")
end

local kingCoin = ServerStorage:WaitForChild("Pickups"):WaitForChild("KingCoin") :: Part
if not kingCoin then
	error("Missing KingCoin in ServerStorage.Pickups")
end

local inventoryFunctions = require(ServerScriptService.Server.ServerModuleScripts.inventoryFunctions)
local killPlayerServer = require(ServerScriptService.Server.ServerModuleScripts.killPlayerServer)

local bomb = script.Parent :: Part
if not bomb or not bomb:IsA("BasePart") then
	error("Bomb script must be parented to a Part")
end

local hitBox = bomb:FindFirstChild("HitBox") :: Part
if not hitBox or not hitBox:IsA("BasePart") then
	error("Missing or invalid HitBox")
end

local curOwnerModel = script:FindFirstAncestorOfClass("Model")
local curOwnerPlayer = Players:GetPlayerFromCharacter(curOwnerModel)

local FUSE_TIME = 30
local Explosion_Radius = 10
local GRACE_PERIOD = 1.5 -- seconds
local COIN_VALUE = 10
local DROP_VARIANTS = 3
local COIN_SPAWN_RADIUS = 10

local touched_key = nil
local lastTransferTime = 0

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

local function spawnKingCoin(value, player)
	local coinClone = kingCoin:Clone()
	coinClone.Parent = workspace
	coinClone.Position = player.Character.PrimaryPart.Position
		+ Vector3.new(
			math.random(-COIN_SPAWN_RADIUS, COIN_SPAWN_RADIUS),
			0,
			math.random(-COIN_SPAWN_RADIUS, COIN_SPAWN_RADIUS)
		)
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

	if not hit or not hit:IsA("BasePart") then
		return
	end

	if hit:IsDescendantOf(bomb.Parent) then
		return
	end

	if hit.Parent and hit.Parent:IsA("Tool") then
		return
	end

	local hitPlayerChar = hit:FindFirstAncestorOfClass("Model")
	if not hitPlayerChar then
		return
	end

	local playerHit = Players:GetPlayerFromCharacter(hitPlayerChar)
	if not playerHit then
		return
	end

	-- Grace period
	if (now - lastTransferTime) < GRACE_PERIOD then
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

	local bombTool = bomb.Parent
	if bombTool and bombTool:IsA("Tool") then
		local success, err = pcall(function()
			lastTransferTime = now
			inventoryFunctions.EquipBomb(playerHit, bombTool, 0)
		end)
		if not success then
			warn("Error equipping bomb to player:", err)
		end
	end
end

hitBox.Touched:Connect(function(hit)
	if touched_key then
		return
	end

	touched_key = hit
	task.defer(function()
		if touched_key ~= hit then
			return
		end
		local success, err = pcall(function()
			BombTouched(hit)
		end)
		if not success then
			warn("Error in BombTouched:", err)
		end
		touched_key = nil
	end)
end)

bomb:GetPropertyChangedSignal("Parent"):Connect(function()
	local parent = bomb.Parent
	local grandparent = parent and parent.Parent
	if grandparent and grandparent:IsA("Model") then
		curOwnerModel = grandparent
		curOwnerPlayer = Players:GetPlayerFromCharacter(curOwnerModel)
	end
end)

task.spawn(function()
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
end)
