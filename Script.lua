-- [[ BROKEN SPAWN MENU - с Анти Грабом (обновление при повторном грабе) ]]

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

-- ========== АНТИ ГРАБ (ОБНОВЛЕНИЕ ПРИ ПОВТОРНОМ ГРАБЕ) ==========
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local antiGrabActive = false
local isGrabbed = false
local savedPosition = nil
local savedCFrame = nil
local freezeConnection = nil
local originalWalkSpeed = nil
local originalJumpPower = nil
local lastPacketTime = 0
local unfreezeTask = nil
local currentStruggleLoop = nil

local PACKET_DELAY = 0.08
local UNFREEZE_DELAY = 1

-- ОСТАНОВКА ВСЕХ ПРОЦЕССОВ
local function stopAllProcesses()
    -- Отменяем отложенную разморозку
    if unfreezeTask then
        task.cancel(unfreezeTask)
        unfreezeTask = nil
    end
    
    -- Отключаем freezeConnection
    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end
    
    -- Останавливаем текущий struggleLoop
    if currentStruggleLoop then
        currentStruggleLoop = false
    end
end

-- ЗАМОРОЗКА (СБРАСЫВАЕМ СТАРОЕ И НАЧИНАЕМ НОВОЕ)
local function freezeCharacter(character, hrp, hum)
    if not hrp or not hum then return end
    
    -- ОСТАНАВЛИВАЕМ ВСЕ ПРЕДЫДУЩИЕ ПРОЦЕССЫ
    stopAllProcesses()
    
    isGrabbed = true
    savedPosition = hrp.Position
    savedCFrame = hrp.CFrame
    originalWalkSpeed = hum.WalkSpeed
    originalJumpPower = hum.JumpPower
    
    -- Мгновенная остановка
    hrp.Anchored = true
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.zero
            part.RotVelocity = Vector3.zero
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
            part.Anchored = true
        end
    end
    
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = true
    hum.AutoRotate = false
    hum.Sit = false
    
    -- Чистим старые BodyPosition/BodyGyro
    local bp = hrp:FindFirstChild("AntiGrabBP")
    if bp then bp:Destroy() end
    bp = Instance.new("BodyPosition")
    bp.Name = "AntiGrabBP"
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.D = 10000
    bp.P = 500000
    bp.Position = savedPosition
    bp.Parent = hrp
    
    local bg = hrp:FindFirstChild("AntiGrabBG")
    if bg then bg:Destroy() end
    bg = Instance.new("BodyGyro")
    bg.Name = "AntiGrabBG"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 500000
    bg.CFrame = savedCFrame
    bg.Parent = hrp
    
    -- НОВЫЙ freezeConnection (постоянный контроль)
    freezeConnection = RunService.Heartbeat:Connect(function()
        if not antiGrabActive or not isGrabbed then
            if freezeConnection then freezeConnection:Disconnect() end
            freezeConnection = nil
            return
        end
        
        if hrp and hrp.Parent and hum and hum.Parent then
            -- Мгновенный возврат при смещении
            if (hrp.Position - savedPosition).Magnitude > 0.001 then
                hrp.CFrame = savedCFrame
            end
            
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.zero
                    part.RotVelocity = Vector3.zero
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            
            if bp then bp.Position = savedPosition end
            if bg then bg.CFrame = savedCFrame end
            
            if hum.Sit then hum.Sit = false end
            hum.PlatformStand = true
        end
    end)
end

-- РАЗМОРОЗКА (С ЗАДЕРЖКОЙ)
local function unfreezeCharacter(character, hrp, hum)
    -- Отменяем предыдущую отложенную разморозку
    if unfreezeTask then
        task.cancel(unfreezeTask)
        unfreezeTask = nil
    end
    
    -- Откладываем разморозку
    unfreezeTask = task.delay(UNFREEZE_DELAY, function()
        if not isGrabbed then
            -- Только если за это время не схватили снова
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
            
            if hrp then
                hrp.Anchored = false
                local bp = hrp:FindFirstChild("AntiGrabBP")
                if bp then bp:Destroy() end
                local bg = hrp:FindFirstChild("AntiGrabBG")
                if bg then bg:Destroy() end
                
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                
                if savedCFrame then
                    hrp.CFrame = savedCFrame
                end
            end
            
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
            
            if hum then
                hum.WalkSpeed = originalWalkSpeed or 16
                hum.JumpPower = originalJumpPower or 50
                hum.PlatformStand = false
                hum.AutoRotate = true
                hum.Sit = false
            end
            
            isGrabbed = false
            unfreezeTask = nil
        end
    end)
end

-- БОРЬБА С ГРАБОМ (ОБНОВЛЯЕМАЯ)
local function struggleLoop(head, hrp, character, hum)
    if not antiGrabActive then return end
    
    -- Сохраняем текущий поток
    currentStruggleLoop = true
    lastPacketTime = 0
    
    while antiGrabActive and isGrabbed and head and head:FindFirstChild("PartOwner") and currentStruggleLoop do
        if tick() - lastPacketTime >= PACKET_DELAY then
            lastPacketTime = tick()
            if Struggle then
                pcall(function() Struggle:FireServer(LocalPlayer) end)
            end
        end
        
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if (hrp.Position - savedPosition).Magnitude > 0.001 then
                hrp.CFrame = savedCFrame
            end
        end
        
        task.wait(0.005)
    end
    
    currentStruggleLoop = nil
    
    -- Запускаем разморозку, только если всё ещё не схватили
    if antiGrabActive and not (head and head:FindFirstChild("PartOwner")) then
        unfreezeCharacter(character, hrp, hum)
    end
end

-- ОТСЛЕЖИВАНИЕ ГРАБА
local function setupAntiGrab(character)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    
    if not head or not hrp or not hum then return end
    
    if antiGrabConnections then
        if antiGrabConnections["PartOwner"] then
            antiGrabConnections["PartOwner"]:Disconnect()
        end
        if antiGrabConnections["IsHeld"] then
            antiGrabConnections["IsHeld"]:Disconnect()
        end
    end
    
    antiGrabConnections = antiGrabConnections or {}
    
    antiGrabConnections["PartOwner"] = head.ChildAdded:Connect(function(child)
        if child.Name == "PartOwner" and antiGrabActive then
            freezeCharacter(character, hrp, hum)
            task.spawn(struggleLoop, head, hrp, character, hum)
        end
    end)
    
    if isHeld then
        antiGrabConnections["IsHeld"] = isHeld.Changed:Connect(function(held)
            if held and antiGrabActive then
                freezeCharacter(character, hrp, hum)
                task.spawn(struggleLoop, head, hrp, character, hum)
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
        print("✅ Анти Граб ВКЛЮЧЁН (обновление при повторном грабе)")
    else
        if antiGrabConnections then
            for _, conn in pairs(antiGrabConnections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        antiGrabConnections = {}
        
        -- Останавливаем все процессы
        stopAllProcesses()
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            isGrabbed = false
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
            if hrp then
                hrp.Anchored = false
                local bp = hrp:FindFirstChild("AntiGrabBP")
                if bp then bp:Destroy() end
                local bg = hrp:FindFirstChild("AntiGrabBG")
                if bg then bg:Destroy() end
            end
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
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

print("✅ Меню загружено | 3 Вид во вкладке Players | Анти Граб во вкладке Defense (с обновлением)")
