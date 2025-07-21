local players = game:GetService("Players")
local player = players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local billboardGUI = ReplicatedStorage:WaitForChild("UI"):WaitForChild("PointGainBillboard")

local expGainClient = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("ExpGainClient")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)

local billboard: BillboardGui = nil

player.CharacterAdded:Connect(function(character)
	local head = character:FindFirstChild("Head")

	if head then
		billboard = billboardGUI:Clone()
		billboard.Parent = head
		billboard.Enabled = true
	end
end)

expGainClient.OnClientEvent:Connect(function(amount: number)
	if not billboard then
		return
	end

	local textLabel = billboard:FindFirstChildOfClass("TextLabel")
	if not textLabel then
		return
	end
	textLabel = textLabel:Clone()
	textLabel.Parent = billboard

	textLabel.Text = (if amount >=0 then "+" .. amount else amount) .. " XP"

	textLabel.Visible = true
	local blowUpTween, floatUpTween = createTweenFunctions.FloatTextUp(textLabel, 0.25, 1, UDim2.fromScale(0.8, 0.8), UDim2.fromScale(0.5, 0))
	floatUpTween.Completed:Once(function()
		textLabel:Destroy()
	end)

	blowUpTween.Completed:Once(function()
		floatUpTween:Play()
	end)

	blowUpTween:Play()
end)