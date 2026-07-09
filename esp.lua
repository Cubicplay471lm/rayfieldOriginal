--[[
    MIXWARE ESP LIBRARY v2.0
    Created by: kt471 & Lmrbro
    Полноценная ESP система с инвентарем, скелетами и всем остальным
--]]

local MixwareESP = {}
MixwareESP.__index = MixwareESP

-- ============ СОЗДАНИЕ НОВОГО ESP ============
function MixwareESP.new()
    local self = setmetatable({}, MixwareESP)
    
    -- Настройки
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
    self.VisibleCheck = false
    
    -- Хранилище объектов
    self.Objects = {}
    self.Players = {}
    
    -- Позиция трассера
    self.TracerPosition = Vector2.new(
        workspace.CurrentCamera.ViewportSize.X / 2,
        workspace.CurrentCamera.ViewportSize.Y - 135
    )
    
    return self
end

-- ============ СОЗДАНИЕ ОБЪЕКТОВ ДЛЯ ИГРОКА ============
function MixwareESP:CreatePlayerObjects(Player)
    if self.Objects[Player] then return end
    
    local Objects = {
        -- Бокс
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        
        -- Текст
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Inventory = Drawing.new("Text"),
        
        -- Линии
        Tracer = Drawing.new("Line"),
        TracerOutline = Drawing.new("Line"),
        
        -- Точка
        HeadDot = Drawing.new("Circle"),
        
        -- Скелет
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
    
    -- Настройка инвентаря
    Objects.Inventory.Size = 13
    Objects.Inventory.Center = true
    Objects.Inventory.Outline = true
    Objects.Inventory.OutlineColor = Color3.fromRGB(0, 0, 0)
    Objects.Inventory.Color = Color3.fromRGB(255, 200, 100)
    Objects.Inventory.Visible = false
    Objects.Inventory.Transparency = 1
    
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

-- ============ УДАЛЕНИЕ ОБЪЕКТОВ ДЛЯ ИГРОКА ============
function MixwareESP:RemovePlayerObjects(Player)
    if self.Objects[Player] then
        local Objects = self.Objects[Player]
        
        -- Удаляем все объекты
        pcall(function() Objects.Box:Remove() end)
        pcall(function() Objects.BoxOutline:Remove() end)
        pcall(function() Objects.Name:Remove() end)
        pcall(function() Objects.Health:Remove() end)
        pcall(function() Objects.Distance:Remove() end)
        pcall(function() Objects.Inventory:Remove() end)
        pcall(function() Objects.Tracer:Remove() end)
        pcall(function() Objects.TracerOutline:Remove() end)
        pcall(function() Objects.HeadDot:Remove() end)
        
        for _, line in pairs(Objects.Skeleton) do
            pcall(function() line:Remove() end)
        end
        
        self.Objects[Player] = nil
    end
end

-- ============ ОЧИСТКА ВСЕГО ESP ============
function MixwareESP:ClearAll()
    for Player, Objects in pairs(self.Objects) do
        pcall(function()
            Objects.Box:Remove()
            Objects.BoxOutline:Remove()
            Objects.Name:Remove()
            Objects.Health:Remove()
            Objects.Distance:Remove()
            Objects.Inventory:Remove()
            Objects.Tracer:Remove()
            Objects.TracerOutline:Remove()
            Objects.HeadDot:Remove()
            for _, line in pairs(Objects.Skeleton) do
                line:Remove()
            end
        end)
    end
    self.Objects = {}
end

-- ============ ПОЛУЧЕНИЕ ИНВЕНТАРЯ ИГРОКА ============
function MixwareESP:GetPlayerInventory(Player)
    local Inventory = {}
    
    -- Проверяем Backpack
    if Player:FindFirstChild("Backpack") then
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(Inventory, item.Name)
            end
        end
    end
    
    -- Проверяем руку (активный предмет)
    if Player.Character then
        local Tool = Player.Character:FindFirstChildOfClass("Tool")
        if Tool then
            table.insert(Inventory, "🟢 " .. Tool.Name)
        end
    end
    
    return table.concat(Inventory, ", ")
end

-- ============ ОБНОВЛЕНИЕ ESP ============
function MixwareESP:Update()
    if not self.Enabled then
        for Player, Objects in pairs(self.Objects) do
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    local Camera = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then 
            if self.Objects[Player] then
                for _, obj in pairs(self.Objects[Player]) do
                    if type(obj) == "table" then
                        for _, line in pairs(obj) do
                            line.Visible = false
                        end
                    else
                        obj.Visible = false
                    end
                end
            end
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
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
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
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
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
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
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
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
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
        
        -- Инвентарь
        if self.ShowInventory then
            local Inventory = self:GetPlayerInventory(Player)
            if Inventory ~= "" then
                Objects.Inventory.Visible = true
                Objects.Inventory.Text = "📦 " .. Inventory
                Objects.Inventory.Position = Vector2.new(ScreenX, ScreenY + 10)
            else
                Objects.Inventory.Visible = false
            end
        else
            Objects.Inventory.Visible = false
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
            
            -- Обновляем линии скелета
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
        
        ::continue::
    end
end

-- ============ НАСТРОЙКА ПОЗИЦИИ ТРАССЕРА ============
function MixwareESP:SetTracerPosition(Position)
    self.TracerPosition = Position
end

-- ============ ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ============
function MixwareESP:SetEnabled(Enabled)
    self.Enabled = Enabled
    if not Enabled then
        for Player, Objects in pairs(self.Objects) do
            Objects.Box.Visible = false
            Objects.BoxOutline.Visible = false
            Objects.Name.Visible = false
            Objects.Health.Visible = false
            Objects.Distance.Visible = false
            Objects.Inventory.Visible = false
            Objects.Tracer.Visible = false
            Objects.TracerOutline.Visible = false
            Objects.HeadDot.Visible = false
            for _, line in pairs(Objects.Skeleton) do
                line.Visible = false
            end
        end
    end
end

-- ============ НАСТРОЙКА ЦВЕТА ============
function MixwareESP:SetColor(Color)
    self.Color = Color
end

-- ============ НАСТРОЙКА ДИСТАНЦИИ ============
function MixwareESP:SetMaxDistance(Distance)
    self.MaxDistance = Distance
end

-- ============ ТОГГЛЫ ============
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
end

function MixwareESP:ToggleTeamCheck(Show)
    self.TeamCheck = Show
end

-- ============ ВОЗВРАЩАЕМ БИБЛИОТЕКУ ============
return MixwareESP
