-- Prison Life Mod Menu - Kill All Methods
-- Optimizado para Android (solo táctil)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local killAllActive = false
local currentMethod = 1
local gui = nil

-- Función para crear la GUI
local function createGUI()
    -- Crear ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal (draggable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Prison Life Mod Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Botón 1: RemoteEvent Kill
    local btn1 = Instance.new("TextButton")
    btn1.Name = "RemoteKill"
    btn1.Size = UDim2.new(0.9, 0, 0, 50)
    btn1.Position = UDim2.new(0.05, 0, 0, 60)
    btn1.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    btn1.BorderSizePixel = 0
    btn1.Text = "Remote Kill All"
    btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn1.TextScaled = true
    btn1.Font = Enum.Font.SourceSans
    btn1.Parent = mainFrame
    
    -- Botón 2: Melee Kill
    local btn2 = Instance.new("TextButton")
    btn2.Name = "MeleeKill"
    btn2.Size = UDim2.new(0.9, 0, 0, 50)
    btn2.Position = UDim2.new(0.05, 0, 0, 120)
    btn2.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    btn2.BorderSizePixel = 0
    btn2.Text = "Melee Kill All"
    btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn2.TextScaled = true
    btn2.Font = Enum.Font.SourceSans
    btn2.Parent = mainFrame
    
    -- Botón 3: Damage Kill
    local btn3 = Instance.new("TextButton")
    btn3.Name = "DamageKill"
    btn3.Size = UDim2.new(0.9, 0, 0, 50)
    btn3.Position = UDim2.new(0.05, 0, 0, 180)
    btn3.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    btn3.BorderSizePixel = 0
    btn3.Text = "Damage Kill All"
    btn3.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn3.TextScaled = true
    btn3.Font = Enum.Font.SourceSans
    btn3.Parent = mainFrame
    
    -- Botón 4: Shoot Kill
    local btn4 = Instance.new("TextButton")
    btn4.Name = "ShootKill"
    btn4.Size = UDim2.new(0.9, 0, 0, 50)
    btn4.Position = UDim2.new(0.05, 0, 0, 240)
    btn4.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    btn4.BorderSizePixel = 0
    btn4.Text = "Shoot Kill All"
    btn4.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn4.TextScaled = true
    btn4.Font = Enum.Font.SourceSans
    btn4.Parent = mainFrame
    
    -- Botón 5: Auto Kill Toggle
    local btn5 = Instance.new("TextButton")
    btn5.Name = "AutoKill"
    btn5.Size = UDim2.new(0.9, 0, 0, 50)
    btn5.Position = UDim2.new(0.05, 0, 0, 300)
    btn5.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    btn5.BorderSizePixel = 0
    btn5.Text = "Auto Kill: OFF"
    btn5.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn5.TextScaled = true
    btn5.Font = Enum.Font.SourceSans
    btn5.Parent = mainFrame
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = mainFrame
    
    return screenGui, btn1, btn2, btn3, btn4, btn5, closeBtn
end

-- Métodos de kill
local function remoteKillAll()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Método usando RemoteEvent
                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                    ReplicatedStorage.meleeEvent:FireServer(player)
                end
            end
        end
    end)
end

local function meleeKillAll()
    pcall(function()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Simular ataque cuerpo a cuerpo
                    if ReplicatedStorage:FindFirstChild("meleeEvent") then
                        ReplicatedStorage.meleeEvent:FireServer(player.Character.HumanoidRootPart, tool.Handle)
                    end
                end
            end
        end
    end)
end

local function damageKillAll()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Método usando DamageEvent
                if ReplicatedStorage:FindFirstChild("DamageEvent") then
                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 100)
                end
            end
        end
    end)
end

local function shootKillAll()
    pcall(function()
        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("M9") or 
                   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47") or
                   LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("M4A1")
        
        if gun and gun:FindFirstChild("ShootEvent") then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    -- Disparar usando ShootEvent
                    gun.ShootEvent:FireServer(player.Character.Head.Position, player.Character.Head)
                end
            end
        elseif ReplicatedStorage:FindFirstChild("ShootEvent") then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    ReplicatedStorage.ShootEvent:FireServer(player.Character.Head.Position, player.Character.Head)
                end
            end
        end
    end)
end

-- Auto kill loop
local function autoKillLoop()
    spawn(function()
        while killAllActive do
            wait(0.1)
            if currentMethod == 1 then
                remoteKillAll()
            elseif currentMethod == 2 then
                meleeKillAll()
            elseif currentMethod == 3 then
                damageKillAll()
            elseif currentMethod == 4 then
                shootKillAll()
            end
        end
    end)
end

-- Función principal
local function initModMenu()
    -- Eliminar GUI anterior si existe
    if PlayerGui:FindFirstChild("ModMenuGUI") then
        PlayerGui.ModMenuGUI:Destroy()
    end
    
    -- Crear nueva GUI
    local screenGui, btn1, btn2, btn3, btn4, btn5, closeBtn = createGUI()
    gui = screenGui
    
    -- Conectar eventos de botones
    btn1.MouseButton1Click:Connect(function()
        currentMethod = 1
        remoteKillAll()
        print("Remote Kill All ejecutado")
    end)
    
    btn2.MouseButton1Click:Connect(function()
        currentMethod = 2
        meleeKillAll()
        print("Melee Kill All ejecutado")
    end)
    
    btn3.MouseButton1Click:Connect(function()
        currentMethod = 3
        damageKillAll()
        print("Damage Kill All ejecutado")
    end)
    
    btn4.MouseButton1Click:Connect(function()
        currentMethod = 4
        shootKillAll()
        print("Shoot Kill All ejecutado")
    end)
    
    btn5.MouseButton1Click:Connect(function()
        killAllActive = not killAllActive
        if killAllActive then
            btn5.Text = "Auto Kill: ON"
            btn5.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            autoKillLoop()
            print("Auto Kill activado")
        else
            btn5.Text = "Auto Kill: OFF"
            btn5.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
            print("Auto Kill desactivado")
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        killAllActive = false
        screenGui:Destroy()
        print("Mod Menu cerrado")
    end)
    
    print("Mod Menu cargado exitosamente!")
    print("Métodos disponibles:")
    print("1. Remote Kill All")
    print("2. Melee Kill All") 
    print("3. Damage Kill All")
    print("4. Shoot Kill All")
    print("5. Auto Kill Toggle")
end

-- Inicializar el mod menu
initModMenu()

-- Función para reabrir el menú (opcional)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if gui and gui.Parent then
            gui:Destroy()
        else
            initModMenu()
        end
    end
end)