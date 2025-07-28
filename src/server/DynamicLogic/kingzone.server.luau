local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")

local kingZoneActivateClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("KingZoneActivateClient")

local expManagerFunctions = require(ServerScriptService.Server.ServerModuleScripts.expManagerFunctions)

local part = script.Parent
local partModel = part:FindFirstChild("KingZoneModel")
local normalTransparency = part.Transparency
local kingScoreBonus = 0
local xpBonus = 0
local kingCandidates = {}
local partibleEmitters = {}

local COLOR_SUCCESS = Color3.fromRGB(9, 255, 0)
local COLOR_FAILURE = Color3.fromRGB(255, 0, 0)
local COLOR_IDLE = Color3.fromRGB(156, 34, 165)

for _, descendant in ipairs(part:GetDescendants()) do
	if descendant:IsA("ParticleEmitter") then
		table.insert(partibleEmitters, descendant)
	end
end

local function setParticleColor(color: Color3)
	for _, emitter in ipairs(partibleEmitters) do
		emitter.Color = ColorSequence.new(color)
	end
end

local function particleEmitterSwitch(turnOn: boolean)
	for _, emitter in ipairs(partibleEmitters) do
		emitter.Enabled = turnOn
	end
end

local function kingZoneSwitch()
	local isActive = part:GetAttribute("isActive")
	if isActive then
		if partModel.Transparency ~= normalTransparency then
			partModel.Transparency = normalTransparency
		end
		kingZoneActivateClient:FireAllClients((partModel :: Part).Position)
	elseif partModel.Transparency == normalTransparency then
		partModel.Transparency = 1
	end
	particleEmitterSwitch(isActive)
end

local function getPlayer(col: { name: string, Parent: Model }): Player?
	local char = col.Parent
	if not char or col.name ~= "HumanoidRootPart" then
		return nil
	end

	local player = players:GetPlayerFromCharacter(char)

	return player
end

local function tryToAddPlayer(userId)
	kingCandidates[#kingCandidates + 1] = userId
end

local function updateKingZone(list)
	table.clear(kingCandidates)
	for _, p in ipairs(list) do
		local player = getPlayer(p)
		local playerChar = player and player.Character
		local humanoid = playerChar and playerChar:FindFirstChildOfClass("Humanoid")
		if player and humanoid and humanoid.Health > 0 then
			tryToAddPlayer(player.UserId)
		end
	end
	if #kingCandidates > 0 then
		kingScoreBonus = math.round(5 / #kingCandidates)
		xpBonus = math.round(5 / #kingCandidates) --Right now same calc, but might want it different in future
	end
end

function scoreKing(userId: number)
	local king = players:GetPlayerByUserId(userId)
	local leaderstats = king and king:FindFirstChild("leaderstats")
	local kingScore: IntValue = leaderstats and leaderstats:FindFirstChild("King Score")

	local xpBoost = 1
	local xpBoostIntValue: IntValue = king and king:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
	if xpBoostIntValue then
		xpBoost = xpBoostIntValue.Value / 100
	end

	if kingScore then
		kingScore.Value += kingScoreBonus
		expManagerFunctions.incrementExp(king.UserId, xpBonus * xpBoost)
	end
end

function scoreKings()
	for _, king in ipairs(kingCandidates) do
		scoreKing(king)
	end
end

local function handleKingZone()
	local partsInZone = workspace:GetPartsInPart(part)
	updateKingZone(partsInZone)
	if #kingCandidates > 0 then
		if #kingCandidates > 0 and kingScoreBonus > 0 then
			partModel.Color = COLOR_SUCCESS
			setParticleColor(COLOR_SUCCESS)
			scoreKings()
		else
			partModel.Color = COLOR_FAILURE
			setParticleColor(COLOR_FAILURE)
		end
	else
		partModel.Color = COLOR_IDLE
		setParticleColor(COLOR_IDLE)
	end
end

part.AttributeChanged:Connect(function(attr)
	kingZoneSwitch()
end)

local function kingZoneMainLoop()
	if part.Transparency then
		part.Transparency = 1
	end
	kingZoneSwitch()
	while true do
		local isActive = part:GetAttribute("isActive")
		if isActive then
			handleKingZone()
		end
		task.wait(1)
	end
end
kingZoneMainLoop()
