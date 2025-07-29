local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local killAllActivo = false
local godModeActivo = false

local function crearBoton(texto, posicion, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 140, 0, 45)
    boton.Position = posicion
    boton.BackgroundColor3 = Color3.fromRGB(30,30,30)
    boton.TextColor3 = Color3.fromRGB(255,255,255)
    boton.TextScaled = true
    boton.Text = texto
    boton.Active = true
    boton.Draggable = true
    boton.Parent = screenGui
    boton.MouseButton1Click:Connect(callback)
    return boton
end

local function notificar(texto)
    local notif = Instance.new("TextLabel", screenGui)
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundTransparency = 0.4
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    notif.Text = texto
    game:GetService("Debris"):AddItem(notif, 2)
end

-- Loop Kill All Global
local function loopKillAll()
    local originalPos = Root.CFrame
    while killAllActivo do
        for _, player in pairs(Players:GetPlayers()) do
            if not killAllActivo then break end
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local targetHumanoid = player.Character.Humanoid
                if targetHumanoid.Health > 0 then
                    local targetRoot = player.Character.HumanoidRootPart
                    -- Spoofea posición rápida
                    Root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 1))
                    task.wait(0.01)
                    for i = 1, 40 do
                        meleeEvent:FireServer(player)
                    end
                    -- Teleport real rápido para casos de jugadores muy pegados
                    Root.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 1)
                    task.wait(0.02)
                end
            end
        end
        Root.CFrame = originalPos
        task.wait(0.1)
    end
    Root.CFrame = originalPos
end

-- Toggle Kill All
local function toggleKillAll()
    killAllActivo = not killAllActivo
    if killAllActivo then
        notificar("Kill All Global iniciado")
        spawn(loopKillAll)
    else
        notificar("Kill All Global detenido")
    end
end

-- Toggle God Mode
local function toggleGodMode()
    godModeActivo = not godModeActivo
    if godModeActivo then
        notificar("God Mode ACTIVADO")
    else
        notificar("God Mode DESACTIVADO")
    end
end

RunService.Heartbeat:Connect(function()
    if godModeActivo and Humanoid then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        if Root.Velocity.Y < -100 then
            Root.Velocity = Vector3.new(0,0,0)
        end
    end
end)

crearBoton("☢️ Kill All Global", UDim2.new(0, 50, 0, 150), toggleKillAll)
crearBoton("🛡️ God Mode", UDim2.new(0, 50, 0, 210), toggleGodMode)