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
function tweenCreate.GoInOut(gui: Frame, tweenInInfo: TweenInfo, tweenOutInfo: TweenInfo)
	local tweenInProps = {
		Size = gui.Size,
		Position = gui.Position,
	}

	local tweenOutProps = {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(
			gui.Position.X.Scale - 0.5,
			gui.Position.X.Offset,
			gui.Position.Y.Scale,
			gui.Position.Y.Offset
		),
	}

	local openTween = TweenService:Create(gui, tweenInInfo, tweenInProps)
	local closeTween = TweenService:Create(gui, tweenOutInfo, tweenOutProps)

	return openTween, closeTween
end

function tweenCreate.Grow(gui: Frame, duration: number, targetSize: UDim2?)
	local finalSize = targetSize or UDim2.new(1, 0, 1, 0)
	gui.Size = UDim2.new(0, 0, 0, 0)

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(gui, tweenInfo, { Size = finalSize })

	return tween
end

return tweenCreate
