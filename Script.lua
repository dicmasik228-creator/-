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

local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

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

local AntiLagGroup = Tabs.Defense:AddRightGroupbox("Анти Лаг")

local antiLagActive = false
local packetLagActive = false
local lastLagSource = false

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

local function startPacketLagDetector()
    local RS = game:GetService("ReplicatedStorage")
    local grabEvents = RS:FindFirstChild("GrabEvents")
    if not grabEvents then return end
    
    local extendLine = grabEvents:FindFirstChild("ExtendGrabLine")
    if not extendLine then return end
    
    local function GetSizeMB(StringLength)
        return StringLength / (1024 * 1024)
    end
    
    extendLine.OnClientEvent:Connect(function(arg1, data)
        if not packetLagActive then return end
        if typeof(data) == "string" and not lastLagSource then
            lastLagSource = true
            local StringLen = string.len(data)
            if StringLen > 300 then
                local SizeRounded = math.round(GetSizeMB(StringLen) * 1000) / 1000
                Library:Notify({
                    Title = "BROKEN SPAWN",
                    Description = "⚠️ ПАКЕТНЫЙ ЛАГ!\nРазмер: " .. tostring(SizeRounded) .. " MB",
                    Duration = 5
                })
                if not antiLagActive then
                    setupAntiLag()
                    antiLagActive = true
                    if Toggles.AntiLag then
                        Toggles.AntiLag:SetValue(true)
                    end
                end
            end
            task.delay(5, function()
                lastLagSource = false
            end)
        end
    end)
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

AntiLagGroup:AddToggle("AutoAntiLag", {
    Text = "Авто Анти Лаг",
    Default = false,
    Callback = function(Value)
        packetLagActive = Value
        if Value then
            startPacketLagDetector()
        end
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

print("✅ Меню загружено | Анти Лаг справа | Оптимизация работает")
