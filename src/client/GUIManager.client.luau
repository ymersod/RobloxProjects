-- GUI elements
local accessBarGui =
	game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("AccessBar")
local accessParentGui: Frame = accessBarGui:WaitForChild("AccessParent")
local openCloseGui = accessBarGui:WaitForChild("OpenClose")
local openCloseButton: ImageButton = accessBarGui:WaitForChild("OpenClose"):WaitForChild("OpenCloseButton")
local openCloseBg: ImageLabel = accessBarGui:WaitForChild("OpenClose"):WaitForChild("OpenCloseIcon")

local TweenService = game:GetService("TweenService")
local tweenInInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local openImageId = "rbxassetid://93555922850987"
local closeImageId = "rbxassetid://89593175570849"
local isUiOpen = true

-- Should be size of frame
local tweenInProps = { Size = accessParentGui.Size, Position = accessParentGui.Position }
local tweenOutProps = {
	Size = UDim2.new(0, 0, 0, 0),
	Position = UDim2.new(
		accessParentGui.Position.X.Scale - 0.5,
		accessParentGui.Position.X.Offset,
		accessParentGui.Position.Y.Scale,
		accessParentGui.Position.Y.Offset
	),
}

local openTween = TweenService:Create(accessParentGui, tweenInInfo, tweenInProps)
local closeTween = TweenService:Create(accessParentGui, tweenOutInfo, tweenOutProps)

local function pulseOpenClose()
	local originalSize = openCloseGui.Size

	local scaleFactor = 0.05 -- 5% increase
	local pulseSize = UDim2.new(originalSize.X.Scale + scaleFactor, 0, originalSize.Y.Scale + scaleFactor, 0)

	local pulseInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local shrinkInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local growTween = TweenService:Create(openCloseGui, pulseInfo, { Size = pulseSize })
	local shrinkTween = TweenService:Create(openCloseGui, shrinkInfo, { Size = originalSize })

	growTween:Play()
	growTween.Completed:Once(function()
		shrinkTween:Play()
	end)
end

openCloseButton.MouseButton1Click:Connect(function()
	pulseOpenClose()
	if isUiOpen then
		print("Closing...")
		openCloseBg.Image = openImageId
		closeTween:Play()
		isUiOpen = false
		closeTween.Completed:Once(function()
			accessParentGui.Visible = false
		end)
	elseif not isUiOpen then
		print("Opening...")
		accessParentGui.Visible = true
		openCloseBg.Image = closeImageId
		openTween:Play()
		isUiOpen = true
	end
end)
