--[[
    ███╗   ███╗██╗██╗  ██╗██╗    ██╗ █████╗ ██████╗ ███████╗
    ████╗ ████║██║╚██╗██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝
    ██╔████╔██║██║ ╚███╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  
    ██║╚██╔╝██║██║ ██╔██╗ ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ██║ ╚═╝ ██║██║██╔╝ ██╗╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
    
    MIXWARE.LOL - Ultimate Roblox Script
    Created by: kt471 & Lmrbro
    Version: 2.0.0
--]]

-- Загрузка Rayfield с поддержкой кастомизации
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Загрузка ESP библиотеки
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

-- Настройки конфигурации с добавлением новых параметров
local Config = {
    -- Настройки интерфейса (НОВОЕ)
    Theme = "Dark", -- "Dark", "Light", "Purple", "Neon"
    Transparency = 0.85, -- 0.0 - 1.0
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
    AimbotToggleMode = true,
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
    ESPColor = Color3.fromRGB(255, 255, 255),
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
local aimbotToggleActive = false

-- Круглая кнопка для аимбота
local AimbotButton = {
    Button = nil,
    Gui = nil,
    IsDragging = false,
    DragStart = nil,
    StartPosition = nil
}

-- Создание FOV круга
local function CreateFOVCircle()
    local success, circle = pcall(function()
        local drawing = Drawing.new("Circle")
        drawing.Visible = false
        drawing.Color = Color3.fromRGB(255, 0, 0)
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
            Duration = 5,
            Image = 4483362458
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
    part.Color = Color3.fromRGB(138, 43, 226)
    part.Transparency = 0.3
    
    local glow = part:FindFirstChild("ChamsGlow") or Instance.new("SurfaceLight")
    glow.Name = "ChamsGlow"
    glow.Color = Color3.fromRGB(138, 43, 226)
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

-- Функция для применения темы и прозрачности к Rayfield
local function ApplyThemeAndTransparency()
    local theme = Config.Theme
    local transparency = Config.Transparency
    
    -- Настройка цветов в зависимости от темы
    local colors = {}
    if theme == "Dark" then
        colors = {
            Background = Color3.fromRGB(20, 20, 30),
            Background2 = Color3.fromRGB(30, 30, 45),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(100, 100, 255),
            Accent2 = Color3.fromRGB(80, 80, 200),
            Border = Color3.fromRGB(60, 60, 80)
        }
    elseif theme == "Light" then
        colors = {
            Background = Color3.fromRGB(240, 240, 250),
            Background2 = Color3.fromRGB(220, 220, 235),
            Text = Color3.fromRGB(0, 0, 0),
            Accent = Color3.fromRGB(80, 80, 200),
            Accent2 = Color3.fromRGB(60, 60, 150),
            Border = Color3.fromRGB(180, 180, 200)
        }
    elseif theme == "Purple" then
        colors = {
            Background = Color3.fromRGB(25, 10, 40),
            Background2 = Color3.fromRGB(40, 15, 60),
            Text = Color3.fromRGB(220, 180, 255),
            Accent = Color3.fromRGB(180, 80, 255),
            Accent2 = Color3.fromRGB(150, 50, 220),
            Border = Color3.fromRGB(100, 40, 150)
        }
    elseif theme == "Neon" then
        colors = {
            Background = Color3.fromRGB(10, 10, 15),
            Background2 = Color3.fromRGB(20, 20, 30),
            Text = Color3.fromRGB(0, 255, 200),
            Accent = Color3.fromRGB(0, 255, 200),
            Accent2 = Color3.fromRGB(0, 200, 150),
            Border = Color3.fromRGB(0, 100, 80)
        }
    end
    
    -- Применяем прозрачность к основным элементам
    -- Rayfield имеет ограниченную поддержку прозрачности, поэтому работаем с тем, что доступно
    -- Создаем глобальную переменную для хранения стилей
    _G.MixwareTheme = {
        Colors = colors,
        Transparency = transparency
    }
    
    -- Применяем кастомные стили для элементов интерфейса (если Rayfield поддерживает)
    -- Это не прямое изменение Rayfield, а подход с переопределением через хук
    -- Для полной кастомизации Rayfield используется метод Rayfield:SetConfiguration()
    
    -- Обновляем уведомления для демонстрации
    Rayfield:Notify({
        Title = "MIXWARE",
        Content = string.format("Тема: %s | Прозрачность: %.0f%%", theme, transparency * 100),
        Duration = 3,
        Image = 4483362458
    })
end

-- Создание окна Rayfield с брендингом MIXWARE и кастомизацией
local Window = Rayfield:CreateWindow({
    Name = "💜 MIXWARE.LOL [kt471 | Lmrbro]",
    LoadingTitle = "MIXWARE LOADING...",
    LoadingSubtitle = "Created by kt471 & Lmrbro",
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

-- Создаем функцию для кнопки аимбота
function AimbotButton:Create()
    if self.Gui then
        self.Gui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MixwareAimbotButton"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local button = Instance.new("Frame")
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.8, 0, 0.7, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    button.BorderSizePixel = 0
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = button
    
    local buttonText = Instance.new("TextButton")
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = "AIM"
    buttonText.TextColor3 = Color3.new(1, 1, 1)
    buttonText.Font = Enum.Font.SourceSansBold
    buttonText.TextSize = 16
    buttonText.TextScaled = true
    buttonText.Parent = button
    
    local function updateInput(input)
        local delta = input.Position - self.DragStart
        local newPosition = UDim2.new(
            self.StartPosition.X.Scale, 
            self.StartPosition.X.Offset + delta.X,
            self.StartPosition.Y.Scale, 
            self.StartPosition.Y.Offset + delta.Y
        )
        button.Position = newPosition
    end

    buttonText.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        if Config.AimbotEnabled and Config.AimbotToggleMode then
            aimbotToggleActive = true
            CurrentTarget = FindTarget()
            if CurrentTarget then
                Rayfield:Notify({
                    Title = "MIXWARE AIMBOT",
                    Content = "АКТИВЕН - Цель: " .. CurrentTarget.Name,
                    Duration = 1,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "MIXWARE AIMBOT",
                    Content = "Цель не найдена",
                    Duration = 1,
                    Image = 4483362458
                })
                aimbotToggleActive = false
            end
        end
        
        self.IsDragging = true
        self.DragStart = Vector2.new(buttonText.AbsolutePosition.X, buttonText.AbsolutePosition.Y)
        self.StartPosition = button.Position
        
        local connection
        connection = buttonText.MouseButton1Up:Connect(function()
            self.IsDragging = false
            button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            if Config.AimbotEnabled and Config.AimbotToggleMode then
                aimbotToggleActive = false
            end
            connection:Disconnect()
        end)
    end)

    buttonText.MouseMoved:Connect(function()
        if self.IsDragging then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local newPosition = UDim2.new(
                0, mouse.X - 40,
                0, mouse.Y - 40
            )
            button.Position = newPosition
        end
    end)

    button.Parent = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    self.Button = button
    self.Gui = screenGui
    self.Label = buttonText
    
    self:UpdateAppearance()
    
    Rayfield:Notify({
        Title = "MIXWARE",
        Content = "Кнопка AIM создана! Перетащите для перемещения",
        Duration = 3,
        Image = 4483362458
    })
end

function AimbotButton:UpdateAppearance()
    if not self.Button or not self.Label then return end
    
    if Config.AimbotEnabled then
        if aimbotToggleActive then
            self.Button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            self.Label.Text = "✓"
        else
            self.Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            self.Label.Text = "AIM"
        end
        self.Button.Visible = true
    else
        self.Button.Visible = false
    end
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

-- СОЗДАНИЕ ВКЛАДОК
local MovementTab = Window:CreateTab("🚀 Движение", 4483362458)
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)
local CombatTab = Window:CreateTab("🎯 Бой", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки", 4483362458)
local ScriptTab = Window:CreateTab("📜 Скрипты", 4483362458)
local ThemeTab = Window:CreateTab("🎨 Оформление", 4483362458) -- НОВАЯ ВКЛАДКА

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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен",
                Duration = 2,
                Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
                Duration = 2,
                Image = 4483362458
            })
        else
            disableChams()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Chams выключены",
                Duration = 2,
                Image = 4483362458
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
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableWallhack()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "X-Ray выключен",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

-- ВКЛАДКА БОЙ
CombatTab:CreateSection("Основные настройки аимбота")
local AimbotToggle = CombatTab:CreateToggle({
    Name = "🎯 Аимбот",
    CurrentValue = Config.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.AimbotEnabled = Value
        AimbotButton:UpdateAppearance()
        
        if fovCircle then
            fovCircle.Visible = Value
        end
        
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Аимбот включен" or "Аимбот выключен",
            Duration = 2,
            Image = 4483362458
        })
    end,
})
local AimbotModeToggle = CombatTab:CreateToggle({
    Name = "🔘 Режим кнопки аимбота",
    CurrentValue = Config.AimbotToggleMode,
    Flag = "AimbotModeToggle",
    Callback = function(Value)
        Config.AimbotToggleMode = Value
        if Value then
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Режим кнопки: ВКЛ (удерживай AIM)",
                Duration = 3,
                Image = 4483362458
            })
        else
            aimbotToggleActive = false
            AimbotButton:UpdateAppearance()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Режим кнопки: ВЫКЛ",
                Duration = 2,
                Image = 4483362458
            })
        end
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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

CombatTab:CreateSection("Кнопка управления")
local CreateAimbotButton = CombatTab:CreateButton({
    Name = "🔄 Создать кнопку AIM",
    Callback = function()
        AimbotButton:Create()
    end,
})
local DebugAimbotButton = CombatTab:CreateButton({
    Name = "🐛 Отладка аимбота",
    Callback = function()
        local target = FindTarget()
        if target then
            Rayfield:Notify({
                Title = "MIXWARE DEBUG",
                Content = "Цель: " .. target.Name .. "\nFOV: " .. Config.AimbotFOV,
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "MIXWARE DEBUG",
                Content = "Цель не найдена!\nПроверьте FOV и наличие игроков",
                Duration = 5,
                Image = 4483362458
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
            Duration = 3,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
            Duration = 2,
            Image = 4483362458
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
                Duration = 2,
                Image = 4483362458
            })
            wait(1)
        end
    end
})

-- НОВАЯ ВКЛАДКА: ОФОРМЛЕНИЕ
ThemeTab:CreateSection("Настройки темы")
local ThemeDropdown = ThemeTab:CreateDropdown({
    Name = "🎨 Выбор темы",
    Options = {"Dark", "Light", "Purple", "Neon"},
    CurrentOption = Config.Theme,
    Flag = "ThemeDropdown",
    Callback = function(Option)
        Config.Theme = Option
        ApplyThemeAndTransparency()
        Rayfield:Notify({
            Title = "MIXWARE THEME",
            Content = "Тема: " .. Option,
            Duration = 2,
            Image = 4483362458
        })
    end,
})

local TransparencySlider = ThemeTab:CreateSlider({
    Name = "🔲 Прозрачность интерфейса",
    Range = {0.3, 1.0},
    Increment = 0.05,
    Suffix = "%",
    CurrentValue = Config.Transparency,
    Flag = "TransparencySlider",
    Callback = function(Value)
        Config.Transparency = Value
        ApplyThemeAndTransparency()
    end,
})

-- Создаем кнопку аимбота и FOV круг
task.spawn(function()
    wait(2)
    AimbotButton:Create()
    fovCircle = CreateFOVCircle()
    ApplyThemeAndTransparency() -- Применяем начальную тему
end)

-- Обработчики ввода
UserInputService.InputBegan:Connect(function(input)
    -- NoClip по N
    if input.KeyCode == Enum.KeyCode.N then
        Config.NoClipEnabled = not Config.NoClipEnabled
        NoClipToggle:Set(Config.NoClipEnabled)
        if Config.NoClipEnabled then
            EnableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip включен (N)",
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "NoClip выключен (N)",
                Duration = 2,
                Image = 4483362458
            })
        end
    end
    
    -- Открытие/закрытие меню по K
    if input.KeyCode == Config.MenuKey then
        Rayfield:SetVisibility(not Rayfield.Visible)
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

    -- Аимбот
    if Config.AimbotEnabled and Config.AimbotToggleMode and aimbotToggleActive then
        local success = AimAtTarget()
        if not success and CurrentTarget then
            CurrentTarget = nil
            aimbotToggleActive = false
            AimbotButton:UpdateAppearance()
            Rayfield:Notify({
                Title = "MIXWARE AIMBOT",
                Content = "Цель потеряна - выключен",
                Duration = 2,
                Image = 4483362458
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

-- Финальные уведомления
task.spawn(function()
    wait(2)
    Rayfield:Notify({
        Title = "💜 MIXWARE.LOL",
        Content = "Загружено! kt471 & Lmrbro",
        Duration = 5,
        Image = 4483362458
    })
    Rayfield:Notify({
        Title = "🎮 Управление",
        Content = "K - меню | N - NoClip | AIM - аимбот",
        Duration = 5,
        Image = 4483362458
    })
end)
