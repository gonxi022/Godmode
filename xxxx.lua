-- Menú arrastrable + ESP rol asesino MM2 + loadstring script externo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DragMenuGui"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Variables estado menú y funcionalidades
local menuOpen = false
local dragToggle = false
local dragInput, dragStart, startPos
local espEnabled = false
local scriptActive = false

-- Tabla para guardar las etiquetas ESP
local espLabels = {}

-- Función para hacer frame arrastrable
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Icono arrastrable para abrir/cerrar menú
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = ScreenGui
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleButton.Image = "rbxassetid://6023426915"
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true

makeDraggable(toggleButton)

-- Panel principal oculto inicialmente
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = ScreenGui
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0, 70, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true

-- Crear botones
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.AutoButtonColor = true
    btn.Parent = mainFrame

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Función para crear etiquetas ESP sobre jugadores
local function createESPLabel(player)
    if espLabels[player] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.Adornee = nil
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(0,1,0)
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = player.Name
    label.Parent = billboard

    espLabels[player] = {billboard = billboard, label = label}
end

-- Actualizar ESP de jugadores
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espLabels[player] then
                createESPLabel(player)
            end

            local role = nil
            -- Buscar rol en PlayerGui
            local gui = player:FindFirstChildOfClass("PlayerGui")
            if gui then
                local roleGui = gui:FindFirstChild("Role")
                if roleGui and roleGui:IsA("TextLabel") then
                    role = roleGui.Text
                end
            end

            -- Como respaldo
            if not role then
                local roleVal = player:FindFirstChild("Role") or player:FindFirstChild("role")
                if roleVal and roleVal:IsA("StringValue") then
                    role = roleVal.Value
                end
            end

            -- Setear adornee y color según rol
            local espData = espLabels[player]
            espData.billboard.Adornee = player.Character.HumanoidRootPart

            if role then
                local r = role:lower()
                if r == "murderer" or r == "asesino" or r == "assassin" then
                    espData.label.TextColor3 = Color3.new(1,0,0)
                    espData.label.Text = player.Name.." [Asesino]"
                elseif r == "sheriff" then
                    espData.label.TextColor3 = Color3.new(0,0,1)
                    espData.label.Text = player.Name.." [Sheriff]"
                else
                    espData.label.TextColor3 = Color3.new(0,1,0)
                    espData.label.Text = player.Name.." [Inocente]"
                end
            else
                espData.label.TextColor3 = Color3.new(0,1,0)
                espData.label.Text = player.Name.." [Inocente]"
            end
        else
            -- Quitar etiqueta si no está el personaje o es local
            if espLabels[player] then
                espLabels[player].billboard:Destroy()
                espLabels[player] = nil
            end
        end
    end
end

-- Limpiar todas las etiquetas ESP
local function clearESP()
    for player, data in pairs(espLabels) do
        data.billboard:Destroy()
        espLabels[player] = nil
    end
end

-- Botones del menú
local espBtn = createButton("ESP: OFF", 10, function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP: ON"
    else
        espBtn.Text = "ESP: OFF"
        clearESP()
    end
end)

local activateBtn = createButton("Activar Script", 60, function()
    if not scriptActive then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gonxi022/God/refs/heads/main/22k.lua"))()
        scriptActive = true
        activateBtn.Text = "Script Activado"
        activateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

local deactivateBtn = createButton("Resetear (Reiniciar)", 110, function()
    activateBtn.Text = "Activar Script"
    activateBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    scriptActive = false
    clearESP()
    espEnabled = false
    espBtn.Text = "ESP: OFF"
    LocalPlayer:LoadCharacter()
end)

-- Loop para actualizar ESP mientras esté activo
RunService.Heartbeat:Connect(function()
    if espEnabled then
        updateESP()
    end
end)

-- Toggle menú
toggleButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
end)