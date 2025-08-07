local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local IsSafeUtil = require(script.Parent.IsSafeUtil)
local inventoryFuncs = require(script.Parent.inventoryFunctions)
local itemSphere = ServerStorage:WaitForChild("Pickups"):WaitForChild("ItemSphere")

local bombUtils = {}

function bombUtils.giveBombToPlayer(player: Player, bomb: Tool)
	if player and player.Character then
		inventoryFuncs.EquipBomb(player, bomb, 0)
	end
end

function bombUtils.createBombItem(bomb: Tool, startingPosition: Vector3, parent)
	local item = itemSphere:Clone()
	item.Position = startingPosition
	item.Parent = parent

	local primary = bomb.PrimaryPart or bomb:FindFirstChild("Handle") --TODO: find out which one it is
	if not primary then
		warn("Bomb tool has no PrimaryPart or Handle to position")
		return
	end

	local bombLogic: Script? = primary:FindFirstChildOfClass("Script")
	if not bombLogic then
		warn("Can't find bomb logic script")
		return
	end

	bombLogic.Enabled = true
	bomb:PivotTo(CFrame.new(startingPosition))
	bomb.Parent = item

	local hitArea = primary:FindFirstChild("HitBox")
	hitArea.CanTouch = false

	-- Making the mesh of the item fit within the itemSphere
	local mesh = primary:FindFirstChildOfClass("MeshPart")
	local worldSize
	local normalSize
	if mesh then -- now assuming mesh is a MeshPart child
		worldSize = Vector3.new(
			primary.Size.X * mesh.Size.X / primary.Size.X, -- mesh.Size.X scaled relative to primary
			primary.Size.Y * mesh.Size.Y / primary.Size.Y,
			primary.Size.Z * mesh.Size.Z / primary.Size.Z
		)
		normalSize = mesh.Size
	else
		worldSize = primary.Size
	end

	local boundingRadius = (worldSize / 2).Magnitude
	local scaleFactor = (itemSphere.Size.Y / 2) / boundingRadius

	if mesh then
		mesh.Size = mesh.Size * scaleFactor
	else
		primary.Size = primary.Size * scaleFactor
	end

	-- Attach bomb to RigidConstraint
	local rigidConstraint = item:FindFirstChildOfClass("RigidConstraint")
	local bombAttachment = Instance.new("Attachment")
	bombAttachment.Name = "BombAttachment"
	bombAttachment.Parent = primary

	if rigidConstraint then
		rigidConstraint.Attachment1 = bombAttachment
	end

	--trying to stop bombs going though mesh
	local att = Instance.new("Attachment")
	att.Parent = item
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Attachment0 = att
	vectorForce.Force = Vector3.new(0, item:GetMass() * workspace.Gravity * 0.90, 0)
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Parent = item

	local touch_key = nil
	item.Touched:Connect(function(hit)
		if touch_key then
			return
		end
		local playerChar = hit:FindFirstAncestorOfClass("Model")
		local player = playerChar and Players:GetPlayerFromCharacter(playerChar)

		if not player then
			return
		end

		if IsSafeUtil.IsSafe(player) then
			return
		end

		touch_key = hit
		task.defer(function()
			if touch_key ~= hit then
				return
			end

			local hasBomb = playerChar:FindFirstChild("Bomb")
			if player and not hasBomb then
				hitArea.CanTouch = true
				bombUtils.giveBombToPlayer(player, bomb)
				item:Destroy()
			end
		end)
	end)

	item.Destroying:Connect(function()
		if not bomb then
			return
		end
		if mesh then
			mesh.Size = normalSize
		else
			primary.Size = normalSize
		end
	end)
	return item
end

return bombUtils
