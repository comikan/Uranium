-- Uranium UI Library
local Uranium = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "UraniumUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Utility functions
local function create(class, props)
	local instance = Instance.new(class)
	for prop, value in pairs(props) do
		instance[prop] = value
	end
	return instance
end

local function tween(object, properties, duration, style, direction)
	local tweenInfo = TweenInfo.new(
		duration or 0.2,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

-- Main window creation
function Uranium.CreateWindow(options)
	options = options or {}
	local title = options.Title or "Uranium UI"
	local size = options.Size or Vector2.new(400, 500)
	local position = options.Position or UDim2.fromScale(0.5, 0.5)
	local accentColor = options.AccentColor or Color3.fromRGB(0, 170, 255)
	local theme = options.Theme or "Dark"

	local backgroundColors = {
		Dark = {
			Main = Color3.fromRGB(30, 30, 40),
			Secondary = Color3.fromRGB(45, 45, 55),
			Text = Color3.fromRGB(240, 240, 240)
		},
		Light = {
			Main = Color3.fromRGB(240, 240, 245),
			Secondary = Color3.fromRGB(220, 220, 230),
			Text = Color3.fromRGB(30, 30, 40)
		}
	}

	local colors = backgroundColors[theme]

	-- Main window frame
	local window = create("Frame", {
		Name = "Window",
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = colors.Main,
		Parent = gui
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = window
	})

	-- Title bar
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = colors.Secondary,
		Parent = window
	})

	create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = titleBar
	})

	local titleText = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = titleBar
	})

	-- Close button
	local closeButton = create("TextButton", {
		Name = "CloseButton",
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -32, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = colors.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Parent = titleBar
	})

	-- Draggable window implementation
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		window.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		tween(window, {Size = UDim2.fromOffset(window.AbsoluteSize.X, 0)}, 0.2)
		task.wait(0.2)
		window:Destroy()
	end)

	-- Content area
	local contentFrame = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.fromOffset(0, 40),
		BackgroundTransparency = 1,
		Parent = window
	})

	-- Tab system
	local tabButtonsFrame = create("Frame", {
		Name = "TabButtons",
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.fromOffset(10, 5),
		BackgroundTransparency = 1,
		Parent = contentFrame
	})

	local tabListLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = tabButtonsFrame
	})

	local tabContentFrame = create("Frame", {
		Name = "TabContent",
		Size = UDim2.new(1, -20, 1, -40),
		Position = UDim2.fromOffset(10, 40),
		BackgroundTransparency = 1,
		Parent = contentFrame
	})

	local tabs = {}
	local currentTab = nil

	function tabs:AddTab(name, icon)
		local tabButton = create("TextButton", {
			Name = name,
			Size = UDim2.fromOffset(80, 30),
			BackgroundColor3 = colors.Secondary,
			Text = icon and (icon .. "  " .. name) or name,
			TextColor3 = colors.Text,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			Parent = tabButtonsFrame
		})

		create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = tabButton
		})

		local tabContent = create("ScrollingFrame", {
			Name = name,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = accentColor,
			Visible = false,
			Parent = tabContentFrame
		})

		local tabContentLayout = create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
			Parent = tabContent
		})

		tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, tabContentLayout.AbsoluteContentSize.Y + 10)
		end)

		tabButton.MouseButton1Click:Connect(function()
			if currentTab then
				currentTab.Visible = false
				tween(tabButtonsFrame[currentTab.Name], {BackgroundColor3 = colors.Secondary}, 0.2)
			end

			currentTab = tabContent
			tabContent.Visible = true
			tween(tabButton, {BackgroundColor3 = accentColor}, 0.2)
		end)

		-- Select first tab by default
		if #tabButtonsFrame:GetChildren() == 2 then -- 1 tab + UIListLayout
			tabButton.BackgroundColor3 = accentColor
			tabContent.Visible = true
			currentTab = tabContent
		end

		local tabElements = {}

		-- Add elements to this tab
		function tabElements:AddLabel(text)
			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = tabContent
			})

			return label
		end

		function tabElements:AddButton(text, callback)
			local button = create("TextButton", {
				Name = "Button",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = colors.Secondary,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = tabContent
			})

			create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = button
			})

			button.MouseEnter:Connect(function()
				tween(button, {BackgroundColor3 = accentColor:lerp(Color3.new(1, 1, 1), 0.2)}, 0.2)
			end)

			button.MouseLeave:Connect(function()
				tween(button, {BackgroundColor3 = colors.Secondary}, 0.2)
			end)

			button.MouseButton1Click:Connect(function()
				tween(button, {Size = UDim2.new(0.95, 0, 0, 28)}, 0.1)
				tween(button, {Size = UDim2.new(1, 0, 0, 30)}, 0.1):Wait()
				if callback then callback() end
			end)

			return button
		end

		function tabElements:AddToggle(text, defaultValue, callback)
			local toggle = create("Frame", {
				Name = "Toggle",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = tabContent
			})

			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -50, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = toggle
			})

			local toggleFrame = create("Frame", {
				Name = "ToggleFrame",
				Size = UDim2.fromOffset(40, 20),
				Position = UDim2.new(1, -5, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = colors.Secondary,
				Parent = toggle
			})

			create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = toggleFrame
			})

			local toggleButton = create("Frame", {
				Name = "ToggleButton",
				Size = UDim2.fromOffset(16, 16),
				Position = defaultValue and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = defaultValue and accentColor or Color3.fromRGB(150, 150, 150),
				Parent = toggleFrame
			})

			create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = toggleButton
			})

			local state = defaultValue or false

			local function updateToggle()
				if state then
					tween(toggleButton, {
						Position = UDim2.new(1, -18, 0.5, 0),
						BackgroundColor3 = accentColor
					}, 0.2)
					tween(toggleFrame, {BackgroundColor3 = accentColor:lerp(colors.Secondary, 0.7)}, 0.2)
				else
					tween(toggleButton, {
						Position = UDim2.new(0, 2, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(150, 150, 150)
					}, 0.2)
					tween(toggleFrame, {BackgroundColor3 = colors.Secondary}, 0.2)
				end

				if callback then callback(state) end
			end

			toggleFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					state = not state
					updateToggle()
				end
			end)

			return {
				Set = function(newState)
					state = newState
					updateToggle()
				end,
				Get = function()
					return state
				end
			}
		end

		function tabElements:AddSlider(text, min, max, defaultValue, callback)
			local slider = create("Frame", {
				Name = "Slider",
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				Parent = tabContent
			})

			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = slider
			})

			local valueLabel = create("TextLabel", {
				Name = "ValueLabel",
				Size = UDim2.new(0, 50, 0, 20),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Text = tostring(defaultValue or min),
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = slider
			})

			local sliderTrack = create("Frame", {
				Name = "SliderTrack",
				Size = UDim2.new(1, 0, 0, 5),
				Position = UDim2.fromOffset(0, 30),
				BackgroundColor3 = colors.Secondary,
				Parent = slider
			})

			create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = sliderTrack
			})

			local sliderFill = create("Frame", {
				Name = "SliderFill",
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = accentColor,
				Parent = sliderTrack
			})

			create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = sliderFill
			})

			local sliderButton = create("TextButton", {
				Name = "SliderButton",
				Size = UDim2.fromOffset(15, 15),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = accentColor,
				AutoButtonColor = false,
				Text = "",
				Parent = sliderTrack
			})

			create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = sliderButton
			})

			local minValue = min or 0
			local maxValue = max or 100
			local currentValue = defaultValue or minValue
			local sliding = false

			local function updateSlider(value)
				currentValue = math.clamp(value, minValue, maxValue)
				local percentage = (currentValue - minValue) / (maxValue - minValue)

				sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
				sliderButton.Position = UDim2.new(percentage, 0, 0.5, 0)
				valueLabel.Text = string.format("%.1f", currentValue)

				if callback then callback(currentValue) end
			end

			sliderButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
				end
			end)

			sliderButton.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = input.Position.X
					local absolutePos = sliderTrack.AbsolutePosition.X
					local absoluteSize = sliderTrack.AbsoluteSize.X

					local relativePos = math.clamp(mousePos - absolutePos, 0, absoluteSize)
					local percentage = relativePos / absoluteSize
					local value = minValue + (maxValue - minValue) * percentage

					updateSlider(value)
				end
			end)

			updateSlider(currentValue)

			return {
				Set = function(value)
					updateSlider(value)
				end,
				Get = function()
					return currentValue
				end
			}
		end

		function tabElements:AddDropdown(text, options, defaultOption, callback)
			local dropdown = create("Frame", {
				Name = "Dropdown",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = tabContent
			})

			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -50, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = dropdown
			})

			local dropdownButton = create("TextButton", {
				Name = "DropdownButton",
				Size = UDim2.fromOffset(120, 30),
				Position = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = colors.Secondary,
				Text = defaultOption or "Select...",
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				Parent = dropdown
			})

			create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = dropdownButton
			})

			local dropdownList = create("ScrollingFrame", {
				Name = "DropdownList",
				Size = UDim2.fromOffset(120, 0),
				Position = UDim2.new(1, 0, 0, 35),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = colors.Secondary,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = accentColor,
				Visible = false,
				Parent = dropdown
			})

			create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = dropdownList
			})

			local dropdownListLayout = create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = dropdownList
			})

			local isOpen = false
			local selectedOption = defaultOption

			local function toggleDropdown()
				isOpen = not isOpen
				dropdownList.Visible = isOpen

				if isOpen then
					local totalHeight = 0
					for _, option in ipairs(dropdownList:GetChildren()) do
						if option:IsA("TextButton") then
							totalHeight = totalHeight + option.AbsoluteSize.Y + 2
						end
					end

					dropdownList.Size = UDim2.fromOffset(120, math.min(totalHeight, 150))
					tween(dropdownList, {Size = UDim2.fromOffset(120, math.min(totalHeight, 150))}, 0.2)
				else
					tween(dropdownList, {Size = UDim2.fromOffset(120, 0)}, 0.2)
				end
			end

			dropdownButton.MouseButton1Click:Connect(toggleDropdown)

			local function createOption(optionText)
				local optionButton = create("TextButton", {
					Name = optionText,
					Size = UDim2.new(1, -10, 0, 25),
					Position = UDim2.fromOffset(5, 0),
					BackgroundColor3 = colors.Secondary,
					Text = optionText,
					TextColor3 = colors.Text,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					Parent = dropdownList
				})

				create("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = optionButton
				})

				optionButton.MouseButton1Click:Connect(function()
					selectedOption = optionText
					dropdownButton.Text = optionText
					toggleDropdown()
					if callback then callback(optionText) end
				end)

				optionButton.MouseEnter:Connect(function()
					tween(optionButton, {BackgroundColor3 = accentColor}, 0.2)
				end)

				optionButton.MouseLeave:Connect(function()
					tween(optionButton, {BackgroundColor3 = colors.Secondary}, 0.2)
				end)
			end

			for _, option in ipairs(options) do
				createOption(option)
			end

			return {
				SetOptions = function(newOptions)
					for _, child in ipairs(dropdownList:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _, option in ipairs(newOptions) do
						createOption(option)
					end
				end,
				GetSelected = function()
					return selectedOption
				end,
				SetSelected = function(option)
					if table.find(options, option) then
						selectedOption = option
						dropdownButton.Text = option
						if callback then callback(option) end
					end
				end
			}
		end

		function tabElements:AddTextbox(text, placeholder, callback)
			local textbox = create("Frame", {
				Name = "Textbox",
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Parent = tabContent
			})

			local label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = textbox
			})

			local inputFrame = create("Frame", {
				Name = "InputFrame",
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.fromOffset(0, 20),
				BackgroundColor3 = colors.Secondary,
				Parent = textbox
			})

			create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = inputFrame
			})

			local textBox = create("TextBox", {
				Name = "TextBox",
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.fromOffset(5, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = placeholder or "Enter text...",
				TextColor3 = colors.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = inputFrame
			})

			textBox.Focused:Connect(function()
				tween(inputFrame, {BackgroundColor3 = accentColor:lerp(colors.Secondary, 0.5)}, 0.2)
			end)

			textBox.FocusLost:Connect(function()
				tween(inputFrame, {BackgroundColor3 = colors.Secondary}, 0.2)
				if callback and textBox.Text ~= "" then
					callback(textBox.Text)
				end
			end)

			return {
				SetText = function(text)
					textBox.Text = text
				end,
				GetText = function()
					return textBox.Text
				end
			}
		end

		return tabElements
	end

	return tabs
end

return Uranium
