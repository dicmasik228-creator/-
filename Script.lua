                task.delay(5, function()
                    lastLagSource = false
                end)
            end
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

local SmileGroup = Tabs.Smile:AddLeftGroupbox("Приколы")

local function loadFurtherReach()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ultraskidding/luau/refs/heads/main/ftap/gamepassreach.lua"))()
    end)
    if success then
        Library:Notify({
            Title = "BROKEN SPAWN",
            Description = "Дальний захват загружен",
            Duration = 3
        })
    else
        Library:Notify({
            Title = "BROKEN SPAWN",
            Description = "Ошибка загрузки",
            Duration = 3
        })
    end
end

SmileGroup:AddButton({
    Text = "Дальний захват",
    Func = function()
        loadFurtherReach()
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

print("✅ Меню загружено")
