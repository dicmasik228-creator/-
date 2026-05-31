-- [[ BROKEN SPAWN MENU - Анти Граб (простой и рабочий) ]]

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
local savedCFrame = nil
local returnTask = nil
local currentHead = nil
local currentHRP = nil

local PACKET_DELAY = 0.08

-- СОХРАНЕНИЕ ПОЗИЦИИ
local function savePosition(hrp)
    if hrp and hrp.Parent then
        savedCFrame = hrp.CFrame
        print("✅ Позиция сохранена")
    end
end

-- ГЛАВНЫЙ ЦИКЛ ВОЗВРАТА
local function startReturn(hrp, head)
    if returnTask then return end
    
    savePosition(hrp)
    
    returnTask = task.spawn(function()
        print("🔄 Возврат запущен")
        while returnTask and antiGrabActive and hrp and hrp.Parent do
            -- Проверяем: всё ещё в грабе?
            local isGrabbed = head and head:FindFirstChild("PartOwner")
            local isHeldNow = isHeld and isHeld.Value
            
            if isGrabbed or isHeldNow then
                -- ВОЗВРАЩАЕМ НА МЕСТО
                if savedCFrame then
                    hrp.CFrame = savedCFrame
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                end
                task.wait(0.001) -- каждую миллисекунду
            else
                -- Граб закончился - выходим
                print("✅ Граб закончился, возврат остановлен")
                break
            end
        end
        returnTask = nil
    end)
end

local function stopReturn()
    if returnTask then
        task.cancel(returnTask)
        returnTask = nil
    end
end

-- БОРЬБА С ГРАБОМ
local function struggleLoop(head, hrp)
    if not antiGrabActive then return end
    
    local lastTime = 0
    
    while antiGrabActive and head and head:FindFirstChild("PartOwner") do
        if tick() - lastTime >= PACKET_DELAY then
            lastTime = tick()
            if Struggle then
                pcall(function() Struggle:FireServer(LocalPlayer) end)
            end
        end
        task.wait(0.05)
    end
end

-- ОТСЛЕЖИВАНИЕ ГРАБА
local function setupAntiGrab(character)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not head or not hrp then return end
    
    currentHead = head
    currentHRP = hrp
    
    if antiGrabConnections then
        if antiGrabConnections["PartOwner"] then
            antiGrabConnections["PartOwner"]:Disconnect()
        end
        if antiGrabConnections["IsHeld"] then
            antiGrabConnections["IsHeld"]:Disconnect()
        end
    end
    
    antiGrabConnections = antiGrabConnections or {}
    
    -- При захвате
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive then
            startReturn(hrp, head)
            task.spawn(struggleLoop, head, hrp)
        end
    end)
    
    -- Через IsHeld
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive then
                startReturn(hrp, head)
                task.spawn(struggleLoop, head, hrp)
            end
        end)
    end
end

local function onCharacterAdded(character)
    task.wait(0.3)
    setupAntiGrab(character)
end

local function setAntiGrab(enabled)
    antiGrabActive = enabled
    
    if enabled then
        local char = LocalPlayer.Character
        if char then setupAntiGrab(char) end
        if not antiGrabConnections["CharacterAdded"] then
            antiGrabConnections["CharacterAdded"] = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
        end
        print("✅ Анти Граб ВКЛЮЧЁН")
    else
        if antiGrabConnections then
            for _, conn in pairs(antiGrabConnections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        antiGrabConnections = {}
        stopReturn()
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
