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

-- Настройки
local Config = {
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

-- Сохраняем оригинальный FOV камеры
Config.OriginalCameraFOV = Camera.FieldOfView

-- Переменные для Chams
local chamsParts = {}

-- Переменные для аимбота
local CurrentTarget = nil
local isAiming = false
local fovCircle
local aimbotToggleActive = false

-- Переменная для FOV круга
local fovCircle = nil

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
            Title = "Ошибка",
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

-- Создание окна Rayfield с ключ-системой
local Window = Rayfield:CreateWindow({
    Name = "🎯 Advanced Hack Menu",
    LoadingTitle = "Advanced Hack Interface",
    LoadingSubtitle = "Aimbot & ESP Features",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AdvancedHackConfig",
        FileName = "AdvancedHackSettings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Advanced Hack Auth",
        Subtitle = "Key System",
        Note = "Get key from Discord",
        FileName = "AdvancedHackKey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {"Admin12", "SaBplyr67", "MCplyr64", "11Li-20_dA"} --M*Xx-D*_xX
    }
})

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

-- Создаем круглую кнопку для аимбота
function AimbotButton:Create()
    -- Удаляем старую кнопку если существует
    if self.Gui then
        self.Gui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotButton"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local button = Instance.new("Frame")
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = UDim2.new(0.8, 0, 0.7, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    button.BorderSizePixel = 0
    
    -- Делаем кнопку круглой
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
    
    -- Функционал перемещения
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

    -- Обработка нажатия
    buttonText.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        if Config.AimbotEnabled and Config.AimbotToggleMode then
            aimbotToggleActive = true
            CurrentTarget = FindTarget()
            if CurrentTarget then
                Rayfield:Notify({
                    Title = "Аимбот",
                    Content = "АКТИВЕН - Цель: " .. CurrentTarget.Name,
                    Duration = 1,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({
                    Title = "Аимбот",
                    Content = "Цель не найдена",
                    Duration = 1,
                    Image = 4483362458
                })
                aimbotToggleActive = false
            end
        end
        
        -- Начинаем перемещение
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

    -- Перемещение кнопки
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
        Title = "Кнопка AIM",
        Content = "Создана! Перетащите для перемещения",
        Duration = 3,
        Image = 4483362458
    })
end

function AimbotButton:UpdateAppearance()
    if not self.Button or not self.Label then return end
    
    if Config.AimbotEnabled then
        if aimbotToggleActive then
            self.Button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            self.Label.Text = "AIM ✓"
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
    -- Если текущая цель недействительна или потеряна, ищем новую
    if not CurrentTarget or not CurrentTarget.Character or CurrentTarget.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
        CurrentTarget = FindTarget()
        if not CurrentTarget then 
            return false -- Не удалось найти новую цель
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
    -- Проверяем, что цель находится на экране и не за камерой
    if not onScreen or screenPos.Z < 0 or (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude > Config.AimbotFOV then
        CurrentTarget = nil
        return false
    end

    local mousePos = UserInputService:GetMouseLocation() -- Получаем текущую позицию мыши
    local targetPos = Vector2.new(screenPos.X, screenPos.Y)

    -- Увеличиваем плавность, чтобы не было слишком резких движений
    local delta = (targetPos - mousePos) * Config.AimbotSmoothness * 0.5 -- Дополнительное уменьшение для большей плавности

    -- Используем наиболее надежный метод перемещения мыши напрямую
    -- mousemoverel обычно наиболее эффективен для внешних скриптов.
    local success = pcall(function()
        mousemoverel(delta.X, delta.Y)
    end)
    
    return success
end

-- Улучшенная функция триггербота
local function TriggerbotCheck()
    if not Config.Triggerbot then return end
    
    local target = FindTarget()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and screenPos.Z > 0 then
                -- Автоматически нажимаем левую кнопку мыши
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

-- Функция для обновления ESP при изменении настроек
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

-- Создаем вкладки
local MovementTab = Window:CreateTab("🚀 Движение", 4483362458)
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)
local CombatTab = Window:CreateTab("🎯 Бой", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки", 4483362458)

-- Вкладка Движение
MovementTab:CreateSection("Скорость")

local SpeedToggle = MovementTab:CreateToggle({
    Name = "⚡ Скорость",
    CurrentValue = Config.SpeedEnabled,
    Flag = "SpeedToggle",
    Callback = function(Value)
        Config.SpeedEnabled = Value
        Rayfield:Notify({
            Title = "Скорость",
            Content = Value and "Включено: " .. Config.SpeedValue or "Выключено",
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
            Title = "Прыжок",
            Content = Value and "Включено: " .. Config.JumpPowerValue or "Выключено",
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
                Title = "NoClip",
                Content = "Включено",
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "NoClip",
                Content = "Выключено",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

-- Вкладка Визуал
VisualTab:CreateSection("Типы ESP")

local ESPDropdown = VisualTab:CreateDropdown({
    Name = "🎯 Типы ESP (множественный выбор)",
    Options = {"📦 Боксы", "🏷️ Имена", "❤️ Здоровье", "📏 Дистанция", "🔺 Трейсеры", "💀 Скелетоны"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ESPDropdown",
    Callback = function(SelectedOptions)
        -- Обновляем настройки ESP
        Config.ESPTypes.Box = table.find(SelectedOptions, "📦 Боксы") ~= nil
        Config.ESPTypes.Name = table.find(SelectedOptions, "🏷️ Имена") ~= nil
        Config.ESPTypes.Health = table.find(SelectedOptions, "❤️ Здоровье") ~= nil
        Config.ESPTypes.Distance = table.find(SelectedOptions, "📏 Дистанция") ~= nil
        Config.ESPTypes.Tracer = table.find(SelectedOptions, "🔺 Трейсеры") ~= nil
        Config.ESPTypes.Skeleton = table.find(SelectedOptions, "💀 Скелетоны") ~= nil
        
        UpdateESP()
        
        Rayfield:Notify({
            Title = "ESP",
            Content = "Настройки ESP обновлены",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- Быстрые пресеты ESP
VisualTab:CreateSection("Быстрые пресеты ESP")

local FullESPPreset = VisualTab:CreateButton({
    Name = "🎯 Полный ESP",
    Callback = function()
        ESPDropdown:Set({"📦 Боксы", "🏷️ Имена", "❤️ Здоровье", "📏 Дистанция", "🔺 Трейсеры", "💀 Скелетоны"})
        Rayfield:Notify({
            Title = "ESP Пресет",
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
            Title = "ESP Пресет",
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
            Title = "ESP Пресет",
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
            Title = "ESP Пресет",
            Content = "ESP отключен",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- Настройки цвета ESP
VisualTab:CreateSection("Настройки цвета ESP")

local ESPColorPicker = VisualTab:CreateColorPicker({
    Name = "🎨 Цвет ESP",
    Color = Config.ESPColor,
    Flag = "ESPColor",
    Callback = function(Color)
        Config.ESPColor = Color
        ESP.Color = Color
        Rayfield:Notify({
            Title = "ESP Цвет",
            Content = "Цвет ESP изменен",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- Дополнительные настройки ESP
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
            Title = "ESP Дистанция",
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
            Title = "ESP",
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
            Title = "FOV камеры",
            Content = "Установлено: " .. Value .. "°",
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
            Title = "FOV камеры",
            Content = "Сброшено до стандартного значения",
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
                Title = "Chams",
                Content = "Включено - фиолетовое свечение",
                Duration = 2,
                Image = 4483362458
            })
        else
            disableChams()
            Rayfield:Notify({
                Title = "Chams",
                Content = "Выключено",
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
                Title = "X-Ray",
                Content = "Включено",
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableWallhack()
            Rayfield:Notify({
                Title = "X-Ray",
                Content = "Выключено",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

-- Вкладка Бой
CombatTab:CreateSection("Основные настройки аимбота")

local AimbotToggle = CombatTab:CreateToggle({
    Name = "🎯 Аимбот",
    CurrentValue = Config.AimbotEnabled,
    Flag = "AimbotToggle",
    Callback = function(Value)
        Config.AimbotEnabled = Value
        AimbotButton:UpdateAppearance()
        
        -- Обновляем FOV круг
        if fovCircle then
            fovCircle.Visible = Value
        end
        
        Rayfield:Notify({
            Title = "Аимбот",
            Content = Value and "Включено (Кнопка AIM)" or "Выключено",
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
                Title = "Аимбот",
                Content = "Режим кнопки: ВКЛ (Нажми и удерживай кнопку AIM)",
                Duration = 3,
                Image = 4483362458
            })
        else
            aimbotToggleActive = false
            AimbotButton:UpdateAppearance()
            Rayfield:Notify({
                Title = "Аимбот",
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
            Title = "FOV",
            Content = "Установлено: " .. Value,
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
            Title = "Триггербот",
            Content = Value and "Включено" or "Выключено",
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

-- Функция для отладки аимбота
local DebugAimbotButton = CombatTab:CreateButton({
    Name = "🐛 Отладка аимбота",
    Callback = function()
        local target = FindTarget()
        if target then
            Rayfield:Notify({
                Title = "Отладка аимбота",
                Content = "Цель найдена: " .. target.Name .. "\nFOV: " .. Config.AimbotFOV,
                Duration = 5,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Отладка аимбота",
                Content = "Цель не найдена!\nПроверьте FOV и наличие игроков",
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

-- Вкладка Настройки
SettingsTab:CreateSection("Управление меню")

local HideMenuButton = SettingsTab:CreateButton({
    Name = "👁️ Скрыть меню (K)",
    Callback = function()
        Rayfield:SetVisibility(false)
        Rayfield:Notify({
            Title = "Меню",
            Content = "Скрыто. Нажми K чтобы показать",
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
            Title = "Меню",
            Content = "Показано",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

ScriptTab:CreateSection("Скрипты")

local 99n = ScriptTab:CreateButton({
	Name = "99 ночей🏕"
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()
		Rayfield:Notify({
			Title = "Скрипт запущен",
			Duration = 2
		})
	end
})

local mm2 = ScriptTab:CreateButton({
	Name = "MM2👉"
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/vertex-peak/vertex/refs/heads/main/loadstring"))()
		Rayfield:Notify({
			Title = "Скрипт запущен",
			Duration = 2
		})
	end
})

local crash = ScriptTab:CreateButton({
	Name = "Crash"
	Callback = function()
		While true do
			Rayfield:Notify({
				Title = "Скрипт запущен",
				Duration = 2
			})
		end
	end
})

-- Создаем кнопку аимбота и FOV круг автоматически
task.spawn(function()
    wait(2)
    AimbotButton:Create()
    fovCircle = CreateFOVCircle()
end)

-- Обработчики ввода
UserInputService.InputBegan:Connect(function(input)
    -- NoClip
    if input.KeyCode == Enum.KeyCode.N then
        Config.NoClipEnabled = not Config.NoClipEnabled
        NoClipToggle:Set(Config.NoClipEnabled)
        if Config.NoClipEnabled then
            EnableNoClip()
            Rayfield:Notify({
                Title = "NoClip",
                Content = "Включено клавишей N",
                Duration = 2,
                Image = 4483362458
            })
        else
            DisableNoClip()
            Rayfield:Notify({
                Title = "NoClip",
                Content = "Выключено клавишей N",
                Duration = 2,
                Image = 4483362458
            })
        end
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

    -- Аимбот (режим кнопки)
    if Config.AimbotEnabled and Config.AimbotToggleMode and aimbotToggleActive then
        -- Всегда пытаемся наводиться, даже если текущая цель потеряна. AimAtTarget сам найдет новую.
        local success = AimAtTarget()
        if not success and CurrentTarget then -- Если наведение не удалось, но цель все еще есть, значит, она вне FOV или невидима
            CurrentTarget = nil
            aimbotToggleActive = false
            AimbotButton:UpdateAppearance()
            Rayfield:Notify({
                Title = "Аимбот",
                Content = "Цель потеряна или вне FOV - выключен",
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

-- Инициализация ESP библиотеки
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

-- Инициализация
task.spawn(function()
    wait(2)
    Rayfield:Notify({
        Title = "Скрипт загружен",
        Content = "K - меню, N - NoClip, Кнопка AIM - аимбот",
        Duration = 5,
        Image = 4483362458
    })
    Rayfield:Notify({
        Title = "Аимбот",
        Content = "Нажми и удерживай круглую кнопку AIM для прицеливания",
        Duration = 5,
        Image = 4483362458
    })
end)