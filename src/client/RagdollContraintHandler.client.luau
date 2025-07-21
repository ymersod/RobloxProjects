local players = game:GetService("Players")
local player = players.LocalPlayer

function SetupConstraints(character)
	print("adding Ball Sockets")
	local list = character:GetDescendants()
	local itemPairs: { [string]: { item1: Instance, item2: Instance } } = {}
	for i, p in ipairs(list) do
		if p.Name:match("RigAttachment") == nil then
			continue
		end
		if not itemPairs[p.Name] then
			itemPairs[p.Name] = { item1 = p, item2 = nil }
		else
			itemPairs[p.Name].item2 = p
		end
	end
	print(itemPairs)
	for i, p in pairs(itemPairs) do
		local socket = Instance.new("BallSocketConstraint")
		socket.Attachment0 = p.item1
		socket.Attachment1 = p.item2
		socket.Parent = p.item1
		socket.TwistLimitsEnabled = true
		socket.LimitsEnabled = true
	end
end

function WaitForCharacterAndSetup(player)
	player.CharacterAdded:Connect(function(character)
		-- Wait for HumanoidRootPart and Humanoid as indicators the character is loaded
		local hrp = character:WaitForChild("HumanoidRootPart", 2)
		local humanoid = character:WaitForChild("Humanoid", 2)

		if hrp and humanoid then
			-- Optionally wait a few frames to ensure attachments exist
			task.wait(0.1)
			SetupConstraints(character)
		else
			warn("Character not fully loaded for constraints setup.")
		end
	end)

	if player.Character then
		local character = player.Character
		if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			task.wait(0.1)
			SetupConstraints(character)
		end
	end
end
WaitForCharacterAndSetup(player)
