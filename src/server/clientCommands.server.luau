local ReplicatedStorage = game:GetService("ReplicatedStorage")
local killModule =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ModuleScripts"):WaitForChild("killPlayerServer"))
local ragdollEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")
local expManagerFunctions = game:GetService("ReplicatedStorage")
	:WaitForChild("Shared")
	:WaitForChild("ModuleScripts")
	:WaitForChild("expManagerFunctions")
local expFuncs = require(expManagerFunctions)

local inventoryFunctionsScript = game:GetService("ReplicatedStorage")
	:WaitForChild("Shared")
	:WaitForChild("ModuleScripts")
	:WaitForChild("inventoryFunctions")
local inventoryFunctions = require(inventoryFunctionsScript)

local slapStyleFolder: Folder = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Slapstyles")

local function subSet(array: { any }, iStart: number, iEnd: number?)
	if iEnd == nil then
		iEnd = #array
	end
	local window = {}
	for i, pair in ipairs(array) do
		if i >= iStart and i <= iEnd then
			window[#window + 1] = pair
		end
	end
	return window
end

local function parseCommand(string: string): { command: string, args: { string } }
	local parts = string:split(" ")
	if parts[1]:find("^/") == nil then
		return { command = "none", args = {} }
	end

	return { command = parts[1], args = subSet(parts, 2) }
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local command = parseCommand(message)
		if command.command == "/kill" then
			killModule.killPlayer(player.Character, player)
		elseif command.command == "/ragdoll" then
			ragdollEvent:FireClient(player, player.Character.PrimaryPart.Position, Vector3.new(1000, 1000, 1000))
		elseif command.command == "/selfxp" then
			if #command.args > 0 then
				expFuncs.incrementExp(player.UserId, tonumber(command.args[1]))
			end
		elseif command.command == "/setselfxp" then
			if #command.args > 0 then
				expFuncs.setExp(player.UserId, tonumber(command.args[1]))
			end
		elseif command.command == "/addtool" then
			if #command.args > 0 then
				local styles = slapStyleFolder:GetDescendants()
				for i, style in ipairs(styles) do
					if style:GetAttribute("ToolId") == command.args[1] then
						inventoryFunctions.AddToInventory(player, style, command.args[2])
					end
				end
			end
		elseif command.command == "/clearinventory" then
			inventoryFunctions.RemoveAllFromInventory(player)
		elseif command.command == "/clearslot" then
			if #command.args > 0 then
				inventoryFunctions.RemoveFromInventory(player, command.args[1])
			end
		end
	end)
end)
