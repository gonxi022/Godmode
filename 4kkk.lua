local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- UI Container
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- Botón Kill All
local killAllBtn = Instance.new("TextButton")
killAllBtn.Text = "🔥 Kill All"
killAllBtn.Size = UDim2.new(0, 120, 0, 50)
killAllBtn.Position = UDim2.new(0, 0, 0.4, 0)
killAllBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
killAllBtn.TextScaled = true
killAllBtn.Parent = gui

-- Botón para abrir panel de matar a uno
local openKillOneBtn = Instance.new("TextButton")
openKillOneBtn.Text = "🎯 Target"
openKillOneBtn.Size = UDim2.new(0, 120, 0, 50)
openKillOneBtn.Position = UDim2.new(0, 0, 0.5, 0)
openKillOneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
openKillOneBtn.TextScaled = true
openKillOneBtn.Parent = gui

-- Panel de matar a uno
local targetPanel = Instance.new("Frame")
targetPanel.Size = UDim2.new(0, 220, 0, 100)
targetPanel.Position = UDim2.new(0, 130, 0.45, 0)
targetPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
targetPanel.Visible = false
targetPanel.Parent = gui

local targetBox = Instance.new("TextBox", targetPanel)
targetBox.Size = UDim2.new(0, 200, 0, 40)
targetBox.Position = UDim2.new(0, 10, 0, 5)
targetBox.PlaceholderText = "Nombre exacto"
targetBox.TextScaled = true

local killBtn = Instance.new("TextButton", targetPanel)
killBtn.Text = "KILL"
killBtn.Size = UDim2.new(0, 200, 0, 40)
killBtn.Position = UDim2.new(0, 10, 0, 50)
killBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
killBtn.TextScaled = true

-- Funciones
local function killPlayer(p)
    if p.Character and p.Character:FindFirstChild("Humanoid") then
        p.Character.Humanoid.Health = 0
    end
end

killAllBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            killPlayer(p)
        end
    end
end)

openKillOneBtn.MouseButton1Click:Connect(function()
    targetPanel.Visible = not targetPanel.Visible
end)

killBtn.MouseButton1Click:Connect(function()
    local name = targetBox.Text
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then
            killPlayer(p)
            break
        end
    end
end)