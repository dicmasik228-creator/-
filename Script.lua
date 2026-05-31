-- [[ BROKEN SPAWN MENU - с Анти Граб (заморозка на месте, без падения) ]]

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

-- Пустые группы
local function addEmptyGroup(tab, name)
    local group = tab:AddLeftGroupbox(name)
    group:AddLabel(" ")
end

addEmptyGroup(Tabs.Players, "Players")
addEmptyGroup(Tabs.Target, "Target")
addEmptyGroup(Tabs.TargetBlob, "Target Blob")
addEmptyGroup(Tabs.Smile, "Smile")

-- ========== АНТИ ГРАБ (ЗАМОРОЗКА НА МЕСТЕ) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local antiGrabConnections = {}
local PACKET_DELAY = 0.1
local freezeConnection = nil
local savedCFrame = nil

local function freezeCharacter(hrp)
    if not hrp then return end
    savedCFrame = hrp.CFrame
    hrp.Anchored = true
    
    local bp = hrp:FindFirstChild("AntiGrabBP")
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "AntiGrabBP"
        bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bp.D = 500
        bp.P = 20000
        bp.Parent = hrp
    end
    bp.Position = savedCFrame.Position
    
    if freezeConnection then freezeConnection:Disconnect() end
    freezeConnection = RunService.Heartbeat:Connect(function()
        if antiGrabActive and hrp and hrp.Parent then
            hrp.CFrame = savedCFrame
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            if bp then bp.Position = savedCFrame.Position end
        else
            if freezeConnection then freezeConnection:Disconnect() end
            freezeConnection = nil
        end
    end)
end

local function unfreezeCharacter(hrp)
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    if hrp then
        hrp.Anchored = false
        local bp = hrp:FindFirstChild("AntiGrabBP")
        if bp then bp:Destroy() end
    end
end

local function setupAntiGrab(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    if antiGrabConnections["PartOwner"] then
        antiGrabConnections["PartOwner"]:Disconnect()
        antiGrabConnections["PartOwner"] = nil
    end
    if antiGrabConnections["IsHeld"] then
        antiGrabConnections["IsHeld"]:Disconnect()
        antiGrabConnections["IsHeld"] = nil
    end
    
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive then
            freezeCharacter(hrp)
            task.spawn(function()
                local lastPacketTime = 0
                while antiGrabActive and head:FindFirstChild("PartOwner") do
                    if tick() - lastPacketTime >= PACKET_DELAY then
                        lastPacketTime = tick()
                        if Struggle then
                            pcall(function() Struggle:FireServer(LocalPlayer) end)
                        end
                    end
                    task.wait(0.1)
                end
                unfreezeCharacter(hrp)
            end)
        end
    end)
    
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive then
                freezeCharacter(hrp)
                task.spawn(function()
                    local lastPacketTime = 0
                    while antiGrabActive and isHeld and isHeld.Value do
                        if tick() - lastPacketTime >= PACKET_DELAY then
                            lastPacketTime = tick()
                            if Struggle then
                                pcall(function() Struggle:FireServer(LocalPlayer) end)
                            end
                        end
                        task.wait(0.1)
                    end
                    unfreezeCharacter(hrp)
                end)
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
            unfreezeCharacter(hrp)
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

print("✅ Меню загружено | Анти Граб во вкладке Defense (заморозка на месте)")
