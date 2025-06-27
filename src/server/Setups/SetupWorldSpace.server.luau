local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local MovingPlatformScript = ServerScriptService:WaitForChild("Server"):WaitForChild("MovingPlatform")

-- Adding script to moving platforms
for _, platform in pairs(CollectionService:GetTagged("MovingPlatform")) do
	local MovingPlatformScriptClone = MovingPlatformScript:Clone()
	MovingPlatformScriptClone.Parent = platform
end
