-- Westbound H2K Mod Menu
-- Optimizado para KRNL Android

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local gui = nil
local isMenuOpen = false
local noclipEnabled = false
local speedEnabled = false
local godmodeEnabled = false
local normalSpeed = 16
local speedValue = 50

-- Conexiones para mantener funciones activas
local noclipConnection = nil
local speedConnection = nil
local godmodeConnection = nil

-- Función para crear el ícono H2K
local function createIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui
    
    -- Ícono H2K (botón circular)
    local iconButton = Instance.new("TextButton")
    iconButton.Name = "H2K_Icon"
    iconButton.Size = UDim2.new(0, 60, 0, 60)
    iconButton.Position = UDim2.new(0, 20, 0, 100)
    iconButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    iconButton.BorderColor3 = Color3.fromRGB(255, 215, 0)
    iconButton.BorderSizePixel = 3
    iconButton.Text = "H2K"
    iconButton.TextColor3 = Color3.fromRGB(255, 215, 0)
    iconButton.TextScaled = true
    iconButton.Font = Enum.Font.SourceSansBold
    iconButton.Active = true
    iconButton.Draggable = true
    iconButton.Parent = screenGui
    
    -- Esquinas redondeadas para el ícono
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 30)
    iconCorner.Parent = iconButton
    
    -- Efecto de brillo
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = Color3.fromRGB(255, 215, 0)
    iconStroke.Thickness = 2
    iconStroke.Parent = iconButton
    
    return screenGui, iconButton
end

-- Función para crear el menú principal
local function createMenu(parentGui)
    -- Frame principal del menú
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0, 300, 0, 400)
    menuFrame.Position = UDim2.new(0, 90, 0, 50)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    menuFrame.BorderColor3 = Color3.fromRGB(139, 69, 19)
    menuFrame.BorderSizePixel = 3
    menuFrame.Visible = false
    menuFrame.Active = true
    menuFrame.Draggable = true
    menuFrame.Parent = parentGui
    
    -- Esquinas redondeadas
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = menuFrame
    
    -- Título del menú
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 50)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = menuFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "WESTBOUND H2K"
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = titleFrame
    
    -- Container para botones
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 1, -70)
    buttonContainer.Position = UDim2.new(0, 10, 0, 60)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = menuFrame
    
    -- Función para crear botones de función
    local function createFunctionButton(name, text, position, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, 60)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderColor3 = Color3.fromRGB(255, 215, 0)
        button.BorderSizePixel = 2
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSansBold
        button.Parent = buttonContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button
        
        return button
    end
    
    -- Crear botones
    local noclipBtn = createFunctionButton("NoclipButton", "NOCLIP: OFF", 
        UDim2.new(0, 0, 0, 10), Color3.fromRGB(80, 80, 80))
    
    local speedBtn = createFunctionButton("SpeedButton", "SPEED: OFF", 
        UDim2.new(0, 0, 0, 80), Color3.fromRGB(80, 80, 80))
    
    local godBtn = createFunctionButton("GodButton", "GOD MODE: OFF", 
        UDim2.new(0, 0, 0, 150), Color3.fromRGB(80, 80, 80))
    
    -- Créditos
    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, 0, 0, 30)
    creditsLabel.Position = UDim2.new(0, 0, 1, -40)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.Text = "by h2k"
    creditsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    creditsLabel.TextScaled = true
    creditsLabel.Font = Enum.Font.SourceSansItalic
    creditsLabel.Parent = menuFrame
    
    return menuFrame, noclipBtn, speedBtn, godBtn
end

-- Función Noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        pcall(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- Función Speed
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
                end
            end)
        end)
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = normalSpeed
            end
        end)
    end
end

-- Función God Mode
local function toggleGodMode()
    godmodeEnabled = not godmodeEnabled
    
    if godmodeEnabled then
        godmodeConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                end
            end)
        end)
    else
        if godmodeConnection then
            godmodeConnection:Disconnect()
            godmodeConnection = nil
        end
    end
end

-- Función para animar la apertura/cierre del menú
local function animateMenu(menuFrame, open)
    local targetSize = open and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 0, 0, 0)
    local targetPos = open and UDim2.new(0, 90, 0, 50) or UDim2.new(0, 90, 0, 250)
    
    menuFrame.Visible = true
    
    local sizeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local sizeTween = TweenService:Create(menuFrame, sizeInfo, {Size = targetSize, Position = targetPos})
    
    sizeTween:Play()
    
    if not open then
        sizeTween.Completed:Connect(function()
            menuFrame.Visible = false
        end)
    end
end

-- Función para reconectar funciones después de morir/respawn
local function reconnectFunctions()
    LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        wait(1) -- Esperar a que el personaje esté completamente cargado
        
        -- Reconectar funciones que estaban activas
        if noclipEnabled and not noclipConnection then
            toggleNoclip()
            toggleNoclip() -- Doble toggle para reactivar
        end
        
        if speedEnabled and not speedConnection then
            toggleSpeed()
            toggleSpeed() -- Doble toggle para reactivar
        end
        
        if godmodeEnabled and not godmodeConnection then
            toggleGodMode()
            toggleGodMode() -- Doble toggle para reactivar
        end
    end)
end

-- Función principal de inicialización
local function initH2K()
    -- Eliminar GUI anterior si existe
    if PlayerGui:FindFirstChild("H2K_GUI") then
        PlayerGui.H2K_GUI:Destroy()
    end
    
    -- Crear ícono y menú
    local screenGui, iconButton = createIcon()
    local menuFrame, noclipBtn, speedBtn, godBtn = createMenu(screenGui)
    
    gui = screenGui
    
    -- Evento del ícono (abrir/cerrar menú)
    iconButton.MouseButton1Click:Connect(function()
        isMenuOpen = not isMenuOpen
        animateMenu(menuFrame, isMenuOpen)
        
        -- Efecto visual en el ícono
        local originalSize = iconButton.Size
        iconButton:TweenSize(UDim2.new(0, 50, 0, 50), "Out", "Back", 0.1, true)
        wait(0.1)
        iconButton:TweenSize(originalSize, "Out", "Back", 0.1, true)
    end)
    
    -- Eventos de los botones de función
    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
        noclipBtn.Text = noclipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
        noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
        
        -- Efecto visual
        noclipBtn:TweenSize(UDim2.new(0.95, 0, 0, 55), "Out", "Quad", 0.1, true)
        wait(0.1)
        noclipBtn:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.1, true)
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
        speedBtn.Text = speedEnabled and "SPEED: ON" or "SPEED: OFF"
        speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
        
        -- Efecto visual
        speedBtn:TweenSize(UDim2.new(0.95, 0, 0, 55), "Out", "Quad", 0.1, true)
        wait(0.1)
        speedBtn:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.1, true)
    end)
    
    godBtn.MouseButton1Click:Connect(function()
        toggleGodMode()
        godBtn.Text = godmodeEnabled and "GOD MODE: ON" or "GOD MODE: OFF"
        godBtn.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
        
        -- Efecto visual
        godBtn:TweenSize(UDim2.new(0.95, 0, 0, 55), "Out", "Quad", 0.1, true)
        wait(0.1)
        godBtn:TweenSize(UDim2.new(1, 0, 0, 60), "Out", "Quad", 0.1, true)
    end)
    
    -- Configurar reconexión después de respawn
    reconnectFunctions()
    
    print("H2K Westbound Mod Menu cargado exitosamente!")
    print("- Toca el ícono H2K para abrir/cerrar el menú")
    print("- Funciones: Noclip, Speed, God Mode")
    print("- Las funciones se mantienen activas después de morir")
end

-- Inicializar el mod menu
initH2K()