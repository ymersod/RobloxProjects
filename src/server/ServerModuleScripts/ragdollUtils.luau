local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RagdollData = require(ServerScriptService.Server.DataModules.RagdollData)
local velocityUtils = require(ReplicatedStorage.Shared.ClientServerModuleScripts.velocityUtils)
local ragdollClientEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local PhysicsService = game:GetService("PhysicsService")
local IsSafeUtil = require(script.Parent.IsSafeUtil)

local ragdollUtils = {}

function ragdollUtils.EnableMotor6D(character: Model, enabled: boolean)
	for _, v in pairs(character:GetDescendants()) do
		if v.Name == "Handle" or v.Name == "RootJoint" or v.Name == "Neck" or v:HasTag("KingCrown") then
			continue
		end
		if v:IsA("Motor6D") then
			v.Enabled = enabled
		end
		if v:IsA("BasePart") then
			if enabled and v.Name ~= "HumanoidRootPart" then
				PhysicsService:SetPartCollisionGroup(v, "Players")
			elseif enabled then
				PhysicsService:SetPartCollisionGroup(v, "PlayerRootPart")
			else
				PhysicsService:SetPartCollisionGroup(v, "RagdollCollide")
			end
		end
	end
end

function ragdollUtils.BuildJoints(character: Model)
	for _, v in pairs(character:GetDescendants()) do
		if not v:IsA("BasePart") or v:FindFirstAncestorOfClass("Accessory") or v.Name == "Handle" then
			continue
		end

		if not RagdollData[v.Name] then
			continue
		end

		local motor = v:FindFirstChildOfClass("Motor6D")
		if not motor or not motor:IsA("Motor6D") then
			continue
		end

		local parentPart = motor.Part0 -- This will be LeftLowerLeg
		if not parentPart or not parentPart:IsA("BasePart") then
			continue
		end

		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		local socket = Instance.new("BallSocketConstraint")

		a0.Name = "RAGDOLL_ATTACHMENT"
		a0.Parent = v
		a0.CFrame = RagdollData[v.Name].CFrame[2]

		a1.Name = "RAGDOLL_ATTACHMENT"
		a1.Parent = parentPart
		a1.CFrame = RagdollData[v.Name].CFrame[1]

		socket.Name = "RAGDOLL_CONSTRAINT"
		socket.LimitsEnabled = true
		socket.TwistLimitsEnabled = true
		socket.Parent = v
		socket.Attachment0 = a0
		socket.Attachment1 = a1
	end
end

function ragdollUtils.DestroyJoints(character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart
	hrp.Massless = false

	for _, v in pairs(character:GetDescendants()) do
		if v.Name == "RAGDOLL_ATTACHMENT" or v.Name == "RAGDOLL_CONSTRAINT" then
			v:Destroy()
		end

		if
			not v:IsA("BasePart")
			or v:FindFirstAncestorOfClass("Accessory")
			or v.Name == "Torso"
			or v.Name == "Head"
		then
			continue
		end
	end
end

function ragdollUtils.EnableCollisionParts(character: Model, enabled: boolean)
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and not v:HasTag("KingCrown") then
			v.CanCollide = not enabled
			local collide = v:FindFirstChild("Collide")
			if collide then
				collide.CanCollide = enabled
			end
		end
	end
end

function ragdollUtils.UnragdollCharacter(character: Model, getUpState: number?)
	local plr = Players:GetPlayerFromCharacter(character)
	local hum = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if plr then
		ragdollClientEvent:FireClient(plr, false)
	else
		hrp:SetNetworkOwner(nil)
		if hum:GetState() == Enum.HumanoidStateType.Dead then
			return
		end
		hum.PlatformStand = false
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		hum.AutoRotate = true
	end

	ragdollUtils.EnableMotor6D(character, true)
	ragdollUtils.DestroyJoints(character)
	ragdollUtils.EnableCollisionParts(character, false)
end

function ragdollUtils.ragdoll(targetPlayer: Player, direction: Vector3, duration: number)
	if IsSafeUtil.IsSafe(targetPlayer) then
		return
	end
	local char = targetPlayer and targetPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = humanoid and humanoid.RootPart

	velocityUtils.applyKnockback(hrp, direction)

	ragdollUtils.EnableMotor6D(char, false)
	ragdollUtils.BuildJoints(char)
	ragdollUtils.EnableCollisionParts(char, true)

	if targetPlayer then
		ragdollClientEvent:FireClient(targetPlayer, true)
	else
		hrp:SetNetworkOwner(nil)
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
	end

	-- Start timer to call
	task.delay(duration, function()
		local newChar = targetPlayer.Character
		local newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
		local newHrp = newHum and newHum.RootPart

		if newHrp.CollisionGroup and newHrp.CollisionGroup == "RagdollCollide" then
			ragdollUtils.UnragdollCharacter(newChar)
		end
	end)
end

local function BuildCollisionParts(character: Model)
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and not v:HasTag("KingCrown") then
			local p = v:Clone()
			p.Parent = v
			p.CanCollide = false
			p.Massless = true
			p.Size = Vector3.one
			p.Name = "Collide"
			p.Transparency = 1
			PhysicsService:SetPartCollisionGroup(p, "RagdollCollide")
			print(p.CollisionGroup)
			p:ClearAllChildren()

			local weld = Instance.new("Weld")
			weld.Parent = p
			weld.Part0 = v
			weld.Part1 = p
		end
	end
end

local function SetupHumanoid(humanoid: Humanoid)
	-- INFO: Requiresneck = false, makes humanoid immortal lulle
	humanoid.BreakJointsOnDeath = false
	-- humanoid.RequiresNeck = false
end

local function WaitForCharacterAndSetup()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			BuildCollisionParts(char)
			SetupHumanoid(char:WaitForChild("Humanoid"))
		end)
	end)
end
WaitForCharacterAndSetup()

return ragdollUtils
