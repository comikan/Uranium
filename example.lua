-- Wait for the Uranium module to exist
local Uranium = loadstring(game:HttpGet("https://raw.githubusercontent.com/comikan/Uranium/Uranium.lua"))()

-- Create a window
local window = Uranium.CreateWindow({
    Title = "Uranium UI Example",
    Size = Vector2.new(350, 450),
    AccentColor = Color3.fromRGB(0, 200, 150),
    Theme = "Dark"
})

-- Add tabs and elements
local mainTab = window:AddTab("Main", "🏠")
local settingsTab = window:AddTab("Settings", "⚙️")

-- Add elements to main tab
mainTab:AddLabel("Welcome to Uranium UI")

mainTab:AddButton("Click Me", function()
    print("Button clicked!")
end)

mainTab:AddToggle("Enable Feature", false, function(state)
    print("Toggle state:", state)
end)

mainTab:AddSlider("Volume", 0, 100, 50, function(value)
    print("Volume set to:", value)
end)

-- Add elements to settings tab
settingsTab:AddLabel("Settings")
settingsTab:AddToggle("Dark Mode", true, function(state)
    print("Dark mode:", state)
end)
