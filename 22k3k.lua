local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "modMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local Noclip = Instance.new("TextButton")
Noclip.Text = "Noclip Off"
Noclip.Size = UDim2.new(0, 150, 0, 50)
Noclip.Position = UDim2.new(0, 120, 0, 20)
Noclip.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Noclip.TextColor3 = Color3.fromRGB(50, 50, 50)
Noclip.TextSize = 20
Noclip.Parent = gui
Noclip.Font = Enum.Font.SourceSans

local noclipActive = false
local RunService = game:GetService("RunService")
local noclipConnection

Noclip.MouseButton1Click:Connect(function()
  noclipActive = not noclipActive
  if noclipActive then
      Noclip.Text = "Noclip On"
      Noclip.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
  
  noclipConnection = RunService.Stepped:Connect(function()
    if player.Character then
      for _, part in 
      ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
          part.CanCollide = false
        end
      end
    end
  end)
  
 else
   Noclip.Text = "Noclip Off"
   Noclip.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
  
  if noclipConnection then
    noclipConnection:Disconnect()
    noclipConnection = nil
  end
  
  if player.Character then
    for _, part in 
    ipairs(player.Character:GetDescendants()) do
       if part:IsA("BasePart") then
         part.CanCollide = true
       end
    end
  end
end)
