--[[
    ███╗   ███╗██╗██╗  ██╗██╗    ██╗ █████╗ ██████╗ ███████╗
    ████╗ ████║██║╚██╗██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝
    ██╔████╔██║██║ ╚███╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  
    ██║╚██╔╝██║██║ ██╔██╗ ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ██║ ╚═╝ ██║██║██╔╝ ██╗╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
    
    MIXWARE.LOL - Ultimate Roblox Script
    Created by: kt471 & Lmrbro
    Version: 6.0.0
--]]

-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ЗАГРУЗКА ESP БИБЛИОТЕКИ (ФАЙЛ 1)
-- !!! ВАЖНО: Файл mixware_esp.lua должен лежать в той же папке !!!
local MixwareESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ваш_репозиторий/mixware_esp.lua"))()
local ESP = MixwareESP.new()

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============ АИМБОТ БИБЛИОТЕКА ============
local AimbotLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Aimbot/Aimbot"))()
local Aimbot = AimbotLibrary.new()

-- Настройки конфигурации
local Config = {
    -- ESP настройки
    ESPEnabled = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPTracers = false,
    ESPHeadDots = false,
    ESPSkeletons = false,
    ESPInventory = false,
    ESPColor = Color3.fromRGB(180, 80, 255),
    ESPMaxDistance = 500,
    ESPTeamCheck = false,
    
    -- Аимбот настройки
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotSmoothness = 0.3,
    AimbotFOV = 150,
    AimbotPriority = "Distance",
    AimbotTeamCheck = false,
    AimbotVisibleCheck = true,
    AimbotLockPart = "Head",
    
    -- Другие настройки
    NoClipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    TriggerbotEnabled = false,
    TriggerbotDelay = 0.1,
    
    -- Интерфейс
    Theme = "MIXWARE",
    MenuKey = Enum.KeyCode.K
}

-- Сохраняем оригинальный FOV
local OriginalFOV = Camera.FieldOfView

-- ============ СОЗДАНИЕ ТЕМЫ MIXWARE ============
local MixwareTheme = {
    TextColor = Color3.fromRGB(220, 200, 255),
    Background = Color3.fromRGB(20, 10, 35),
    Topbar = Color3.fromRGB(40, 20, 60),
    Shadow = Color3.fromRGB(15, 5, 25),
    NotificationBackground = Color3.fromRGB(30, 15, 50),
    NotificationActionsBackground = Color3.fromRGB(60, 30, 90),
    TabBackground = Color3.fromRGB(45, 25, 65),
    TabStroke = Color3.fromRGB(80, 40, 120),
    TabBackgroundSelected = Color3.fromRGB(180, 80, 255),
    TabTextColor = Color3.fromRGB(200, 180, 220),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(35, 20, 55),
    ElementBackgroundHover = Color3.fromRGB(50, 30, 75),
    SecondaryElementBackground = Color3.fromRGB(25, 15, 40),
    ElementStroke = Color3.fromRGB(80, 40, 120),
    SecondaryElementStroke = Color3.fromRGB(60, 30, 90),
    SliderBackground = Color3.fromRGB(180, 80, 255),
    SliderProgress = Color3.fromRGB(200, 100, 255),
    SliderStroke = Color3.fromRGB(220, 120, 255),
    ToggleBackground = Color3.fromRGB(30, 15, 50),
    ToggleEnabled = Color3.fromRGB(180, 80, 255),
    ToggleDisabled = Color3.fromRGB(80, 40, 120),
    ToggleEnabledStroke = Color3.fromRGB(200, 100, 255),
    ToggleDisabledStroke = Color3.fromRGB(100, 50, 150),
    ToggleEnabledOuterStroke = Color3.fromRGB(150, 70, 220),
    ToggleDisabledOuterStroke = Color3.fromRGB(60, 30, 90),
    DropdownSelected = Color3.fromRGB(50, 30, 75),
    DropdownUnselected = Color3.fromRGB(30, 15, 50),
    InputBackground = Color3.fromRGB(30, 15, 50),
    InputStroke = Color3.fromRGB(80, 40, 120),
    PlaceholderColor = Color3.fromRGB(150, 130, 180)
}

-- ============ НАСТРОЙКА АИМБОТА ============
Aimbot:SetSmoothness(Config.AimbotSmoothness)
Aimbot:SetFOV(Config.AimbotFOV)
Aimbot:SetPriority(Config.AimbotPriority)
Aimbot:SetTeamCheck(Config.AimbotTeamCheck)
Aimbot:SetVisibleCheck(Config.AimbotVisibleCheck)
Aimbot:SetLockPart(Config.AimbotLockPart)
Aimbot:SetEnabled(Config.AimbotEnabled)

-- ============ НАСТРОЙКА ESP ============
ESP:SetColor(Config.ESPColor)
ESP:SetMaxDistance(Config.ESPMaxDistance)
ESP:ToggleTeamCheck(Config.ESPTeamCheck)

-- ============ СОЗДАНИЕ ОКНА ============
local Window = Rayfield:CreateWindow({
    Name = "💜 MIXWARE.LOL [kt471 | Lmrbro]",
    LoadingTitle = "MIXWARE LOADING...",
    LoadingSubtitle = "Created by kt471 & Lmrbro",
    Theme = MixwareTheme,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MixwareConfig",
        FileName = "MixwareSettings"
    },
    Discord = {
        Enabled = true,
        Invite = "mixware",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "MIXWARE Auth",
        Subtitle = "Enter Key to Access",
        Note = "Join Discord: discord.gg/mixware",
        FileName = "MixwareKey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"MIX2026", "KT471_LMR", "MIXWARE_ULTRA", "11Li-20_dA"}
    }
})

-- ============ СОЗДАНИЕ ВКЛАДОК ============
local MovementTab = Window:CreateTab("🚀 Движение", 4483362458)
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)
local CombatTab = Window:CreateTab("🎯 Бой", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки", 4483362458)
local ScriptTab = Window:CreateTab("📜 Скрипты", 4483362458)
local ThemeTab = Window:CreateTab("🎨 Оформление", 4483362458)

-- ============ ВКЛАДКА ДВИЖЕНИЕ ============
MovementTab:CreateSection("Скорость")

local SpeedToggle = MovementTab:CreateToggle({
    Name = "⚡ Скорость",
    CurrentValue = Config.SpeedEnabled,
    Flag = "SpeedToggle",
    Callback = function(Value)
        Config.SpeedEnabled = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Скорость: " .. Config.SpeedValue or "Скорость выключена",
            Duration = 2
        })
    end,
})

local SpeedSlider = MovementTab:CreateSlider({
    Name = "Скорость ходьбы",
    Range = {16, 100},
    Increment = 1,
    Suffix = "ед.",
    CurrentValue = Config.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(Value)
        Config.SpeedValue = Value
    end,
})

MovementTab:CreateSection("Прыжок")

local JumpToggle = MovementTab:CreateToggle({
    Name = "🦘 Высокий прыжок",
    CurrentValue = Config.JumpPowerEnabled,
    Flag = "JumpToggle",
    Callback = function(Value)
        Config.JumpPowerEnabled = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Прыжок: " .. Config.JumpPowerValue or "Прыжок выключен",
            Duration = 2
        })
    end,
})

local JumpSlider = MovementTab:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 200},
    Increment = 1,
    Suffix = "ед.",
    CurrentValue = Config.JumpPowerValue,
    Flag = "JumpValue",
    Callback = function(Value)
        Config.JumpPowerValue = Value
    end,
})

MovementTab:CreateSection("NoClip")

local NoClipToggle = MovementTab:CreateToggle({
    Name = "👻 Сквозь стены (NoClip)",
    CurrentValue = Config.NoClipEnabled,
    Flag = "NoClipToggle",
    Callback = function(Value)
        Config.NoClipEnabled = Value
        if Value then
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip включен",
                Duration = 2
            })
        else
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен",
                Duration = 2
            })
        end
    end,
})

-- ============ ВКЛАДКА ВИЗУАЛ ============
VisualTab:CreateSection("Основные настройки ESP")

local ESPToggle = VisualTab:CreateToggle({
    Name = "👁️ Включить ESP",
    CurrentValue = Config.ESPEnabled,
    Flag = "ESPToggle",
    Callback = function(Value)
        Config.ESPEnabled = Value
        ESP:SetEnabled(Value)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "ESP включен" or "ESP выключен",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Типы ESP")

local ESPBoxesToggle = VisualTab:CreateToggle({
    Name = "📦 Боксы",
    CurrentValue = Config.ESPBoxes,
    Flag = "ESPBoxes",
    Callback = function(Value)
        Config.ESPBoxes = Value
        ESP:ToggleBoxes(Value)
    end,
})

local ESPNamesToggle = VisualTab:CreateToggle({
    Name = "🏷️ Имена",
    CurrentValue = Config.ESPNames,
    Flag = "ESPNames",
    Callback = function(Value)
        Config.ESPNames = Value
        ESP:ToggleNames(Value)
    end,
})

local ESPHealthToggle = VisualTab:CreateToggle({
    Name = "❤️ Здоровье",
    CurrentValue = Config.ESPHealth,
    Flag = "ESPHealth",
    Callback = function(Value)
        Config.ESPHealth = Value
        ESP:ToggleHealth(Value)
    end,
})

local ESPDistanceToggle = VisualTab:CreateToggle({
    Name = "📏 Дистанция",
    CurrentValue = Config.ESPDistance,
    Flag = "ESPDistance",
    Callback = function(Value)
        Config.ESPDistance = Value
        ESP:ToggleDistance(Value)
    end,
})

local ESPTracersToggle = VisualTab:CreateToggle({
    Name = "🔺 Трейсеры",
    CurrentValue = Config.ESPTracers,
    Flag = "ESPTracers",
    Callback = function(Value)
        Config.ESPTracers = Value
        ESP:ToggleTracers(Value)
    end,
})

local ESPHeadDotsToggle = VisualTab:CreateToggle({
    Name = "🔴 Точка на голове",
    CurrentValue = Config.ESPHeadDots,
    Flag = "ESPHeadDots",
    Callback = function(Value)
        Config.ESPHeadDots = Value
        ESP:ToggleHeadDots(Value)
    end,
})

local ESPSkeletonsToggle = VisualTab:CreateToggle({
    Name = "💀 Скелетоны",
    CurrentValue = Config.ESPSkeletons,
    Flag = "ESPSkeletons",
    Callback = function(Value)
        Config.ESPSkeletons = Value
        ESP:ToggleSkeletons(Value)
    end,
})

local ESPInventoryToggle = VisualTab:CreateToggle({
    Name = "🎒 Инвентарь",
    CurrentValue = Config.ESPInventory,
    Flag = "ESPInventory",
    Callback = function(Value)
        Config.ESPInventory = Value
        ESP:ToggleInventory(Value)
    end,
})

VisualTab:CreateSection("Настройки цвета")

local ESPColorPicker = VisualTab:CreateColorPicker({
    Name = "🎨 Цвет ESP",
    Color = Config.ESPColor,
    Flag = "ESPColor",
    Callback = function(Color)
        Config.ESPColor = Color
        ESP:SetColor(Color)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Цвет ESP изменен",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Дополнительные настройки")

local ESPDistanceSlider = VisualTab:CreateSlider({
    Name = "📏 Макс. дистанция",
    Range = {0, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = Config.ESPMaxDistance,
    Flag = "ESPMaxDistance",
    Callback = function(Value)
        Config.ESPMaxDistance = Value
        ESP:SetMaxDistance(Value)
    end,
})

local ESPTeamCheckToggle = VisualTab:CreateToggle({
    Name = "👥 Командный цвет (зелёный)",
    CurrentValue = Config.ESPTeamCheck,
    Flag = "ESPTeamCheck",
    Callback = function(Value)
        Config.ESPTeamCheck = Value
        ESP:ToggleTeamCheck(Value)
    end,
})

VisualTab:CreateSection("Настройки камеры")

local CameraFOVSlider = VisualTab:CreateSlider({
    Name = "📷 FOV камеры",
    Range = {10, 120},
    Increment = 5,
    Suffix = "°",
    CurrentValue = Camera.FieldOfView,
    Flag = "CameraFOV",
    Callback = function(Value)
        Camera.FieldOfView = Value
    end,
})

local ResetFOVButton = VisualTab:CreateButton({
    Name = "🔄 Сброс FOV",
    Callback = function()
        Camera.FieldOfView = OriginalFOV
        CameraFOVSlider:Set(OriginalFOV)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "FOV сброшен",
            Duration = 2
        })
    end,
})

-- ============ ВКЛАДКА БОЙ ============
CombatTab:CreateSection("Аимбот")

local AimbotToggle = CombatTab:CreateToggle({
    Name = "🎯 Аимбот (ПКМ)",
    CurrentValue = Config.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.AimbotEnabled = Value
        Aimbot:SetEnabled(Value)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Аимбот включен (держи ПКМ)" or "Аимбот выключен",
            Duration = 2
        })
    end,
})

CombatTab:CreateSection("Настройки аимбота")

local SmoothnessSlider = CombatTab:CreateSlider({
    Name = "Плавность",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "ед.",
    CurrentValue = Config.AimbotSmoothness,
    Flag = "Smoothness",
    Callback = function(Value)
        Config.AimbotSmoothness = Value
        Aimbot:SetSmoothness(Value)
    end,
})

local FOVSlider = CombatTab:CreateSlider({
    Name = "Поле зрения (FOV)",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = Config.AimbotFOV,
    Flag = "AimbotFOV",
    Callback = function(Value)
        Config.AimbotFOV = Value
        Aimbot:SetFOV(Value)
    end,
})

local PriorityDropdown = CombatTab:CreateDropdown({
    Name = "Приоритет цели",
    Options = {"Distance", "Health", "ClosestToCrosshair"},
    CurrentOption = Config.AimbotPriority,
    Flag = "Priority",
    Callback = function(Option)
        Config.AimbotPriority = Option
        Aimbot:SetPriority(Option)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Приоритет: " .. Option,
            Duration = 2
        })
    end,
})

local LockPartDropdown = CombatTab:CreateDropdown({
    Name = "Часть тела для прицела",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = Config.AimbotLockPart,
    Flag = "LockPart",
    Callback = function(Option)
        Config.AimbotLockPart = Option
        Aimbot:SetLockPart(Option)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Цель: " .. Option,
            Duration = 2
        })
    end,
})

local TeamCheckToggle = CombatTab:CreateToggle({
    Name = "🚫 Игнорировать тиммейтов",
    CurrentValue = Config.AimbotTeamCheck,
    Flag = "TeamCheck",
    Callback = function(Value)
        Config.AimbotTeamCheck = Value
        Aimbot:SetTeamCheck(Value)
    end,
})

local VisibleCheckToggle = CombatTab:CreateToggle({
    Name = "👁️ Только видимые цели",
    CurrentValue = Config.AimbotVisibleCheck,
    Flag = "VisibleCheck",
    Callback = function(Value)
        Config.AimbotVisibleCheck = Value
        Aimbot:SetVisibleCheck(Value)
    end,
})

CombatTab:CreateSection("Триггербот")

local TriggerbotToggle = CombatTab:CreateToggle({
    Name = "🔫 Триггербот",
    CurrentValue = Config.TriggerbotEnabled,
    Flag = "Triggerbot",
    Callback = function(Value)
        Config.TriggerbotEnabled = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Триггербот включен" or "Триггербот выключен",
            Duration = 2
        })
    end,
})

local TriggerbotDelaySlider = CombatTab:CreateSlider({
    Name = "Задержка",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "сек.",
    CurrentValue = Config.TriggerbotDelay,
    Flag = "TriggerbotDelay",
    Callback = function(Value)
        Config.TriggerbotDelay = Value
    end,
})

-- ============ ВКЛАДКА СКРИПТЫ ============
ScriptTab:CreateSection("Запуск скриптов")

local Script99n = ScriptTab:CreateButton({
    Name = "🏕 99 ночей",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Скрипт 99 ночей запущен",
            Duration = 2
        })
    end
})

local ScriptMM2 = ScriptTab:CreateButton({
    Name = "🔪 MM2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vertex-peak/vertex/refs/heads/main/loadstring"))()
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Скрипт MM2 запущен",
            Duration = 2
        })
    end
})

local ScriptCrash = ScriptTab:CreateButton({
    Name = "💥 Crash (Тест)",
    Callback = function()
        while true do
            Rayfield:Notify({
                Title = "MIXWARE CRASH",
                Content = "Скрипт краша запущен",
                Duration = 2
            })
            wait(1)
        end
    end
})

-- ============ ВКЛАДКА НАСТРОЙКИ ============
SettingsTab:CreateSection("Управление меню")

local HideMenuButton = SettingsTab:CreateButton({
    Name = "👁️ Скрыть меню (K)",
    Callback = function()
        Rayfield:SetVisibility(false)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Меню скрыто. Нажми K чтобы показать",
            Duration = 3
        })
    end,
})

local ShowMenuButton = SettingsTab:CreateButton({
    Name = "👁️ Показать меню",
    Callback = function()
        Rayfield:SetVisibility(true)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Меню показано",
            Duration = 2
        })
    end,
})

-- ============ ВКЛАДКА ОФОРМЛЕНИЕ ============
ThemeTab:CreateSection("Настройки темы")

local ThemeDropdown = ThemeTab:CreateDropdown({
    Name = "🎨 Выбор темы",
    Options = {"MIXWARE (Фиолетовая)", "Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = "MIXWARE (Фиолетовая)",
    Flag = "ThemeDropdown",
    Callback = function(Option)
        if Option == "MIXWARE (Фиолетовая)" then
            Window:ModifyTheme(MixwareTheme)
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Тема: MIXWARE Фиолетовая",
                Duration = 2
            })
        else
            Window:ModifyTheme(Option)
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Тема: " .. Option,
                Duration = 2
            })
        end
    end,
})

-- ============ ОБРАБОТЧИКИ КЛАВИШ ============
UserInputService.InputBegan:Connect(function(input)
    -- Аимбот по ПКМ
    if Config.AimbotEnabled and input.UserInputType == Config.AimbotKey then
        Aimbot:Start()
    end
    
    -- NoClip по N
    if input.KeyCode == Enum.KeyCode.N then
        Config.NoClipEnabled = not Config.NoClipEnabled
        NoClipToggle:Set(Config.NoClipEnabled)
        if Config.NoClipEnabled then
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip включен (N)",
                Duration = 2
            })
        else
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен (N)",
                Duration = 2
            })
        end
    end
    
    -- Меню по K
    if input.KeyCode == Config.MenuKey then
        Rayfield:SetVisibility(not Rayfield.Visible)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if Config.AimbotEnabled and input.UserInputType == Config.AimbotKey then
        Aimbot:Stop()
    end
end)

-- ============ ОСНОВНОЙ ЦИКЛ ============
RunService.Heartbeat:Connect(function()
    -- Speed hack
    if Config.SpeedEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.SpeedValue
        end
    end
    
    -- Jump Power
    if Config.JumpPowerEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = Config.JumpPowerValue
        end
    end
    
    -- NoClip поддержка
    if Config.NoClipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Триггербот
    if Config.TriggerbotEnabled then
        local target = Aimbot:GetTarget()
        if target then
            pcall(function()
                mouse1press()
                wait(Config.TriggerbotDelay)
                mouse1release()
            end)
        end
    end
    
    -- Обновление ESP (каждый кадр)
    ESP:Update()
end)

-- ============ ЗАПУСК ============
Rayfield:LoadConfiguration()

-- Уведомления
task.spawn(function()
    wait(2)
    Rayfield:Notify({
        Title = "💜 MIXWARE.LOL",
        Content = "Загружено! kt471 & Lmrbro",
        Duration = 5
    })
    Rayfield:Notify({
        Title = "🎮 Управление",
        Content = "K - меню | N - NoClip | ПКМ - аимбот",
        Duration = 5
    })
end)
