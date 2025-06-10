local serverScriptService = game:GetService("ReplicatedStorage")

local kingZoneScript = serverScriptService:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")

kingZoneScript.Parent = workspace:FindFirstChild("Kingzone")