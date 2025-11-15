-- RemoveProvince - скрипт для удаления провинций из защиты
-- Клик правой кнопкой мыши на защищенной провинции убирает её из защиты

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Ожидаем загрузку
while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
    task.wait(0.01)
end

-- Проверяем, активен ли режим выбора провинций в основном скрипте
local selectionState = ReplicatedStorage:FindFirstChild("SelectionActive")

if selectionState and selectionState.Value == true then
    -- Режим выбора еще активен, ждем пока пользователь нажмет Done
    print("Please finish province selection first (click 'Done' in AutoPaint script)")
    
    -- Создаем сообщение для пользователя
    local playerGui = player:WaitForChild("PlayerGui")
    local messageGui = Instance.new("ScreenGui")
    messageGui.Name = "RemoveProvinceWaitMessage"
    messageGui.ResetOnSpawn = false
    messageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    messageGui.Parent = playerGui
    
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "WaitMessageFrame"
    messageFrame.Size = UDim2.new(0, 400, 0, 100)
    messageFrame.Position = UDim2.new(0.5, -200, 0.5, -50)
    messageFrame.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    messageFrame.BorderSizePixel = 0
    messageFrame.BackgroundTransparency = 0.1
    messageFrame.Parent = messageGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = messageFrame
    
    local messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.Size = UDim2.new(1, -40, 1, -40)
    messageText.Position = UDim2.new(0, 20, 0, 20)
    messageText.BackgroundTransparency = 1
    messageText.Text = "Please finish province selection first!\nClick 'Done' in AutoPaint script first."
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.TextSize = 18
    messageText.Font = Enum.Font.GothamBold
    messageText.TextWrapped = true
    messageText.Parent = messageFrame
    
    -- Ждем, пока режим выбора не завершится
    local connection
    connection = selectionState:GetPropertyChangedSignal("Value"):Connect(function()
        if selectionState.Value == false then
            -- Режим выбора завершен, можно запускать скрипт удаления
            messageGui:Destroy()
            connection:Disconnect()
            -- Запускаем основной код скрипта
            task.spawn(function()
                task.wait(0.5)  -- Небольшая задержка для завершения основного скрипта
                -- Продолжаем выполнение скрипта
                runRemoveProvinceScript()
            end)
        end
    end)
    
    -- Если режим выбора уже завершен, сразу запускаем
    if selectionState.Value == false then
        messageGui:Destroy()
        if connection then connection:Disconnect() end
        runRemoveProvinceScript()
    else
        return  -- Выходим из скрипта, ждем завершения режима выбора
    end
end

-- Функция с основным кодом скрипта удаления
function runRemoveProvinceScript()
    -- Создаем GUI для индикации режима удаления
    local playerGui = player:WaitForChild("PlayerGui")

    -- Очистка старых GUI
    local oldGui = playerGui:FindFirstChild("RemoveProvinceGUI")
    if oldGui then
        oldGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RemoveProvinceGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Кнопка Done
    local doneButtonFrame = Instance.new("Frame")
doneButtonFrame.Name = "DoneButtonFrame"
doneButtonFrame.Size = UDim2.new(0, 0, 0, 0)  -- Начинаем с нулевого размера для анимации
doneButtonFrame.Position = UDim2.new(0.5, -175, 0, 20)
doneButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
doneButtonFrame.BorderSizePixel = 0
doneButtonFrame.BackgroundTransparency = 1  -- Начинаем с прозрачным для анимации
doneButtonFrame.Parent = screenGui

    local doneCorner = Instance.new("UICorner")
    doneCorner.CornerRadius = UDim.new(0, 16)
    doneCorner.Parent = doneButtonFrame

    local doneButton = Instance.new("TextButton")
doneButton.Name = "DoneButton"
doneButton.Size = UDim2.new(1, -30, 1, -30)
doneButton.Position = UDim2.new(0, 15, 0, 15)
doneButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
doneButton.BorderSizePixel = 0
doneButton.Text = "Done"
doneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
doneButton.TextSize = 32
doneButton.Font = Enum.Font.GothamBold
doneButton.TextTransparency = 1  -- Начинаем с прозрачным текстом
doneButton.BackgroundTransparency = 1  -- Начинаем с прозрачным фоном
    doneButton.Parent = doneButtonFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = doneButton

    -- Анимация появления
    task.spawn(function()
    task.wait(0.1)
    -- Анимация кнопки Done
    local doneFadeIn = TweenService:Create(
        doneButtonFrame,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 350, 0, 90),
            BackgroundTransparency = 0.2
        }
    )
    doneFadeIn:Play()
    
    local doneButtonFadeIn = TweenService:Create(
        doneButton,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0,
            TextTransparency = 0
        }
    )
        doneButtonFadeIn:Play()
    end)

    -- Анимация при наведении на кнопку Done
    doneButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(
        doneButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(220, 70, 70)}
    )
    tween:Play()
end)

doneButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(
        doneButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}
    )
        tween:Play()
    end)

    -- Флаг для отслеживания режима удаления
    local removalModeActive = true

    -- Обработка нажатия кнопки Done
    doneButton.MouseButton1Click:Connect(function()
    -- Отключаем режим удаления
    removalModeActive = false
    
    -- Анимация исчезновения
    local fadeOut = TweenService:Create(
        doneButtonFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}
    )
    fadeOut:Play()
    
    fadeOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Изменяем текст кнопки на короткое время
        doneButton.Text = "Removal Complete!"
        doneButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    end)

    -- Функция проверки, защищена ли провинция
    local function isProvinceProtected(part)
    local protectedFolder = ReplicatedStorage:FindFirstChild("ProtectedProvinces")
    if not protectedFolder then
        return false
    end
    
    -- Проверяем только по прямой ссылке (самый надежный способ)
    for _, objValue in ipairs(protectedFolder:GetChildren()) do
        if objValue:IsA("ObjectValue") and objValue.Value == part then
            return true, objValue
        end
    end
        return false
    end

    -- Функция удаления провинции из защиты
    local function removeProvince(part)
    if not part or not part.Parent then
        return false
    end
    
    local protectedFolder = ReplicatedStorage:FindFirstChild("ProtectedProvinces")
    if not protectedFolder then
        return false
    end
    
    -- Ищем ObjectValue, который ссылается именно на эту провинцию (только по прямой ссылке)
    local foundRef = nil
    for _, objValue in ipairs(protectedFolder:GetChildren()) do
        if objValue:IsA("ObjectValue") and objValue.Value == part then
            foundRef = objValue
            break
        end
    end
    
    if foundRef then
        -- Удаляем только найденную ссылку
        foundRef:Destroy()
        
        -- Визуальная обратная связь
        if part and part.Parent then
            local originalColor = part.Color
            local highlight = Instance.new("SelectionBox")
            highlight.Adornee = part
            highlight.Color3 = Color3.fromRGB(255, 100, 100)
            highlight.Transparency = 0.5
            highlight.LineThickness = 0.2
            highlight.Parent = part
            
            -- Мигание
            task.spawn(function()
                for i = 1, 3 do
                    if part and part.Parent then
                        part.Color = Color3.fromRGB(255, 150, 150)
                        task.wait(0.1)
                        if part and part.Parent then
                            part.Color = originalColor
                        end
                        task.wait(0.1)
                    end
                end
                if highlight then
                    highlight:Destroy()
                end
            end)
        end
        
            print("Province removed from protection: " .. tostring(part))
            return true
        end
        return false
    end

    -- Обработка клика левой кнопкой мыши
    local mouse = player:GetMouse()

    mouse.Button1Down:Connect(function()
        if not removalModeActive then return end
        
        local target = mouse.Target
        if target and target.Name == "Province" and target:IsDescendantOf(Workspace:WaitForChild("Map")) then
            removeProvince(target)
        end
    end)

    -- Синхронизация с основным скриптом
    -- Периодически проверяем, какие провинции еще защищены, и обновляем локальный список
    local protectedProvinces = {}
    local protectedFolder = ReplicatedStorage:WaitForChild("ProtectedProvinces")

    protectedFolder.ChildAdded:Connect(function(child)
        if child:IsA("ObjectValue") and child.Value then
            protectedProvinces[child.Value] = true
        end
    end)

    protectedFolder.ChildRemoved:Connect(function(child)
        if child:IsA("ObjectValue") and child.Value then
            protectedProvinces[child.Value] = nil
        end
    end)

    -- Инициализация существующих провинций
    for _, child in ipairs(protectedFolder:GetChildren()) do
        if child:IsA("ObjectValue") and child.Value then
            protectedProvinces[child.Value] = true
        end
    end

    print("RemoveProvince script loaded. Click on protected provinces to remove them from protection.")
end

-- Если режим выбора уже завершен, сразу запускаем скрипт
if not selectionState or selectionState.Value == false then
    runRemoveProvinceScript()
end
