local players = game:GetService("Players")
local player = players.LocalPlayer

local stats : Folder = player:WaitForChild("LocalStats")
local states : Folder = player:WaitForChild("States")

local jumpVal : IntValue = stats:WaitForChild("JumpValue") :: IntValue
local speedVal : IntValue = stats:WaitForChild("SpeedValue") :: IntValue

local canJumpVal : BoolValue = states:WaitForChild("CanJump") :: BoolValue

jumpVal.Changed:Connect(function(number)
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and canJumpVal.Value then
		humanoid.JumpHeight = number
	elseif humanoid and not canJumpVal.Value then
		humanoid.JumpHeight = 0
	end
end)

canJumpVal.Changed:Connect(function(canJump)
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if canJump and humanoid and jumpVal then
		humanoid.JumpHeight = jumpVal.Value
	elseif humanoid and not canJump then
		humanoid.JumpHeight = 0
	end
end)

speedVal.Changed:Connect(function(number)
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = number
	end
end)

player.CharacterAdded:Connect(function(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = speedVal.Value
		humanoid.JumpHeight = jumpVal.Value
	end
end)