--[[
    ███╗   ███╗██╗██╗  ██╗██╗    ██╗ █████╗ ██████╗ ███████╗
    ████╗ ████║██║╚██╗██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝
    ██╔████╔██║██║ ╚███╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  
    ██║╚██╔╝██║██║ ██╔██╗ ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ██║ ╚═╝ ██║██║██╔╝ ██╗╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
    
    MIXWARE.LOL - Ultimate Roblox Script
    Created by: kt471 & Lmrbro
    Version: 2.1.0
--]]

-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Загрузка ESP библиотеки
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

-- Настройки конфигурации
local Config = {
    -- Настройки интерфейса
    Theme = "MIXWARE", -- Кастомная фиолетовая тема
    Transparency = 0.85,
    MenuKey = Enum.KeyCode.K,
    
    -- Основные настройки
    ESPEnabled = false,
    ESPTypes = {
        Box = false,
        Name = false, 
        Health = false,
        Distance = false,
        Tracer = false,
        Skeleton = false
    },
    ChamsEnabled = false,
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2, -- ПКМ
    NoClipEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    WallhackEnabled = false,
    AimbotSmoothness = 0.3,
    AimbotFOV = 100,
    Triggerbot = false,
    TriggerbotDelay = 0.1,
    ShowTeammates = false,
    ESPDistance = 500,
    ESPColor = Color3.fromRGB(180, 80, 255),
    CameraFOV = 70,
    OriginalCameraFOV = 70
}

-- Сохраняем оригинальный FOV
Config.OriginalCameraFOV = Camera.FieldOfView

-- Переменные для Chams
local chamsParts = {}

-- Переменные для аимбота
local CurrentTarget = nil
local isAiming = false
local fovCircle
local aimbotActive = false

-- Создание FOV круга
local function CreateFOVCircle()
    local success, circle = pcall(function()
        local drawing = Drawing.new("Circle")
        drawing.Visible = false
        drawing.Color = Color3.fromRGB(180, 80, 255)
        drawing.Thickness = 2
        drawing.Transparency = 1
        drawing.Filled = false
        drawing.Radius = Config.AimbotFOV
        drawing.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        return drawing
    end)
    
    if success then
        return circle
    else
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Drawing API недоступно",
            Duration = 5
        })
        return nil
    end
end

-- Обновление FOV круга
local function UpdateFOVCircle()
    if fovCircle then
        fovCircle.Visible = Config.AimbotEnabled
        fovCircle.Radius = Config.AimbotFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

-- Функция для изменения FOV камеры
local function UpdateCameraFOV()
    if Camera then
        Camera.FieldOfView = Config.CameraFOV
    end
end

-- Функция для сброса FOV камеры
local function ResetCameraFOV()
    if Camera then
        Camera.FieldOfView = Config.OriginalCameraFOV
        Config.CameraFOV = Config.OriginalCameraFOV
    end
end

-- Функции для Chams
local function findCharacterParts()
    local parts = {}
    if LocalPlayer.Character then
        local leftArm = LocalPlayer.Character:FindFirstChild("Left Arm") or LocalPlayer.Character:FindFirstChild("LeftHand")
        local rightArm = LocalPlayer.Character:FindFirstChild("Right Arm") or LocalPlayer.Character:FindFirstChild("RightHand")
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        
        if leftArm then table.insert(parts, leftArm) end
        if rightArm then table.insert(parts, rightArm) end
        if tool then 
            for _, part in ipairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(parts, part)
                end
            end
        end
    end
    return parts
end

local function applyChamsEffect(part)
    part.Material = Enum.Material.ForceField
    part.Color = Color3.fromRGB(180, 80, 255)
    part.Transparency = 0.3
    
    local glow = part:FindFirstChild("ChamsGlow") or Instance.new("SurfaceLight")
    glow.Name = "ChamsGlow"
    glow.Color = Color3.fromRGB(180, 80, 255)
    glow.Brightness = 2
    glow.Range = 5
    glow.Parent = part
end

local function removeChamsEffect(part)
    part.Material = Enum.Material.Plastic
    part.Transparency = 0
    part.Color = Color3.fromRGB(255, 255, 255)
    
    local glow = part:FindFirstChild("ChamsGlow")
    if glow then
        glow:Destroy()
    end
end

local function enableChams()
    local parts = findCharacterParts()
    for _, part in ipairs(parts) do
        applyChamsEffect(part)
        table.insert(chamsParts, part)
    end
end

local function disableChams()
    for _, part in ipairs(chamsParts) do
        removeChamsEffect(part)
    end
    chamsParts = {}
end

-- Функции аимбота
local function FindTarget()
    local closestPlayer = nil
    local closestDistance = Config.AimbotFOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
                
                if visible then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function AimAtTarget()
    if not CurrentTarget or not CurrentTarget.Character or CurrentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
        CurrentTarget = FindTarget()
        if not CurrentTarget then 
            return false
        end
    end

    local head = CurrentTarget.Character:FindFirstChild("Head")
    if not head then
        CurrentTarget = nil
        return false
    end

    local humanoid = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        CurrentTarget = nil
        return false
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen or screenPos.Z < 0 or (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude > Config.AimbotFOV then
        CurrentTarget = nil
        return false
    end

    local mousePos = UserInputService:GetMouseLocation()
    local targetPos = Vector2.new(screenPos.X, screenPos.Y)

    local delta = (targetPos - mousePos) * Config.AimbotSmoothness * 0.5

    local success = pcall(function()
        mousemoverel(delta.X, delta.Y)
    end)
    
    return success
end

local function TriggerbotCheck()
    if not Config.Triggerbot then return end
    
    local target = FindTarget()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and screenPos.Z > 0 then
                pcall(function()
                    mouse1press()
                    wait(0.05)
                    mouse1release()
                end)
                wait(Config.TriggerbotDelay)
            end
        end
    end
end

-- Функции NoClip
function EnableNoClip()
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

function DisableNoClip()
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Функции Wallhack
function EnableWallhack()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            part.LocalTransparencyModifier = 0.5
        end
    end
end

function DisableWallhack()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        end
    end
end

-- Функция для обновления ESP
local function UpdateESP()
    ESP.ShowBox = Config.ESPTypes.Box
    ESP.ShowName = Config.ESPTypes.Name
    ESP.ShowHealth = Config.ESPTypes.Health
    ESP.ShowDistance = Config.ESPTypes.Distance
    ESP.ShowTracer = Config.ESPTypes.Tracer
    ESP.ShowSkeletons = Config.ESPTypes.Skeleton
    
    local anyESPEnabled = Config.ESPTypes.Box or Config.ESPTypes.Name or 
                         Config.ESPTypes.Health or Config.ESPTypes.Distance or
                         Config.ESPTypes.Tracer or Config.ESPTypes.Skeleton
    
    ESP.Enabled = anyESPEnabled
    Config.ESPEnabled = anyESPEnabled
end

-- СОЗДАНИЕ КАСТОМНОЙ ТЕМЫ MIXWARE (ФИОЛЕТОВАЯ)
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

-- Создание окна Rayfield с кастомной темой
local Window = Rayfield:CreateWindow({
    Name = "💜 MIXWARE.LOL [kt471 | Lmrbro]",
    LoadingTitle = "MIXWARE LOADING...",
    LoadingSubtitle = "Created by kt471 & Lmrbro",
    Theme = MixwareTheme, -- Используем кастомную тему
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

-- СОЗДАНИЕ ВКЛАДОК
local MovementTab = Window:CreateTab("🚀 Движение", 4483362458)
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)
local CombatTab = Window:CreateTab("🎯 Бой", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки", 4483362458)
local ScriptTab = Window:CreateTab("📜 Скрипты", 4483362458)
local ThemeTab = Window:CreateTab("🎨 Оформление", 4483362458)

-- ВКЛАДКА ДВИЖЕНИЕ
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
            EnableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip включен",
                Duration = 2
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен",
                Duration = 2
            })
        end
    end,
})

-- ВКЛАДКА ВИЗУАЛ
VisualTab:CreateSection("Типы ESP")
local ESPDropdown = VisualTab:CreateDropdown({
    Name = "🎯 Типы ESP (множественный выбор)",
    Options = {"📦 Боксы", "🏷️ Имена", "❤️ Здоровье", "📏 Дистанция", "🔺 Трейсеры", "💀 Скелетоны"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ESPDropdown",
    Callback = function(SelectedOptions)
        Config.ESPTypes.Box = table.find(SelectedOptions, "📦 Боксы") ~= nil
        Config.ESPTypes.Name = table.find(SelectedOptions, "🏷️ Имена") ~= nil
        Config.ESPTypes.Health = table.find(SelectedOptions, "❤️ Здоровье") ~= nil
        Config.ESPTypes.Distance = table.find(SelectedOptions, "📏 Дистанция") ~= nil
        Config.ESPTypes.Tracer = table.find(SelectedOptions, "🔺 Трейсеры") ~= nil
        Config.ESPTypes.Skeleton = table.find(SelectedOptions, "💀 Скелетоны") ~= nil
        
        UpdateESP()
        
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Настройки ESP обновлены",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Быстрые пресеты ESP")
local FullESPPreset = VisualTab:CreateButton({
    Name = "🎯 Полный ESP",
    Callback = function()
        ESPDropdown:Set({"📦 Боксы", "🏷️ Имена", "❤️ Здоровье", "📏 Дистанция", "🔺 Трейсеры", "💀 Скелетоны"})
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Полный ESP включен",
            Duration = 2
        })
    end,
})
local MinimalESPPreset = VisualTab:CreateButton({
    Name = "📱 Минимальный ESP",
    Callback = function()
        ESPDropdown:Set({"📦 Боксы", "🏷️ Имена"})
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Минимальный ESP включен",
            Duration = 2
        })
    end,
})
local CombatESPPreset = VisualTab:CreateButton({
    Name = "⚔️ Боевой ESP",
    Callback = function()
        ESPDropdown:Set({"📦 Боксы", "❤️ Здоровье", "🔺 Трейсеры"})
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Боевой ESP включен",
            Duration = 2
        })
    end,
})
local ClearESPPreset = VisualTab:CreateButton({
    Name = "🗑️ Очистить ESP",
    Callback = function()
        ESPDropdown:Set({})
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "ESP отключен",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Настройки цвета ESP")
local ESPColorPicker = VisualTab:CreateColorPicker({
    Name = "🎨 Цвет ESP",
    Color = Config.ESPColor,
    Flag = "ESPColor",
    Callback = function(Color)
        Config.ESPColor = Color
        ESP.Color = Color
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Цвет ESP изменен",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Дополнительные настройки ESP")
local ESPDistanceSlider = VisualTab:CreateSlider({
    Name = "📏 Макс. дистанция ESP",
    Range = {0, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = Config.ESPDistance,
    Flag = "ESPDistance",
    Callback = function(Value)
        Config.ESPDistance = Value
        ESP.MaxDistance = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Макс. дистанция: " .. Value .. " studs",
            Duration = 2
        })
    end,
})
local ShowTeammatesToggle = VisualTab:CreateToggle({
    Name = "👥 Показывать тиммейтов",
    CurrentValue = Config.ShowTeammates,
    Flag = "ShowTeammates",
    Callback = function(Value)
        Config.ShowTeammates = Value
        ESP.ShowTeammates = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Тиммейты отображаются" or "Тиммейты скрыты",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Настройки камеры")
local CameraFOVSlider = VisualTab:CreateSlider({
    Name = "📷 FOV камеры",
    Range = {10, 120},
    Increment = 5,
    Suffix = "°",
    CurrentValue = Config.CameraFOV,
    Flag = "CameraFOV",
    Callback = function(Value)
        Config.CameraFOV = Value
        UpdateCameraFOV()
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "FOV: " .. Value .. "°",
            Duration = 2
        })
    end,
})
local ResetFOVButton = VisualTab:CreateButton({
    Name = "🔄 Сброс FOV камеры",
    Callback = function()
        ResetCameraFOV()
        CameraFOVSlider:Set(Config.CameraFOV)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "FOV сброшен",
            Duration = 2
        })
    end,
})

VisualTab:CreateSection("Другие визуальные эффекты")
local ChamsToggle = VisualTab:CreateToggle({
    Name = "🌈 Chams (руки/оружие)",
    CurrentValue = Config.ChamsEnabled,
    Flag = "ChamsToggle",
    Callback = function(Value)
        Config.ChamsEnabled = Value
        if Value then
            enableChams()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Chams включены",
                Duration = 2
            })
        else
            disableChams()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Chams выключены",
                Duration = 2
            })
        end
    end,
})
local WallhackToggle = VisualTab:CreateToggle({
    Name = "👁️ Сквозь стены (X-Ray)",
    CurrentValue = Config.WallhackEnabled,
    Flag = "WallhackToggle",
    Callback = function(Value)
        Config.WallhackEnabled = Value
        if Value then
            EnableWallhack()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "X-Ray включен",
                Duration = 2
            })
        else
            DisableWallhack()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "X-Ray выключен",
                Duration = 2
            })
        end
    end,
})

-- ВКЛАДКА БОЙ
CombatTab:CreateSection("Основные настройки аимбота")
local AimbotToggle = CombatTab:CreateToggle({
    Name = "🎯 Аимбот (ПКМ)",
    CurrentValue = Config.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.AimbotEnabled = Value
        if not Value then
            aimbotActive = false
        end
        if fovCircle then
            fovCircle.Visible = Value
        end
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Аимбот включен (держи ПКМ)" or "Аимбот выключен",
            Duration = 2
        })
    end,
})

CombatTab:CreateSection("Настройки аимбота")
local SmoothnessSlider = CombatTab:CreateSlider({
    Name = "Плавность аимбота",
    Range = {0.1, 1},
    Increment = 0.1,
    Suffix = "ед.",
    CurrentValue = Config.AimbotSmoothness,
    Flag = "AimbotSmoothness",
    Callback = function(Value)
        Config.AimbotSmoothness = Value
    end,
})
local FOVSlider = CombatTab:CreateSlider({
    Name = "Поле зрения аимбота",
    Range = {10, 500},
    Increment = 5,
    Suffix = "ед.",
    CurrentValue = Config.AimbotFOV,
    Flag = "AimbotFOV",
    Callback = function(Value)
        Config.AimbotFOV = Value
        if fovCircle then
            fovCircle.Radius = Value
        end
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "FOV: " .. Value,
            Duration = 2
        })
    end,
})

CombatTab:CreateSection("Триггербот")
local TriggerbotToggle = CombatTab:CreateToggle({
    Name = "🔫 Триггербот",
    CurrentValue = Config.Triggerbot,
    Flag = "Triggerbot",
    Callback = function(Value)
        Config.Triggerbot = Value
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Триггербот включен" or "Триггербот выключен",
            Duration = 2
        })
    end,
})
local TriggerbotDelaySlider = CombatTab:CreateSlider({
    Name = "Задержка триггербота",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "сек.",
    CurrentValue = Config.TriggerbotDelay,
    Flag = "TriggerbotDelay",
    Callback = function(Value)
        Config.TriggerbotDelay = Value
    end,
})

CombatTab:CreateSection("Отладка")
local DebugAimbotButton = CombatTab:CreateButton({
    Name = "🐛 Отладка аимбота",
    Callback = function()
        local target = FindTarget()
        if target then
            Rayfield:Notify({
                Title = "MIXWARE DEBUG",
                Content = "Цель: " .. target.Name .. "\nFOV: " .. Config.AimbotFOV,
                Duration = 5
            })
        else
            Rayfield:Notify({
                Title = "MIXWARE DEBUG",
                Content = "Цель не найдена!\nПроверьте FOV и наличие игроков",
                Duration = 5
            })
        end
    end,
})

-- ВКЛАДКА НАСТРОЙКИ
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

-- ВКЛАДКА СКРИПТЫ
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

-- ВКЛАДКА ОФОРМЛЕНИЕ
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
                Title = "MIXWARE THEME",
                Content = "Тема: MIXWARE Фиолетовая",
                Duration = 2
            })
        else
            Window:ModifyTheme(Option)
            Rayfield:Notify({
                Title = "MIXWARE THEME",
                Content = "Тема: " .. Option,
                Duration = 2
            })
        end
    end,
})

-- Обработчики ввода для аимбота на ПКМ
UserInputService.InputBegan:Connect(function(input)
    -- Аимбот по ПКМ
    if Config.AimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotActive = true
        CurrentTarget = FindTarget()
        if CurrentTarget then
            Rayfield:Notify({
                Title = "MIXWARE AIMBOT",
                Content = "АКТИВЕН - Цель: " .. CurrentTarget.Name,
                Duration = 1
            })
        else
            Rayfield:Notify({
                Title = "MIXWARE AIMBOT",
                Content = "Цель не найдена",
                Duration = 1
            })
            aimbotActive = false
        end
    end
    
    -- NoClip по N
    if input.KeyCode == Enum.KeyCode.N then
        Config.NoClipEnabled = not Config.NoClipEnabled
        NoClipToggle:Set(Config.NoClipEnabled)
        if Config.NoClipEnabled then
            EnableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip включен (N)",
                Duration = 2
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен (N)",
                Duration = 2
            })
        end
    end
    
    -- Открытие/закрытие меню по K
    if input.KeyCode == Config.MenuKey then
        Rayfield:SetVisibility(not Rayfield.Visible)
    end
end)

-- Отпускание ПКМ
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimbotActive = false
        CurrentTarget = nil
    end
end)

-- Основной цикл
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

    -- No Clip
    if Config.NoClipEnabled and LocalPlayer.Character then
        EnableNoClip()
    end

    -- Аимбот (ПКМ)
    if Config.AimbotEnabled and aimbotActive then
        local success = AimAtTarget()
        if not success and CurrentTarget then
            CurrentTarget = nil
            aimbotActive = false
            Rayfield:Notify({
                Title = "MIXWARE AIMBOT",
                Content = "Цель потеряна - выключен",
                Duration = 2
            })
        end
    end

    -- Триггербот
    if Config.Triggerbot then
        TriggerbotCheck()
    end

    -- Auto update Chams
    if Config.ChamsEnabled then
        local currentParts = findCharacterParts()
        for _, part in ipairs(currentParts) do
            if not table.find(chamsParts, part) then
                applyChamsEffect(part)
                table.insert(chamsParts, part)
            end
        end
    end
end)

-- Обновление FOV круга
if RunService.RenderStepped then
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            UpdateFOVCircle()
        end
    end)
end

-- Инициализация ESP
ESP.BoxType = "Corner Box Esp"
ESP.Enabled = false
ESP.ShowBox = false
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowDistance = false
ESP.ShowTracer = false
ESP.ShowSkeletons = false
ESP.Color = Config.ESPColor
ESP.MaxDistance = Config.ESPDistance
ESP.ShowTeammates = Config.ShowTeammates

-- Загрузка конфигурации
Rayfield:LoadConfiguration()

-- Создаем FOV круг
task.spawn(function()
    wait(1)
    fovCircle = CreateFOVCircle()
end)

-- Финальные уведомления
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
