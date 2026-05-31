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

-- ========== ЛАГ 1 (ExtendGrabLine) ==========
local lag1Active = false
local lag1Power = 100
local lag1Connection = nil

local lag1Slider = SmileGroup:AddSlider("Lag1Power", {
    Text = "Лаг 1 (Line) мощность",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) lag1Power = Value end
})

local function startLag1()
    if lag1Connection then lag1Connection:Disconnect() end
    local extendLine = ReplicatedStorage:FindFirstChild("GrabEvents") and ReplicatedStorage.GrabEvents:FindFirstChild("ExtendGrabLine")
    if not extendLine then Library:Notify({Title = "Ошибка", Description = "ExtendGrabLine не найден", Duration = 3}) return end
    lag1Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if lag1Active then for i = 1, lag1Power do pcall(function() extendLine:FireServer(string.rep("A", 500)) end) end end
    end)
    Library:Notify({Title = "Лаг 1", Description = "Включён (Line)", Duration = 3})
end

local function stopLag1()
    if lag1Connection then lag1Connection:Disconnect() end
    Library:Notify({Title = "Лаг 1", Description = "Выключен", Duration = 2})
end

SmileGroup:AddToggle("Lag1Toggle", {
    Text = "Лаг 1 (ExtendGrabLine)",
    Default = false,
    Callback = function(Value)
        lag1Active = Value
        if Value then startLag1() else stopLag1() end
    end
})

-- ========== ЛАГ 2 (StopAllVelocity) ==========
local lag2Active = false
local lag2Power = 100
local lag2Connection = nil

local lag2Slider = SmileGroup:AddSlider("Lag2Power", {
    Text = "Лаг 2 (Velocity) мощность",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) lag2Power = Value end
})

local function startLag2()
    if lag2Connection then lag2Connection:Disconnect() end
    local stopVelocity = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("StopAllVelocity")
    if not stopVelocity then Library:Notify({Title = "Ошибка", Description = "StopAllVelocity не найден", Duration = 3}) return end
    lag2Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if lag2Active then for i = 1, lag2Power do pcall(function() stopVelocity:FireServer() end) end end
    end)
    Library:Notify({Title = "Лаг 2", Description = "Включён (Velocity)", Duration = 3})
end

local function stopLag2()
    if lag2Connection then lag2Connection:Disconnect() end
    Library:Notify({Title = "Лаг 2", Description = "Выключен", Duration = 2})
end

SmileGroup:AddToggle("Lag2Toggle", {
    Text = "Лаг 2 (StopAllVelocity)",
    Default = false,
    Callback = function(Value)
        lag2Active = Value
        if Value then startLag2() else stopLag2() end
    end
})

-- ========== ЛАГ 3 (CreateGrabLine) ==========
local lag3Active = false
local lag3Power = 100
local lag3Connection = nil

local lag3Slider = SmileGroup:AddSlider("Lag3Power", {
    Text = "Лаг 3 (Grab) мощность",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) lag3Power = Value end
})

local function startLag3()
    if lag3Connection then lag3Connection:Disconnect() end
    local createLine = ReplicatedStorage:FindFirstChild("GrabEvents") and ReplicatedStorage.GrabEvents:FindFirstChild("CreateGrabLine")
    if not createLine then Library:Notify({Title = "Ошибка", Description = "CreateGrabLine не найден", Duration = 3}) return end
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local targets = {}
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(targets, hrp) end
        end
    end
    lag3Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if lag3Active then
            for _, target in ipairs(targets) do
                for i = 1, lag3Power do
                    pcall(function() createLine:FireServer(target, target.CFrame) end)
                end
            end
        end
    end)
    Library:Notify({Title = "Лаг 3", Description = "Включён (Grab)", Duration = 3})
end

local function stopLag3()
    if lag3Connection then lag3Connection:Disconnect() end
    Library:Notify({Title = "Лаг 3", Description = "Выключен", Duration = 2})
end

SmileGroup:AddToggle("Lag3Toggle", {
    Text = "Лаг 3 (CreateGrabLine)",
    Default = false,
    Callback = function(Value)
        lag3Active = Value
        if Value then startLag3() else stopLag3() end
    end
})

-- ========== ЛАГ 4 (GameCorrectionsNotify) ==========
local lag4Active = false
local lag4Power = 100
local lag4Connection = nil

local lag4Slider = SmileGroup:AddSlider("Lag4Power", {
    Text = "Лаг 4 (Notify) мощность",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) lag4Power = Value end
})

local function startLag4()
    if lag4Connection then lag4Connection:Disconnect() end
    local gameNotify = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")
    if not gameNotify then Library:Notify({Title = "Ошибка", Description = "GameCorrectionsNotify не найден", Duration = 3}) return end
    lag4Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if lag4Active then for i = 1, lag4Power do pcall(function() gameNotify:FireServer("Flying") end) end end
    end)
    Library:Notify({Title = "Лаг 4", Description = "Включён (Notify)", Duration = 3})
end

local function stopLag4()
    if lag4Connection then lag4Connection:Disconnect() end
    Library:Notify({Title = "Лаг 4", Description = "Выключен", Duration = 2})
end

SmileGroup:AddToggle("Lag4Toggle", {
    Text = "Лаг 4 (GameCorrectionsNotify)",
    Default = false,
    Callback = function(Value)
        lag4Active = Value
        if Value then startLag4() else stopLag4() end
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

print("✅ Меню загружено | 4 вида лага во вкладке Smile")
