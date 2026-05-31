-- ========== ЗАГРУЗКА БИБЛИОТЕК ==========
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- ========== СОЗДАНИЕ ОКНА МЕНЮ ==========
local Window = Library:CreateWindow({
    Title = "BROKEN SPAWN",
    Footer = "by MEHKO МЕРУЛЕК",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- ========== СОЗДАНИЕ ВКЛАДОК ==========
local Tabs = {
    Players = Window:AddTab("Players", "users"),
    Target = Window:AddTab("Target", "target"),
    TargetBlob = Window:AddTab("Target Blob", "bot"),
    Defense = Window:AddTab("Defense", "shield"),
    Smile = Window:AddTab("Smile", "smile"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- ========== ВКЛАДКА PLAYERS (НАСТРОЙКИ) ==========
local PlayersGroup = Tabs.Players:AddLeftGroupbox("Настройки")

-- ========== 3 ВИД ==========
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
-- ========== КОНЕЦ 3 ВИД ==========

-- ========== УСКОРЕНИЕ (ТОЛКАЕТ ВПЕРЁД) ==========
local speedActive = false
local currentSpeedValue = 30
local speedConnection = nil

local speedSlider = PlayersGroup:AddSlider("SpeedValue", {
    Text = "Сила ускорения",
    Default = 30,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        currentSpeedValue = Value
    end
})

local function startSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
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
    end)
end

local function stopSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
end

PlayersGroup:AddToggle("SpeedToggle", {
    Text = "Ускорение (толкает вперёд)",
    Default = false,
    Callback = function(Value)
        speedActive = Value
        if Value then startSpeedBoost() else stopSpeedBoost() end
    end
})
-- ========== КОНЕЦ УСКОРЕНИЯ ==========
-- ========== КОНЕЦ ВКЛАДКИ PLAYERS ==========

-- ========== ВКЛАДКА DEFENSE (ЗАЩИТА) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

-- ========== АНТИ ГРАБ ==========
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
-- ========== КОНЕЦ АНТИ ГРАБ ==========

-- ========== АНТИ ЛАГ ==========
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
-- ========== КОНЕЦ АНТИ ЛАГ ==========
-- ========== КОНЕЦ ВКЛАДКИ DEFENSE ==========

-- ========== ВКЛАДКА SMILE (ПРИКОЛЫ) ==========
local SmileGroup = Tabs.Smile:AddLeftGroupbox("Приколы")

local дальнийЗахватАктивен = false
local дальнийЗахватDiedHandle = nil

local function reloadGrabbingScript()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("GrabbingScript") then
        pcall(function()
            char.GrabbingScript.Enabled = false
            char.GrabbingScript.Enabled = true
        end)
    end
end

local function applyДальнийЗахват()
    local LocalPlayer = game.Players.LocalPlayer
    local RS = game:GetService("ReplicatedStorage")
    local RFirst = game:GetService("ReplicatedFirst")
    
    local oldMarker = LocalPlayer:FindFirstChild("FartherReach")
    if oldMarker then oldMarker:Destroy() end
    
    local marker = Instance.new("BoolValue")
    marker.Name = "FartherReach"
    marker.Value = true
    marker.Parent = LocalPlayer
    
    local ScriptNotify = RS.GamepassEvents.FurtherReachBoughtNotifier
    local Activator = RS.MenuToys.LimitedTimeToyEvent
    
    ScriptNotify.Parent = RFirst
    Activator.Parent = RS.GamepassEvents
    Activator.Name = "FurtherReachBoughtNotifier"
    
    reloadGrabbingScript()
    
    task.delay(0.1, function()
        pcall(function() Activator:FireServer() end)
    end)
end

local function removeДальнийЗахват()
    local LocalPlayer = game.Players.LocalPlayer
    local RS = game:GetService("ReplicatedStorage")
    
    local marker = LocalPlayer:FindFirstChild("FartherReach")
    if marker then marker:Destroy() end
    
    local ScriptNotify = RS.GamepassEvents.FurtherReachBoughtNotifier
    local Activator = RS.MenuToys.LimitedTimeToyEvent
    
    ScriptNotify.Parent = RS.GamepassEvents
    Activator.Name = "LimitedTimeToyEvent"
    Activator.Parent = RS.MenuToys
    
    reloadGrabbingScript()
end

local function toggleДальнийЗахват()
    дальнийЗахватАктивен = not дальнийЗахватАктивен
    local isEnabled = дальнийЗахватАктивен
    
    Library:Notify({
        Title = "BROKEN SPAWN",
        Description = isEnabled and "Дальний захват ВКЛЮЧЁН" or "Дальний захват ВЫКЛЮЧЕН",
        Duration = 3
    })
    
    if isEnabled then
        applyДальнийЗахват()
        
        if дальнийЗахватDiedHandle then
            дальнийЗахватDiedHandle:Disconnect()
        end
        
        дальнийЗахватDiedHandle = game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
            task.wait(0.5)
            if дальнийЗахватАктивен then
                task.wait(0.3)
                pcall(function() applyДальнийЗахват() end)
            end
        end)
    else
        removeДальнийЗахват()
        if дальнийЗахватDiedHandle then
            дальнийЗахватDiedHandle:Disconnect()
            дальнийЗахватDiedHandle = nil
        end
    end
end

SmileGroup:AddToggle("ДальнийЗахват", {
    Text = "Дальний захват",
    Default = false,
    Callback = function(Value)
        if Value and not дальнийЗахватАктивен then
            toggleДальнийЗахват()
        elseif not Value and дальнийЗахватАктивен then
            toggleДальнийЗахват()
        end
    end
})
-- ========== КОНЕЦ ВКЛАДКИ SMILE ==========

-- ========== ОПТИМИЗАЦИЯ (РАБОТАЕТ В ФОНЕ) ==========
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
            if v:IsA("Beam") then
                v:Destroy()
            end
            if v:IsA("Decal") and v.Name ~= "PartOwner" then
                v:Destroy()
            end
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                v.Enabled = false
            end
        end
        
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = false
            end
        end
        
        lighting.GlobalShadows = false
        lighting.Brightness = 1
        lighting.ClockTime = 14
    end
end)
-- ========== КОНЕЦ ОПТИМИЗАЦИИ ==========

-- ========== ВКЛАДКА SETTINGS (НАСТРОЙКИ UI) ==========
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
-- ========== КОНЕЦ ВКЛАДКИ SETTINGS ==========

print("✅ Меню загружено | Дальний захват не отключается при смерти")
