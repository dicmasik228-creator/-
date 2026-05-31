-- [[ BROKEN SPAWN - МАКСИМАЛЬНАЯ ОПТИМИЗАЦИЯ (УБИРАЕМ СЕРОСТЬ) ]]

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

-- ========== ЗАЩИТА ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")

local antiGrabActive = false
local antiGrabConnection = nil

DefenseGroup:AddToggle("AntiGrab", {
    Text = "Анти Граб",
    Default = false,
    Callback = function(Value)
        antiGrabActive = Value
        if antiGrabConnection then antiGrabConnection:Disconnect() end
        if Value then
            antiGrabConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char.Head and char.Head:FindFirstChild("PartOwner") then
                    if Struggle then pcall(function() Struggle:FireServer(LocalPlayer) end) end
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = true end
                    end
                    local held = LocalPlayer:FindFirstChild("IsHeld")
                    while antiGrabActive and held and held.Value do task.wait() end
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.Anchored = false end
                    end
                end
            end)
        end
    end
})

-- ========== АНТИ ЛАГ ==========
local AntiLagGroup = Tabs.Defense:AddRightGroupbox("Анти Лаг")

AntiLagGroup:AddToggle("AntiLag", {
    Text = "Анти Лаг",
    Default = false,
    Callback = function(Value)
        if Value then
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
    end
})

-- ========== ОПТИМИЗАЦИЯ (УБИРАЕМ СЕРОСТЬ) ==========
task.spawn(function()
    print("✅ Максимальная оптимизация: убираем серость")
    
    local lighting = game:GetService("Lighting")
    
    -- Отключаем всё освещение
    lighting.Ambient = Color3.fromRGB(0, 0, 0)
    lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    lighting.Brightness = 0
    lighting.ExposureCompensation = 0
    lighting.GlobalShadows = false
    lighting.ClockTime = 0
    lighting.FogEnd = 0
    lighting.FogStart = 0
    
    -- Удаляем всё лишнее из Lighting
    for _, v in ipairs(lighting:GetChildren()) do
        pcall(function() v:Destroy() end)
    end
    
    -- Удаляем скайбокс и атмосферу
    local sky = game:GetService("Lighting"):FindFirstChild("Sky")
    if sky then sky:Destroy() end
    
    -- Удаляем все эффекты в игре
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v:Destroy()
        end
        if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
            v:Destroy()
        end
        if v:IsA("Decal") then
            v:Destroy()
        end
        if v:IsA("Beam") then
            v:Destroy()
        end
        if v:IsA("Atmosphere") or v:IsA("Sky") then
            v:Destroy()
        end
    end
    
    -- Постоянно поддерживаем черноту
    while true do
        task.wait(5)
        lighting.Ambient = Color3.fromRGB(0, 0, 0)
        lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        lighting.Brightness = 0
        lighting.ClockTime = 0
        lighting.FogEnd = 0
    end
end)

-- ========== НАСТРОЙКИ ==========
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

print("✅ BROKEN SPAWN загружен | Максимальная оптимизация включена")
