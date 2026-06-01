local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
    Title = "BROKEN SPAWN LITE",
    Footer = "Лаг сервера",
    NotifySide = "Right",
})

local mainTab = Window:AddTab("Лаг", "smile")
local mainGroup = mainTab:AddLeftGroupbox("Настройки лага")

-- Отключаем обработку CreateGrabLine на клиенте
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
if grabEvents then
    local createGrabLine = grabEvents:FindFirstChild("CreateGrabLine")
    if createGrabLine then
        createGrabLine.OnClientEvent = function() end
        print("✅ CreateGrabLine отключён")
    end
end

local lagActive = false
local lagPower = 50
local lagConnection = nil

local lagSlider = mainGroup:AddSlider("LagPower", {
    Text = "Мощность лага",
    Default = 50,
    Min = 10,
    Max = 1000,
    Step = 10,
    Callback = function(Value)
        lagPower = Value
    end
})

local function startLag()
    if lagConnection then lagConnection:Disconnect() end
    
    local createGrabLine = ReplicatedStorage:FindFirstChild("GrabEvents") and ReplicatedStorage.GrabEvents:FindFirstChild("CreateGrabLine")
    if not createGrabLine then
        Library:Notify({Title = "Ошибка", Description = "CreateGrabLine не найден", Duration = 3})
        return
    end
    
    lagConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if lagActive then
            for i = 1, lagPower do
                pcall(function()
                    createGrabLine:FireServer(workspace.CurrentCamera.CFrame.Position, CFrame.new())
                end)
            end
        end
    end)
    
    Library:Notify({Title = "Лаг сервера", Description = "Включён (мощность: " .. lagPower .. ")", Duration = 3})
end

local function stopLag()
    if lagConnection then
        lagConnection:Disconnect()
        lagConnection = nil
    end
    Library:Notify({Title = "Лаг сервера", Description = "Выключен", Duration = 2})
end

mainGroup:AddToggle("LagToggle", {
    Text = "Включить лаг сервера",
    Default = false,
    Callback = function(Value)
        lagActive = Value
        if Value then startLag() else stopLag() end
    end
})

print("✅ Меню загружено | Нажми RightShift")
