local Players = game:GetService("Players")

local abilityUtils = {}

function abilityUtils.SpawnPoop(character: Model, tool: Tool)
	local spawnableRef = tool:FindFirstChildOfClass("ObjectValue")
	local poop = spawnableRef and spawnableRef.Value

	if not poop then
		warn("Couldn't find spawnable ref")
		return
	end

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

	return poopFlush, poopClone
end

function abilityUtils.createAOEVisualization(originPosition, radius, duration)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.7
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0) -- red or any color you want
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
	part.CFrame = CFrame.new(originPosition)
	part.Parent = workspace

	-- Optional: make it slightly above the ground if you want a cylinder instead of a ball:
	-- part.Size = Vector3.new(radius * 2, 1, radius * 2)
	-- part.CFrame = CFrame.new(originPosition.X, originPosition.Y + 1, originPosition.Z)

	-- Destroy after duration
	task.delay(duration, function()
		part:Destroy()
	end)
end
local function visualizeCone(
	origin: Vector3,
	forward: Vector3,
	coneAngle: number,
	coneDistance: number,
	segments: number
)
	local folder = Instance.new("Folder")
	folder.Name = "ConeVisualization"
	folder.Parent = workspace

	local halfAngleRad = math.rad(coneAngle)
	local step = (halfAngleRad * 2) / segments

	for i = 0, segments do
		local angle = -halfAngleRad + (step * i)
		local rotatedDir = CFrame.fromAxisAngle(Vector3.yAxis, angle) * forward
		local endPos = origin + rotatedDir.Unit * coneDistance

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0.1, 0.1, (endPos - origin).Magnitude)
		part.CFrame = CFrame.new(origin, endPos) * CFrame.new(0, 0, -part.Size.Z / 2)
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Material = Enum.Material.Neon
		part.Transparency = 0.5
		part.Name = "ConeRay"
		part.Parent = folder
	end

	-- Clean up visualization after a few seconds
	game:GetService("Debris"):AddItem(folder, 2)
end

function abilityUtils.getPlayersInCone(
	originPlayer: Player,
	originPos: Vector3,
	forwardDir: Vector3,
	coneAngle: number,
	coneDistance: number
): { Player }
	local playersInCone = {}
	local cosAngle = math.cos(math.rad(coneAngle)) -- For dot product comparison

	local segments = 20
	-- visualizeCone(originPos, forwardDir, coneAngle, coneDistance, segments)
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= originPlayer then
			local otherChar = otherPlayer.Character
			local otherHRP = otherChar and otherChar:FindFirstChild("HumanoidRootPart")

			if otherHRP then
				local toTarget = (otherHRP.Position - originPos)
				local distance = toTarget.Magnitude

				if distance <= coneDistance then
					local dirToTarget = toTarget.Unit
					local dot = forwardDir:Dot(dirToTarget)

					if dot >= cosAngle then
						table.insert(playersInCone, otherPlayer)
					end
				end
			end
		end
	end

	return playersInCone
end
return abilityUtils
