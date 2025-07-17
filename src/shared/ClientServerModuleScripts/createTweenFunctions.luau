local TweenService = game:GetService("TweenService")

local tweenCreate = {}

-- Pulse: Enlarges and shrinks a GUI for visual feedback
function tweenCreate.Pulse(gui: Frame, scaleFactor: number, duration: number)
	local originalSize = gui.Size
	local pulseSize = UDim2.new(originalSize.X.Scale + scaleFactor, 0, originalSize.Y.Scale + scaleFactor, 0)

	local pulseInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrinkInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local growTween = TweenService:Create(gui, pulseInfo, { Size = pulseSize })
	local shrinkTween = TweenService:Create(gui, shrinkInfo, { Size = originalSize })

	return growTween, shrinkTween
end

-- GoInOut: Creates "open" and "close" tweens for panels (position + size)
function tweenCreate.GoInOut(
	gui: Frame,
	tweenInInfo: TweenInfo,
	tweenOutInfo: TweenInfo,
	offsetXScale: number?,
	offsetYScale: number?,
	offsetXOffset: number?,
	offsetYOffset: number?
)
	local offsetXScaleT = offsetXScale or 0
	local offsetYScaleT = offsetYScale or 0
	local offsetXOffsetT = offsetXOffset or 0
	local offsetYOffsetT = offsetYOffset or 0

	local tweenInProps = {
		Size = gui.Size,
		Position = gui.Position,
	}

	local tweenOutProps = {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(
			gui.Position.X.Scale + offsetXScaleT,
			gui.Position.X.Offset + offsetXOffsetT,
			gui.Position.Y.Scale + offsetYScaleT,
			gui.Position.Y.Offset + offsetYOffsetT
		),
	}

	local openTween = TweenService:Create(gui, tweenInInfo, tweenInProps)
	local closeTween = TweenService:Create(gui, tweenOutInfo, tweenOutProps)

	return openTween, closeTween
end

function tweenCreate.Grow(gui: Frame, duration: number, startSize: UDim2?, endSize: UDim2?)
	local initialSize = startSize or UDim2.new(0, 0, 0, 0)
	local finalSize = endSize or UDim2.new(1, 0, 1, 0)

	gui.Size = initialSize

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(gui, tweenInfo, { Size = finalSize })

	return tween
end
function tweenCreate.Grow2(gui: Frame, duration: number, endSize: UDim2?)
	local finalSize = endSize or UDim2.new(1, 0, 1, 0)

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(gui, tweenInfo, { Size = finalSize })

	return tween
end

function tweenCreate.Shrink(gui: Frame, duration: number, startSize: UDim2?, endSize: UDim2?)
	local initialSize = startSize or UDim2.new(1, 0, 1, 0)
	local finalSize = endSize or UDim2.new(0, 0, 0, 0)

	gui.Size = initialSize

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local tween = TweenService:Create(gui, tweenInfo, { Size = finalSize })

	return tween
end
function tweenCreate.Shrink2(gui: Frame, duration: number, endSize: UDim2?)
	local finalSize = endSize or UDim2.new(0, 0, 0, 0)

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local tween = TweenService:Create(gui, tweenInfo, { Size = finalSize })

	return tween
end

function tweenCreate.MoveTo(gui, duration: number, endPosition: UDim2)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(gui, tweenInfo, { Position = endPosition })

	return tween
end

function tweenCreate.PulseTransparency(gui: Frame, transparencyMax: number, transparencyStart: number, duration: number)
	local pulseTweenIn = TweenService:Create(gui, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Transparency = transparencyMax,
	})
	local pulseTweenOut = TweenService:Create(gui, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Transparency = transparencyStart,
	})

	return pulseTweenIn, pulseTweenOut
end

function tweenCreate.Zoom(gui, originalSize: UDim2, duration: number, zoomAmount: UDim2)
	local zoomIn = TweenService:Create(gui, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Size = originalSize + zoomAmount,
	})
	local zoomOut = TweenService:Create(gui, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Size = originalSize,
	})

	return zoomIn, zoomOut
end

return tweenCreate
