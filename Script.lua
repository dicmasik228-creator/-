-- [[ RESONANCE STYLE MENU - MEHKO МЕРУЛЕК ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ResonanceMenu"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ПЛАВАЮЩАЯ КНОПКА
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
FloatButton.Text = "⚡"
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.TextSize = 30
FloatButton.Font = Enum.Font.GothamBold
FloatButton.BorderSizePixel = 0
FloatButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = FloatButton

-- ОСНОВНОЕ МЕНЮ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 90)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- ВЕРХНЯЯ ПАНЕЛЬ (ЗАГОЛОВОК)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 80)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 20)
TopCorner.Parent = TopBar

-- Заголовок "MEHKO" и "МЕРУЛЕК" (две строки)
local Title1 = Instance.new("TextLabel")
Title1.Size = UDim2.new(1, 0, 0, 35)
Title1.Position = UDim2.new(0, 0, 0, 15)
Title1.BackgroundTransparency = 1
Title1.Text = "MEHKO"
Title1.TextColor3 = Color3.fromRGB(255, 255, 255)
Title1.TextSize = 24
Title1.Font = Enum.Font.GothamBold
Title1.TextXAlignment = Enum.TextXAlignment.Center
Title1.Parent = TopBar

local Title2 = Instance.new("TextLabel")
Title2.Size = UDim2.new(1, 0, 0, 25)
Title2.Position = UDim2.new(0, 0, 0, 50)
Title2.BackgroundTransparency = 1
Title2.Text = "МЕРУЛЕК"
Title2.TextColor3 = Color3.fromRGB(180, 180, 220)
Title2.TextSize = 16
Title2.Font = Enum.Font.GothamRegular
Title2.TextXAlignment = Enum.TextXAlignment.Center
Title2.Parent = TopBar

-- КНОПКА ЗАКРЫТЬ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- СПИСОК ВКЛАДОК
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -130)
Scroll.Position = UDim2.new(0, 0, 0, 85)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

-- ВКЛАДКИ (как на скриншоте)
local tabs = {"Visual", "Auto-Clicker", "Keybinds", "Misc", "Lists", "Settings"}

for _, name in ipairs(tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.85, 0, 0, 48)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TabBtn.BackgroundTransparency = 0.4
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    TabBtn.TextSize = 16
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = Scroll
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 12)
    TabCorner.Parent = TabBtn
    
    -- Подсветка при нажатии
    TabBtn.TouchTap:Connect(function()
        for _, btn in pairs(Scroll:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 0.4
            end
        end
        TabBtn.BackgroundTransparency = 0.1
        print("Выбрано: " .. name)
    end)
end

-- НИЖНЯЯ ПАНЕЛЬ (цифра 9160 как на скрине)
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 45)
BottomBar.Position = UDim2.new(0, 0, 1, -45)
BottomBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
BottomBar.BackgroundTransparency = 0.3
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame

local BottomCorner = Instance.new("UICorner")
BottomCorner.CornerRadius = UDim.new(0, 20)
BottomCorner.Parent = BottomBar

local BottomNumber = Instance.new("TextLabel")
BottomNumber.Size = UDim2.new(1, 0, 1, 0)
BottomNumber.BackgroundTransparency = 1
BottomNumber.Text = "9160"
BottomNumber.TextColor3 = Color3.fromRGB(180, 180, 200)
BottomNumber.TextSize = 18
BottomNumber.Font = Enum.Font.GothamBold
BottomNumber.TextXAlignment = Enum.TextXAlignment.Center
BottomNumber.Parent = BottomBar

-- ЛОГИКА ОТКРЫТИЯ
local menuOpen = false

FloatButton.TouchTap:Connect(function()
    if menuOpen then
        menuOpen = false
        MainFrame.Visible = false
    else
        menuOpen = true
        MainFrame.Visible = true
    end
end)

CloseBtn.TouchTap:Connect(function()
    menuOpen = false
    MainFrame.Visible = false
end)

-- ПЕРЕТАСКИВАНИЕ
local dragActive = false
local dragStart
local frameStart

TopBar.TouchBegan:Connect(function(input)
    dragActive = true
    dragStart = input.Position
    frameStart = MainFrame.Position
end)

TopBar.TouchMoved:Connect(function(input)
    if dragActive then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

TopBar.TouchEnded:Connect(function()
    dragActive = false
end)

-- АНИМАЦИЯ ПОЯВЛЕНИЯ КНОПКИ
FloatButton.BackgroundTransparency = 1
FloatButton.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.05)
FloatButton:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Quad", 0.3)
FloatButton.BackgroundTransparency = 0

print("✅ Resonance Menu | MEHKO МЕРУЛЕК | Нажми ⚡")
