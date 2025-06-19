local globalLeaderBoardScript = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("globalLeaderBoard")

local funcs = require(globalLeaderBoardScript)

local players = game:GetService("Players")

local gridframe = script.Parent:WaitForChild("SurfaceGui"):WaitForChild("GridFrame")

local function CreateText(rank, playerName, playerLvl)
	local frame1 = Instance.new("Frame")
	frame1.Name = rank .. "1Frame"
	frame1.Size = UDim2.fromScale(0.5, 0.05)
	frame1.BackgroundColor3 = Color3.fromHex("#000000")
	frame1.BackgroundTransparency = 0.9
	local label1 = Instance.new("TextLabel")
	label1.TextSize = 40
	label1.Size = UDim2.fromScale(1, 1)
	label1.BackgroundColor3 = Color3.fromHex("#ffffff")
	label1.Text = playerName
	label1.TextColor3 = Color3.fromHex("#000000")
	label1.TextTransparency = 0
	label1.BackgroundTransparency = 1
	label1.Parent = frame1
	label1.TextTruncate = Enum.TextTruncate.AtEnd
	
	local frame2 = frame1:Clone()
	frame2.Name = rank .. "2Frame"
	frame2.Size = UDim2.fromScale(0.3, 0.05)
	local level2 : TextLabel = frame2:FindFirstChild("TextLabel") 
	level2.Text = playerLvl
	local frame0 = frame1:Clone()
	frame0.Name = rank .. "0Frame"
	frame0.Size = UDim2.fromScale(0.1, 0.05)
	local level0 : TextLabel = frame0:FindFirstChild("TextLabel") 
	level0.Text = "#" .. rank
	return frame0, frame1, frame2
end

local leaderboardCoroutine = coroutine.create(function()
	while true do
		local sortedLevels = funcs.GetTop10()
		local playerRanks = {}
		for i, e in ipairs(sortedLevels) do
			local success, playerName = pcall(function() 
				return players:GetNameFromUserIdAsync(e.key)
			end)
			if success then
				table.insert(playerRanks,{rank = i, name = playerName, lvl = e.value})
			end
		end
		local layout = gridframe:FindFirstChildOfClass("UIListLayout"):Clone()
		gridframe:ClearAllChildren()
		layout.Parent = gridframe
		for i, p in ipairs(playerRanks) do
			local frame0, frame1, frame2 = CreateText( p.rank, p.name, p.lvl)
			frame0.Parent = gridframe
			frame1.Parent = gridframe
			frame2.Parent = gridframe
		end
		wait(1)
	end
end)

coroutine.resume(leaderboardCoroutine)
