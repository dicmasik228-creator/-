-- [[ ПРОСТОЕ МОБИЛЬНОЕ МЕНЮ - БЕЗ НАДПИСЕЙ ]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleMenu"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 60, 0, 60)
Button.Position = UDim2.new(0.8, 0, 0.8, 0)
Button.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
Button.Text = "⚡"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 30
Button.Font = Enum.Font.GothamBold
Button.BorderSizePixel = 0
Button.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = Button

local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 280, 0, 350)
Menu.Position = UDim2.new(0.5, -140, 0.5, -175)
Menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Menu.BackgroundTransparency = 0.1
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 20)
MenuCorner.Parent = Menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.BackgroundTransparency = 0.3
Title.Text = ""
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -45)
Scroll.Position = UDim2.new(0, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local sections = {"Home", "Player", "Combat", "Invincibility", "Target"}

for _, name in ipairs(sections) do
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0.9, 0, 0, 40)
    Section.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Section.BackgroundTransparency = 0.5
    Section.BorderSizePixel = 0
    Section.Parent = Scroll
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 10)
    SectionCorner.Parent = Section
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Center
    Label.Parent = Section
end

local menuOpen = false

Button.MouseButton1Click:Connect(function()
    if menuOpen then
        menuOpen = false
        Menu.Visible = false
    else
        menuOpen = true
        Menu.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    Menu.Visible = false
end)

local dragging = false
local dragStart
local menuStart

Title.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = UserInputService:GetMouseLocation()
    menuStart = Menu.Position
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging then
        local delta = UserInputService:GetMouseLocation() - dragStart
        Menu.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y)
    end
end)
