local ServerStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local kingZoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("kingzone")
local bombScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("bombLogic")
local slapScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("slaplogic")
local safezoneScript = replicatedStorage:WaitForChild("Shared"):WaitForChild("DynamicLogic"):WaitForChild("Safezone")

local bombPrefab: Tool = ServerStorage:WaitForChild("Tools"):WaitForChild("Bombs"):WaitForChild("Bomb")
local slapPrefab: Tool = ServerStorage:WaitForChild("Tools"):WaitForChild("Slapstyles"):WaitForChild("CommonStyle0")

kingZoneScript.Parent = workspace:FindFirstChild("Kingzone")
safezoneScript.Parent = workspace:FindFirstChild("Safezone")

local bombScriptClone = bombScript:Clone()
bombScriptClone.Parent = bombPrefab.PrimaryPart

local slapScriptClone = slapScript:Clone()
slapScriptClone.Parent = slapPrefab.PrimaryPart
