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

local Tabs = {
    Visual = Window:AddTab("Visual", "eye"),
    AutoClicker = Window:AddTab("Auto-Clicker", "mouse"),
    Keybinds = Window:AddTab("Keybinds", "keyboard"),
    Misc = Window:AddTab("Misc", "layers"),
    Lists = Window:AddTab("Lists", "list"),
    Settings = Window:AddTab("Settings", "settings"),
}

local VisualGroup = Tabs.Visual:AddLeftGroupbox("ESP")
VisualGroup:AddToggle("PCLD_ESP", {
    Text = "PCLD ESP",
    Default = false,
    Callback = function(Value) end
})

local ClickerGroup = Tabs.AutoClicker:AddLeftGroupbox("Auto Clicker")
ClickerGroup:AddToggle("AutoClicker", {
    Text = "Auto Clicker",
    Default = false,
    Callback = function(Value) end
})

local KeybindsGroup = Tabs.Keybinds:AddLeftGroupbox("Keybinds")
KeybindsGroup:AddKeyPicker("MenuKey", {
    Text = "Open Menu",
    Default = "RightShift",
    NoUI = false,
    Callback = function() end
})

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
