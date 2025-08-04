local CollectionService = game:GetService("CollectionService")

local volumeMixerFunction = {}

type internalVolumeMixer = {
	GeneralVolume: number,
	MusicVolume: number,
	UIVolume: number,
	FXVolume: number,
	sounds: {
		musicBaseVolume: { [Sound]: number },
		uiSoundBaseVolume: { [Sound]: number },
		fxSoundBaseVolume: { [Sound]: number },
	},
	SetGeneralVolume: (number) -> (),
	SetMusicVolume: (number) -> (),
	SetUIVolume: (number) -> (),
	SetFXVolume: (number) -> (),
}
type VolumeMixer = {
	--- Volume variable for changing the volume of all sounds, DO NOT WRITE ON THIS VARIABLE
	GeneralVolume: number,
	--- Volume variable for music sounds, DO NOT WRITE ON THIS VARIABLE
	MusicVolume: number,
	--- Volume variable for UI sounds, DO NOT WRITE ON THIS VARIABLE
	UIVolume: number,
	--- Volume variable for in game effect sounds, DO NOT WRITE ON THIS VARIABLE
	FXVolume: number,
	--- Sets the general volume, the value should always be between 0 and 1
	SetGeneralVolume: (number) -> (),
	--- Sets the volume of music, the value should always be between 0 and 1
	SetMusicVolume: (number) -> (),
	--- Sets the volume of ui sound effects, the value should always be between 0 and 1
	SetUIVolume: (number) -> (),
	--- Sets the volume of world sound effects, the value should always be between 0 and 1
	SetFXVolume: (number) -> (),
}

--- Returns a mixer for setting volume values, should only be called from a client script
function volumeMixerFunction.new(): VolumeMixer
	local obj = {}

	obj.GeneralVolume = 0.5
	obj.MusicVolume = 0.5
	obj.UIVolume = 0.5
	obj.FXVolume = 0.5

	-- get initial sounds
	obj.sounds = {}
	obj.sounds.musicBaseVolume = {}
	local music: { Sound } = CollectionService:GetTagged("music")
	for i, m in ipairs(music) do
		obj.sounds.musicBaseVolume[m] = m.Volume
	end

	obj.sounds.uiSoundBaseVolume = {}
	local UISounds: { Sound } = CollectionService:GetTagged("uisound")
	for i, s in ipairs(UISounds) do
		obj.sounds.uiSoundBaseVolume[s] = s.Volume
	end

	obj.sounds.fxSoundBaseVolume = {}
	local FXSounds: { Sound } = CollectionService:GetTagged("fxsound")
	for i, s in ipairs(FXSounds) do
		obj.sounds.fxSoundBaseVolume[s] = s.Volume
	end

	-- setup event handlers for new sounds
	CollectionService:GetInstanceAddedSignal("music"):Connect(function(sound: Sound)
		obj.sounds.musicBaseVolume[sound] = sound.Volume
		sound.Volume *= obj.MusicVolume * obj.GeneralVolume
	end)
	CollectionService:GetInstanceAddedSignal("uisound"):Connect(function(sound: Sound)
		obj.sounds.uiSoundBaseVolume[sound] = sound.Volume
		sound.Volume *= obj.UIVolume * obj.GeneralVolume
	end)
	CollectionService:GetInstanceAddedSignal("fxsound"):Connect(function(sound: Sound)
		obj.sounds.fxSoundBaseVolume[sound] = sound.Volume
		sound.Volume *= obj.FXVolume * obj.GeneralVolume
	end)

	-- setup cleanup event handlers
	CollectionService:GetInstanceRemovedSignal("music"):Connect(function(sound: Sound)
		obj.sounds.musicBaseVolume[sound] = nil
	end)
	CollectionService:GetInstanceRemovedSignal("uisound"):Connect(function(sound: Sound)
		obj.sounds.uiSoundBaseVolume[sound] = nil
	end)
	CollectionService:GetInstanceRemovedSignal("fxsound"):Connect(function(sound: Sound)
		obj.sounds.fxSoundBaseVolume[sound] = nil
	end)

	function obj.SetGeneralVolume(number: number)
		if number > 1 or number < 0 then
			warn("Volume settings should always be between 0 and 1")
		end

		obj.GeneralVolume = number
		for sound, baseVol in pairs(obj.sounds.musicBaseVolume) do
			sound.Volume = baseVol * obj.MusicVolume * obj.GeneralVolume
		end
		for sound, baseVol in pairs(obj.sounds.uiSoundBaseVolume) do
			sound.Volume = baseVol * obj.UIVolume * obj.GeneralVolume
		end
		for sound, baseVol in pairs(obj.sounds.fxSoundBaseVolume) do
			sound.Volume = baseVol * obj.FXVolume * obj.GeneralVolume
		end
	end
	function obj.SetMusicVolume(number: number)
		if number > 1 or number < 0 then
			warn("Volume settings should always be between 0 and 1")
		end

		obj.MusicVolume = number
		for sound, baseVol in pairs(obj.sounds.musicBaseVolume) do
			sound.Volume = baseVol * obj.MusicVolume * obj.GeneralVolume
		end
	end
	function obj.SetUIVolume(number: number)
		if number > 1 or number < 0 then
			warn("Volume settings should always be between 0 and 1")
		end

		obj.UIVolume = number
		for sound, baseVol in pairs(obj.sounds.uiSoundBaseVolume) do
			sound.Volume = baseVol * obj.UIVolume * obj.GeneralVolume
		end
	end
	function obj.SetFXVolume(number: number)
		if number > 1 or number < 0 then
			warn("Volume settings should always be between 0 and 1")
		end

		obj.FXVolume = number
		for sound, baseVol in pairs(obj.sounds.fxSoundBaseVolume) do
			sound.Volume = baseVol * obj.FXVolume * obj.GeneralVolume
		end
	end

	return obj
end

return volumeMixerFunction
