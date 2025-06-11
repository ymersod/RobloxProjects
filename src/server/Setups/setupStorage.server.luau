local replicatedStorage = game:GetService("ReplicatedStorage")

local kingZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")
local slapScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")

local bombPrefab = replicatedStorage:WaitForChild("Tools"):WaitForChild("Bomb")
local slapPrefab: Tool = replicatedStorage:WaitForChild("Tools"):WaitForChild("SlapTool")

kingZoneScript.Parent = workspace:FindFirstChild("Kingzone")

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab

local slapScriptClone = slapScript:Clone()
slapScriptClone.Parent = slapPrefab.PrimaryPart
