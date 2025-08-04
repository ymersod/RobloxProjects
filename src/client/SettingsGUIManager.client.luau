local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local VolumePersistenceExchangeEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"):WaitForChild("VolumePersistenceExchange")

local createTweenFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.createTweenFunctions)
local sounds = require(ReplicatedStorage.Shared.ClientServerModuleScripts.sounds)
local volumeMixerFunctions = require(ReplicatedStorage.Shared.ClientServerModuleScripts.volumeMixerFunctions)
local volumeMixer = volumeMixerFunctions.new()
local Player = game:GetService("Players").LocalPlayer
local screenGui = Player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local volumes = {
	General = "General",
	Music = "Music",
	SFX = "SFX",
	UI = "UI",
}

local settings = screenGui:WaitForChild("Settings")
local clipLeftBot = settings:WaitForChild("ClipLeftBot")
local SliderParents: { Frame } = clipLeftBot:GetChildren()
type SliderUI = {
	sliderButton: ImageButton,
	sliderFill: Frame,
}
local closeButton = settings:WaitForChild("ImageButton")

local shrinkTween = createTweenFunctions.Shrink2(settings, 0.1, UDim2.new(0, 0, 0, 0))

local function SetupSlider(SliderParent: Frame, slider: Frame, handle: ImageButton)
	local sliderVolumeType = SliderParent:GetAttribute("Volumes")

	local dragging = false
	local function updateSlider(inputX)
		local sliderAbsPos = slider.AbsolutePosition.X
		local sliderWidth = slider.AbsoluteSize.X
		local handleWidth = handle.AbsoluteSize.X
		local halfHandleWidth = handleWidth / 2

		local relativeX = inputX - sliderAbsPos

		local minX = halfHandleWidth
		local maxX = sliderWidth + halfHandleWidth

		relativeX = math.clamp(relativeX, minX, maxX)

		local percent = (relativeX - minX) / (maxX - minX)

		local scaledX = (relativeX - halfHandleWidth) / sliderWidth

		handle.Position = UDim2.new(scaledX, 0, 0.5, 0)

		print("Slider Value: " .. math.floor(percent))
		print(sliderVolumeType)
		if sliderVolumeType == volumes.General then
			volumeMixer.SetGeneralVolume(percent)
		elseif sliderVolumeType == volumes.Music then
			volumeMixer.SetMusicVolume(percent)
		elseif sliderVolumeType == volumes.UI then
			volumeMixer.SetUIVolume(percent)
		elseif sliderVolumeType == volumes.SFX then
			volumeMixer.SetFXVolume(percent)
		else
			warn("SliderVolumeType doesnt exist")
		end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			print("saving volume setting")
			VolumePersistenceExchangeEvent:FireServer(volumeMixer.GetVolumeSettingsPersistenceString())
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)
end

local sliders: {{parent:Frame,slider:ImageButton}} = {}
for _, sliderParent in ipairs(SliderParents) do
	if not sliderParent:IsA("Frame") then
		continue
	end
	local sliderFill = sliderParent:WaitForChild("SliderBg") :: Frame
	local sliderButton = sliderFill:WaitForChild("SliderHandle") :: ImageButton
	table.insert(sliders,{ parent = sliderFill, slider = sliderButton})

	SetupSlider(sliderParent, sliderFill, sliderButton)
end

closeButton.MouseButton1Click:Connect(function()
	SoundService:PlayLocalSound(sounds.CloseGUI)
	shrinkTween:Play()
	shrinkTween.Completed:Connect(function()
		settings.Visible = false
	end)
end)

VolumePersistenceExchangeEvent.OnClientEvent:Connect(function(volumeSettingsPersistenceString)
	volumeMixer.LoadVolumeSettings(volumeSettingsPersistenceString)
	for i, slider in ipairs(sliders) do
		if slider.parent.Parent:GetAttribute("Volumes") == volumes.General then
			slider.slider.Position = UDim2.new(volumeMixer.GeneralVolume, 0, 0.5, 0)
		elseif slider.parent.Parent:GetAttribute("Volumes") == volumes.Music then
			slider.slider.Position = UDim2.new(volumeMixer.MusicVolume, 0, 0.5, 0)
		elseif slider.parent.Parent:GetAttribute("Volumes") == volumes.UI then
			slider.slider.Position = UDim2.new(volumeMixer.UIVolume, 0, 0.5, 0)
		elseif slider.parent.Parent:GetAttribute("Volumes") == volumes.SFX then
			slider.slider.Position = UDim2.new(volumeMixer.FXVolume, 0, 0.5, 0)
		end
	end
end)