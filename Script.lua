local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "BROKEN SPAWN",
    Footer = "делаем",
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

local PlayersGroup = Tabs.Players:AddLeftGroupbox("Настройки игрока")

local thirdPersonActive = false
local function enableThirdPerson()
    local player = game.Players.LocalPlayer
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMaxZoomDistance = 100
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

local speedActive = false
local currentSpeedValue = 30
local speedConnection = nil
local speedSteppedConnection = nil
local speedSlider = PlayersGroup:AddSlider("SpeedValue", {
    Text = "Сила ускорения",
    Default = 30,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value) currentSpeedValue = Value end
})
local function applySpeed()
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
end
local function startSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
    if speedSteppedConnection then speedSteppedConnection:Disconnect() end
    speedConnection = game:GetService("RunService").Stepped:Connect(applySpeed)
    speedSteppedConnection = game:GetService("RunService").Stepped:Connect(function()
        if not speedActive then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y, hrp.Velocity.Z) end
            end
        end
    end)
end
local function stopSpeedBoost()
    if speedConnection then speedConnection:Disconnect() end
    if speedSteppedConnection then speedSteppedConnection:Disconnect() end
    local char = game.Players.LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.zero end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end
PlayersGroup:AddToggle("SpeedToggle", {
    Text = "Ускорение",
    Default = false,
    Callback = function(Value)
        speedActive = Value
        if Value then startSpeedBoost() else stopSpeedBoost() end
    end
})

local jumpActive = false
local jumpPowerValue = 50
local jumpSlider = PlayersGroup:AddSlider("JumpPower", {
    Text = "Сила прыжка",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        jumpPowerValue = Value
        if jumpActive then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = jumpPowerValue
            end
        end
    end
})
local function applyJumpPower()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpPowerValue
    end
end
local function resetJumpPower()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 50
    end
end
PlayersGroup:AddToggle("JumpToggle", {
    Text = "Увеличенный прыжок",
    Default = false,
    Callback = function(Value)
        jumpActive = Value
        if Value then applyJumpPower() else resetJumpPower() end
    end
})

local infiniteJumpActive = false
local infiniteJumpConnection = nil
local function startInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
    infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if infiniteJumpActive then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end
local function stopInfiniteJump()
    if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
end
PlayersGroup:AddToggle("InfiniteJump", {
    Text = "Бесконечный прыжок",
    Default = false,
    Callback = function(Value)
        infiniteJumpActive = Value
        if Value then startInfiniteJump() else stopInfiniteJump() end
    end
})

local noclipActive = false
local noclipConnection = nil
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if noclipActive then
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end
local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    local char = game.Players.LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end
PlayersGroup:AddToggle("Noclip", {
    Text = "Ноклип",
    Default = false,
    Callback = function(Value)
        noclipActive = Value
        if Value then startNoclip() else stopNoclip() end
    end
})

local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Защита")

local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Struggle = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("Struggle")
local isHeld = LocalPlayer:FindFirstChild("IsHeld")

local autoStruggleConn = nil
local antiGrabHeldConn, antiGrabStruggleConn, antiGrabHumConn
local antiGrabRootCF, antiGrabRootPos, antiGrabHardFreeze = nil, nil, false
local antiGrabAnchorConn = nil

local function antiGrabUnfreeze(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        if hrp:FindFirstChild("FreezeJoint") then
            hrp.FreezeJoint:Destroy()
        end
    end
    antiGrabHardFreeze = false
    if antiGrabAnchorConn then
        antiGrabAnchorConn:Disconnect()
        antiGrabAnchorConn = nil
    end
end

local function antiGrabFreezeInPlace(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    antiGrabRootCF = hrp.CFrame
    antiGrabRootPos = hrp.Position
    antiGrabHardFreeze = true
    if not hrp:FindFirstChild("FreezeJoint") then
        local align = Instance.new("AlignPosition")
        align.Name = "FreezeJoint"
        align.Mode = Enum.PositionAlignmentMode.OneAttachment
        align.MaxForce = 1e6
        align.MaxVelocity = 0
        align.Responsiveness = 200
        local att = Instance.new("Attachment", hrp)
        align.Attachment0 = att
        align.Position = antiGrabRootPos
        align.Parent = hrp
    end
    antiGrabAnchorConn = RunService.Heartbeat:Connect(function()
        if antiGrabHardFreeze and hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = antiGrabRootCF
        end
    end)
end

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
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            if antiGrabHumConn then antiGrabHumConn:Disconnect() end
            antiGrabHumConn = hum.Changed:Connect(function(p)
                if p == "Sit" and hum.Sit then
                    if not (hum.SeatPart and tostring(hum.SeatPart.Parent) == "CreatureBlobman") then
                        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        hum.Sit = false
                    end
                end
            end)
            antiGrabHeldConn = LocalPlayer:FindFirstChild("IsHeld").Changed:Connect(function(heldState)
                if heldState then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("PartOwner") then
                        task.spawn(function()
                            if Struggle then Struggle:FireServer(LocalPlayer) end
                        end)
                    end
                end
            end)
            antiGrabStruggleConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char.Head and char.Head:FindFirstChild("PartOwner") then
                    if Struggle then Struggle:FireServer(LocalPlayer) end
                end
            end)
        else
            if autoStruggleConn then autoStruggleConn:Disconnect() end
            if antiGrabHeldConn then antiGrabHeldConn:Disconnect() end
            if antiGrabStruggleConn then antiGrabStruggleConn:Disconnect() end
            if antiGrabHumConn then antiGrabHumConn:Disconnect() end
            autoStruggleConn = nil
            antiGrabHeldConn = nil
            antiGrabStruggleConn = nil
            antiGrabHumConn = nil
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
            antiGrabUnfreeze(char)
        end
    end
})

local antiFireActive = false
local antiFireConnection = nil
local antiFireCharConn = nil

local function startAntiFire()
    if antiFireConnection then antiFireConnection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    char.PrimaryPart = hrp
    antiFireConnection = hum.FireDebounce.Changed:Connect(function(isBurning)
        if isBurning and antiFireActive then
            task.spawn(function()
                local me = char
                local oldCF = hrp.CFrame
                local camera = workspace.CurrentCamera
                local oldCameraCF = camera.CFrame
                local oldCameraSubject = camera.CameraSubject
                local plots = workspace:FindFirstChild("Plots")
                if plots and plots:FindFirstChild("Plot2") then
                    local plot2 = plots.Plot2
                    local barrier = plot2:FindFirstChild("Barrier")
                    local pb = barrier and barrier:FindFirstChild("PlotBarrier")
                    if pb and pb:IsA("BasePart") then
                        local safeCF = pb.CFrame
                        me:SetPrimaryPartCFrame(safeCF)
                        task.wait(0.00001)
                        local firePart = me:FindFirstChild("FirePlayerPart", true)
                        if firePart then
                            for _, obj in ipairs(firePart:GetChildren()) do
                                if obj:IsA("Sound") then obj:Stop() end
                                if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                                    obj.Enabled = false
                                end
                            end
                            if firePart:FindFirstChild("CanBurn") then
                                firePart.CanBurn.Value = false
                            end
                            if hum:FindFirstChild("FireDebounce") then
                                hum.FireDebounce.Value = false
                            end
                        end
                        task.wait(0.00001)
                        if me and me.PrimaryPart and antiFireActive then
                            me:SetPrimaryPartCFrame(oldCF)
                        end
                        camera.CameraSubject = oldCameraSubject
                        camera.CFrame = oldCameraCF
                    end
                end
            end)
        end
    end)
end

local function stopAntiFire()
    if antiFireConnection then
        antiFireConnection:Disconnect()
        antiFireConnection = nil
    end
end

DefenseGroup:AddToggle("AntiFire", {
    Text = "Анти Огонь",
    Default = false,
    Callback = function(Value)
        antiFireActive = Value
        if Value then
            startAntiFire()
            if antiFireCharConn then antiFireCharConn:Disconnect() end
            antiFireCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                task.wait(0.00001)
                if antiFireActive then
                    if antiFireConnection then antiFireConnection:Disconnect() end
                    local hum = newChar:WaitForChild("Humanoid")
                    local hrp = newChar:WaitForChild("HumanoidRootPart")
                    newChar.PrimaryPart = hrp
                    antiFireConnection = hum.FireDebounce.Changed:Connect(function(isBurning)
                        if isBurning and antiFireActive then
                            task.spawn(function()
                                local me = newChar
                                local oldCF = hrp.CFrame
                                local camera = workspace.CurrentCamera
                                local oldCameraCF = camera.CFrame
                                local oldCameraSubject = camera.CameraSubject
                                local plots = workspace:FindFirstChild("Plots")
                                if plots and plots:FindFirstChild("Plot2") then
                                    local plot2 = plots.Plot2
                                    local barrier = plot2:FindFirstChild("Barrier")
                                    local pb = barrier and barrier:FindFirstChild("PlotBarrier")
                                    if pb and pb:IsA("BasePart") then
                                        local safeCF = pb.CFrame
                                        me:SetPrimaryPartCFrame(safeCF)
                                        task.wait(0.00001)
                                        local firePart = me:FindFirstChild("FirePlayerPart", true)
                                        if firePart then
                                            for _, obj in ipairs(firePart:GetChildren()) do
                                                if obj:IsA("Sound") then obj:Stop() end
                                                if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                                                    obj.Enabled = false
                                                end
                                            end
                                            if firePart:FindFirstChild("CanBurn") then
                                                firePart.CanBurn.Value = false
                                            end
                                            if hum:FindFirstChild("FireDebounce") then
                                                hum.FireDebounce.Value = false
                                            end
                                        end
                                        task.wait(0.00001)
                                        if me and me.PrimaryPart and antiFireActive then
                                            me:SetPrimaryPartCFrame(oldCF)
                                        end
                                        camera.CameraSubject = oldCameraSubject
                                        camera.CFrame = oldCameraCF
                                    end
                                end
                            end)
                        end
                    end)
                end
            end)
        else
            stopAntiFire()
            if antiFireCharConn then
                antiFireCharConn:Disconnect()
                antiFireCharConn = nil
            end
        end
    end
})

local antiExplosionActive = false
local antiExplosionConnection = nil
local antiExplosionCharConn = nil

local function startAntiExplosion()
    if antiExplosionConnection then antiExplosionConnection:Disconnect() end
    local function onExplosion(model)
        if not antiExplosionActive then return end
        if model.Name ~= "Part" then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local mag = (model.Position - hrp.Position).Magnitude
        if mag <= 25 then
            hrp.Anchored = true
            for _, limb in pairs({"Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
                local part = char:FindFirstChild(limb)
                if part and part:FindFirstChild("RagdollLimbPart") then
                    part.RagdollLimbPart.CanCollide = false
                end
            end
            task.wait(0.05)
            for _, limb in pairs({"Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
                local part = char:FindFirstChild(limb)
                if part and part:FindFirstChild("RagdollLimbPart") then
                    part.RagdollLimbPart.CanCollide = true
                end
            end
            hrp.Anchored = false
        end
    end
    antiExplosionConnection = workspace.ChildAdded:Connect(onExplosion)
end

local function stopAntiExplosion()
    if antiExplosionConnection then
        antiExplosionConnection:Disconnect()
        antiExplosionConnection = nil
    end
end

DefenseGroup:AddToggle("AntiExplosion", {
    Text = "Анти Взрывы",
    Default = false,
    Callback = function(Value)
        antiExplosionActive = Value
        if Value then
            startAntiExplosion()
            if antiExplosionCharConn then antiExplosionCharConn:Disconnect() end
            antiExplosionCharConn = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                if antiExplosionActive then
                    startAntiExplosion()
                end
            end)
        else
            stopAntiExplosion()
            if antiExplosionCharConn then
                antiExplosionCharConn:Disconnect()
                antiExplosionCharConn = nil
            end
        end
    end
})

local antiVoidActive = false
local antiVoidConnection = nil

local function startAntiVoid()
    if antiVoidConnection then antiVoidConnection:Disconnect() end
    game.Workspace.FallenPartsDestroyHeight = -9e99
    antiVoidConnection = RunService.Heartbeat:Connect(function()
        if not antiVoidActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if torso then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {char}
            local rayResult = workspace:Raycast(torso.Position, Vector3.new(0, -2, 0), raycastParams)
            if rayResult and rayResult.Instance and (rayResult.Instance.Name:lower():find("water") or rayResult.Instance.Name:lower():find("ocean")) then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end
        if hrp.Position.Y < -100 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
        end
    end)
end

local function stopAntiVoid()
    if antiVoidConnection then
        antiVoidConnection:Disconnect()
        antiVoidConnection = nil
    end
    game.Workspace.FallenPartsDestroyHeight = -50
end

local AntiVoidGroup = Tabs.Defense:AddRightGroupbox("Анти Войд")
AntiVoidGroup:AddToggle("AntiVoid", {
    Text = "Режим воды",
    Default = false,
    Callback = function(Value)
        antiVoidActive = Value
        if Value then
            startAntiVoid()
        else
            stopAntiVoid()
        end
    end
})

local antiLagActive = false
local antiLagConnection = nil

local function setupAntiLag()
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        local beamScript = playerScripts:FindFirstChild("CharacterAndBeamMove")
        if beamScript then
            beamScript.Disabled = true
        end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Beam") then
            v:Destroy()
        end
        if v.Name and v.Name:lower():find("line") then
            v:Destroy()
        end
    end
    local grabFolder = ReplicatedStorage:FindFirstChild("GrabEvents")
    if grabFolder then
        local create = grabFolder:FindFirstChild("CreateGrabLine")
        local extend = grabFolder:FindFirstChild("ExtendGrabLine")
        if create then create:Destroy() end
        if extend then extend:Destroy() end
    end
end

local function startAntiLag()
    if antiLagConnection then antiLagConnection:Disconnect() end
    setupAntiLag()
end

local function stopAntiLag()
    if antiLagConnection then
        antiLagConnection:Disconnect()
        antiLagConnection = nil
    end
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        local beamScript = playerScripts:FindFirstChild("CharacterAndBeamMove")
        if beamScript then
            beamScript.Disabled = false
        end
    end
end

local AntiLagGroup = Tabs.Defense:AddRightGroupbox("Анти Лаг")
AntiLagGroup:AddToggle("AntiLag", {
    Text = "Анти Лаг",
    Default = false,
    Callback = function(Value)
        antiLagActive = Value
        if Value then
            startAntiLag()
        else
            stopAntiLag()
        end
    end
})

local SmileGroup = Tabs.Smile:AddLeftGroupbox("Приколы")

local lagActive = false
local lagPower = 100
local lagConnection = nil

local lagSlider = SmileGroup:AddSlider("LagPower", {
    Text = "Мощность лага",
    Default = 100,
    Min = 10,
    Max = 300,
    Step = 10,
    Rounding = 0,
    Callback = function(Value)
        lagPower = Value
    end
})

local function startLag()
    if lagConnection then lagConnection:Disconnect() end
    local createGrabLine = ReplicatedStorage:FindFirstChild("GrabEvents") and ReplicatedStorage.GrabEvents:FindFirstChild("CreateGrabLine")
    if not createGrabLine then
        Library:Notify({Title = "Ошибка", Description = "CreateGrabLine не найден", Duration = 3})
        return
    end
    lagConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if lagActive then
            for i = 1, lagPower do
                pcall(function()
                    createGrabLine:FireServer(workspace.CurrentCamera.CFrame.Position, CFrame.new())
                end)
            end
        end
    end)
end

local function stopLag()
    if lagConnection then
        lagConnection:Disconnect()
        lagConnection = nil
    end
end

SmileGroup:AddToggle("LagToggle", {
    Text = "Лаг сервера убийца",
    Default = false,
    Callback = function(Value)
        lagActive = Value
        if Value then startLag() else stopLag() end
    end
})

local serverLagActive = false
local serverLagTask = nil
local serverLagIntensity = 150

local lagIntensitySlider = SmileGroup:AddSlider("LagIntensity", {
    Text = "Мощность лага (Line)",
    Default = 150,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        serverLagIntensity = Value
        if serverLagActive then
            serverLagActive = false
            task.wait(0.1)
            serverLagActive = true
            if serverLagTask then task.cancel(serverLagTask) end
            serverLagTask = task.spawn(function()
                ServerLagFunction(serverLagIntensity)
            end)
        end
    end
})

local function ServerLagFunction(intensity)
    local players = game:GetService("Players")
    local rs = game:GetService("ReplicatedStorage")
    local grabEvents = rs:FindFirstChild("GrabEvents")
    if not grabEvents then
        Library:Notify({Title = "Ошибка", Description = "GrabEvents не найден", Duration = 3})
        return
    end
    local createGrabLine = grabEvents:FindFirstChild("CreateGrabLine")
    if not createGrabLine then
        Library:Notify({Title = "Ошибка", Description = "CreateGrabLine не найден", Duration = 3})
        return
    end
    while serverLagActive do
        for i = 1, intensity do
            for _, player in pairs(players:GetPlayers()) do
                if player.Character then
                    local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
                    if torso then
                        pcall(function()
                            createGrabLine:FireServer(torso, torso.CFrame)
                        end)
                    end
                end
            end
        end
        task.wait(1)
    end
}

SmileGroup:AddToggle("ServerLagToggle", {
    Text = "Включить лаг сервера",
    Default = false,
    Callback = function(Value)
        serverLagActive = Value
        if Value then
            serverLagTask = task.spawn(function()
                ServerLagFunction(serverLagIntensity)
            end)
            Library:Notify({Title = "Лаг сервера", Description = "Включён (мощность: " .. serverLagIntensity .. ")", Duration = 2})
        else
            if serverLagTask then
                task.cancel(serverLagTask)
                serverLagTask = nil
            end
            Library:Notify({Title = "Лаг сервера", Description = "Выключен", Duration = 2})
        end
    end
})

local waterWalkActive = false
local waterWalkParts = {}

local function setupWaterWalk()
    local oceanModel = workspace:FindFirstChild("Map")
    if oceanModel then
        local alwaysHere = oceanModel:FindFirstChild("AlwaysHereTweenedObjects")
        if alwaysHere then
            local ocean = alwaysHere:FindFirstChild("Ocean")
            if ocean then
                local object = ocean:FindFirstChild("Object")
                if object then
                    local objectModel = object:FindFirstChild("ObjectModel")
                    if objectModel then
                        for _, child in pairs(objectModel:GetChildren()) do
                            if child:IsA("BasePart") and child.Name == "Ocean" then
                                table.insert(waterWalkParts, {
                                    part = child,
                                    originalCollide = child.CanCollide
                                })
                                child.CanCollide = true
                            end
                        end
                    end
                end
            end
        end
    end
end

local function restoreWaterWalk()
    for _, data in ipairs(waterWalkParts) do
        if data.part and data.part.Parent then
            data.part.CanCollide = data.originalCollide
        end
    end
    waterWalkParts = {}
end

local function startWaterWalk()
    setupWaterWalk()
end

local function stopWaterWalk()
    restoreWaterWalk()
end

local WaterWalkGroup = Tabs.Smile:AddLeftGroupbox("Вода")
WaterWalkGroup:AddToggle("WaterWalk", {
    Text = "Хождение по воде",
    Default = false,
    Callback = function(Value)
        waterWalkActive = Value
        if Value then
            startWaterWalk()
        else
            stopWaterWalk()
        end
    end
})

task.spawn(function()
    print("Оптимизация запущена")
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
            if v:IsA("Beam") then v:Destroy() end
            if v:IsA("Decal") and v.Name ~= "PartOwner" then v:Destroy() end
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false end
        end
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("ParticleEmitter") then v.Enabled = false end
        end
        lighting.GlobalShadows = false
        lighting.Brightness = 1
        lighting.ClockTime = 14
    end
end)

local lastPacketNotifyTime = 0
local packetLagSuspects = {}
local packetMonitorConnection = nil

local function startPacketLagMonitor()
    if packetMonitorConnection then packetMonitorConnection:Disconnect() end
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not GrabEvents then return end
    local ExtendGrabLine = GrabEvents:FindFirstChild("ExtendGrabLine")
    if not ExtendGrabLine then return end
    local originalFunction = ExtendGrabLine.OnClientEvent
    ExtendGrabLine.OnClientEvent = function(data, ...)
        local packetSize = 0
        local sender = "Unknown"
        if type(data) == "string" then
            packetSize = #data
            local args = {...}
            if args[1] and type(args[1]) == "string" then
                sender = args[1]
            elseif args[1] and type(args[1]) == "table" and args[1].Name then
                sender = args[1].Name
            end
        elseif type(data) == "table" and data.Name then
            sender = data.Name
        end
        if packetSize > 500 then
            local now = tick()
            if not packetLagSuspects[sender] then
                packetLagSuspects[sender] = {
                    count = 0,
                    maxSize = 0
                }
            end
            packetLagSuspects[sender].count = packetLagSuspects[sender].count + 1
            if packetSize > packetLagSuspects[sender].maxSize then
                packetLagSuspects[sender].maxSize = packetSize
            end
            if now - lastPacketNotifyTime > 6 then
                lastPacketNotifyTime = now
                local notifyText = ""
                local totalCount = 0
                for name, data in pairs(packetLagSuspects) do
                    totalCount = totalCount + data.count
                end
                if totalCount > 0 then
                    local topSuspect = nil
                    local topCount = 0
                    for name, data in pairs(packetLagSuspects) do
                        if data.count > topCount then
                            topCount = data.count
                            topSuspect = name
                        end
                    end
                    if topSuspect and topCount > 0 then
                        local sizeKB = math.floor(packetLagSuspects[topSuspect].maxSize / 1024)
                        notifyText = string.format(
                            "Лагер: %s\nПакетов: %d\nРазмер: %d KB",
                            topSuspect,
                            topCount,
                            sizeKB
                        )
                    else
                        notifyText = string.format("Обнаружен пакетный лаг!\nВсего пакетов: %d", totalCount)
                    end
                    Library:Notify({
                        Title = "PACKET LAG",
                        Description = notifyText,
                        Duration = 5
                    })
                    packetLagSuspects = {}
                end
            end
        end
        if originalFunction then
            originalFunction(data, ...)
        end
    end
    print("Packet Lag Notify активирован")
end

task.spawn(function()
    task.wait(2)
    startPacketLagMonitor()
end)

local function CreateHUD()
    if _G.HUD then
        pcall(function() _G.HUD:Destroy() end)
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrokenSpawnHUD"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    _G.HUD = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundTransparency = 1
    mainFrame.Position = UDim2.new(1, -140, 0, 10)
    mainFrame.Size = UDim2.new(0, 130, 0, 65)
    mainFrame.Parent = screenGui
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextStrokeTransparency = 0.5
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextSize = 16
    fpsLabel.Text = "FPS: 0"
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.Size = UDim2.new(1, 0, 0, 20)
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
    fpsLabel.Parent = mainFrame
    local pingLabel = Instance.new("TextLabel")
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLabel.TextStrokeTransparency = 0.5
    pingLabel.Font = Enum.Font.SourceSansBold
    pingLabel.TextSize = 16
    pingLabel.Text = "Ping: 0 ms"
    pingLabel.Position = UDim2.new(0, 0, 0, 22)
    pingLabel.Size = UDim2.new(1, 0, 0, 20)
    pingLabel.TextXAlignment = Enum.TextXAlignment.Right
    pingLabel.Parent = mainFrame
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextStrokeTransparency = 0.5
    coinsLabel.Font = Enum.Font.SourceSansBold
    coinsLabel.TextSize = 16
    coinsLabel.Text = "Монет: 0"
    coinsLabel.Position = UDim2.new(0, 0, 0, 44)
    coinsLabel.Size = UDim2.new(1, 0, 0, 20)
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
    coinsLabel.Parent = mainFrame
    local lastTime = tick()
    local frameCount = 0
    local fps = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = currentTime
            fpsLabel.Text = "FPS: " .. fps
        end
    end)
    task.spawn(function()
        while screenGui and screenGui.Parent do
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            pingLabel.Text = "Ping: " .. ping .. " ms"
            task.wait(1)
        end
    end)
    local function findCoins()
        local player = game.Players.LocalPlayer
        if not player then return 0 end
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local coinStat = leaderstats:FindFirstChild("coin") or leaderstats:FindFirstChild("Coin") or leaderstats:FindFirstChild("coins") or leaderstats:FindFirstChild("Coins")
            if coinStat then
                return tonumber(coinStat.Value) or 0
            end
        end
        local stats = player:FindFirstChild("Stats") or player:FindFirstChild("Data")
        if stats then
            local coinStat = stats:FindFirstChild("coin") or stats:FindFirstChild("Coin") or stats:FindFirstChild("coins") or stats:FindFirstChild("Coins")
            if coinStat then
                return tonumber(coinStat.Value) or 0
            end
        end
        return 0
    end
    task.spawn(function()
        while screenGui and screenGui.Parent do
            local coins = findCoins()
            coinsLabel.Text = "Монет: " .. coins
            task.wait(0.5)
        end
    end)
end

task.spawn(function()
    task.wait(1)
    CreateHUD()
end)

local UIGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")
UIGroup:AddButton("Unload", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("BrokenSpawn")
SaveManager:SetFolder("BrokenSpawn/Configs")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
if grabEvents then
    local createGrabLine = grabEvents:FindFirstChild("CreateGrabLine")
    if createGrabLine then
        createGrabLine.OnClientEvent = function() end
        print("CreateGrabLine отключён на клиенте")
    end
end

print("Меню загружено")
