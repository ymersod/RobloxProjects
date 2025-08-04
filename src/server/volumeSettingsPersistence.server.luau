local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local volumeSettingsDataStore = DataStoreService:GetDataStore("VolumeSettings")

local players = game:GetService("Players")

local VolumePersistenceExchangeEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("VolumePersistenceExchange")

players.PlayerAdded:Connect(function(player)
	local success, volumeSettingsPersistenceString = pcall(function()
		return volumeSettingsDataStore:GetAsync(player.UserId)
	end)
	if success and volumeSettingsPersistenceString then
		VolumePersistenceExchangeEvent:FireClient(player, volumeSettingsPersistenceString)
	end
end)

VolumePersistenceExchangeEvent.OnServerEvent:Connect(function(player, volumeSettingsPersistenceString)
	print("saving volume setting")
	local success, err = pcall(function()
		return volumeSettingsDataStore:SetAsync(player.UserId, volumeSettingsPersistenceString)
	end)
	if not success then
		warn(err)
	end
end)