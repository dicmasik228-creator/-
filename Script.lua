-- [[ MOBILE MENU - Ultra Minimal ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinimalMenu"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== ПЛАВАЮЩАЯ КРУГЛАЯ КНОПКА ==========
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
FloatButton.Text = "⚡"
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.TextSize = 28
FloatButton.Font = Enum.Font.GothamBold
FloatButton.BorderSizePixel = 0
FloatButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = FloatButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(120, 180, 255)
ButtonStroke.Thickness = 2
ButtonStroke.Parent = FloatButton

-- Тень для кнопки
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 8, 1, 8)
Shadow.Position = UDim2.new(0, -4, 0, -4)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://131604521"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ZIndex = -1
Shadow.Parent = FloatButton

-- Перетаскивание кнопки
local btnDragActive = false
local btnDragStart
local btnStartPos

FloatButton.TouchBegan:Connect(function(input)
    btnDragActive = true
    btnDragStart = input.Position
    btnStartPos = FloatButton.Position
end)

FloatButton.TouchMoved:Connect(function(input)
    if btnDragActive then
        local delta = input.Position - btnDragStart
        local newX = btnStartPos.X.Offset + delta.X
        local newY = btnStartPos.Y.Offset + delta.Y
        -- Ограничения по краям экрана
        newX = math.clamp(newX, 0, 800)
        newY = math.clamp(newY, 0, 1400)
        FloatButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

FloatButton.TouchEnded:Connect(function()
    btnDragActive = false
end)

-- ========== ОСНОВНАЯ ПАНЕЛЬ ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Заголовок
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 50)
TitleFrame.Position = UDim2.new(0, 0, 0, 0)
TitleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleFrame.BackgroundTransparency = 0.3
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "МЕНЮ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleFrame

-- Скролл
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -50)
Scroll.Position = UDim2.new(0, 0, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 10)
ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Parent = Scroll

-- Создание раздела
local function CreateSection(name)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0.9, 0, 0, 45)
    Section.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Section.BackgroundTransparency = 0.5
    Section.BorderSizePixel = 0
    Section.Parent = Scroll
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 12)
    SectionCorner.Parent = Section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 255)
    Label.TextSize = 17
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.Parent = Section
end

-- Разделы
CreateSection("Home")
CreateSection("Player")
CreateSection("Combat")
CreateSection("Invincibility")
CreateSection("Target")

-- Кнопка закрыть внутри меню
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- ========== ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ ==========
local menuOpen = false

-- Открыть меню
local function OpenMenu()
    menuOpen = true
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(0, 0, 0, 400)
    MainFrame:TweenSize(UDim2.new(0, 300, 0, 400), "Out", "Quad", 0.3)
    MainFrame.BackgroundTransparency = 0.1
end

-- Закрыть меню
local function CloseMenu()
    menuOpen = false
    MainFrame:TweenSize(UDim2.new(0, 0, 0, 400), "Out", "Quad", 0.25)
    task.wait(0.25)
    MainFrame.Visible = false
end

-- Нажатие на плавающую кнопку
FloatButton.TouchTap:Connect(function()
    if menuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end)

-- Кнопка закрытия внутри меню
CloseBtn.TouchTap:Connect(function()
    CloseMenu()
end)

-- ========== ПЕРЕТАСКИВАНИЕ ПАНЕЛИ ==========
local dragActive = false
local dragStart
local frameStart

TitleFrame.TouchBegan:Connect(function(input)
    dragActive = true
    dragStart = input.Position
    frameStart = MainFrame.Position
end)

TitleFrame.TouchMoved:Connect(function(input)
    if dragActive then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

TitleFrame.TouchEnded:Connect(function()
    dragActive = false
end)

-- Анимация появления кнопки
FloatButton.BackgroundTransparency = 1
FloatButton.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.05)
FloatButton:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Quad", 0.3)
FloatButton.BackgroundTransparency = 0

print("✅ Меню загружено | Нажми на круглую кнопку")
