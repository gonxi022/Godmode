-- Prison Life Mod Menu Premium
-- Kill All Spoof + TP All + Speed + Noclip + Auto Respawn
-- By ChatGPT + Gonxi

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
local damageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")

local speedVal = 60
local killAllOn = false
local tpAllOn = false
local speedOn = false
local respawnOn = false
local deathPos = nil
local currentTPIndex = 1

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PremiumPrisonModMenu"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 350)
mainFrame.Position = UDim2.new(0, 20, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 2

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚔️ Premium Prison Mod"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleBtn = Instance.new("TextButton", titleBar)
toggleBtn.Size = UDim2.new(0, 35, 0, 35)
toggleBtn.Position = UDim2.new(1, -45, 0.5, -17)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleBtn.Text = "➖"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 24
toggleBtn.BorderSizePixel = 0
local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 10)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 1, -40)
statusLabel.BackgroundTransparency = 0.5
statusLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Text = "🟢 Listo | Jugadores: " .. (#Players:GetPlayers()-1)
statusLabel.BorderSizePixel = 0
local statusCorner = Instance.new("UICorner", statusLabel)
statusCorner.CornerRadius = UDim.new(0, 10)

-- Función para crear botones
local function createButton(text, order, callback, colorOn, colorOff)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, order*55)
    btn.BackgroundColor3 = colorOff or Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.Parent = contentFrame
    btn.AutoButtonColor = false
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 12)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(100,100,100)
    btnStroke.Thickness = 1

    local toggled = false

    local function updateColors()
        if toggled then
            btn.BackgroundColor3 = colorOn or Color3.fromRGB(200, 50, 50)
            btnStroke.Color = Color3.fromRGB(255, 80, 80)
        else
            btn.BackgroundColor3 = colorOff or Color3.fromRGB(50, 50, 50)
            btnStroke.Color = Color3.fromRGB(100, 100, 100)
        end
    end

    btn.MouseEnter:Connect(function()
        if not toggled then
            btn.BackgroundColor3 = (colorOff or Color3.fromRGB(50, 50, 50)):Lerp(Color3.fromRGB(100,100,100), 0.4)
        end
    end)
    btn.MouseLeave:Connect(function()
        updateColors()
    end)

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateColors()
        callback(toggled)
    end)

    if UserInputService.TouchEnabled then
        btn.TouchTap:Connect(function()
            toggled = not toggled
            updateColors()
            callback(toggled)
        end)
    end

    updateColors()
    return btn
end

-- Kill All (sin teletransportación visible, spoof TP para atacar)
local function killAllLoop()
    spawn(function()
        while true do
            if killAllOn and Character and Root and meleeEvent and damageEvent then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                        local dist = (plr.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                        if dist <= 70 then  -- distancia para "cercano"
                            -- Spoof TP
                            local originalCFrame = Root.CFrame
                            Root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,1)
                            task.wait(0.01)
                            -- Manda 69 melee y damage events rápido
                            for i=1,69 do
                                meleeEvent:FireServer(plr)
                                damageEvent:FireServer(plr)
                            end
                            Root.CFrame = originalCFrame
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- TP All (teletransporte real jugador por jugador)
local function tpAllLoop()
    spawn(function()
        while true do
            if tpAllOn and Character and Root then
                local playersList = {}
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(playersList, plr)
                    end
                end
                if #playersList > 0 then
                    currentTPIndex = (currentTPIndex % #playersList) + 1
                    local target = playersList[currentTPIndex]
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        Root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        statusLabel.Text = "🌀 TP to: " .. target.Name
                        statusLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Speed
local function setSpeed(val)
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = val
    end
end

-- Noclip solo paredes
local function noclipLoop()
    RunService.Stepped:Connect(function()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    if part.Name ~= "HumanoidRootPart" and part.Position.Y > Root.Position.Y - 3 then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

-- Auto Respawn rápido en lugar de muerte
local function setupRespawn()
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
        Root = newChar:WaitForChild("HumanoidRootPart")
        if respawnOn and deathPos then
            Root.CFrame = CFrame.new(deathPos)
            statusLabel.Text = "💀 Respawned at death position"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        end
        if speedOn then
            setSpeed(speedVal)
        end
    end)

    spawn(function()
        while true do
            if respawnOn and Character and Humanoid and Humanoid.Health <= 0 and Root then
                deathPos = Root.Position
            end
            task.wait(0.1)
        end
    end)
end

-- Crear botones
local killButton = createButton("Kill All (69 melees)", 0, function(toggle)
    killAllOn = toggle
    if killAllOn then
        statusLabel.Text = "⚔️ Kill All ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        statusLabel.Text = "⚔️ Kill All DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end, Color3.fromRGB(255, 100, 100))

local tpButton = createButton("TP All (Jugador por jugador)", 1, function(toggle)
    tpAllOn = toggle
    if tpAllOn then
        statusLabel.Text = "🌀 TP All ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
    else
        statusLabel.Text = "🌀 TP All DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end, Color3.fromRGB(100, 100, 255))

local speedButton = createButton("Speed x60", 2, function(toggle)
    speedOn = toggle
    if speedOn then
        setSpeed(speedVal)
        statusLabel.Text = "💨 Speed ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 255)
    else
        setSpeed(16)
        statusLabel.Text = "💨 Speed DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end, Color3.fromRGB(100, 255, 255))

local respawnButton = createButton("Auto Respawn", 3, function(toggle)
    respawnOn = toggle
    if respawnOn then
        deathPos = Root.Position
        statusLabel.Text = "💀 Auto Respawn ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    else
        statusLabel.Text = "💀 Auto Respawn DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end, Color3.fromRGB(255, 255, 100))

-- Toggle menú minimizable
toggleBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = not contentFrame.Visible
    toggleBtn.Text = contentFrame.Visible and "➖" or "➕"
    local newSize = contentFrame.Visible and UDim2.new(0, 240, 0, 350) or UDim2.new(0, 240, 0, 50)
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = newSize}):Play()
end)

if UserInputService.TouchEnabled then
    toggleBtn.TouchTap:Connect(function()
        contentFrame.Visible = not contentFrame.Visible
        toggleBtn.Text = contentFrame.Visible and "➖" or "➕"
        local newSize = contentFrame.Visible and UDim2.new(0, 240, 0, 350) or UDim2.new(0, 240, 0, 50)
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = newSize}):Play()
    end)
end

-- Actualizar contador de jugadores cada 5 segundos si no hay kill ni tp activo
spawn(function()
    while true do
        if not killAllOn and not tpAllOn then
            statusLabel.Text = "🟢 Listo | Jugadores: " .. (#Players:GetPlayers()-1)
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
        task.wait(5)
    end
end)

-- Inicializar loops y noclip
killAllLoop()
tpAllLoop()
noclipLoop()
setupRespawn()

print("✅ Premium Prison Life Mod cargado")