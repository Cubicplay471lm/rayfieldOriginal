--[[
    ███╗   ███╗██╗██╗  ██╗██╗    ██╗ █████╗ ██████╗ ███████╗
    ████╗ ████║██║╚██╗██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝
    ██╔████╔██║██║ ╚███╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  
    ██║╚██╔╝██║██║ ██╔██╗ ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ██║ ╚═╝ ██║██║██╔╝ ██╗╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
    
    MIXWARE.LOL - Ultimate Roblox Script
    Created by: kt471 & Lmrbro
    Version: 7.0.0 - INVENTORY TABLE FOR ENEMIES
--]]

-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- ============ ESP БИБЛИОТЕКА С ИНВЕНТАРНЫМИ ТАБЛИЦАМИ ============
-- ============================================================
local MixwareESP = {}
MixwareESP.__index = MixwareESP

function MixwareESP.new()
    local self = setmetatable({}, MixwareESP)
    
    -- Настройки ESP
    self.Enabled = false
    self.ShowBoxes = false
    self.ShowNames = false
    self.ShowHealth = false
    self.ShowDistance = false
    self.ShowTracers = false
    self.ShowHeadDots = false
    self.ShowSkeletons = false
    self.ShowInventory = false
    self.Color = Color3.fromRGB(180, 80, 255)
    self.MaxDistance = 500
    self.TeamCheck = false
    
    -- Хранилище объектов
    self.Objects = {}
    self.InventoryTables = {} -- Таблицы для каждого игрока
    
    -- Позиция трассера
    self.TracerPosition = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y - 135
    )
    
    return self
end

-- ============ ПОЛУЧЕНИЕ ИНВЕНТАРЯ ИГРОКА ============
function MixwareESP:GetPlayerInventory(Player)
    local Inventory = {}
    local Character = Player.Character
    
    if not Character then return Inventory end
    
    -- Проверяем все инструменты в руках
    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool then
        table.insert(Inventory, {
            Name = Tool.Name,
            Icon = "🔫",
            Active = true,
            Type = "Weapon"
        })
    end
    
    -- Проверяем Backpack
    if Player:FindFirstChild("Backpack") then
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                -- Пропускаем если уже в руках
                if not Tool or item ~= Tool then
                    table.insert(Inventory, {
                        Name = item.Name,
                        Icon = "📦",
                        Active = false,
                        Type = "Item"
                    })
                end
            end
        end
    end
    
    -- Проверяем другие части тела (аксессуары, броня и т.д.)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("Accessory") or part:IsA("Clothing") then
            table.insert(Inventory, {
                Name = part.Name,
                Icon = "👕",
                Active = true,
                Type = "Accessory"
            })
        end
    end
    
    return Inventory
end

-- ============ СОЗДАНИЕ ИНВЕНТАРНОЙ ТАБЛИЦЫ ============
function MixwareESP:CreateInventoryTable(Player, ScreenPos)
    -- Удаляем старую таблицу для этого игрока
    self:DestroyInventoryTable(Player)
    
    local InventoryItems = self:GetPlayerInventory(Player)
    if #InventoryItems == 0 then 
        -- Если инвентарь пуст, показываем сообщение
        InventoryItems = {{Name = "Empty Inventory", Icon = "📭", Active = false}}
    end
    
    local TableWidth = 220
    local RowHeight = 22
    local Padding = 8
    local Rows = #InventoryItems + 1 -- +1 для заголовка
    local TableHeight = Rows * RowHeight + Padding * 2
    
    -- Позиция таблицы (рядом с игроком)
    local TablePos = Vector2.new(
        ScreenPos.X + 10, -- Смещаем вправо от игрока
        ScreenPos.Y - TableHeight / 2 - 20 -- Центрируем по вертикали
    )
    
    -- Ограничиваем позицию, чтобы таблица не выходила за экран
    TablePos = Vector2.new(
        math.clamp(TablePos.X, 10, Camera.ViewportSize.X - TableWidth - 10),
        math.clamp(TablePos.Y, 10, Camera.ViewportSize.Y - TableHeight - 10)
    )
    
    local TableObjects = {}
    
    -- Основной фон
    local Background = Drawing.new("Square")
    Background.Visible = self.ShowInventory
    Background.Filled = true
    Background.Color = Color3.fromRGB(15, 15, 25)
    Background.Transparency = 0.9
    Background.Thickness = 0
    Background.Position = TablePos
    Background.Size = Vector2.new(TableWidth, TableHeight)
    TableObjects.Background = Background
    
    -- Рамка
    local Border = Drawing.new("Square")
    Border.Visible = self.ShowInventory
    Border.Filled = false
    Border.Color = self.Color
    Border.Thickness = 2
    Border.Transparency = 1
    Border.Position = TablePos
    Border.Size = Vector2.new(TableWidth, TableHeight)
    TableObjects.Border = Border
    
    -- Заголовок
    local Title = Drawing.new("Text")
    Title.Visible = self.ShowInventory
    Title.Text = "🎒 " .. Player.Name
    Title.Color = self.Color
    Title.Size = 15
    Title.Center = true
    Title.Outline = true
    Title.OutlineColor = Color3.fromRGB(0, 0, 0)
    Title.Position = Vector2.new(
        TablePos.X + TableWidth / 2,
        TablePos.Y + 5
    )
    TableObjects.Title = Title
    
    -- Разделительная линия под заголовком
    local Divider = Drawing.new("Line")
    Divider.Visible = self.ShowInventory
    Divider.Color = self.Color
    Divider.Thickness = 1
    Divider.Transparency = 0.5
    Divider.From = Vector2.new(TablePos.X + 10, TablePos.Y + RowHeight + 2)
    Divider.To = Vector2.new(TablePos.X + TableWidth - 10, TablePos.Y + RowHeight + 2)
    TableObjects.Divider = Divider
    
    -- Строки с предметами
    local RowObjects = {}
    for i, item in ipairs(InventoryItems) do
        local Y = TablePos.Y + Padding + i * RowHeight
        
        -- Иконка предмета
        local Icon = Drawing.new("Text")
        Icon.Visible = self.ShowInventory
        Icon.Text = item.Icon or "📦"
        Icon.Color = Color3.fromRGB(255, 255, 255)
        Icon.Size = 13
        Icon.Position = Vector2.new(
            TablePos.X + 8,
            Y
        )
        table.insert(RowObjects, Icon)
        
        -- Название предмета
        local Name = Drawing.new("Text")
        Name.Visible = self.ShowInventory
        Name.Text = item.Name
        Name.Color = item.Active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200)
        Name.Size = 13
        Name.Position = Vector2.new(
            TablePos.X + 30,
            Y
        )
        Name.Outline = true
        Name.OutlineColor = Color3.fromRGB(0, 0, 0)
        table.insert(RowObjects, Name)
        
        -- Индикатор активного предмета
        if item.Active then
            local ActiveTag = Drawing.new("Text")
            ActiveTag.Visible = self.ShowInventory
            ActiveTag.Text = "⚡"
            ActiveTag.Color = Color3.fromRGB(0, 255, 0)
            ActiveTag.Size = 12
            ActiveTag.Position = Vector2.new(
                TablePos.X + TableWidth - 20,
                Y
            )
            table.insert(RowObjects, ActiveTag)
        end
    end
    
    TableObjects.Rows = RowObjects
    
    -- Сохраняем таблицу для игрока
    self.InventoryTables[Player] = {
        Objects = TableObjects,
        Position = TablePos,
        Items = InventoryItems,
        Size = Vector2.new(TableWidth, TableHeight)
    }
end

-- ============ ОБНОВЛЕНИЕ ПОЗИЦИИ ИНВЕНТАРНОЙ ТАБЛИЦЫ ============
function MixwareESP:UpdateInventoryTable(Player, ScreenPos)
    if not self.InventoryTables[Player] then
        self:CreateInventoryTable(Player, ScreenPos)
        return
    end
    
    local Table = self.InventoryTables[Player]
    local TableWidth = Table.Size.X
    local TableHeight = Table.Size.Y
    
    -- Новая позиция
    local NewPos = Vector2.new(
        ScreenPos.X + 10,
        ScreenPos.Y - TableHeight / 2 - 20
    )
    
    -- Ограничиваем позицию
    NewPos = Vector2.new(
        math.clamp(NewPos.X, 10, Camera.ViewportSize.X - TableWidth - 10),
        math.clamp(NewPos.Y, 10, Camera.ViewportSize.Y - TableHeight - 10)
    )
    
    -- Обновляем позиции всех объектов
    local Objects = Table.Objects
    local Offset = NewPos - Table.Position
    
    if Objects.Background then
        Objects.Background.Position = Objects.Background.Position + Offset
    end
    if Objects.Border then
        Objects.Border.Position = Objects.Border.Position + Offset
    end
    if Objects.Title then
        Objects.Title.Position = Objects.Title.Position + Offset
    end
    if Objects.Divider then
        Objects.Divider.From = Objects.Divider.From + Offset
        Objects.Divider.To = Objects.Divider.To + Offset
    end
    
    -- Обновляем строки
    for i, obj in ipairs(Objects.Rows) do
        obj.Position = obj.Position + Offset
    end
    
    Table.Position = NewPos
end

-- ============ СКРЫТИЕ/ПОКАЗ ИНВЕНТАРНОЙ ТАБЛИЦЫ ============
function MixwareESP:ShowInventoryTable(Player, Show)
    if not self.InventoryTables[Player] then return end
    
    local Objects = self.InventoryTables[Player].Objects
    
    if Objects.Background then
        Objects.Background.Visible = Show
    end
    if Objects.Border then
        Objects.Border.Visible = Show
    end
    if Objects.Title then
        Objects.Title.Visible = Show
    end
    if Objects.Divider then
        Objects.Divider.Visible = Show
    end
    for _, obj in ipairs(Objects.Rows) do
        obj.Visible = Show
    end
end

-- ============ УДАЛЕНИЕ ИНВЕНТАРНОЙ ТАБЛИЦЫ ============
function MixwareESP:DestroyInventoryTable(Player)
    if not self.InventoryTables[Player] then return end
    
    local Objects = self.InventoryTables[Player].Objects
    
    if Objects.Background then
        pcall(function() Objects.Background:Remove() end)
    end
    if Objects.Border then
        pcall(function() Objects.Border:Remove() end)
    end
    if Objects.Title then
        pcall(function() Objects.Title:Remove() end)
    end
    if Objects.Divider then
        pcall(function() Objects.Divider:Remove() end)
    end
    for _, obj in ipairs(Objects.Rows) do
        pcall(function() obj:Remove() end)
    end
    
    self.InventoryTables[Player] = nil
end

-- ============ ОЧИСТКА ВСЕХ ТАБЛИЦ ============
function MixwareESP:DestroyAllInventoryTables()
    for Player, _ in pairs(self.InventoryTables) do
        self:DestroyInventoryTable(Player)
    end
    self.InventoryTables = {}
end

-- ============ СОЗДАНИЕ ОБЪЕКТОВ ДЛЯ ИГРОКА ============
function MixwareESP:CreatePlayerObjects(Player)
    if self.Objects[Player] then return end
    
    local Objects = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        TracerOutline = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
        Skeleton = {
            Head = Drawing.new("Line"),
            Torso = Drawing.new("Line"),
            LeftArm = Drawing.new("Line"),
            RightArm = Drawing.new("Line"),
            LeftLeg = Drawing.new("Line"),
            RightLeg = Drawing.new("Line")
        }
    }
    
    -- Настройка бокса
    Objects.Box.Thickness = 2
    Objects.Box.Filled = false
    Objects.Box.Color = self.Color
    Objects.Box.Visible = false
    Objects.Box.Transparency = 1
    
    Objects.BoxOutline.Thickness = 1
    Objects.BoxOutline.Filled = false
    Objects.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    Objects.BoxOutline.Visible = false
    Objects.BoxOutline.Transparency = 0.5
    
    -- Настройка имени
    Objects.Name.Size = 16
    Objects.Name.Center = true
    Objects.Name.Outline = true
    Objects.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    Objects.Name.Color = self.Color
    Objects.Name.Visible = false
    Objects.Name.Transparency = 1
    
    -- Настройка здоровья
    Objects.Health.Size = 14
    Objects.Health.Center = true
    Objects.Health.Outline = true
    Objects.Health.OutlineColor = Color3.fromRGB(0, 0, 0)
    Objects.Health.Color = Color3.fromRGB(255, 255, 255)
    Objects.Health.Visible = false
    Objects.Health.Transparency = 1
    
    -- Настройка дистанции
    Objects.Distance.Size = 14
    Objects.Distance.Center = true
    Objects.Distance.Outline = true
    Objects.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    Objects.Distance.Color = Color3.fromRGB(200, 200, 200)
    Objects.Distance.Visible = false
    Objects.Distance.Transparency = 1
    
    -- Настройка трассера
    Objects.Tracer.Thickness = 2
    Objects.Tracer.Color = self.Color
    Objects.Tracer.Visible = false
    Objects.Tracer.Transparency = 0.7
    
    Objects.TracerOutline.Thickness = 4
    Objects.TracerOutline.Color = Color3.fromRGB(0, 0, 0)
    Objects.TracerOutline.Visible = false
    Objects.TracerOutline.Transparency = 0.3
    
    -- Настройка точки на голове
    Objects.HeadDot.Radius = 4
    Objects.HeadDot.Filled = true
    Objects.HeadDot.NumSides = 20
    Objects.HeadDot.Color = self.Color
    Objects.HeadDot.Visible = false
    Objects.HeadDot.Transparency = 1
    
    -- Настройка скелета
    for _, line in pairs(Objects.Skeleton) do
        line.Thickness = 2
        line.Color = self.Color
        line.Visible = false
        line.Transparency = 0.8
    end
    
    self.Objects[Player] = Objects
end

-- ============ УДАЛЕНИЕ ОБЪЕКТОВ ============
function MixwareESP:RemovePlayerObjects(Player)
    if self.Objects[Player] then
        local Objects = self.Objects[Player]
        pcall(function() Objects.Box:Remove() end)
        pcall(function() Objects.BoxOutline:Remove() end)
        pcall(function() Objects.Name:Remove() end)
        pcall(function() Objects.Health:Remove() end)
        pcall(function() Objects.Distance:Remove() end)
        pcall(function() Objects.Tracer:Remove() end)
        pcall(function() Objects.TracerOutline:Remove() end)
        pcall(function() Objects.HeadDot:Remove() end)
        for _, line in pairs(Objects.Skeleton) do
            pcall(function() line:Remove() end)
        end
        self.Objects[Player] = nil
    end
    
    -- Удаляем инвентарную таблицу
    self:DestroyInventoryTable(Player)
end

-- ============ ОБНОВЛЕНИЕ ESP ============
function MixwareESP:Update()
    if not self.Enabled then
        -- Скрываем всё
        for Player, Objects in pairs(self.Objects) do
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
        end
        -- Скрываем все инвентарные таблицы
        for Player, _ in pairs(self.InventoryTables) do
            self:ShowInventoryTable(Player, false)
        end
        return
    end
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then 
            -- Скрываем ESP для себя
            if self.Objects[Player] then
                local Objects = self.Objects[Player]
                Objects.Box.Visible = false
                Objects.BoxOutline.Visible = false
                Objects.Name.Visible = false
                Objects.Health.Visible = false
                Objects.Distance.Visible = false
                Objects.Tracer.Visible = false
                Objects.TracerOutline.Visible = false
                Objects.HeadDot.Visible = false
                for _, line in pairs(Objects.Skeleton) do
                    line.Visible = false
                end
            end
            -- Скрываем инвентарную таблицу для себя
            self:DestroyInventoryTable(Player)
            goto continue
        end
        
        -- Создаем объекты если их нет
        self:CreatePlayerObjects(Player)
        local Objects = self.Objects[Player]
        
        local Character = Player.Character
        if not Character then
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
            -- Скрываем инвентарную таблицу
            self:ShowInventoryTable(Player, false)
            goto continue
        end
        
        local Head = Character:FindFirstChild("Head")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        
        if not Head or not Humanoid or not RootPart then
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
            self:ShowInventoryTable(Player, false)
            goto continue
        end
        
        -- Проверка дистанции
        local Distance = (Camera.CFrame.Position - Head.Position).Magnitude
        if Distance > self.MaxDistance then
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
            self:ShowInventoryTable(Player, false)
            goto continue
        end
        
        -- Проверка видимости
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
        if not OnScreen or ScreenPos.Z < 0 then
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
            self:ShowInventoryTable(Player, false)
            goto continue
        end
        
        -- Определяем цвет (команда/враг)
        local Color = self.Color
        if self.TeamCheck and Player.Team == LocalPlayer.Team then
            Color = Color3.fromRGB(0, 255, 0)
        end
        
        -- Обновляем все объекты
        local ScreenX, ScreenY = ScreenPos.X, ScreenPos.Y
        
        -- Бокс
        if self.ShowBoxes then
            local Size = Head.Size.Y * 2.5
            local TopPos = Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, Size/2, 0)).Position)
            local BottomPos = Camera:WorldToViewportPoint((Head.CFrame * CFrame.new(0, -Size/2, 0)).Position)
            local Width = math.abs(TopPos.X - BottomPos.X) / 2
            
            Objects.Box.Visible = true
            Objects.Box.Color = Color
            Objects.Box.Position = Vector2.new(ScreenX - Width, ScreenY - Size/2)
            Objects.Box.Size = Vector2.new(Width * 2, Size)
            
            Objects.BoxOutline.Visible = true
            Objects.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
            Objects.BoxOutline.Position = Objects.Box.Position + Vector2.new(-1, -1)
            Objects.BoxOutline.Size = Objects.Box.Size + Vector2.new(2, 2)
        else
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
        end
        
        -- Имя
        if self.ShowNames then
            Objects.Name.Visible = true
            Objects.Name.Color = Color
            Objects.Name.Text = Player.Name
            Objects.Name.Position = Vector2.new(ScreenX, ScreenY - 60)
        else
            Objects.Name.Visible = false
        end
        
        -- Здоровье
        if self.ShowHealth then
            Objects.Health.Visible = true
            local HealthPercent = Humanoid.Health / Humanoid.MaxHealth * 100
            local HealthColor = HealthPercent > 50 and Color3.fromRGB(0, 255, 0) or 
                              HealthPercent > 25 and Color3.fromRGB(255, 255, 0) or 
                              Color3.fromRGB(255, 0, 0)
            Objects.Health.Color = HealthColor
            Objects.Health.Text = string.format("[%d/%d]", Humanoid.Health, Humanoid.MaxHealth)
            Objects.Health.Position = Vector2.new(ScreenX, ScreenY - 40)
        else
            Objects.Health.Visible = false
        end
        
        -- Дистанция
        if self.ShowDistance then
            Objects.Distance.Visible = true
            Objects.Distance.Text = string.format("[%dm]", math.floor(Distance))
            Objects.Distance.Position = Vector2.new(ScreenX, ScreenY - 25)
        else
            Objects.Distance.Visible = false
        end
        
        -- Трассер
        if self.ShowTracers then
            Objects.Tracer.Visible = true
            Objects.Tracer.Color = Color
            Objects.Tracer.From = self.TracerPosition
            Objects.Tracer.To = Vector2.new(ScreenX, ScreenY)
            
            Objects.TracerOutline.Visible = true
            Objects.TracerOutline.From = self.TracerPosition
            Objects.TracerOutline.To = Vector2.new(ScreenX, ScreenY)
        else
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
        end
        
        -- Точка на голове
        if self.ShowHeadDots then
            Objects.HeadDot.Visible = true
            Objects.HeadDot.Color = Color
            Objects.HeadDot.Position = Vector2.new(ScreenX, ScreenY)
        else
            Objects.HeadDot.Visible = false
        end
        
        -- Скелет
        if self.ShowSkeletons then
            local function GetPartPos(Part)
                if not Part then return nil end
                local Pos, Vis = Camera:WorldToViewportPoint(Part.Position)
                if Vis and Pos.Z > 0 then
                    return Vector2.new(Pos.X, Pos.Y)
                end
                return nil
            end
            
            local HeadPos = GetPartPos(Head)
            local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
            local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftUpperArm")
            local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightUpperArm")
            local LeftLeg = Character:FindFirstChild("Left Leg") or Character:FindFirstChild("LeftLowerLeg")
            local RightLeg = Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightLowerLeg")
            
            local TorsoPos = GetPartPos(Torso)
            local LeftArmPos = GetPartPos(LeftArm)
            local RightArmPos = GetPartPos(RightArm)
            local LeftLegPos = GetPartPos(LeftLeg)
            local RightLegPos = GetPartPos(RightLeg)
            
            local SkeletonLines = {
                {Objects.Skeleton.Head, HeadPos, TorsoPos},
                {Objects.Skeleton.Torso, TorsoPos, RootPart and GetPartPos(RootPart)},
                {Objects.Skeleton.LeftArm, TorsoPos, LeftArmPos},
                {Objects.Skeleton.RightArm, TorsoPos, RightArmPos},
                {Objects.Skeleton.LeftLeg, TorsoPos, LeftLegPos},
                {Objects.Skeleton.RightLeg, TorsoPos, RightLegPos}
            }
            
            for _, data in ipairs(SkeletonLines) do
                local Line, From, To = data[1], data[2], data[3]
                if From and To then
                    Line.Visible = true
                    Line.Color = Color
                    Line.From = From
                    Line.To = To
                else
                    Line.Visible = false
                end
            end
        else
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
        end
        
        -- ============ ИНВЕНТАРНАЯ ТАБЛИЦА ============
        if self.ShowInventory then
            -- Создаем или обновляем таблицу
            if not self.InventoryTables[Player] then
                self:CreateInventoryTable(Player, Vector2.new(ScreenX, ScreenY))
            else
                self:UpdateInventoryTable(Player, Vector2.new(ScreenX, ScreenY))
            end
            self:ShowInventoryTable(Player, true)
        else
            self:ShowInventoryTable(Player, false)
        end
        
        ::continue::
    end
end

-- ============ НАСТРОЙКИ ESP ============
function MixwareESP:SetEnabled(Enabled)
    self.Enabled = Enabled
    if not Enabled then
        self:DestroyAllInventoryTables()
    end
end

function MixwareESP:SetColor(Color)
    self.Color = Color
end

function MixwareESP:SetMaxDistance(Distance)
    self.MaxDistance = Distance
end

function MixwareESP:ToggleBoxes(Show)
    self.ShowBoxes = Show
end

function MixwareESP:ToggleNames(Show)
    self.ShowNames = Show
end

function MixwareESP:ToggleHealth(Show)
    self.ShowHealth = Show
end

function MixwareESP:ToggleDistance(Show)
    self.ShowDistance = Show
end

function MixwareESP:ToggleTracers(Show)
    self.ShowTracers = Show
end

function MixwareESP:ToggleHeadDots(Show)
    self.ShowHeadDots = Show
end

function MixwareESP:ToggleSkeletons(Show)
    self.ShowSkeletons = Show
end

function MixwareESP:ToggleInventory(Show)
    self.ShowInventory = Show
    if not Show then
        self:DestroyAllInventoryTables()
    end
end

function MixwareESP:ToggleTeamCheck(Show)
    self.TeamCheck = Show
end

-- ============================================================
-- ============ СОЗДАНИЕ ESP ОБЪЕКТА ============
-- ============================================================
local ESP = MixwareESP.new()

-- ============================================================
-- ============ АИМБОТ БИБЛИОТЕКА ============
-- ============================================================
local AimbotLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Aimbot/Aimbot"))()
local Aimbot = AimbotLibrary.new()

-- ============================================================
-- ============ КОНФИГУРАЦИЯ ============
-- ============================================================
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

-- ============================================================
-- ============ ТЕМА MIXWARE ============
-- ============================================================
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

-- ============================================================
-- ============ НАСТРОЙКА АИМБОТА ============
-- ============================================================
Aimbot:SetSmoothness(Config.AimbotSmoothness)
Aimbot:SetFOV(Config.AimbotFOV)
Aimbot:SetPriority(Config.AimbotPriority)
Aimbot:SetTeamCheck(Config.AimbotTeamCheck)
Aimbot:SetVisibleCheck(Config.AimbotVisibleCheck)
Aimbot:SetLockPart(Config.AimbotLockPart)
Aimbot:SetEnabled(Config.AimbotEnabled)

-- ============================================================
-- ============ СОЗДАНИЕ ОКНА ============
-- ============================================================
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

-- ============================================================
-- ============ СОЗДАНИЕ ВКЛАДОК ============
-- ============================================================
local MovementTab = Window:CreateTab("🚀 Движение", 4483362458)
local VisualTab = Window:CreateTab("👁️ Визуал", 4483362458)
local CombatTab = Window:CreateTab("🎯 Бой", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Настройки", 4483362458)
local ScriptTab = Window:CreateTab("📜 Скрипты", 4483362458)
local ThemeTab = Window:CreateTab("🎨 Оформление", 4483362458)

-- ============================================================
-- ============ ВКЛАДКА ДВИЖЕНИЕ ============
-- ============================================================
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

-- ============================================================
-- ============ ВКЛАДКА ВИЗУАЛ ============
-- ============================================================
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
    Name = "🎒 Инвентарь (таблица рядом с игроком)",
    CurrentValue = Config.ESPInventory,
    Flag = "ESPInventory",
    Callback = function(Value)
        Config.ESPInventory = Value
        ESP:ToggleInventory(Value)
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = Value and "Инвентарь включен (показывает предметы рядом с игроком)" or "Инвентарь выключен",
            Duration = 3
        })
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

-- ============================================================
-- ============ ВКЛАДКА БОЙ ============
-- ============================================================
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

-- ============================================================
-- ============ ВКЛАДКА СКРИПТЫ ============
-- ============================================================
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

-- ============================================================
-- ============ ВКЛАДКА НАСТРОЙКИ ============
-- ============================================================
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

-- ============================================================
-- ============ ВКЛАДКА ОФОРМЛЕНИЕ ============
-- ============================================================
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

-- ============================================================
-- ============ ОБРАБОТЧИКИ КЛАВИШ ============
-- ============================================================
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

-- ============================================================
-- ============ ОСНОВНОЙ ЦИКЛ ============
-- ============================================================
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

-- ============================================================
-- ============ ЗАПУСК ============
-- ============================================================
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
