local kingZoneHighlightFunctions = {}

function kingZoneHighlightFunctions.Highlight(spinnerFrame: Frame, backGlowImage: ImageLabel, duration: number)
	spinnerFrame.Visible = true

	task.delay(duration, function()
		spinnerFrame.Visible = false
		backGlowImage.Visible = false
	end)
end

return kingZoneHighlightFunctions
