local players = game:GetService("Players")
local runner = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local compositeIntValueMultiton = require(ServerScriptService.Server.ServerModuleScripts.CompositeIntValueMultiton)

local crown = serverStorage:WaitForChild("Hats"):WaitForChild("Crown") :: Part
local curCrown: Part? = nil

local oldLeader: Player? = nil
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
		if child:IsA("Player") and (not oldLeader or child.UserId ~= oldLeader.UserId) then
			local compIntValue = compositeIntValueMultiton.getCompositeIntValue(child.UserId.."ExpBoost")
			if compIntValue.containsMod("KingExpBoost") then
				compIntValue -= { Name = "KingExpBoost", Value = 100 }
			end
			local speedCompIntValue = compositeIntValueMultiton.getCompositeIntValue(child.UserId.."SpeedValue")
			if speedCompIntValue.containsMod("KingSpeedBoost") then
				speedCompIntValue.removeModifier("KingSpeedBoost")
				local childHumanoid = child.Character:FindFirstChildOfClass("Humanoid")
				if childHumanoid then
					childHumanoid.WalkSpeed = speedCompIntValue.Value
				end
			end
		end
	end
	if leader and leader.Character then	
		local leaderChar = leader.Character
		local leaderHumanoid = leaderChar:FindFirstChildOfClass("Humanoid")

		if (not leaderHumanoid) or leaderHumanoid.Health < 1 or not leader.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local speedCompIntValue = compositeIntValueMultiton.getCompositeIntValue(leader.UserId.."SpeedValue")
		if leader:IsA("Player") and (not oldLeader or leader.UserId ~= oldLeader.UserId) then
			local compIntValue = compositeIntValueMultiton.getCompositeIntValue(leader.UserId.."ExpBoost")
			if not compIntValue.containsMod("KingExpBoost") then
				compIntValue += { Name = "KingExpBoost", Value = 100 }
			end
			if not speedCompIntValue.containsMod("KingSpeedBoost") then
				speedCompIntValue += { Name = "KingSpeedBoost", Value = 1.5 }
				leaderHumanoid.WalkSpeed = speedCompIntValue.Value
			end
		end

		
		if leader.Character:FindFirstChild("Crown") or (leaderHumanoid and leaderHumanoid.Health <= 0) then
			return
		end
		if leaderHumanoid.WalkSpeed ~= speedCompIntValue.Value then
			leaderHumanoid.WalkSpeed = speedCompIntValue.Value
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
	oldLeader = leader
end)
