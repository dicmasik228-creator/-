-- [[ BROKEN SPAWN MENU - с Анти Граб, Анти Лаг, без тумана ]]

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
        if Value then
            enableThirdPerson()
        else
            disableThirdPerson()
        end
    end
})
-- ========== КОНЕЦ 3 ВИД ==========

-- ========== ЗАЩИТА (ЛЕВАЯ ГРУППА) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

-- АНТИ ГРАБ
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local antiGrabConnection = nil

DefenseGroup:AddToggle("AntiGrab", {
    Text = "Анти Граб",
    Default = false,
    Callback = function(Value)
        antiGrabActive = Value
        
        if antiGrabConnection then
            antiGrabConnection:Disconnect()
            antiGrabConnection = nil
        end
        
        if Value then
            antiGrabConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    if head:FindFirstChild("PartOwner") then
                        if Struggle then
                            pcall(function() Struggle:FireServer(LocalPlayer) end)
                        end
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        local held = LocalPlayer:FindFirstChild("IsHeld")
                        while antiGrabActive and held and held.Value do
                            task.wait()
                        end
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
        end
    end
})
-- ========== КОНЕЦ АНТИ ГРАБ ==========

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
    print("✅ Анти Лаг включён")
end

AntiLagGroup:AddToggle("AntiLag", {
    Text = "Анти Лаг",
    Default = false,
    Callback = function(Value)
        antiLagActive = Value
        if Value then
            setupAntiLag()
        else
            print("✅ Анти Лаг выключён")
        end
    end
})
-- ========== КОНЕЦ АНТИ ЛАГ ==========

-- ========== ОПТИМИЗАЦИЯ (ТУМАН УБРАН) ==========
task.spawn(function()
    print("✅ Оптимизация запущена (туман убран)")
    
    -- Убираем туман сразу
    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 0
    lighting.FogStart = 0
    lighting.GlobalShadows = false
    lighting.Brightness = 1.5
    
    while true do
        task.wait(10)
        collectgarbage("collect")
        
        -- Повторно убираем туман
        lighting.FogEnd = 0
        lighting.FogStart = 0
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = false
            end
            if v:IsA("Beam") then
                v:Destroy()
            end
        end
    end
end)
-- ========== КОНЕЦ ОПТИМИЗАЦИИ ==========

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

print("✅ Меню загружено | Анти Граб и Анти Лаг во вкладке Defense")
