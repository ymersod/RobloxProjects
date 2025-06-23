local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local killModule = require(
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("killPlayerServer")
)
local ragdollEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("RagdollClient")

local ServerScriptService = game:GetService("ServerScriptService")
local dailyRewardScript =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("dailyReward")

local dailyRewardFunctions = require(dailyRewardScript)

local expManagerFunctions =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("expManagerFunctions")
local expFuncs = require(expManagerFunctions)

local inventoryFunctionsScript =
	ServerScriptService:WaitForChild("Server"):WaitForChild("ServerModuleScripts"):WaitForChild("inventoryFunctions")
local inventoryFunctions = require(inventoryFunctionsScript)

local dataStoreDevManagementFunctionsScript = ServerScriptService:WaitForChild("Server")
	:WaitForChild("ServerModuleScripts")
	:WaitForChild("dataStoreDevManagement")
local dataStoreDevManagementFunctions = require(dataStoreDevManagementFunctionsScript)

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
		elseif command.command == "/getdailyprogress" then
			local dailyRewards = dailyRewardFunctions.getRewardProgress(player.UserId)
			print(dailyRewards)
		elseif command.command == "/claimdaily" then
			local dailyReward = dailyRewardFunctions.progressRewards(player.UserId)
			print(dailyReward)
		elseif command.command == "/resetdaily" then
			local resetResponse = dailyRewardFunctions.resetPlayer(player.UserId)
			print(resetResponse)
		elseif command.command == "/removeplayerfromstore" then
			if #command.args >= 0 then
				if #command.args == 1 or #command.args == 2 and command.args[2] == "daily" then
					local response = dataStoreDevManagementFunctions.removePlayerDailyRewardStore(command.args[1])
					print(response)
				end
				if #command.args == 1 or #command.args == 2 and command.args[2] == "xp" then
					local response = dataStoreDevManagementFunctions.removePlayerExpStore(command.args[1])
					print(response)
				end
				if #command.args == 1 or #command.args == 2 and command.args[2] == "orderedxp" then
					local response = dataStoreDevManagementFunctions.removePlayerOrderedExpStore(command.args[1])
					print(response)
				end
				if #command.args == 1 or #command.args == 2 and command.args[2] == "inventory" then
					local response = dataStoreDevManagementFunctions.removePlayerInventoryStore(command.args[1])
					print(response)
				end
				if #command.args == 1 or #command.args == 2 and command.args[2] == "ticket" then
					local response = dataStoreDevManagementFunctions.removePlayerTicketStore(command.args[1])
					print(response)
				end
			end
		elseif command.command == "/getuserid" then
			print(player.UserId)
		elseif command.command == "/lookupusername" then
			if #command.args > 0 then
				print(players:GetNameFromUserIdAsync(command.args[1]))
			end
		end
	end)
end)
