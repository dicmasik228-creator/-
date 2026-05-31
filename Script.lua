-- [[ BROKEN SPAWN MENU - с Анти Кик (Ресет) и Анти Грабом ]]

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

-- ========== АНТИ КИК (РЕСЕТ) ==========
local function setupAntiKickReset()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local GameNotify = ReplicatedStorage:FindFirstChild("GameCorrectionEvents") and ReplicatedStorage.GameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")
    
    if not GameNotify then return end
    
    GameNotify.OnClientEvent:Connect(function(message)
        if not antiKickResetActive then return end
        
        local kickMessages = {
            "вы летите невозможным образом",
            "вы были кикнуты",
            "flying",
            "exploiting",
            "anticheat",
            "kick",
            "летаете",
            "невозможным образом",
            "вылет",
            "кикнут"
        }
        
        local msgLower = string.lower(tostring(message))
        for _, kickMsg in ipairs(kickMessages) do
            if string.find(msgLower, kickMsg) then
                -- Ресет персонажа
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        hum.Health = 0
                        print("✅ Анти Кик: Ресет выполнен")
                    end
                end
                break
            end
        end
    end)
end

local antiKickResetActive = false

-- ========== АНТИ ГРАБ (МАКСИМАЛЬНО БЫСТРЫЙ ВОЗВРАТ) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local savedCFrame = nil
local savedPosition = nil
local returnConnection = nil
local savedHRP = nil
local savedCharacter = nil
local lastPacketTime = 0
local isCurrentlyGrabbed = false
local returnTask = nil

local PACKET_DELAY = 0.08

-- СОХРАНЕНИЕ ПОЗИЦИИ
local function saveMyPost(hrp)
    if not hrp then return end
    savedCFrame = hrp.CFrame
    savedPosition = hrp.Position
end

-- МАКСИМАЛЬНО БЫСТРЫЙ ВОЗВРАТ
local function startReturn(character, hrp)
    if not hrp then return end
    
    savedHRP = hrp
    savedCharacter = character
    
    if returnTask then return end
    
    if returnConnection then
        returnConnection:Disconnect()
        returnConnection = nil
    end
    
    returnConnection = RunService.Heartbeat:Connect(function()
        if not antiGrabActive then
            stopReturn()
            return
        end
        
        local head = savedCharacter and savedCharacter:FindFirstChild("Head")
        local hum = savedCharacter and savedCharacter:FindFirstChild("Humanoid")
        local isRagdolled = hum and hum:FindFirstChild("Ragdolled") and hum.Ragdolled.Value
        local isGrabbed = head and head:FindFirstChild("PartOwner")
        local isHeldNow = isHeld and isHeld.Value
        
        if isGrabbed or isRagdolled or isHeldNow then
            isCurrentlyGrabbed = true
            if savedHRP and savedHRP.Parent and savedCFrame then
                savedHRP.CFrame = savedCFrame
                savedHRP.Velocity = Vector3.zero
                savedHRP.RotVelocity = Vector3.zero
                savedHRP.AssemblyLinearVelocity = Vector3.zero
                savedHRP.AssemblyAngularVelocity = Vector3.zero
                
                for _, part in pairs(savedCharacter:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= savedHRP then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        else
            if isCurrentlyGrabbed then
                isCurrentlyGrabbed = false
            end
            stopReturn()
        end
    end)
    
    if returnTask then task.cancel(returnTask) end
    returnTask = task.spawn(function()
        while returnConnection and antiGrabActive do
            if savedHRP and savedHRP.Parent and savedCFrame then
                savedHRP.CFrame = savedCFrame
                savedHRP.Velocity = Vector3.zero
                savedHRP.AssemblyLinearVelocity = Vector3.zero
                savedHRP.AssemblyAngularVelocity = Vector3.zero
            end
            task.wait(0.001)
        end
    end)
end

local function stopReturn()
    if returnConnection then
        returnConnection:Disconnect()
        returnConnection = nil
    end
    if returnTask then
        task.cancel(returnTask)
        returnTask = nil
    end
    savedHRP = nil
    savedCharacter = nil
end

local function struggleLoop(head, hrp, character)
    if not antiGrabActive then return end
    
    lastPacketTime = 0
    
    while antiGrabActive and head and head:FindFirstChild("PartOwner") do
        if tick() - lastPacketTime >= PACKET_DELAY then
            lastPacketTime = tick()
            if Struggle then
                pcall(function() Struggle:FireServer(LocalPlayer) end)
            end
        end
        
        if hrp and hrp.Parent and savedCFrame then
            hrp.CFrame = savedCFrame
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
        
        task.wait(0.001)
    end
end

local function setupAntiGrab(character)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    
    if not head or not hrp then return end
    
    if antiGrabConnections then
        if antiGrabConnections["PartOwner"] then
            antiGrabConnections["PartOwner"]:Disconnect()
        end
        if antiGrabConnections["IsHeld"] then
            antiGrabConnections["IsHeld"]:Disconnect()
        end
        if antiGrabConnections["Ragdolled"] and hum then
            pcall(function() antiGrabConnections["Ragdolled"]:Disconnect() end)
        end
    end
    
    antiGrabConnections = antiGrabConnections or {}
    
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive then
            saveMyPost(hrp)
            startReturn(character, hrp)
            task.spawn(struggleLoop, head, hrp, character)
        end
    end)
    
    if hum then
        local ragdolled = hum:FindFirstChild("Ragdolled")
        if ragdolled then
            antiGrabConnections["Ragdolled"] = ragdolled.Changed:Connect(function()
                if ragdolled.Value and antiGrabActive then
                    saveMyPost(hrp)
                    startReturn(character, hrp)
                end
            end)
        end
    end
    
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive then
                saveMyPost(hrp)
                startReturn(character, hrp)
                task.spawn(struggleLoop, head, hrp, character)
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

-- ========== КНОПКИ В ЗАЩИТУ ==========
DefenseGroup:AddToggle("AntiGrab", {
    Text = "Анти Граб",
    Default = false,
    Callback = function(Value)
        setAntiGrab(Value)
    end
})

DefenseGroup:AddToggle("AntiKickReset", {
    Text = "Анти Кик (Ресет)",
    Default = false,
    Callback = function(Value)
        antiKickResetActive = Value
        if Value then
            setupAntiKickReset()
            print("✅ Анти Кик (Ресет) ВКЛЮЧЁН")
        else
            print("✅ Анти Кик (Ресет) ВЫКЛЮЧЕН")
        end
    end
})
-- ========== КОНЕЦ ЗАЩИТЫ ==========

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

print("✅ Меню загружено | 3 Вид во вкладке Players | Защита во вкладке Defense")
