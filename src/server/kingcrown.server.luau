local players = game:GetService("Players")
local runer = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")

local crown = serverStorage:WaitForChild("Hats"):WaitForChild("Part") :: Part 
local oldCrownScore = 0

runer.Heartbeat:Connect(function()
    local topScore = 0
    local leader:Player?
    for i, child in ipairs(players:GetChildren()) do
        local leaderstats = child and child:FindFirstChild("leaderstats")
        local kingScore = leaderstats and leaderstats:FindFirstChild("King Score")
        if kingScore.Value > topScore then
            topScore = kingScore.Value
            leader = child
        end
    end
    if leader and leader.Character and (oldCrownScore ~= topScore or not crown:FindFirstChildOfClass("WeldConstraint")) then
        if crown:FindFirstChildOfClass("WeldConstraint") then crown:FindFirstChildOfClass("WeldConstraint"):Destroy() end
        oldCrownScore = topScore
        local weld = Instance.new("WeldConstraint")
        crown.Position = (leader.Character:WaitForChild("HumanoidRootPart") :: Part).Position + Vector3.yAxis*5
        crown.Rotation = (leader.Character:WaitForChild("HumanoidRootPart") :: Part).Rotation
        weld.Part0 = leader.Character:WaitForChild("HumanoidRootPart")
        weld.Part1 = crown
        crown.Parent = workspace
        weld.Parent = crown
    end
end)