local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputSevice = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local flyToggleEvent = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Events")
	:WaitForChild("FlyToggleClient")

local GRAVITY = workspace.Gravity

-- Variables used in flying
local Up = Vector3.zero
local Down = Vector3.zero
local isMovingObj: { Forward:boolean, Backward:boolean, Up:boolean, Down:boolean, OR:({Forward:boolean, Backward:boolean, Up:boolean, Down:boolean})->boolean} = {
	Forward = false,
	Backward = false,
	Up = false,
	Down = false,
	OR = function(this)
		return this.Forward or this.Backward or this.Up or this.Down
	end
}

--- Function for handling main loop of the flying script
function LoopHandler(deltaTime: number)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	local CameraNormal = vector.zero
	if isMovingObj.Forward then
		CameraNormal = workspace.CurrentCamera.CFrame.LookVector
	elseif isMovingObj.Backward then
		CameraNormal = -workspace.CurrentCamera.CFrame.LookVector
	end

	if isMovingObj:OR() then
		rootPart.AssemblyLinearVelocity += CameraNormal + Up + Down
		if (rootPart.AssemblyLinearVelocity :: Vector3).Magnitude < 50 then
			rootPart.AssemblyLinearVelocity *= Vector3.new(2, 1, 2)
		end
	else
		rootPart.AssemblyLinearVelocity = Vector3.zero
	end


end

--- Function for handling rising edge input
function InputStartHandler(inputObj: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end
	if inputObj.KeyCode == Enum.KeyCode.W then
		isMovingObj.Forward = true
	elseif inputObj.KeyCode == Enum.KeyCode.S then
		isMovingObj.Backward = true
	elseif inputObj.KeyCode == Enum.KeyCode.Space then
		Up = Vector3.yAxis
		isMovingObj.Up = true
	elseif inputObj.KeyCode == Enum.KeyCode.C then
		Down = -Vector3.yAxis
		isMovingObj.Down = true
	end
end

--- Function for handling falling edge input
function InputEndHandler(inputObj: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end
	if inputObj.KeyCode == Enum.KeyCode.W then
		isMovingObj.Forward = false
	elseif inputObj.KeyCode == Enum.KeyCode.S then
		isMovingObj.Backward = false
	elseif inputObj.KeyCode == Enum.KeyCode.Space then
		Up = Vector3.zero
		isMovingObj.Up = false
	elseif inputObj.KeyCode == Enum.KeyCode.C then
		Down = Vector3.zero
		isMovingObj.Down = false
	end
end

InputSevice.InputBegan:Connect(InputStartHandler)
InputSevice.InputEnded:Connect(InputEndHandler)

local heartbeatConnection : RBXScriptConnection? = nil
flyToggleEvent.OnClientEvent:Connect(function()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		workspace.Gravity = GRAVITY
	else
		heartbeatConnection = RunService.Heartbeat:Connect(LoopHandler)
		workspace.Gravity = 0
	end
end)
