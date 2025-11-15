-- AutoPaint vPriority+ with SelectionController
-- Объединенный скрипт для Roblox Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ============================================
-- SelectionController - создание GUI и управления выбором
-- ============================================

-- Очистка старых GUI при повторном запуске
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("SelectionController")
if oldGui then
    oldGui:Destroy()
end

-- Очистка и создание состояния выбора
local oldSelectionState = ReplicatedStorage:FindFirstChild("SelectionActive")
if oldSelectionState then
    oldSelectionState:Destroy()
end

local selectionState = Instance.new("BoolValue")
selectionState.Name = "SelectionActive"
selectionState.Value = true
selectionState.Parent = ReplicatedStorage

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SelectionController"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Создаем фрейм для кнопки (увеличенный размер)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "DoneButtonFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0)  -- Начинаем с нулевого размера для анимации
mainFrame.Position = UDim2.new(0.5, -175, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 1  -- Начинаем с прозрачным для анимации
mainFrame.Parent = screenGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Кнопка Done (увеличенная)
local doneButton = Instance.new("TextButton")
doneButton.Name = "DoneButton"
doneButton.Size = UDim2.new(1, -30, 1, -30)
doneButton.Position = UDim2.new(0, 15, 0, 15)
doneButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
doneButton.BorderSizePixel = 0
doneButton.Text = "Done"
doneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
doneButton.TextSize = 32
doneButton.Font = Enum.Font.GothamBold
doneButton.TextTransparency = 1  -- Начинаем с прозрачным текстом
doneButton.BackgroundTransparency = 1  -- Начинаем с прозрачным фоном
doneButton.Parent = mainFrame

-- Скругление углов для кнопки
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = doneButton

-- Анимация появления кнопки (с задержкой для плавности)
task.spawn(function()
    task.wait(0.1)  -- Небольшая задержка перед анимацией
    
    -- Анимация появления фрейма (fade in + scale с эффектом "bounce")
    local fadeIn = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 350, 0, 90),
            BackgroundTransparency = 0.2
        }
    )
    fadeIn:Play()
    
    -- Анимация появления кнопки (синхронизирована с фреймом)
    local buttonFadeIn = TweenService:Create(
        doneButton,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0,
            TextTransparency = 0
        }
    )
    buttonFadeIn:Play()
end)

-- Анимация при наведении
doneButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(
        doneButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(60, 220, 60)}
    )
    tween:Play()
end)

doneButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(
        doneButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}
    )
    tween:Play()
end)

-- Обработка нажатия кнопки
doneButton.MouseButton1Click:Connect(function()
    -- Отключаем выбор провинций
    selectionState.Value = false
    
    -- Анимация исчезновения
    local fadeOut = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}
    )
    
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Изменяем текст кнопки на короткое время
    doneButton.Text = "Selection Complete!"
    doneButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
end)

-- ============================================
-- AutoPaint - основной скрипт покраски
-- ============================================

-- Ждём Character и PaintBucket
while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
    task.wait(0.01)
end

local tool
while true do
    tool = player.Backpack:FindFirstChild("PaintBucket") or player.Character:FindFirstChild("PaintBucket")
    if tool then break end
    task.wait(0.01)
end

local serverRemote = tool:WaitForChild("Remotes"):WaitForChild("ServerControls")
assert(serverRemote:IsA("RemoteFunction"), "ServerControls is not a RemoteFunction!")

-- Проверка состояния выбора провинций
local function isSelectionActive()
    local selectionState = ReplicatedStorage:FindFirstChild("SelectionActive")
    if selectionState then
        return selectionState.Value
    end
    -- Если SelectionController не запущен, разрешаем выбор по умолчанию
    return true
end

-- Настройки
local currentColor = Color3.fromRGB(233, 218, 218)
local mode = "Peace"

-- Настройки антиспама и детекта автокликера
local autoclickerThreshold = 8
local autoclickerWindow = 1.5
local ignoreDuration = 1.0
local recoveryCheckInterval = 0.5
local recoveryTime = 2.0

-- Настройки производительности
local paintCooldown = 0.06
local priorityPaintCooldown = 0.04
local maxPaintsPerFrame = 5
local colorCheckInterval = 0.08
local minChangeDelay = 0.15
local maxProvincesPerCycle = 50

-- Очистка старых данных при повторном запуске
local protectedProvinces = {}      -- [part] = true
local provinceData = {}            -- данные по провинциям

-- Создаем общий контейнер для хранения защищенных провинций (для доступа из других скриптов)
local protectedProvincesFolder = ReplicatedStorage:FindFirstChild("ProtectedProvinces")
if not protectedProvincesFolder then
    protectedProvincesFolder = Instance.new("Folder")
    protectedProvincesFolder.Name = "ProtectedProvinces"
    protectedProvincesFolder.Parent = ReplicatedStorage
end

-- Восстанавливаем защищенные провинции из ReplicatedStorage при запуске
for _, objValue in ipairs(protectedProvincesFolder:GetChildren()) do
    if objValue:IsA("ObjectValue") and objValue.Value then
        local part = objValue.Value
        if part and part.Parent and part.Name == "Province" and not protectedProvinces[part] then
            protectedProvinces[part] = true
            
            local initialColor = part.Color
            local now = os.clock()
            provinceData[part] = {
                lastColor = initialColor,
                colorChangeTimestamps = {},
                ignoreTimer = 0,
                wasRepainted = false,
                ourColor = (initialColor == currentColor),
                lastPaintTime = 0,
                underAutoclickerAttack = false,
                lastColorChangeTime = now,
                lastRecoveryCheck = now,
                lastChangeTime = 0,
                ref = objValue
            }
        elseif not part or not part.Parent then
            -- Очищаем ссылки на несуществующие провинции
            objValue:Destroy()
        end
    end
end

-- Синхронизация: если провинция удалена из ReplicatedStorage, удаляем её из локального списка
protectedProvincesFolder.ChildRemoved:Connect(function(removedChild)
    if removedChild:IsA("ObjectValue") then
        local removedPart = removedChild.Value
        
        -- Удаляем только по прямой ссылке (самый надежный способ)
        if removedPart then
            if protectedProvinces[removedPart] then
                protectedProvinces[removedPart] = nil
            end
            if provinceData[removedPart] then
                provinceData[removedPart] = nil
            end
        end
    end
end)

-- Синхронизация: если провинция добавлена в ReplicatedStorage, добавляем её в локальный список
protectedProvincesFolder.ChildAdded:Connect(function(addedChild)
    if addedChild:IsA("ObjectValue") and addedChild.Value then
        local part = addedChild.Value
        if part and part.Parent and part.Name == "Province" and not protectedProvinces[part] then
            protectedProvinces[part] = true
            
            local initialColor = part.Color
            local now = os.clock()
            provinceData[part] = {
                lastColor = initialColor,
                colorChangeTimestamps = {},
                ignoreTimer = 0,
                wasRepainted = false,
                ourColor = (initialColor == currentColor),
                lastPaintTime = 0,
                underAutoclickerAttack = false,
                lastColorChangeTime = now,
                lastRecoveryCheck = now,
                lastChangeTime = 0,
                ref = addedChild
            }
        end
    end
end)

-- Добавление провинции под защиту
local function protectProvince(part)
    if part and part.Name == "Province" and not protectedProvinces[part] then
        protectedProvinces[part] = true
        
        -- Создаем ObjectValue в ReplicatedStorage для доступа из других скриптов
        local provinceRef = Instance.new("ObjectValue")
        provinceRef.Name = tostring(part:GetDebugId())
        provinceRef.Value = part
        provinceRef.Parent = protectedProvincesFolder
        
        local initialColor = part.Color
        local now = os.clock()
        provinceData[part] = {
            lastColor = initialColor,
            colorChangeTimestamps = {},
            ignoreTimer = 0,
            wasRepainted = false,
            ourColor = (initialColor == currentColor),
            lastPaintTime = 0,
            underAutoclickerAttack = false,
            lastColorChangeTime = now,
            lastRecoveryCheck = now,
            lastChangeTime = 0,
            ref = provinceRef  -- Сохраняем ссылку для удаления
        }
    end
end

-- Удаление провинции из защиты
local function unprotectProvince(part)
    if part and protectedProvinces[part] then
        protectedProvinces[part] = nil
        local data = provinceData[part]
        if data then
            if data.ref then
                data.ref:Destroy()
            end
            provinceData[part] = nil
        end
    end
end

-- Быстрая проверка возможности покраски
local function canPaintProvince(data, now, partColor)
    if partColor == currentColor then
        data.underAutoclickerAttack = false
        data.ignoreTimer = 0
        data.colorChangeTimestamps = {}
        data.lastColorChangeTime = now
        return false
    end
    if data.lastChangeTime > 0 and (now - data.lastChangeTime) < minChangeDelay then
        if not data.wasRepainted or (now - data.lastChangeTime) < (minChangeDelay * 0.5) then
            return false
        end
    end
    if data.underAutoclickerAttack then
        if now - data.lastRecoveryCheck >= recoveryCheckInterval then
            data.lastRecoveryCheck = now
            if now - data.lastColorChangeTime >= recoveryTime then
                data.underAutoclickerAttack = false
                data.ignoreTimer = 0
                data.colorChangeTimestamps = {}
            else
                return false
            end
        else
            if now < data.ignoreTimer then
                return false
            end
            if now - data.lastColorChangeTime < recoveryTime then
                return false
            end
        end
    end
    return true
end

-- Регистрация изменения цвета
local function registerColorChange(data, now)
    now = now or os.clock()
    table.insert(data.colorChangeTimestamps, now)
    data.lastColorChangeTime = now
    local cutoff = now - autoclickerWindow
    local i = 1
    while i <= #data.colorChangeTimestamps do
        if data.colorChangeTimestamps[i] <= cutoff then
            table.remove(data.colorChangeTimestamps, i)
        else
            break
        end
    end
    if #data.colorChangeTimestamps >= autoclickerThreshold then
        data.underAutoclickerAttack = true
        data.ignoreTimer = now + ignoreDuration
        data.colorChangeTimestamps = {}
        data.lastRecoveryCheck = now
    end
end

-- Основной цикл
local lastPaintTime = 0
local lastPriorityPaintTime = 0
local lastColorCheckTime = 0
local checkOffset = 0

RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local shouldCheckColor = (now - lastColorCheckTime >= colorCheckInterval)
    if shouldCheckColor then
        lastColorCheckTime = now
    end

    local priorityQueue = {}
    local secondaryQueue = {}
    local provincesArray = {}

    for part, _ in pairs(protectedProvinces) do
        if part and part.Parent then
            table.insert(provincesArray, part)
        end
    end

    local totalProvinces = #provincesArray
    if totalProvinces == 0 then return end

    local checkedCount = 0
    local startIndex = (checkOffset % totalProvinces) + 1

    -- Проверка перекрашенных (приоритетных)
    for part, _ in pairs(protectedProvinces) do
        if part and part.Parent then
            local data = provinceData[part]
            if data and data.wasRepainted then
                local partColor = part.Color
                if partColor ~= data.lastColor then
                    data.lastChangeTime = now
                    if data.ourColor and partColor ~= currentColor then
                        data.wasRepainted = true
                        data.ourColor = false
                        registerColorChange(data, now)
                    elseif partColor == currentColor then
                        data.ourColor = true
                        data.wasRepainted = false
                        data.underAutoclickerAttack = false
                        data.ignoreTimer = 0
                        data.colorChangeTimestamps = {}
                        data.lastColorChangeTime = now
                        data.lastChangeTime = 0
                    else
                        registerColorChange(data, now)
                    end
                    data.lastColor = partColor
                end
                if canPaintProvince(data, now, data.lastColor) then
                    table.insert(priorityQueue, part)
                end
            end
        end
    end

    -- Ротация остальных провинций
    for i = 0, totalProvinces - 1 do
        local index = ((startIndex + i - 1) % totalProvinces) + 1
        local part = provincesArray[index]
        if part and part.Parent then
            local data = provinceData[part]
            if not data or not data.wasRepainted then
                if not data then
                    protectProvince(part)
                    data = provinceData[part]
                end
                local willCheckColor = checkedCount < maxProvincesPerCycle and shouldCheckColor
                if willCheckColor then checkedCount += 1 end
                local partColor = willCheckColor and part.Color or data.lastColor
                if willCheckColor and partColor ~= data.lastColor then
                    data.lastChangeTime = now
                    if data.ourColor and partColor ~= currentColor then
                        data.wasRepainted = true
                        data.ourColor = false
                        registerColorChange(data, now)
                    elseif partColor == currentColor then
                        data.ourColor = true
                        data.wasRepainted = false
                        data.underAutoclickerAttack = false
                        data.ignoreTimer = 0
                        data.colorChangeTimestamps = {}
                        data.lastColorChangeTime = now
                        data.lastChangeTime = 0
                    else
                        registerColorChange(data, now)
                    end
                    data.lastColor = partColor
                end
                if canPaintProvince(data, now, data.lastColor) then
                    if data.wasRepainted then
                        table.insert(priorityQueue, part)
                    else
                        table.insert(secondaryQueue, part)
                    end
                end
            end
        end
    end

    for part, _ in pairs(protectedProvinces) do
        if not part or not part.Parent then
            unprotectProvince(part)
        end
    end

    if checkedCount > 0 then
        checkOffset = (checkOffset + checkedCount) % math.max(totalProvinces, 1)
    end

    local paintsThisFrame = 0
    if #priorityQueue > 0 and (now - lastPriorityPaintTime >= priorityPaintCooldown) then
        for _, part in ipairs(priorityQueue) do
            if paintsThisFrame >= maxPaintsPerFrame then break end
            local data = provinceData[part]
            if data and part.Parent then
                local partColor = part.Color
                if partColor ~= currentColor and canPaintProvince(data, now, partColor) then
                    pcall(function()
                        serverRemote:InvokeServer("PaintPart", {Part = part, Color = currentColor}, mode)
                        data.lastPaintTime = now
                        data.ourColor = true
                        data.lastColor = currentColor
                        data.lastChangeTime = 0
                        paintsThisFrame += 1
                    end)
                end
            end
        end
        lastPriorityPaintTime = now
        lastPaintTime = now
    end

    if paintsThisFrame < maxPaintsPerFrame and (now - lastPaintTime >= paintCooldown) then
        for _, part in ipairs(secondaryQueue) do
            if paintsThisFrame >= maxPaintsPerFrame then break end
            local data = provinceData[part]
            if data and part.Parent then
                local partColor = part.Color
                if partColor ~= currentColor and canPaintProvince(data, now, partColor) then
                    pcall(function()
                        serverRemote:InvokeServer("PaintPart", {Part = part, Color = currentColor}, mode)
                        data.lastPaintTime = now
                        data.ourColor = true
                        data.lastColor = currentColor
                        data.lastChangeTime = 0
                        paintsThisFrame += 1
                    end)
                end
            end
        end
        lastPaintTime = now
    end
end)

-- Выбор провинций мышью (с проверкой состояния выбора)
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
    -- Проверяем, активен ли режим выбора провинций
    if not isSelectionActive() then
        return
    end
    
    local target = mouse.Target
    if target and target.Name == "Province" and target:IsDescendantOf(Workspace:WaitForChild("Map")) then
        protectProvince(target)
    end
end)
