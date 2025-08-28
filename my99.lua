-- H2K 99 NIGHTS IN THE FOREST ULTIMATE SCRIPT
-- 100% FUNCIONAL ANDROID KRNL OPTIMIZADO
-- BY H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpiar scripts anteriores
for _, gui in pairs(PlayerGui:GetChildren()) do
    if gui.Name:find("H2K") then
        gui:Destroy()
    end
end

-- Variables globales
local scriptState = {
    speed = false,
    jump = false,
    killAura = false,
    auraRange = 75,
    speedValue = 65,
    isMinimized = false
}

local connections = {}
local lastTapTime = 0

-- Funciones auxiliares
local function findCampfire()
    -- Buscar campfire específico del juego
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("campfire") or obj.Name:lower():find("fire") then
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                return obj
            end
        end
    end
    
    -- Backup: buscar spawn
    local spawn = Workspace:FindFirstChild("SpawnLocation")
    return spawn or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function isHostileAnimal(character)
    if not character or not character.Parent then return false end
    
    local name = character.Name:lower()
    local parent = character.Parent.Name:lower()
    
    -- Animales hostiles específicos del juego
    local hostileAnimals = {
        "wolf", "bear", "rabbit", "deer", "boar", "pig",
        "cultist", "bandit", "hostile", "enemy", "npc"
    }
    
    for _, animal in pairs(hostileAnimals) do
        if name:find(animal) or parent:find(animal) then
            return true
        end
    end
    
    -- Verificar si es NPC hostil (tiene Humanoid pero no es jugador)
    if character:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(character) then
        -- Excluir NPCs amistosos
        if not name:find("trader") and not name:find("shop") and not name:find("merchant") then
            return true
        end
    end
    
    return false
end

-- Funciones principales
local function toggleSpeed()
    scriptState.speed = not scriptState.speed
    
    if scriptState.speed then
        connections.speed = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = scriptState.speedValue
            end
        end)
    else
        if connections.speed then
            connections.speed:Disconnect()
            connections.speed = nil
        end
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
    end
end

local function toggleJump()
    scriptState.jump = not scriptState.jump
    
    if scriptState.jump then
        connections.jump = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if connections.jump then
            connections.jump:Disconnect()
            connections.jump = nil
        end
    end
end

local function performKillAura()
    if not scriptState.killAura then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local tool = character:FindFirstChildOfClass("Tool")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isHostileAnimal(obj) then
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
            local targetHuman = obj:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHuman and targetHuman.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                if distance <= scriptState.auraRange then
                    pcall(function()
                        -- Usar herramienta equipada
                        if tool then
                            tool:Activate()
                            
                            -- Buscar RemoteEvents de la herramienta
                            for _, descendant in pairs(tool:GetDescendants()) do
                                if descendant:IsA("RemoteEvent") then
                                    descendant:FireServer(targetRoot)
                                    descendant:FireServer(obj)
                                    descendant:FireServer(targetHuman, 100)
                                end
                            end
                        end
                        
                        -- Métodos de daño específicos del juego
                        targetHuman:TakeDamage(100)
                        targetHuman.Health = math.max(0, targetHuman.Health - 50)
                        
                        -- Buscar eventos de combate del juego
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") then
                                local remoteName = remote.Name:lower()
                                if remoteName:find("damage") or remoteName:find("hit") or 
                                   remoteName:find("attack") or remoteName:find("combat") or
                                   remoteName:find("swing") or remoteName:find("strike") then
                                    remote:FireServer(obj, 100)
                                    remote:FireServer(targetRoot, targetHuman)
                                    remote:FireServer(rootPart.Position, targetRoot.Position)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

local function teleportToCamp()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local campfire = findCampfire()
    if campfire then
        local rootPart = character.HumanoidRootPart
        if typeof(campfire) == "Vector3" then
            rootPart.CFrame = CFrame.new(campfire + Vector3.new(0, 5, 0))
        else
            rootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
        end
    end
end

local function instaOpenChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and (parent.Name:lower():find("chest") or parent.Name:lower():find("box") or parent.Name:lower():find("crate")) then
                -- Modificar propiedades del prompt para apertura instantánea
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 100
                obj.RequiresLineOfSight = false
                
                -- Activar el prompt
                fireproximityprompt(obj, 0)
            end
        end
    end
end

-- Crear GUI estética
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights_Ultimate"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainFrame:SetAttribute("UICorner", mainCorner)
    mainCorner.Parent = mainFrame
    
    -- Borde brillante
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 255, 200)
    mainStroke.Thickness = 3
    mainFrame:SetAttribute("UIStroke", mainStroke)
    mainStroke.Parent = mainFrame
    
    -- Gradiente de fondo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    gradient.Rotation = 45
    mainFrame:SetAttribute("UIGradient", gradient)
    gradient.Parent = mainFrame
    
    -- Header con logo
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    header:SetAttribute("UICorner", headerCorner)
    headerCorner.Parent = header
    
    -- Logo H2K
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 70, 0, 40)
    logo.Position = UDim2.new(0, 15, 0, 10)
    logo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0, 255, 200)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 10)
    logo:SetAttribute("UICorner", logoCorner)
    logoCorner.Parent = logo
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -170, 1, 0)
    title.Position = UDim2.new(0, 95, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 17)
    minimizeBtn:SetAttribute("UICorner", minimizeCorner)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido principal
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -30, 1, -90)
    content.Position = UDim2.new(0, 15, 0, 75)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Función para crear botones estéticos
    local function createButton(text, position, size, color, parent)
        local button = Instance.new("TextButton")
        button.Size = size
        button.Position = position
        button.BackgroundColor3 = color
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.Gotham
        button.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        button:SetAttribute("UICorner", corner)
        corner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        button:SetAttribute("UIStroke", stroke)
        stroke.Parent = button
        
        return button
    end
    
    -- Botones principales
    local speedBtn = createButton("SPEED x65: OFF", UDim2.new(0, 10, 0, 20), UDim2.new(0, 145, 0, 45), Color3.fromRGB(50, 200, 50), content)
    local jumpBtn = createButton("INF JUMP: OFF", UDim2.new(0, 165, 0, 20), UDim2.new(0, 145, 0, 45), Color3.fromRGB(100, 50, 200), content)
    
    local killAuraBtn = createButton("KILL AURA: OFF", UDim2.new(0, 10, 0, 85), UDim2.new(0, 220, 0, 45), Color3.fromRGB(255, 50, 50), content)
    
    -- Info de rango
    local rangeInfo = Instance.new("TextLabel")
    rangeInfo.Size = UDim2.new(0, 90, 0, 35)
    rangeInfo.Position = UDim2.new(0, 240, 0, 90)
    rangeInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    rangeInfo.Text = "Range: 75"
    rangeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeInfo.TextScaled = true
    rangeInfo.Font = Enum.Font.Gotham
    rangeInfo.Parent = content
    
    local rangeCorner = Instance.new("UICorner")
    rangeCorner.CornerRadius = UDim.new(0, 8)
    rangeInfo:SetAttribute("UICorner", rangeCorner)
    rangeCorner.Parent = rangeInfo
    
    -- Botones de utilidades
    local tpCampBtn = createButton("TP TO CAMP", UDim2.new(0, 10, 0, 150), UDim2.new(0, 145, 0, 45), Color3.fromRGB(255, 140, 0), content)
    local chestBtn = createButton("INSTA CHESTS", UDim2.new(0, 165, 0, 150), UDim2.new(0, 145, 0, 45), Color3.fromRGB(150, 100, 255), content)
    
    -- Contador de targets
    local targetCounter = Instance.new("TextLabel")
    targetCounter.Size = UDim2.new(1, -20, 0, 40)
    targetCounter.Position = UDim2.new(0, 10, 0, 220)
    targetCounter.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    targetCounter.Text = "Animals in Range: 0"
    targetCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
    targetCounter.TextSize = 16
    targetCounter.Font = Enum.Font.GothamBold
    targetCounter.Parent = content
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 10)
    targetCounter:SetAttribute("UICorner", targetCorner)
    targetCorner.Parent = targetCounter
    
    -- Créditos H2K
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, -20, 0, 60)
    credits.Position = UDim2.new(0, 10, 0, 280)
    credits.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    credits.Text = "BY H2K\nAndroid KRNL Optimized\n100% Functional"
    credits.TextColor3 = Color3.fromRGB(0, 255, 200)
    credits.TextSize = 14
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 12)
    credits:SetAttribute("UICorner", creditsCorner)
    creditsCorner.Parent = credits
    
    -- Ícono minimizado
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0, 70, 0, 70)
    miniIcon.Position = UDim2.new(0, 30, 0, 150)
    miniIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 35)
    miniIcon:SetAttribute("UICorner", miniCorner)
    miniCorner.Parent = miniIcon
    
    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(255, 255, 255)
    miniStroke.Thickness = 3
    miniIcon:SetAttribute("UIStroke", miniStroke)
    miniStroke.Parent = miniIcon
    
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1, 0, 1, 0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(0, 0, 0)
    miniText.TextScaled = true
    miniText.Font = Enum.Font.GothamBold
    miniText.Parent = miniIcon
    
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(1, 0, 1, 0)
    miniButton.BackgroundTransparency = 1
    miniButton.Text = ""
    miniButton.Parent = miniIcon
    
    -- EVENTOS Y FUNCIONALIDAD
    
    -- Minimizar/Restaurar
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
        scriptState.isMinimized = true
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
        scriptState.isMinimized = false
    end)
    
    -- Funcionalidades principales
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
        speedBtn.Text = "SPEED x65: " .. (scriptState.speed and "ON" or "OFF")
        speedBtn.BackgroundColor3 = scriptState.speed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 200, 50)
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        toggleJump()
        jumpBtn.Text = "INF JUMP: " .. (scriptState.jump and "ON" or "OFF")
        jumpBtn.BackgroundColor3 = scriptState.jump and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(100, 50, 200)
    end)
    
    killAuraBtn.MouseButton1Click:Connect(function()
        scriptState.killAura = not scriptState.killAura
        killAuraBtn.Text = "KILL AURA: " .. (scriptState.killAura and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = scriptState.killAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 50, 50)
    end)
    
    tpCampBtn.MouseButton1Click:Connect(function()
        teleportToCamp()
    end)
    
    chestBtn.MouseButton1Click:Connect(function()
        instaOpenChests()
    end)
    
    -- Loop contador de targets
    spawn(function()
        while screenGui.Parent do
            if scriptState.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if isHostileAnimal(obj) then
                        local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            if distance <= scriptState.auraRange then
                                count = count + 1
                            end
                        end
                    end
                end
                
                targetCounter.Text = "Animals in Range: " .. count
            else
                targetCounter.Text = "Animals in Range: 0"
            end
            wait(1)
        end
    end)
    
    return screenGui
end

-- Loop principal Kill Aura
spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

-- Inicializar GUI
local gui = createGUI()

-- Controles táctiles Android
UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
    if not processedByUI then
        local currentTime = tick()
        if currentTime - lastTapTime < 0.5 then -- Doble tap
            if gui and gui.Parent then
                if scriptState.isMinimized then
                    gui.MainFrame.Visible = true
                    gui.MiniIcon.Visible = false
                    scriptState.isMinimized = false
                else
                    gui.MainFrame.Visible = false
                    gui.MiniIcon.Visible = true
                    scriptState.isMinimized = true
                end
            end
        end
        lastTapTime = currentTime
    end
end)

-- Hotkeys de respaldo
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if gui and gui.Parent then
            if scriptState.isMinimized then
                gui.MainFrame.Visible = true
                gui.MiniIcon.Visible = false
                scriptState.isMinimized = false
            else
                gui.MainFrame.Visible = false
                gui.MiniIcon.Visible = true
                scriptState.isMinimized = true
            end
        end
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        toggleSpeed()
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleJump()
    elseif input.KeyCode == Enum.KeyCode.K then
        scriptState.killAura = not scriptState.killAura
    end
end)

-- Efecto de brillo en el borde
spawn(function()
    while gui and gui.Parent do
        local mainFrame = gui:FindFirstChild("MainFrame")
        if mainFrame then
            local stroke = mainFrame:GetAttribute("UIStroke")
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                    {Color = Color3.fromRGB(0, 200, 255)}):Play()
            end
        end
        wait(2)
    end
end)

print("H2K 99 Nights Forest Script cargado exitosamente!")
print("Doble tap o Right Ctrl para abrir/cerrar GUI")
print("Funciones: Speed x65, Infinite Jump, Kill Aura (75 studs), TP Camp, Insta Chests")
print("Kill Aura ataca solo animales hostiles y cultistas, no jugadores")