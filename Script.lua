-- [[ BROKEN SPAWN MENU - Obsidian Library Version ]]

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

-- ТОЛЬКО ЭТИ ВКЛАДКИ
local Tabs = {
    Players = Window:AddTab("Players", "users"),        -- игроки
    Target = Window:AddTab("Target", "target"),         -- прицел
    TargetBlob = Window:AddTab("Target Blob", "bot"),   -- таргет блобом
    Defense = Window:AddTab("Defense", "shield"),       -- защита (щит)
    Smile = Window:AddTab("Smile", "smile"),            -- улыбка
    Settings = Window:AddTab("Settings", "settings"),   -- настройки
}

-- Пустые заглушки (чтобы не было ошибок)
local function addEmptyGroup(tab, name)
    local group = tab:AddLeftGroupbox(name)
    group:AddLabel(" ")
end

addEmptyGroup(Tabs.Players, "Players")
addEmptyGroup(Tabs.Target, "Target")
addEmptyGroup(Tabs.TargetBlob, "Target Blob")
addEmptyGroup(Tabs.Defense, "Defense")
addEmptyGroup(Tabs.Smile, "Smile")

-- Настройки (только выгрузка)
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
