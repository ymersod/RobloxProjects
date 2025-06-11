local players = game:GetService("Players")

local part = script.Parent

local kingCandidates = {}

local function getPlayer(col: { name: string, Parent: Model }): Player?
	local char = col.Parent
	if not char or col.name ~= "HumanoidRootPart" then
		return nil
	end

	local player = players:GetPlayerFromCharacter(char)

	return player
end

local function removePlayerWithId(T, id)
	for i, item in ipairs(T) do
		if item.id == id then
			T[i] = nil
			print("removed: " .. item.id)
		end
		if T[i] == nil then
			T[i] = T[i + 1]
			T[i + 1] = nil
		end
	end
	return T
end

local function removeAllPlayersNotInList(list,toBeKeptList)
    local playerIds = {}
    for i,p in ipairs(toBeKeptList) do
        local player = getPlayer(p)
        if player then
            playerIds[#playerIds+1] = player.UserId
        end
    end
    for i,p in ipairs(list) do
        if function() for i, pid in ipairs(playerIds) do if pid == p.id then return false end return true end end then
            list = removePlayerWithId(list, p.id)
        end
    end
    return list
end

local function tryToAddPlayer(T, entry)
	local playerIsAlreadyInSet = false
	print(#T)
	for _, item in ipairs(T) do
		if item.id == entry.id then
			playerIsAlreadyInSet = true
		end
	end

	if not playerIsAlreadyInSet then
		T[#T + 1] = entry
	end
	return T
end

local function partListContainsPlayer(list)
	for _, p in ipairs(list) do
		if getPlayer(p) then
			return true
		end
	end
	return false
end

local function scoreKing()
	while true do
		local partsInZone = workspace:GetPartsInPart(part)
		if partListContainsPlayer(partsInZone) then
			if #kingCandidates == 1 then
				kingCandidates[1].kingScore.Value += 1
			end
			part.Color = Color3.fromRGB(255, 0, 0)
		else
			part.Color = Color3.fromRGB(163, 162, 165)
			kingCandidates = removeAllPlayersNotInList(kingCandidates,partsInZone)
		end
		task.wait(1)
	end
end

local scorer = coroutine.create(scoreKing)
coroutine.resume(scorer)

local function onTouched(otherPart)
	local player = getPlayer(otherPart)
	if player ~= nil and not part:GetAttribute("Touched") then
		print(part.Name .. " collided with " .. player.Name)
		local leaderstats = player and player:FindFirstChild("leaderstats")
		local kingScore = leaderstats and leaderstats:FindFirstChild("King Score")

		if kingScore then
			kingCandidates = tryToAddPlayer(kingCandidates, { id = player.UserId, kingScore = kingScore })
		end
	end
end

part.Touched:Connect(onTouched)
