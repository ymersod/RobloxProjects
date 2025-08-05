local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local enums = require(ReplicatedStorage.Shared.ClientServerModuleScripts.enums)
local delayUtil = require(ServerScriptService.Server.ServerModuleScripts.delayUtil)
local bindableEvents =
	ServerScriptService:WaitForChild("Server"):WaitForChild("Abilities"):WaitForChild("BindableEvents")
local speedBoostBind = bindableEvents:WaitForChild("speedBoostBind")
local jumpBoostBind = bindableEvents:WaitForChild("jumpBoostBind")
local speedJumpBoostBind = bindableEvents:WaitForChild("speedJumpBoostBind")
local slapBind = bindableEvents:WaitForChild("slapBind")
local spawnAbilityBind = bindableEvents:WaitForChild("spawnAbilityBind")
local slapLogicPassiveBind = bindableEvents:WaitForChild("slapLogicPassiveBind")

local compTypes = require(ServerScriptService.Server.ServerModuleScripts.CompIntValTypes)
local compUtils = require(ServerScriptService.Server.ServerModuleScripts.CompIntValUtils)
local killPlayerServer = require(ServerScriptService.Server.ServerModuleScripts.killPlayerServer)
local ragdollUtils = require(ServerScriptService.Server.ServerModuleScripts.ragdollUtils)

local function handleBoost(
	player: Player,
	abilityVals: Instance,
	slotToolId: string,
	boostType: compTypes.CompIntIdSuffixes
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
	local modifier: compTypes.CompModifier = { Name = modifierName, Value = amp }
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
	spawnableToDestroy: Instance?
)
	startsound:Play()
	startsound.Ended:Connect(function()
		startsound:Destroy()
	end)
	delayUtil.Delay(timer, function()
		if not player.Character then
			warn("Player died before sound could end")
			return
		end

		if endsound then
			endsound:Play()
			endsound.Ended:Connect(function()
				endsound:Destroy()
				if spawnableToDestroy then
					spawnableToDestroy:Destroy()
				end
			end)
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

slapBind.Event:Connect(function(targetPlayer, direction, abilityVals: StringValue?)
	local passiveValue = abilityVals and abilityVals:GetAttribute("abilityType")
	print(passiveValue)
	if abilityVals and passiveValue and passiveValue == enums.abilityTypes.slimy then
		handleBoost(targetPlayer, abilityVals, "slimy", "SpeedValue")
		ragdollUtils.ragdoll(targetPlayer, direction, 2)
	elseif abilityVals and passiveValue and passiveValue == enums.abilityTypes.hell then
		killPlayerServer.killPlayer(targetPlayer)
	else
		ragdollUtils.ragdoll(targetPlayer, direction, 2)
	end
end)

spawnAbilityBind.Event:Connect(function(player: Player, abilityVals: Instance, _: string, tool: Tool)
	local abilityType = abilityVals:GetAttribute("abilityType")
	local duration = abilityVals:GetAttribute("duration")

	if abilityType and duration and abilityType == enums.abilityTypes.spawnPoop then
		local spawnableRef = tool:FindFirstChildOfClass("ObjectValue")
		local poop = spawnableRef and spawnableRef.Value

		if not poop then
			warn("Couldn't find spawnable ref")
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local startSound = getStartEndSound(tool, character)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local poopClone = poop:Clone()

		local verticalLift = 0
		local backOffset = -2
		local spawnPosition = hrp.Position + (hrp.CFrame.LookVector * backOffset) + Vector3.new(0, verticalLift, 0)
		local spawnCFrame = CFrame.new(spawnPosition, spawnPosition + hrp.CFrame.LookVector)

		poopClone:PivotTo(spawnCFrame)
		poopClone.Parent = workspace

		local backwardDirection = -hrp.CFrame.LookVector
		local pushStrength = 50
		local poopRootPart = poopClone.PrimaryPart or poopClone:FindFirstChildWhichIsA("BasePart")

		if poopRootPart then
			poopRootPart.AssemblyLinearVelocity = backwardDirection * pushStrength
		end

		local poopFlush = poopClone:FindFirstChildOfClass("Model")
			and poopClone:FindFirstChildOfClass("Model"):FindFirstChild("PoopTop")
			and poopClone:FindFirstChildOfClass("Model"):FindFirstChild("PoopTop"):FindFirstChildOfClass("Sound")

		handleSoundAndDelays(duration, startSound, poopFlush, player, poopClone)
	end
end)

slapLogicPassiveBind.Event:Connect(function(player: Player, abilityVals: Instance)
	local char = player.Character
	local abilityType = abilityVals:GetAttribute("abilityType")

	if abilityType == enums.abilityTypes.slimy then
		print("slimy :>")
	else
		warn("no passive types")
	end
end)
