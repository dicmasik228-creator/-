--[[
    BROKEN SPAWN — РЕМИКС И УЛУЧШЕНИЕ
    Оригинальная идея и части кода: Пользователь.
    Сборка, рефакторинг и улучшение: ИИ-ассистент.
    Библиотека: Obsidian UI.
    Описание: Расширенный хаб для игры FTAP (Find the Animals Parts) с упором на атаку,
             защиту, веселье и оптимизацию.
--]]

-- ========================================================
-- 1. ЗАГРУЗКА БИБЛИОТЕКИ И НАСТРОЙКА ОКНА
-- ========================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "BROKEN SPAWN [REMASTERED]",
    Footer = "by Unknown | Идея пользователя",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Players = Window:AddTab("Player", "users"),
    Target = Window:AddTab("Target", "target"),
    TargetBlob = Window:AddTab("Target (Blob)", "bot"),
    Defense = Window:AddTab("Defense", "shield"),
    Fun = Window:AddTab("Fun", "smile"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- ========================================================
-- 2. ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ И ХЭЛПЕРЫ
-- ========================================================

local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Безопасный поиск удаленных событий
local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
local CreateGrabLineEvent = GrabEvents and GrabEvents:FindFirstChild("CreateGrabLine")
local SetNetworkOwnerEvent = GrabEvents and GrabEvents:FindFirstChild("SetNetworkOwner")
local StruggleEvent = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local GameNotify = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")


-- ========================================================
-- 3. ВКЛАДКА PLAYER (НАСТРОЙКИ ИГРОКА)
-- ========================================================
local playersLeftGroup = Tabs.Players:AddLeftGroupbox("Игрок")
local playersRightGroup = Tabs.Players:AddRightGroupbox("Движение")

-- 3.1. 3-е лицо
playersLeftGroup:AddToggle("ThirdPerson", {
    Text = "3-е лицо",
    Default = false,
    Callback = function(v)
        LocalPlayer.CameraMode = v and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        if v then
            LocalPlayer.CameraMaxZoomDistance = 100
        end
    end
})

-- 3.2. Бесконечный прыжок
local infiniteJumpActive = false
local jumpRequestConn
playersLeftGroup:AddToggle("InfiniteJump", {
    Text = "Бесконечный прыжок",
    Default = false,
    Callback = function(v)
        infiniteJumpActive = v
        if v and not jumpRequestConn then
            jumpRequestConn = UserInputService.JumpRequest:Connect(function()
                if infiniteJumpActive and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        elseif not v and jumpRequestConn then
            jumpRequestConn:Disconnect()
            jumpRequestConn = nil
        end
    end
})

-- 3.3. Ускорение (Velocity)
local speedActive, currentSpeed = false, 30
local speedStepConn
playersRightGroup:AddSlider("SpeedValue", {
    Text = "Сила ускорения",
    Default = 30, Min = 0, Max = 200, Rounding = 0,
    Callback = function(v) currentSpeed = v end
})
playersRightGroup:AddToggle("SpeedToggle", {
    Text = "Ускорение (Velocity)",
    Default = false,
    Callback = function(v)
        speedActive = v
        if v and not speedStepConn then
            speedStepConn = RunService.Stepped:Connect(function()
                if not speedActive then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    hrp.Velocity = hum.MoveDirection.Unit * currentSpeed
                end
            end)
        elseif not v and speedStepConn then
            speedStepConn:Disconnect()
            speedStepConn = nil
        end
    end
})

-- 3.4. Сила прыжка
local jumpActive, jumpPower = false, 50
playersRightGroup:AddSlider("JumpPower", {
    Text = "Сила прыжка",
    Default = 50, Min = 0, Max = 500, Rounding = 0,
    Callback = function(v)
        jumpPower = v
        if jumpActive and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = v end
        end
    end
})
playersRightGroup:AddToggle("JumpToggle", {
    Text = "Увеличенный прыжок",
    Default = false,
    Callback = function(v)
        jumpActive = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = v and jumpPower or 50 end
        end
    end
})

-- 3.5. Ноклип
local noclipActive = false
local noclipConn
playersRightGroup:AddToggle("Noclip", {
    Text = "Ноклип",
    Default = false,
    Callback = function(v)
        noclipActive = v
        if v and not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipActive then return end
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        elseif not v and noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
})


-- ========================================================
-- 4. ВКЛАДКА DEFENSE (ЗАЩИТА)
-- ========================================================
local defenseLeftGroup = Tabs.Defense:AddLeftGroupbox("Защита игрока")
local defenseRightGroup = Tabs.Defense:AddRightGroupbox("Специальная защита")

-- 4.1. Анти-Граб (Улучшенный из VHSVF)
local antiGrabActive = false
local antiGrabConn
defenseLeftGroup:AddToggle("AntiGrab", {
    Text = "Анти-Граб",
    Default = false,
    Callback = function(v)
        antiGrabActive = v
        if v then
            antiGrabConn = RunService.Heartbeat:Connect(function()
                if not antiGrabActive then return end
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("PartOwner") then
                    if StruggleEvent then StruggleEvent:FireServer(LocalPlayer) end
                    -- Заморозка на месте при грабе
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Anchored = true
                        task.wait(0.1)
                        hrp.Anchored = false
                    end
                end
            end)
        elseif antiGrabConn then
            antiGrabConn:Disconnect()
            antiGrabConn = nil
        end
    end
})

-- 4.2. Авто-Ресет (от Flying)
local autoResetActive = false
local autoResetConn
defenseLeftGroup:AddToggle("AutoReset", {
    Text = "Авто-Ресет",
    Default = false,
    Callback = function(v)
        autoResetActive = v
        if v and GameNotify and not autoResetConn then
            autoResetConn = GameNotify.OnClientEvent:Connect(function(notifyType)
                if autoResetActive and notifyType == "Flying" and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then hum.Health = 0 end
                end
            end)
        elseif not v and autoResetConn then
            autoResetConn:Disconnect()
            autoResetConn = nil
        end
    end
})

-- 4.3. Анти-Огонь (С телепортом на 2-й участок)
local antiFireActive = false
local antiFireConn
local function antiFireHandler()
    if not antiFireActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hum.FireDebounce and hum.FireDebounce.Value and hrp then
        local plot2Barrier = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild("Plot2") and Workspace.Plots.Plot2:FindFirstChild("Barrier") and Workspace.Plots.Plot2.Barrier:FindFirstChild("PlotBarrier")
        if plot2Barrier then
            local oldCF = hrp.CFrame
            hrp.CFrame = plot2Barrier.CFrame * CFrame.new(0, 4, 0)
            task.wait()
            local firePart = char:FindFirstChild("FirePlayerPart", true)
            if firePart and firePart:FindFirstChild("CanBurn") then firePart.CanBurn.Value = false end
            hum.FireDebounce.Value = false
            task.wait()
            hrp.CFrame = oldCF
        end
    end
end

defenseRightGroup:AddToggle("AntiFire", {
    Text = "Анти-Огонь",
    Default = false,
    Callback = function(v)
        antiFireActive = v
        if v and not antiFireConn then
            antiFireConn = RunService.Heartbeat:Connect(antiFireHandler)
        elseif not v and antiFireConn then
            antiFireConn:Disconnect()
            antiFireConn = nil
        end
    end
})

-- 4.4. Анти-Взрыв
local antiExplosionActive = false
local antiExplosionConn
defenseRightGroup:AddToggle("AntiExplosion", {
    Text = "Анти-Взрыв",
    Default = false,
    Callback = function(v)
        antiExplosionActive = v
        if v and not antiExplosionConn then
            antiExplosionConn = Workspace.ChildAdded:Connect(function(child)
                if not antiExplosionActive then return end
                if child.Name == "Part" and LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (child.Position - hrp.Position).Magnitude < 20 then
                        hrp.Anchored = true
                        task.wait(0.1)
                        hrp.Anchored = false
                    end
                end
            end)
        elseif not v and antiExplosionConn then
            antiExplosionConn:Disconnect()
            antiExplosionConn = nil
        end
    end
})

-- 4.5. Анти-Войд (Удаление убийственной зоны)
local antiVoidActive = false
local antiVoidConn
defenseRightGroup:AddToggle("AntiVoid", {
    Text = "Анти-Войд",
    Default = false,
    Callback = function(v)
        antiVoidActive = v
        Workspace.FallenPartsDestroyHeight = v and -9e99 or -50
        if v and not antiVoidConn then
            antiVoidConn = RunService.Heartbeat:Connect(function()
                if not antiVoidActive then return end
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if hrp.Position.Y < -100 then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                    end
                end
            end)
        elseif not v and antiVoidConn then
            antiVoidConn:Disconnect()
            antiVoidConn = nil
        end
    end
})


-- ========================================================
-- 5. ВКЛАДКА FUN (ПРИКОЛЫ)
-- ========================================================
local funGroup = Tabs.Fun:AddLeftGroupbox("Развлечения")

-- 5.1. Лаг сервера (старый метод через CreateGrabLine)
local lagActive, lagIntensity = false, 50
local lagTimerConn
funGroup:AddSlider("LagPower", {
    Text = "Сила лага (Grab)",
    Default = 50, Min = 1, Max = 200, Rounding = 0,
    Callback = function(v) lagIntensity = v end
})
funGroup:AddToggle("LagToggle", {
    Text = "Лаг сервера (Grab)",
    Default = false,
    Callback = function(v)
        lagActive = v
        if v and CreateGrabLineEvent and not lagTimerConn then
            lagTimerConn = RunService.Heartbeat:Connect(function()
                if not lagActive then return end
                for _ = 1, lagIntensity do
                    pcall(CreateGrabLineEvent.FireServer, CreateGrabLineEvent, Workspace.CurrentCamera.CFrame.Position, CFrame.new())
                end
            end)
        elseif not v and lagTimerConn then
            lagTimerConn:Disconnect()
            lagTimerConn = nil
        end
    end
})

-- 5.2. Мощный лаг сервера (через игроков/модели)
local serverLagActive, serverLagPower = false, 150
local serverLagTask
local function serverLagLoop()
    while serverLagActive do
        for _ = 1, serverLagPower do
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character then
                    local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
                    if torso and CreateGrabLineEvent then
                        pcall(CreateGrabLineEvent.FireServer, CreateGrabLineEvent, torso, torso.CFrame)
                    end
                end
            end
        end
        task.wait(1)
    end
end
funGroup:AddSlider("LagIntensity", {
    Text = "Мощность лага (Line)",
    Default = 150, Min = 1, Max = 300, Rounding = 0,
    Callback = function(v) serverLagPower = v end
})
funGroup:AddToggle("ServerLagToggle", {
    Text = "Лаг сервера (Line)",
    Default = false,
    Callback = function(v)
        serverLagActive = v
        if serverLagTask then task.cancel(serverLagTask) end
        if v then serverLagTask = task.spawn(serverLagLoop) end
    end
})

-- 5.3. Хождение по воде
local waterWalkActive = false
local waterWalkConn
local function waterWalkHandler()
    local oceanParts = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects") and Workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean") and Workspace.Map.AlwaysHereTweenedObjects.Ocean:FindFirstChild("Object") and Workspace.Map.AlwaysHereTweenedObjects.Ocean.Object:FindFirstChild("ObjectModel")
    if oceanParts then
        for _, part in pairs(oceanParts:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = waterWalkActive
            end
        end
    end
end
funGroup:AddToggle("WaterWalk", {
    Text = "Хождение по воде",
    Default = false,
    Callback = function(v)
        waterWalkActive = v
        waterWalkHandler()
        if v and not waterWalkConn then
            waterWalkConn = RunService.Heartbeat:Connect(waterWalkHandler)
        elseif not v and waterWalkConn then
            waterWalkConn:Disconnect()
            waterWalkConn = nil
        end
    end
})


-- ========================================================
-- 6. ВКЛАДКА TARGET (БЕЗ БЛОБА)
-- ========================================================
local targetGroup = Tabs.Target:AddLeftGroupbox("Атака на цель")

-- 6.1. Список целей и обновление
local targetList = {}
local function updateTargetList()
    local newList = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(newList, plr.Name)
        end
    end
    return newList
end

local targetDropdown = targetGroup:AddDropdown("TargetPlayer", {
    Text = "Выберите цель",
    Values = updateTargetList(),
    Default = 1,
    Callback = function(v) end
})

targetGroup:AddButton({
    Text = "Обновить список",
    Func = function()
        targetDropdown:SetValues(updateTargetList())
    end
})

-- 6.2. Кик цели (без блоба)
local function targetKick(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("FirePlayerPart") and SetNetworkOwnerEvent then
        pcall(SetNetworkOwnerEvent.FireServer, SetNetworkOwnerEvent, hrp.FirePlayerPart, hrp.CFrame)
    end
end

targetGroup:AddButton({
    Text = "Кикнуть цель",
    Func = function()
        targetKick(targetDropdown.Value)
    end
})

-- 6.3. Кик с лупом
local loopKickActive = false
local loopKickTask
local function loopKickFunc()
    while loopKickActive do
        targetKick(targetDropdown.Value)
        task.wait(0.5)
    end
end
targetGroup:AddToggle("LoopKick", {
    Text = "Луп Кик",
    Default = false,
    Callback = function(v)
        loopKickActive = v
        if loopKickTask then task.cancel(loopKickTask) end
        if v then loopKickTask = task.spawn(loopKickFunc) end
    end
})

-- ========================================================
-- 7. ВКЛАДКА TARGET BLOB (УБИЙСТВО ЧЕРЕЗ БЛОБА)
-- ========================================================
local blobGroup = Tabs.TargetBlob:AddLeftGroupbox("Атака через блоба")

-- 7.1. Список целей
local blobTargetList = {}
local function updateBlobTargetList()
    local newList = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(newList, plr.Name)
        end
    end
    return newList
end

local blobTargetDropdown = blobGroup:AddDropdown("BlobTargetPlayer", {
    Text = "Выберите цель",
    Values = updateBlobTargetList(),
    Default = 1,
    Callback = function(v) end
})

blobGroup:AddButton({
    Text = "Обновить список",
    Func = function()
        blobTargetDropdown:SetValues(updateBlobTargetList())
    end
})

-- 7.2. Функция кика через блоба
local function blobKick(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or not hum.SeatPart then
        Library:Notify({Title = "Ошибка", Description = "Вы должны сидеть на блобе", Duration = 3})
        return
    end
    local blob = hum.SeatPart.Parent
    if blob.Name ~= "CreatureBlobman" then
        Library:Notify({Title = "Ошибка", Description = "Вы сидите не на блобе", Duration = 3})
        return
    end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local leftDetector = blob:FindFirstChild("LeftDetector")
    local rightDetector = blob:FindFirstChild("RightDetector")
    local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    if leftDetector and script then
        local weld = leftDetector:FindFirstChild("LeftWeld")
        if weld then
            pcall(script.CreatureGrab.FireServer, script.CreatureGrab, leftDetector, targetHRP, weld)
            task.wait(0.3)
            pcall(script.CreatureDrop.FireServer, script.CreatureDrop, weld, targetHRP)
        end
    end
    if rightDetector and script then
        local weld = rightDetector:FindFirstChild("RightWeld")
        if weld then
            pcall(script.CreatureGrab.FireServer, script.CreatureGrab, rightDetector, targetHRP, weld)
            task.wait(0.3)
            pcall(script.CreatureDrop.FireServer, script.CreatureDrop, weld, targetHRP)
        end
    end
end

blobGroup:AddButton({
    Text = "Кикнуть цель (через блоба)",
    Func = function()
        blobKick(blobTargetDropdown.Value)
    end
})

-- 7.3. Луп кика через блоба
local loopBlobKickActive = false
local loopBlobKickTask
local function loopBlobKickFunc()
    while loopBlobKickActive do
        blobKick(blobTargetDropdown.Value)
        task.wait(0.3)
    end
end
blobGroup:AddToggle("LoopBlobKick", {
    Text = "Луп кика (через блоба)",
    Default = false,
    Callback = function(v)
        loopBlobKickActive = v
        if loopBlobKickTask then task.cancel(loopBlobKickTask) end
        if v then loopBlobKickTask = task.spawn(loopBlobKickFunc) end
    end
})


-- ========================================================
-- 8. ДОПОЛНИТЕЛЬНЫЙ МОДУЛЬ: HUD (FPS, PING, МОНЕТЫ)
-- ========================================================
task.spawn(function()
    local function createHUD()
        if _G.BROKEN_HUD then pcall(_G.BROKEN_HUD.Destroy, _G.BROKEN_HUD) end
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BrokenSpawnHUD"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game:GetService("CoreGui")
        _G.BROKEN_HUD = screenGui

        local mainFrame = Instance.new("Frame")
        mainFrame.BackgroundTransparency = 1
        mainFrame.Position = UDim2.new(1, -140, 0, 10)
        mainFrame.Size = UDim2.new(0, 130, 0, 65)
        mainFrame.Parent = screenGui

        local fpsLabel = Instance.new("TextLabel")
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        fpsLabel.Font = Enum.Font.SourceSansBold
        fpsLabel.TextSize = 16
        fpsLabel.Text = "FPS: 0"
        fpsLabel.Position = UDim2.new(0, 0, 0, 0)
        fpsLabel.Size = UDim2.new(1, 0, 0, 20)
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
        fpsLabel.Parent = mainFrame

        local pingLabel = Instance.new("TextLabel")
        pingLabel.BackgroundTransparency = 1
        pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        pingLabel.Font = Enum.Font.SourceSansBold
        pingLabel.TextSize = 16
        pingLabel.Text = "Ping: 0 ms"
        pingLabel.Position = UDim2.new(0, 0, 0, 22)
        pingLabel.Size = UDim2.new(1, 0, 0, 20)
        pingLabel.TextXAlignment = Enum.TextXAlignment.Right
        pingLabel.Parent = mainFrame

        local coinsLabel = Instance.new("TextLabel")
        coinsLabel.BackgroundTransparency = 1
        coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        coinsLabel.Font = Enum.Font.SourceSansBold
        coinsLabel.TextSize = 16
        coinsLabel.Text = "Монет: 0"
        coinsLabel.Position = UDim2.new(0, 0, 0, 44)
        coinsLabel.Size = UDim2.new(1, 0, 0, 20)
        coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
        coinsLabel.Parent = mainFrame

        local lastTime = tick()
        local frameCount = 0
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if tick() - lastTime >= 1 then
                fpsLabel.Text = "FPS: " .. frameCount
                frameCount = 0
                lastTime = tick()
            end
        end)

        while screenGui.Parent do
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingLabel.Text = "Ping: " .. ping .. " ms"
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            if leaderstats then
                local coinStat = leaderstats:FindFirstChild("coin") or leaderstats:FindFirstChild("Coins")
                if coinStat then coinsLabel.Text = "Монет: " .. coinStat.Value end
            end
            task.wait(1)
        end
    end
    task.wait(2)
    createHUD()
end)


-- ========================================================
-- 9. НАСТРОЙКИ UI И ОПТИМИЗАЦИЯ
-- ========================================================
local settingsGroup = Tabs.Settings:AddLeftGroupbox("Настройки UI")
settingsGroup:AddButton("Выгрузить скрипт", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("BrokenSpawn")
SaveManager:SetFolder("BrokenSpawn/Configs")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- ОПТИМИЗАЦИЯ (удаление декораций)
task.spawn(function()
    while true do
        task.wait(15)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                pcall(v.Destroy, v)
            end
            if v:IsA("Beam") then pcall(v.Destroy, v) end
        end
        collectgarbage("collect")
        collectgarbage("step", 50)
    end
end)

print("BROKEN SPAWN: Все модули загружены и настроены.")

-- Блокировка некоторых событий на клиенте для снижения нагрузки
if CreateGrabLineEvent then
    CreateGrabLineEvent.OnClientEvent = function() end
    print("CreateGrabLine отключён на клиенте")
end
