-- [[ ОТЛАДОЧНАЯ ВЕРСИЯ - С ВИЗУАЛЬНЫМ СТАТУСОМ ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DebugMenu"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- СТАТУСНАЯ СТРОКА (будет показывать что происходит)
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 300, 0, 30)
StatusText.Position = UDim2.new(0.5, -150, 0, 10)
StatusText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusText.BackgroundTransparency = 0.3
StatusText.Text = "Статус: скрипт загружен"
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = ScreenGui

-- КНОПКА
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 70, 0, 70)
Button.Position = UDim2.new(0.8, 0, 0.8, 0)
Button.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
Button.Text = "⚡"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 35
Button.Font = Enum.Font.GothamBold
Button.BorderSizePixel = 0
Button.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = Button

-- МЕНЮ
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 300, 0, 400)
Menu.Position = UDim2.new(0.5, -150, 0.5, -200)
Menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 20)
MenuCorner.Parent = Menu

-- ТЕКСТ В МЕНЮ
local MenuText = Instance.new("TextLabel")
MenuText.Size = UDim2.new(1, 0, 1, 0)
MenuText.BackgroundTransparency = 1
MenuText.Text = "МЕНЮ РАБОТАЕТ!"
MenuText.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuText.TextSize = 20
MenuText.Font = Enum.Font.GothamBold
MenuText.Parent = Menu

-- ЗАГОЛОВОК МЕНЮ (для перетаскивания)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Header.BorderSizePixel = 0
Header.Parent = Menu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

-- КНОПКА ЗАКРЫТИЯ ВНУТРИ МЕНЮ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- ЛОГИКА С ВИЗУАЛЬНЫМ СТАТУСОМ
local isOpen = false

Button.TouchTap:Connect(function()
    StatusText.Text = "Статус: кнопка нажата!"
    StatusText.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    
    task.wait(0.2)
    
    if isOpen then
        isOpen = false
        Menu.Visible = false
        StatusText.Text = "Статус: меню ЗАКРЫТО"
        StatusText.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        isOpen = true
        Menu.Visible = true
        StatusText.Text = "Статус: меню ОТКРЫТО"
        StatusText.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

CloseBtn.TouchTap:Connect(function()
    isOpen = false
    Menu.Visible = false
    StatusText.Text = "Статус: меню закрыто через крестик"
    StatusText.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end)

-- ПЕРЕТАСКИВАНИЕ
local dragging = false
local dragStartPos
local menuStartPos

Header.TouchBegan:Connect(function(input)
    dragging = true
    dragStartPos = input.Position
    menuStartPos = Menu.Position
    StatusText.Text = "Статус: начато перетаскивание"
end)

Header.TouchMoved:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStartPos
        Menu.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
    end
end)

Header.TouchEnded:Connect(function()
    dragging = false
    StatusText.Text = "Статус: перетаскивание закончено"
    task.wait(0.5)
    if isOpen then
        StatusText.Text = "Статус: меню ОТКРЫТО"
    else
        StatusText.Text = "Статус: меню ЗАКРЫТО"
    end
end)

print("✅ Отладочная версия загружена")
