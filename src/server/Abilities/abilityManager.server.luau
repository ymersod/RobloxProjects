local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local velocityUtils = require(ReplicatedStorage.Shared.ClientServerModuleScripts.velocityUtils)
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")
local speedJumpBoostBind = bindableEvents:WaitForChild("speedJumpBoostBind")
local slapBind = bindableEvents:WaitForChild("slapBind")
local spawnAbilityBind = bindableEvents:WaitForChild("spawnAbilityBind")
local slapLogicPassiveBind = bindableEvents:WaitForChild("slapLogicPassiveBind")
local bombPrefab = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb") :: Tool

local compTypes = require(ServerScriptService.Server.ServerModuleScripts.CompIntValTypes)
local compUtils = require(ServerScriptService.Server.ServerModuleScripts.CompIntValUtils)
local KingCoinFunctions = require(ServerScriptService.Server.ServerModuleScripts.KingCoinFunctions)
local abilityUtils = require(ServerScriptService.Server.ServerModuleScripts.abilityUtils)
local bombUtils = require(ServerScriptService.Server.ServerModuleScripts.bombUtils)
local killPlayerServer = require(ServerScriptService.Server.ServerModuleScripts.killPlayerServer)
local ragdollUtils = require(ServerScriptService.Server.ServerModuleScripts.ragdollUtils)

local emoteClientEvent =
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("playEmoteEventClient")

local function handleBoost(
	player: Player,
	abilityVals: Instance,
	slotToolId: string,
	boostType: compTypes.CompIntIdSuffixes,
	postMul: true?
)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local amp = abilityVals:GetAttribute("boostAmp") :: number?
	local timer = abilityVals:GetAttribute("boostTime") :: number?

	if not amp or not timer then
		warn("Cant find vars on abilityVals for " .. boostType)
		return
	end

	local modifierName = slotToolId .. boostType .. "Amp"
	local modifier: compTypes.CompModifier = { Name = modifierName, Value = amp, PostMul = postMul }
	compUtils.applyModifier(player, boostType, modifier)

	delayUtil.Delay(timer, function()
		local newCharacter = player and player.Character
		local newHumanoid = newCharacter and newCharacter:FindFirstChildOfClass("Humanoid")

		if newHumanoid and newHumanoid:IsDescendantOf(game) then
			compUtils.removeModifier(player, boostType, modifier)
		else
			player.CharacterAdded:Once(function()
				compUtils.removeModifier(player, boostType, modifier)
			end)
		end
	end)
end

local function getStartEndSound(tool, char: Model)
	local sounds: { Sound } = {}
	local startSound: Sound? = nil
	local endSound: Sound? = nil

	if not char then
		return
	end

	for _, child in ipairs(tool.Handle:GetChildren()) do
		if child:IsA("Sound") then
			table.insert(sounds, child)
		end
	end

	for _, sound in ipairs(sounds) do
		local playOnUse = sound:GetAttribute("PlayOnUse")

		if playOnUse == true then
			local soundClone = sound:Clone()
			soundClone.Parent = char.PrimaryPart
			startSound = soundClone
		end
		if playOnUse == false then
			local soundClone = sound:Clone()
			soundClone.Parent = char.PrimaryPart
			endSound = soundClone
		end
	end

	return startSound, endSound
end

local function handleSoundAndDelays(
	timer: number,
	startsound: Sound,
	endsound: Sound?,
	player: Player,
	cleanupFunction: (() -> ())?
)
	startsound:Play()
	startsound.Ended:Connect(function()
		startsound:Destroy()
	end)

	if timer == 0 then
		return
	end

	delayUtil.Delay(timer, function()
		if not player.Character then
			warn("Player died before sound could end")
			return
		end
		if startsound and startsound.Playing then
			startsound:Stop()
			startsound:Destroy()
		end
		if endsound then
			endsound:Play()
			endsound.Ended:Connect(function()
				endsound:Destroy()
				if cleanupFunction then
					cleanupFunction()
				end
			end)
		elseif cleanupFunction then
			cleanupFunction()
		end
	end)
end

speedJumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string, tool: Tool)
	local timer = abilityVals:GetAttribute("boostTime") :: number?
	local char = player.Character

	local startSound, endSound = getStartEndSound(tool, char)
	handleSoundAndDelays(timer, startSound, endSound, player)
	handleBoost(player, abilityVals, slotToolId, "SpeedValue")
	handleBoost(player, abilityVals, slotToolId, "JumpValue")
end)

speedBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string, tool: Tool)
	local timer = abilityVals:GetAttribute("boostTime") :: number?

	local char = player.Character
	local startSound, endSound = getStartEndSound(tool, char)
	handleSoundAndDelays(timer, startSound, endSound, player)
	handleBoost(player, abilityVals, slotToolId, "SpeedValue")
end)

jumpBoostBind.Event:Connect(function(player: Player, abilityVals: Instance, slotToolId: string, tool: Tool)
	local timer = abilityVals:GetAttribute("boostTime") :: number?

	local char = player.Character
	local startSound, endSound = getStartEndSound(tool, char)
	handleSoundAndDelays(timer, startSound, endSound, player)
	handleBoost(player, abilityVals, slotToolId, "JumpValue")
end)

slapBind.Event:Connect(function(targetPlayer, self, direction, abilityVals: StringValue?)
	local passiveValue = abilityVals and abilityVals:GetAttribute("abilityType")
	print(passiveValue)
	if abilityVals and passiveValue and passiveValue == enums.abilityTypes.slimy then
		handleBoost(targetPlayer, abilityVals, "slimy", "SpeedValue", true)
		ragdollUtils.ragdoll(targetPlayer, direction, 2)
	elseif abilityVals and passiveValue and passiveValue == enums.abilityTypes.hell then
		killPlayerServer.killPlayer(targetPlayer)
	elseif abilityVals and passiveValue and passiveValue == enums.abilityTypes.steal then
		local stealAmount = abilityVals and abilityVals:GetAttribute("StealAmount")
		KingCoinFunctions.StealKingScore(targetPlayer, self, stealAmount)
		ragdollUtils.ragdoll(targetPlayer, direction, 2)
	else
		ragdollUtils.ragdoll(targetPlayer, direction, 2)
	end
end)

spawnAbilityBind.Event:Connect(function(player: Player, abilityVals: Instance, _: string, tool: Tool)
	local abilityType = abilityVals:GetAttribute("abilityType")
	local duration = tonumber(abilityVals:GetAttribute("duration"))
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not char or not hum or not hrp then
		warn("model and/or humanoid not found")
		return
	end
	-- [[[ POOP ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.spawnPoop then
		local startSound = getStartEndSound(tool, char)
		local poopFlush, poopClone = abilityUtils.SpawnPoop(char, tool)
		handleSoundAndDelays(duration, startSound, poopFlush, player, function()
			poopClone:Destroy()
		end)
		return
	end

	-- [[[ GYAT ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.gyat then
		local danceTrack = abilityVals:GetAttribute("danceTrack")
		local aoeRadius = abilityVals:GetAttribute("aoeRadius")
		local startSound = getStartEndSound(tool, char)
		local origin = char:FindFirstChild("HumanoidRootPart")

		if not origin then
			return
		end
		if not aoeRadius or not danceTrack then
			warn("missing attributes")
			return
		end

		local pList: { Player } = {}
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			local otherChar = otherPlayer.Character
			local otherHrp = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
			if otherHrp and (otherHrp.Position - origin.Position).Magnitude <= aoeRadius then
				emoteClientEvent:InvokeClient(otherPlayer, danceTrack, true, 1)
				handleBoost(otherPlayer, abilityVals, "dance", "SpeedValue", true)
				table.insert(pList, otherPlayer)
			elseif not otherHrp then
				warn("cant find other players hrp")
			else
				warn("Gyat broke")
			end
		end

		-- abilityUtils.createAOEVisualization(origin.Position, aoeRadius, duration)

		handleSoundAndDelays(duration, startSound, nil, player, function()
			for _, otherPlayer in ipairs(pList) do
				emoteClientEvent:InvokeClient(otherPlayer, danceTrack, false, 1)
			end
		end)
		return
	end

	-- [[[ BASEBALL BAT ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.bat then
		local range = abilityVals:GetAttribute("range")
		local angle = abilityVals:GetAttribute("angle")
		local power = abilityVals:GetAttribute("power")
		local upAngle = abilityVals:GetAttribute("upAngle")

		local animationId = abilityVals:GetAttribute("animationId")
		if not animationId or not char then
			warn("Missing animationId or character")
			return
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			warn("No humanoid found")
			return
		end

		local startSound = getStartEndSound(tool, char)

		local trackLength: number? = emoteClientEvent:InvokeClient(player, animationId, true, 2)
		task.delay(trackLength, function()
			handleSoundAndDelays(duration, startSound, nil, player)
			local players = abilityUtils.getPlayersInCone(player, hrp.Position, hrp.CFrame.LookVector, angle, range)

			for _, playerHit in ipairs(players) do
				ragdollUtils.ragdoll(playerHit, (hrp.CFrame.LookVector + Vector3.new(0, upAngle, 0)) * power, 3)
			end
		end)
		return
	end

	-- [[[ BOMB ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.bomb then
		local animationId = abilityVals:GetAttribute("animationId")
		local power = abilityVals:GetAttribute("power")
		local upAngle = abilityVals:GetAttribute("upAngle")
		local trackLength: number? = emoteClientEvent:InvokeClient(player, animationId, true, 2)

		if not animationId or not char then
			warn("Missing animationId or character")
			return
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			warn("No humanoid found")
			return
		end

		local startSound = getStartEndSound(tool, char)

		local bombVisual = tool:FindFirstChild("Meshes/dynamite") :: MeshPart?
		local pos = bombVisual and bombVisual.CFrame.Position or hrp.Position

		task.delay(trackLength, function()
			local states = player:FindFirstChild("States")
			local ExternalBombSafe = states and states:FindFirstChild("ExternalBombSafe") :: BoolValue?
			ExternalBombSafe.Value = true
			handleSoundAndDelays(duration, startSound, nil, player, function()
				ExternalBombSafe.Value = false
			end)

			local item = bombUtils.createBombItem(bombPrefab:Clone(), pos, workspace)
			velocityUtils.applyKnockback(item, (hrp.CFrame.LookVector + Vector3.new(0, upAngle, 0)) * power)
		end)
		return
	end

	-- [[[ GODMODE ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.godmode then
		local spawnableRef = tool:FindFirstChild("SpawnableRef") :: ObjectValue
		local humanoidPart = abilityVals:GetAttribute("HumanoidPartApplyParticles") :: string

		local states = player:FindFirstChild("States")
		local externalSafe = states and states:FindFirstChild("ExternalSafe") :: BoolValue?
		externalSafe.Value = true

		local godparticlesClone = spawnableRef.Value:Clone()
		godparticlesClone.Parent = char:FindFirstChild(humanoidPart)

		local startSound = getStartEndSound(tool, char)
		handleSoundAndDelays(duration, startSound, nil, player, function()
			externalSafe.Value = false

			if godparticlesClone then
				godparticlesClone:Destroy()
			end
		end)
		return
	end

	-- [[[ TELEPORT ]]]
	if abilityType and duration and abilityType == enums.abilityTypes.teleport then
		local range = abilityVals:GetAttribute("range") or 50
		local breakChance = abilityVals:GetAttribute("breakChance") or 0
		local breakLocations = CollectionService:GetTagged("BreakRoom")
		local firstBreakLocation = breakLocations and breakLocations[1]

		local startSound = getStartEndSound(tool, char)
		handleSoundAndDelays(duration, startSound, nil, player)

		if char and hrp then
			local destinationCFrame

			if math.random() <= breakChance and firstBreakLocation then
				destinationCFrame = CFrame.new(firstBreakLocation.Position)
			else
				destinationCFrame = hrp.CFrame * CFrame.new(0, 0, range)
			end

			char:SetPrimaryPartCFrame(destinationCFrame)
		end
	end
	warn("No ability logic happened")
end)

slapLogicPassiveBind.Event:Connect(function(player: Player, abilityVals: Instance)
	local char = player.Character
	local abilityType = abilityVals:GetAttribute("abilityType")

	if abilityType == enums.abilityTypes.slimy then
		print("slimy :>")
	elseif abilityType == enums.abilityTypes.hell then
		print("What the helly :o")
	else
		warn("no passive types")
	end
end)
