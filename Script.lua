-- [[ BROKEN SPAWN MENU - с оптимизацией (каждые 10 сек) ]]

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

-- ВКЛАДКИ
local Tabs = {
    Players = Window:AddTab("Players", "users"),
    Target = Window:AddTab("Target", "target"),
    TargetBlob = Window:AddTab("Target Blob", "bot"),
    Defense = Window:AddTab("Defense", "shield"),
    Smile = Window:AddTab("Smile", "smile"),
    Settings = Window:AddTab("Settings", "settings"),
}

local function addEmptyGroup(tab, name)
    local group = tab:AddLeftGroupbox(name)
    group:AddLabel(" ")
end

addEmptyGroup(Tabs.Target, "Target")
addEmptyGroup(Tabs.TargetBlob, "Target Blob")
addEmptyGroup(Tabs.Smile, "Smile")

-- ========== 3 ВИД ==========
local PlayersGroup = Tabs.Players:AddLeftGroupbox("Настройки")

local thirdPersonActive = false
local originalCameraMode = nil
local originalZoomDistance = nil

local function enableThirdPerson()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    originalCameraMode = player.CameraMode
    originalZoomDistance = player.CameraMaxZoomDistance
    
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMaxZoomDistance = 50
    player.CameraMinZoomDistance = 0.5
    
    local function onCharacterAdded()
        task.wait(0.1)
        if thirdPersonActive then
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = 50
            player.CameraMinZoomDistance = 0.5
        end
    end
    
    if not PlayersGroup._charConn then
        PlayersGroup._charConn = player.CharacterAdded:Connect(onCharacterAdded)
    end
end

local function disableThirdPerson()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    if originalCameraMode then
        player.CameraMode = originalCameraMode
    else
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end
    
    if originalZoomDistance then
        player.CameraMaxZoomDistance = originalZoomDistance
    else
        player.CameraMaxZoomDistance = 0.5
    end
    player.CameraMinZoomDistance = 0.5
    
    if PlayersGroup._charConn then
        PlayersGroup._charConn:Disconnect()
        PlayersGroup._charConn = nil
    end
end

PlayersGroup:AddToggle("ThirdPerson", {
    Text = "3 Вид",
    Default = false,
    Callback = function(Value)
        thirdPersonActive = Value
        if Value then
            enableThirdPerson()
        else
            disableThirdPerson()
        end
    end
})
-- ========== КОНЕЦ 3 ВИД ==========

-- ========== ПЕРМАНЕНТНАЯ ОПТИМИЗАЦИЯ (КАЖДЫЕ 10 СЕКУНД) ==========
local function startOptimization()
    print("✅ Оптимизация запущена (каждые 10 секунд)")
    
    -- 1. ОТКЛЮЧАЕМ НЕНУЖНЫЕ ЭФФЕКТЫ В ЛАНДШАФТЕ
    local function optimizeLighting()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1000
        lighting.Brightness = 1.5
        lighting.ClockTime = 14
        lighting.Ambient = Color3.fromRGB(80, 80, 80)
        lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
        
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = false
            end
        end
    end
    
    -- 2. ОПТИМИЗАЦИЯ РАБОЧЕГО ПРОСТРАНСТВА
    local function optimizeWorkspace()
        workspace.Gravity = 196.2
        workspace.FallenPartsDestroyHeight = -500
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
            if v:IsA("Decal") then
                v.Transparency = 1
            end
            if v:IsA("Beam") then
                v:Destroy()
            end
        end
    end
    
    -- 3. ОПТИМИЗАЦИЯ ИГРОКОВ
    local function optimizePlayers()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") then
                        part.Enabled = false
                    end
                end
            end
        end
    end
    
    -- 4. АВТОМАТИЧЕСКАЯ ОЧИСТКА ПАМЯТИ
    local function garbageCollector()
        collectgarbage("collect")
        collectgarbage("step", 50)
    end
    
    -- 5. УДАЛЕНИЕ ЛИШНИХ ОБЪЕКТОВ
    local function cleanMisc()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Beam") or (v.Name and (v.Name:lower():find("line") or v.Name:lower():find("grab"))) then
                v:Destroy()
            end
        end
        
        local rs = game:GetService("ReplicatedStorage")
        for _, v in ipairs(rs:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = false
            end
        end
    end
    
    -- 6. ОПТИМИЗАЦИЯ ЗВУКОВ
    local function optimizeSounds()
        local soundService = game:GetService("SoundService")
        soundService.Volume = 0.5
        soundService.RespectFilteringEnabled = false
    end
    
    -- ВЫПОЛНЯЕМ ОДНОРАЗОВЫЕ ОПТИМИЗАЦИИ
    optimizeLighting()
    optimizeWorkspace()
    optimizeSounds()
    
    -- ЗАПУСКАЕМ ЦИКЛИЧЕСКУЮ ОЧИСТКУ (каждые 10 секунд)
    task.spawn(function()
        while true do
            task.wait(10)  -- ← КАЖДЫЕ 10 СЕКУНД
            garbageCollector()
            cleanMisc()
            optimizePlayers()
        end
    end)
    
    -- СЛЕДИМ ЗА НОВЫМИ ОБЪЕКТАМИ
    workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        end
        if obj:IsA("Beam") or (obj.Name and obj.Name:lower():find("line")) then
            obj:Destroy()
        end
    end)
    
    print("✅ Оптимизация полностью запущена (очистка каждые 10 сек)")
end

-- ЗАПУСКАЕМ ОПТИМИЗАЦИЮ СРАЗУ
startOptimization()
-- ========== КОНЕЦ ОПТИМИЗАЦИИ ==========

-- ========== ЗАЩИТА (ЛЕВАЯ ГРУППА) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

-- АНТИ ГРАБ
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
            if autoStruggleConn then
                autoStruggleConn:Disconnect()
            end
            autoStruggleConn = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    if head:FindFirstChild("PartOwner") then
                        task.spawn(function()
                            if Struggle then
                                Struggle:FireServer(LocalPlayer)
                            end
                            pcall(function()
                                ReplicatedStorage.GameCorrectionEvents.StopAllVelocity:FireServer()
                            end)
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = true
                                end
                            end
                            local isHeld = LocalPlayer:FindFirstChild("IsHeld")
                            while isHeld and isHeld.Value do
                                task.wait()
                            end
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Anchored = false
                                end
                            end
                        end)
                    end
                end
            end)
        else
            if autoStruggleConn then
                autoStruggleConn:Disconnect()
                autoStruggleConn = nil
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end
    end
})

-- ========== АНТИ ЛАГ (ПРАВАЯ ГРУППА) ==========
local AntiLagGroup = Tabs.Defense:AddRightGroupbox("Анти Лаг")

local antiLagActive = false

local function setupAntiLag()
    local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
    if grabFolder then
        local create = grabFolder:FindFirstChild("CreateGrabLine")
        local extend = grabFolder:FindFirstChild("ExtendGrabLine")
        if create and create:IsA("RemoteEvent") then
            create:Destroy()
        end
        if extend and extend:IsA("RemoteEvent") then
            extend:Destroy()
        end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Beam") or (v.Name and v.Name:lower():find("line")) then
            v:Destroy()
        end
    end
end

AntiLagGroup:AddToggle("AntiLag", {
    Text = "Анти Лаг",
    Default = false,
    Callback = function(Value)
        antiLagActive = Value
        if Value then
            setupAntiLag()
        end
    end
})
-- ========== КОНЕЦ АНТИ ЛАГ ==========

-- НАСТРОЙКИ
local UIGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")
UIGroup:AddButton("Unload", function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("BrokenSpawn")
SaveManager:SetFolder("BrokenSpawn/Configs")

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

print("✅ Меню загружено | Оптимизация каждые 10 секунд")
