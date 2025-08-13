local Player = game:GetService("Players").LocalPlayer

local localstats = Player:WaitForChild("LocalStats")
local speedIntVal: IntValue = localstats:WaitForChild("SpeedValue")
local jumpIntVal: IntValue = localstats:WaitForChild("JumpValue")
local expBoost: IntValue = localstats:WaitForChild("ExpBoost")

local ScreenGui = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local statboosts = ScreenGui:WaitForChild("Statboosts")
local jumpText = statboosts:WaitForChild("Jump"):FindFirstChildOfClass("TextLabel")
local speedText = statboosts:WaitForChild("Speed"):FindFirstChildOfClass("TextLabel")
local expText = statboosts:WaitForChild("Xp"):FindFirstChildOfClass("TextLabel")

local SPEED_BASE = speedIntVal.Value
local JUMP_BASE = jumpIntVal.Value
local EXP_BASE = expBoost.Value

local function animateNumber(label: TextLabel, oldValue: number, newValue: number, prefix: string)
	local duration = 0.3

	local animConn = label:FindFirstChild("AnimConn")
	if animConn then
		animConn:Disconnect()
		animConn:Destroy()
	end

	local animConn = Instance.new("BindableEvent")
	animConn.Parent = label

	local startTime = tick()
	local conn
	conn = game:GetService("RunService").RenderStepped:Connect(function()
		local alpha = math.min((tick() - startTime) / duration, 1)
		local value = oldValue + (newValue - oldValue) * alpha
		label.Text = string.format("%s : %.1fx", prefix, value)

		if alpha >= 1 then
			conn:Disconnect()
			animConn:Destroy()
		end
	end)
end
local lastSpeedMult = speedIntVal.Value / SPEED_BASE
local lastJumpMult = jumpIntVal.Value / JUMP_BASE
local lastExpMult = expBoost.Value / EXP_BASE

function setup()
	speedIntVal.Changed:Connect(function()
		local mult = speedIntVal.Value / SPEED_BASE
		animateNumber(speedText, lastSpeedMult, mult, "Speed")
		lastSpeedMult = mult
	end)

	jumpIntVal.Changed:Connect(function()
		local mult = jumpIntVal.Value / JUMP_BASE
		animateNumber(jumpText, lastJumpMult, mult, "Jump")
		lastJumpMult = mult
	end)

	expBoost.Changed:Connect(function()
		local mult = expBoost.Value / EXP_BASE
		animateNumber(expText, lastExpMult, mult, "EXP")
		lastExpMult = mult
	end)
end

setup()
