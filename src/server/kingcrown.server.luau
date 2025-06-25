local players = game:GetService("Players")
local runner = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")

local crown = serverStorage:WaitForChild("Hats"):WaitForChild("Crown") :: Part
local curCrown: Part? = nil

runner.Heartbeat:Connect(function()
	local topScore = 0
	local leader: Player?
	for _, child in ipairs(players:GetChildren()) do
		local leaderstats = child and child:FindFirstChild("leaderstats")
		local kingScore = leaderstats and leaderstats:FindFirstChild("King Score")
		if kingScore.Value > topScore then
			topScore = kingScore.Value
			leader = child
		end
		local xpBoostIntValue : IntValue = child and child:WaitForChild("LocalStats"):WaitForChild("ExpBoost")
		if xpBoostIntValue then
			xpBoostIntValue.Value = 100
		end
	end
	if leader and leader.Character then	
		local xpBoostIntValue : IntValue = leader:WaitForChild("LocalStats"):WaitForChild("ExpBoost") :: IntValue
		if xpBoostIntValue then
			xpBoostIntValue.Value = 130
		end

		local leaderChar = leader.Character
		local leaderHumanoid = leaderChar:FindFirstChildOfClass("Humanoid")
		if leader.Character:FindFirstChild("Crown") or (leaderHumanoid and leaderHumanoid.Health <= 0) then
			return
		end
		if curCrown then
			curCrown:Destroy()
		end
		local crownClone = crown:Clone()

		local weld = Instance.new("WeldConstraint")
		crownClone.Position = (leader.Character:WaitForChild("HumanoidRootPart") :: Part).Position + Vector3.yAxis * 5
		crownClone.Rotation = (leader.Character:WaitForChild("HumanoidRootPart") :: Part).Rotation
		weld.Part0 = leader.Character:WaitForChild("HumanoidRootPart")
		weld.Part1 = crownClone
		weld.Parent = crownClone

		crownClone.Parent = leader.Character
		curCrown = crownClone
	end
end)
