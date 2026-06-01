local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "BROKEN SPAWN",
    Footer = "by MEHKO МЕРУЛЕК",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Players = Window:AddTab("Players", "users"),
    Target = Window:AddTab("Target", "target"),
    TargetBlob = Window:AddTab("Target Blob", "bot"),
    Defense = Window:AddTab("Defense", "shield"),
    Smile = Window:AddTab("Smile", "smile"),
    Settings = Window:AddTab("Settings", "settings"),
}

local PlayersGroup = Tabs.Players:AddLeftGroupbox("Настройки")

local thirdPersonActive = false
local function enableThirdPerson()
    local player = game.Players.LocalPlayer
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMaxZoomDistance = 50
    player.CameraMinZoomDistance = 0.5
end
local function disableThirdPerson()
    local player = game.Players.LocalPlayer
    player.CameraMode = Enum.CameraMode.LockFirstPerson
end
PlayersGroup:AddToggle("ThirdPerson", {
    Text = "3 Вид",
    Default = false,
    Callback = function(Value)
        thirdPersonActive = Value
        if Value then enableThirdPerson() else disableThirdPerson() end
    end
})

local speedActive = false
local currentSpeedValue = 30
local speedConnection = nil
local speedSteppedConnection = nil
local speedSlider = PlayersGroup:AddSlider("SpeedValue", {
    Text = "Сила ускорения",
    Default = 30,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value) currentSpeedValue = Value end
})
local function applySpeed()
    if not speedActive then return end
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local moveDirection = hum.MoveDirection
    if moveDirection.Magnitude > 0 then
        local velocity = moveDirection.Unit * currentSpeedValue
        hrp.Velocity = Vector3.new(velocity.X, hrp.Velocity.Y, velocity.Z)
    end
end
local function startSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
    if speedSteppedConnection then speedSteppedConnection:Disconnect() end
    speedConnection = game:GetService("RunService").Stepped:Connect(applySpeed)
    speedSteppedConnection = game:GetService("RunService").Stepped:Connect(function()
        if not speedActive then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y, hrp.Velocity.Z) end
            end
        end
    end)
end
local function stopSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
    if speedSteppedConnection then speedSteppedConnection:Disconnect() end
    local char = game.Players.LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end
PlayersGroup:AddToggle("SpeedToggle", {
    Text = "Ускорение (толкает вперёд)",
    Default = false,
    Callback = function(Value)
        speedActive = Value
        if Value then startSpeedBoost() else stopSpeedBoost() end
    end
})

local jumpActive = false
local jumpPowerValue = 50
local jumpSlider = PlayersGroup:AddSlider("JumpPower", {
    Text = "Сила прыжка",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        jumpPowerValue = Value
        if jumpActive then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = jumpPowerValue
            end
        end
    end
})
local function applyJumpPower()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpPowerValue
        Library:Notify({Title = "BROKEN SPAWN", Description = "Сила прыжка: " .. jumpPowerValue, Duration = 2})
    end
end
local function resetJumpPower()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 50
        Library:Notify({Title = "BROKEN SPAWN", Description = "Сила прыжка сброшена до 50", Duration = 2})
    end
end
PlayersGroup:AddToggle("JumpToggle", {
    Text = "Увеличенный прыжок",
    Default = false,
    Callback = function(Value)
        jumpActive = Value
        if Value then applyJumpPower() else resetJumpPower() end
    end
})

local infiniteJumpActive = false
local infiniteJumpConnection = nil
local function startInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJumpActive then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end
local function stopInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
end
PlayersGroup:AddToggle("InfiniteJump", {
    Text = "Бесконечный прыжок",
    Default = false,
    Callback = function(Value)
        infiniteJumpActive = Value
        if Value then startInfiniteJump() else stopInfiniteJump() end
    end
})

local noclipActive = false
local noclipConnection = nil
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if noclipActive then
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end
local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end
PlayersGroup:AddToggle("Noclip", {
    Text = "Прохождение сквозь стены",
    Default = false,
    Callback = function(Value)
        noclipActive = Value
        if Value then startNoclip() else stopNoclip() end
    end
})

local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local autoStruggleConn = nil
DefenseGroup:AddToggle("AntiGrab", {
    Text = "Анти Граб",
    Default = false,
    Callback = function(Value)
        if Value then
            if autoStruggleConn then autoStruggleConn:Disconnect() end
            autoStruggleConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char.Head and char.Head:FindFirstChild("PartOwner") then
                    task.spawn(function()
                        if Struggle then pcall(function() Struggle:FireServer(LocalPlayer) end) end
                        pcall(function() ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer() end)
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then part.Anchored = true end
                        end
                        local held = LocalPlayer:FindFirstChild("IsHeld")
                        while held and held.Value do task.wait() end
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then part.Anchored = false end
                        end
                    end)
                end
            end)
        else
            if autoStruggleConn then autoStruggleConn:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end
    end
})

local AntiLagGroup = Tabs.Defense:AddRightGroupbox("Анти Лаг")
local antiLagActive = false
local function setupAntiLag()
    local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
    if grabFolder then
        local create = grabFolder:FindFirstChild("CreateGrabLine")
        local extend = grabFolder:FindFirstChild("ExtendGrabLine")
        if create then create:Destroy() end
        if extend then extend:Destroy() end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Beam") then v:Destroy() end
    end
end
AntiLagGroup:AddToggle("AntiLag", {
    Text = "Анти Лаг",
    Default = false,
    Callback = function(Value)
        antiLagActive = Value
        if Value then setupAntiLag() end
    end
})

local SmileGroup = Tabs.Smile:AddLeftGroupbox("Приколы")

-- ========== ЛАГ СЕРВЕРА (КАК В RESONANCE) ==========
-- Отключаем обработку CreateGrabLine на клиенте
local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
if grabEvents then
    local createGrabLine = grabEvents:FindFirstChild("CreateGrabLine")
    if createGrabLine then
        createGrabLine.OnClientEvent = function() end
        print("✅ CreateGrabLine отключён на клиенте")
    end
end

local lagActive = false
local lagPower = 50
local lagConnection = nil

local lagSlider = SmileGroup:AddSlider("LagPower", {
    Text = "Мощность лага",
    Default = 50,
    Min = 10,
    Max = 1000,
    Step = 10,
    Rounding = 0,
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

SmileGroup:AddToggle("LagToggle", {
    Text = "Включить лаг сервера",
    Default = false,
    Callback = function(Value)
        lagActive = Value
        if Value then startLag() else stopLag() end
    end
})

task.spawn(function()
    print("✅ Оптимизация запущена")
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.Brightness = 1
    lighting.ClockTime = 14
    for _, v in ipairs(lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end
    while true do
        task.wait(15)
        collectgarbage("collect")
        collectgarbage("step", 50)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
                v:Destroy()
            end
            if v:IsA("Beam") then v:Destroy() end
            if v:IsA("Decal") and v.Name ~= "PartOwner" then v:Destroy() end
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false end
        end
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("ParticleEmitter") then v.Enabled = false end
        end
        lighting.GlobalShadows = false
        lighting.Brightness = 1
        lighting.ClockTime = 14
    end
end)

local UIGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")
UIGroup:AddButton("Unload", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("BrokenSpawn")
SaveManager:SetFolder("BrokenSpawn/Configs")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

print("✅ Меню загружено | Лаг сервера работает")
