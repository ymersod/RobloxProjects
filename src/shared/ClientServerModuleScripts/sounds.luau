local NonSpacialSounds = workspace:FindFirstChild("NonSpacialSounds")

local sounds = {
	Click = NonSpacialSounds:FindFirstChild("Button Click") :: Sound,
	Equip = NonSpacialSounds:FindFirstChild("Equip sound") :: Sound,
	Claim = NonSpacialSounds:FindFirstChild("Donate Claim Sound") :: Sound,
	CloseGUI = NonSpacialSounds:FindFirstChild("GUI CLOSE SOUND") :: Sound,
	Jumppads = NonSpacialSounds:FindFirstChild("Bounce - Sonic the Hedgehog SFX") :: Sound,
	Gacha = NonSpacialSounds:FindFirstChild("Half a Fruitcake sting b") :: Sound,
}

return sounds
