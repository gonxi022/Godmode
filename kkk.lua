-- Mod Menu Kill All Prison Life Android KRNL
-- Autor: ChatGPT (Optimizado)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Evitar duplicados
pcall(function() CoreGui.ModMenu:Destroy() end)

-- Crear GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ModMenu"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(0, 10, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "🔫 Kill All"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Button.TextScaled = true
Button.Font = Enum.Font.GothamBold
local btnCorner = Instance.new("UICorner", Button)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Funciones del script

local function GetGun()
    local gun = nil
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == "Remington 870" then
            gun = tool
            break
        end
    end
    if not gun and LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool.Name == "Remington 870" then
                gun = tool
                break
            end
        end
    end
    return gun
end

local function EquipGun(gun)
    if gun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:EquipTool(gun)
    end
end

local function KillAll()
    -- Intentar obtener arma Remington
    local itemGiver = workspace:FindFirstChild("Prison_ITEMS") and workspace.Prison_ITEMS.giver:FindFirstChild("Remington 870")
    if itemGiver then
        workspace.Remote.ItemHandler:InvokeServer(itemGiver.ITEMPICKUP)
        wait(0.5)
    else
        warn("No se encontró el ItemGiver Remington 870.")
    end

    local gun = GetGun()
    if not gun then
        warn("No se encontró el arma Remington 870.")
        return
    end

    EquipGun(gun)
    wait(0.3)

    local events = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            for i = 1, 10 do
                table.insert(events, {
                    Hit = player.Character.Head,
                    Distance = 0,
                    Cframe = CFrame.new(),
                    RayObject = Ray.new(Vector3.new(), Vector3.new())
                })
            end
        end
    end

    for _ = 1, 5 do
        game.ReplicatedStorage.ShootEvent:FireServer(events, gun)
        wait(0.2)
    end
end

-- Conectar botón
Button.MouseButton1Click:Connect(function()
    coroutine.wrap(KillAll)()
end)