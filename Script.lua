-- [[ BROKEN SPAWN MENU - Mobile ]] --
-- Картинка: https://create.roblox.com/store/asset/112281889314647/Broken-spawn

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrokenSpawn"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ОСНОВНАЯ ПАНЕЛЬ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 22)
MainCorner.Parent = MainFrame

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 110)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 22)
TopCorner.Parent = TopBar

-- КАРТИНКА (ТВОЯ)
local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 55, 0, 55)
Icon.Position = UDim2.new(0.5, -27, 0, 12)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://112281889314647"
Icon.Parent = TopBar

-- НАЗВАНИЕ
local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 30)
MenuTitle.Position = UDim2.new(0, 0, 0, 72)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "BROKEN SPAWN"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 18
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextXAlignment = Enum.TextXAlignment.Center
MenuTitle.Parent = TopBar

-- СТРОКА ПОИСКА
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(0.9, 0, 0, 38)
SearchFrame.Position = UDim2.new(0.05, 0, 0.245, 0)
SearchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SearchFrame.BackgroundTransparency = 0.6
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 12)
SearchCorner.Parent = SearchFrame

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 35, 1, 0)
SearchIcon.Position = UDim2.new(0, 10, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 180)
SearchIcon.TextSize = 18
SearchIcon.Font = Enum.Font.GothamRegular
SearchIcon.Parent = SearchFrame

local SearchText = Instance.new("TextLabel")
SearchText.Size = UDim2.new(1, -50, 1, 0)
SearchText.Position = UDim2.new(0, 45, 0, 0)
SearchText.BackgroundTransparency = 1
SearchText.Text = "Search"
SearchText.TextColor3 = Color3.fromRGB(120, 120, 150)
SearchText.TextSize = 16
SearchText.Font = Enum.Font.GothamRegular
SearchText.TextXAlignment = Enum.TextXAlignment.Left
SearchText.Parent = SearchFrame

-- СКРОЛЛ
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -200)
Scroll.Position = UDim2.new(0, 0, 0, 200)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 10)
ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Parent = Scroll

-- ВКЛАДКИ
local tabs = {"Visual", "Auto-Clicker", "Keybinds", "Misc", "Lists", "Settings"}

for _, name in ipairs(tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.85, 0, 0, 50)
    TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = "   " .. name
    TabBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
    TabBtn.TextSize = 17
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = Scroll
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 14)
    TabCorner.Parent = TabBtn
end

-- НИЖНЯЯ ПАНЕЛЬ (FPS и Toggle)
local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1, 0, 0, 45)
BottomBar.Position = UDim2.new(0, 0, 1, -45)
BottomBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
BottomBar.BackgroundTransparency = 0.3
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame

local BottomCorner = Instance.new("UICorner")
BottomCorner.CornerRadius = UDim.new(0, 22)
BottomCorner.Parent = BottomBar

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0.5, 0, 1, 0)
FPSLabel.Position = UDim2.new(0, 15, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "56 fps | 113 ms"
FPSLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
FPSLabel.TextSize = 13
FPSLabel.Font = Enum.Font.GothamRegular
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = BottomBar

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.3, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0.5, -35, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Toggle"
ToggleLabel.TextColor3 = Color3.fromRGB(80, 180, 200)
ToggleLabel.TextSize = 14
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.Parent = BottomBar

-- КНОПКА ЗАКРЫТЬ ВНУТРИ МЕНЮ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 65, 0, 65)
FloatButton.Position = UDim2.new(0.8, 0, 0.8, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
FloatButton.Text = "⚡"
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.TextSize = 32
FloatButton.Font = Enum.Font.GothamBold
FloatButton.BorderSizePixel = 0
FloatButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = FloatButton

-- ЛОГИКА
local menuOpen = false

FloatButton.MouseButton1Click:Connect(function()
    if menuOpen then
        menuOpen = false
        MainFrame.Visible = false
    else
        menuOpen = true
        MainFrame.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    MainFrame.Visible = false
end)

-- ПЕРЕТАСКИВАНИЕ МЕНЮ
local dragging = false
local dragStart
local menuStart

TopBar.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = UserInputService:GetMouseLocation()
    menuStart = MainFrame.Position
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging then
        local delta = UserInputService:GetMouseLocation() - dragStart
        MainFrame.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y)
    end
end)

-- АНИМАЦИЯ
FloatButton.BackgroundTransparency = 1
FloatButton.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.05)
FloatButton:TweenSize(UDim2.new(0, 65, 0, 65), "Out", "Quad", 0.3)
FloatButton.BackgroundTransparency = 0

print("✅ Broken Spawn Menu | Картинка загружена, нажми ⚡")
