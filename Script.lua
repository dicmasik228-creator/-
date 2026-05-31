-- [[ BROKEN SPAWN MENU - ПРОСТОЙ РАБОЧИЙ АНТИ ГРАБ ]]

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

-- ========== АНТИ ГРАБ (ПРОСТОЙ РАБОЧИЙ) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local savedPosition = nil
local returnLoop = nil
local currentHRP = nil

-- СОХРАНЯЕМ ПОЗИЦИЮ
local function saveMyPosition(hrp)
    if hrp then
        savedPosition = hrp.Position
        print("📍 Позиция сохранена:", savedPosition)
    end
end

-- ЗАПУСКАЕМ ВОЗВРАТ
local function startReturn(hrp)
    if returnLoop then return end
    
    saveMyPosition(hrp)
    currentHRP = hrp
    
    returnLoop = RunService.Heartbeat:Connect(function()
        if not antiGrabActive then
            if returnLoop then returnLoop:Disconnect() end
            returnLoop = nil
            return
        end
        
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        local isGrabbed = head and head:FindFirstChild("PartOwner")
        local isHeldNow = isHeld and isHeld.Value
        
        if (isGrabbed or isHeldNow) and currentHRP and currentHRP.Parent then
            -- ВОЗВРАЩАЕМ НА МЕСТО
            currentHRP.Position = savedPosition
            currentHRP.Velocity = Vector3.zero
            currentHRP.RotVelocity = Vector3.zero
        elseif not (isGrabbed or isHeldNow) then
            -- Граб закончился - отключаемся
            if returnLoop then returnLoop:Disconnect() end
            returnLoop = nil
            currentHRP = nil
            print("✅ Граб закончился, возврат отключён")
        end
    end)
end

-- ОТСЛЕЖИВАНИЕ ГРАБА
local function setupAntiGrab()
    local char = LocalPlayer.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not head or not hrp then return end
    
    -- Следим за появлением PartOwner
    local conn
    conn = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive then
            print("⚠️ Граб обнаружен!")
            startReturn(hrp)
            
            -- Отправляем Struggle
            task.spawn(function()
                while antiGrabActive and head and head:FindFirstChild("PartOwner") do
                    if Struggle then
                        pcall(function() Struggle:FireServer(LocalPlayer) end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)
    
    -- Сохраняем для отключения
    if antiGrabConnections then
        antiGrabConnections["PartOwner"] = conn
    end
end

local function onCharacterAdded()
    task.wait(0.5)
    setupAntiGrab()
end

local function setAntiGrab(enabled)
    antiGrabActive = enabled
    
    if enabled then
        setupAntiGrab()
        if not antiGrabConnections then antiGrabConnections = {} end
        if not antiGrabConnections["CharacterAdded"] then
            antiGrabConnections["CharacterAdded"] = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
        end
        print("✅ Анти Граб ВКЛЮЧЁН")
    else
        if antiGrabConnections then
            for _, conn in pairs(antiGrabConnections) do
                pcall(function() conn:Disconnect() end)
            end
            antiGrabConnections = {}
        end
        if returnLoop then
            returnLoop:Disconnect()
            returnLoop = nil
        end
        print("✅ Анти Граб ВЫКЛЮЧЕН")
    end
end

DefenseGroup:AddToggle("AntiGrab", {
    Text = "Анти Граб",
    Default = false,
    Callback = function(Value)
        setAntiGrab(Value)
    end
})
-- ========== КОНЕЦ АНТИ ГРАБ ==========

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

print("✅ Меню загружено | 3 Вид во вкладке Players | Анти Граб во вкладке Defense")
