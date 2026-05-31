-- [[ BROKEN SPAWN MENU - с исправленным Анти Грабом ]]

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

-- ========== АНТИ ГРАБ ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local antiGrabConnections = {}
local isGrabbed = false
local savedPosition = nil
local savedCFrame = nil
local freezeConnection = nil
local originalWalkSpeed = nil

local PACKET_DELAY = 0.08

local function fullFreeze(character, hrp, hum)
    if not hrp or not hum then return end
    if isGrabbed then return end
    
    isGrabbed = true
    savedPosition = hrp.Position
    savedCFrame = hrp.CFrame
    originalWalkSpeed = hum.WalkSpeed
    
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = true
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
            if part.Name ~= "HumanoidRootPart" then
                part.Anchored = true
            end
        end
    end
    
    local bp = hrp:FindFirstChild("AntiGrabBP")
    if bp then bp:Destroy() end
    bp = Instance.new("BodyPosition")
    bp.Name = "AntiGrabBP"
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.D = 2000
    bp.P = 100000
    bp.Position = savedPosition
    bp.Parent = hrp
    
    if freezeConnection then freezeConnection:Disconnect() end
    freezeConnection = RunService.Heartbeat:Connect(function()
        if not antiGrabActive or not isGrabbed then
            if freezeConnection then freezeConnection:Disconnect() end
            freezeConnection = nil
            return
        end
        if hrp and hrp.Parent then
            if (hrp.Position - savedPosition).Magnitude > 0.1 then
                hrp.CFrame = savedCFrame
            end
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if bp then bp.Position = savedPosition end
        end
    end)
end

local function fullUnfreeze(character, hrp, hum)
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
        if savedCFrame then hrp.CFrame = savedCFrame end
    end
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Anchored = false
                part.Velocity = Vector3.zero
                part.RotVelocity = Vector3.zero
            end
        end
    end
    if hum then
        hum.WalkSpeed = originalWalkSpeed or 16
        hum.JumpPower = 50
        hum.PlatformStand = false
    end
end

local function struggleLoop(head, hrp, character, hum)
    if not antiGrabActive then return end
    local lastPacketTime = 0
    while antiGrabActive and isGrabbed and head and head:FindFirstChild("PartOwner") do
        if tick() - lastPacketTime >= PACKET_DELAY then
            lastPacketTime = tick()
            if Struggle then pcall(function() Struggle:FireServer(LocalPlayer) end) end
        end
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
        task.wait(0.1)
    end
    fullUnfreeze(character, hrp, hum)
end

local function setupAntiGrab(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not head or not hrp or not hum then return end
    
    if antiGrabConnections["PartOwner"] then
        antiGrabConnections["PartOwner"]:Disconnect()
        antiGrabConnections["PartOwner"] = nil
    end
    if antiGrabConnections["IsHeld"] then
        antiGrabConnections["IsHeld"]:Disconnect()
        antiGrabConnections["IsHeld"] = nil
    end
    
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive and not isGrabbed then
            fullFreeze(character, hrp, hum)
            task.spawn(struggleLoop, head, hrp, character, hum)
        end
    end)
    
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive and not isGrabbed then
                fullFreeze(character, hrp, hum)
                task.spawn(struggleLoop, head, hrp, character, hum)
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
        for _, conn in pairs(antiGrabConnections) do
            pcall(function() conn:Disconnect() end)
        end
        antiGrabConnections = {}
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            fullUnfreeze(char, hrp, hum)
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

print("✅ Меню загружено | Анти Граб (пакеты 0.8 сек) во вкладке Defense")
