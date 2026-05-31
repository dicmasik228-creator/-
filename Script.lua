-- [[ BROKEN SPAWN MENU - с Анти Граб (фикс лагов и полёта) ]]

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

addEmptyGroup(Tabs.Players, "Players")
addEmptyGroup(Tabs.Target, "Target")
addEmptyGroup(Tabs.TargetBlob, "Target Blob")
addEmptyGroup(Tabs.Smile, "Smile")

-- ========== АНТИ ГРАБ (БЕЗ ЛАГОВ, БЕЗ ПОЛЁТА) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local antiGrabConnections = {}
local freezeConnection = nil
local savedCFrame = nil
local isGrabbed = false

local PACKET_DELAY = 0.1 -- уменьшил частоту пакетов для телефона

local function freezeCharacter(character, hrp, hum)
    if not hrp then return end
    if isGrabbed then return end  -- уже заморожен
    
    isGrabbed = true
    savedCFrame = hrp.CFrame
    
    -- Полная остановка
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    
    -- Останавливаем все части тела
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
        end
    end
    
    -- Фиксация позиции (один раз, без постоянного обновления)
    local bp = hrp:FindFirstChild("AntiGrabBP")
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "AntiGrabBP"
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.D = 2000
        bp.P = 100000
        bp.Parent = hrp
    end
    bp.Position = savedCFrame.Position
    
    -- Блокируем скорость (раз в 0.2 сек, не каждый кадр)
    if freezeConnection then freezeConnection:Disconnect() end
    freezeConnection = RunService.Heartbeat:Connect(function()
        if antiGrabActive and isGrabbed and hrp and hrp.Parent then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if bp then bp.Position = savedCFrame.Position end
        else
            if freezeConnection then freezeConnection:Disconnect() end
            freezeConnection = nil
        end
    end)
end

local function unfreezeCharacter(character, hrp)
    isGrabbed = false
    
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    
    if hrp then
        hrp.Anchored = false
        local bp = hrp:FindFirstChild("AntiGrabBP")
        if bp then bp:Destroy() end
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
end

local function struggleLoop(head, hrp, character)
    if not antiGrabActive then return end
    
    local lastPacketTime = 0
    local struggleCount = 0
    
    while antiGrabActive and isGrabbed and head:FindFirstChild("PartOwner") do
        -- Отправляем Struggle редко (раз в 0.15 сек)
        if tick() - lastPacketTime >= PACKET_DELAY then
            lastPacketTime = tick()
            if Struggle then
                pcall(function() Struggle:FireServer(LocalPlayer) end)
            end
            struggleCount = struggleCount + 1
            if struggleCount > 20 then  -- макс 3 секунды, потом отпускаем
                break
            end
        end
        task.wait(0.1)  -- проверяем реже
    end
    
    -- Отпускаем
    unfreezeCharacter(character, hrp)
end

local function setupAntiGrab(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    -- Удаляем старые соединения
    if antiGrabConnections["PartOwner"] then
        antiGrabConnections["PartOwner"]:Disconnect()
        antiGrabConnections["PartOwner"] = nil
    end
    if antiGrabConnections["IsHeld"] then
        antiGrabConnections["IsHeld"]:Disconnect()
        antiGrabConnections["IsHeld"] = nil
    end
    
    -- Отслеживаем захват
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive and not isGrabbed then
            freezeCharacter(character, hrp)
            task.spawn(struggleLoop, head, hrp, character)
        end
    end)
    
    -- Альтернативный способ
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive and not isGrabbed then
                freezeCharacter(character, hrp)
                task.spawn(struggleLoop, head, hrp, character)
            end
        end)
    end
end

local function onCharacterAdded(character)
    task.wait(0.5)
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
    else
        -- Отключаем всё
        for _, conn in pairs(antiGrabConnections) do
            pcall(function() conn:Disconnect() end)
        end
        antiGrabConnections = {}
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            unfreezeCharacter(char, hrp)
        end
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

print("✅ Меню загружено | Анти Граб во вкладке Defense (без лагов)")
