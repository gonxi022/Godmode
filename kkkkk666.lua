local gui = Instance.new("ScreenGui")
gui.Name = "VelocidadGui"
gui.ResetOnSpawn = false
gui.Parent =
game.Players.LocalPlayer:WaitForChild("PlayerGui")

local boton =
Instance.new("TextButton")
boton.Parent = gui 
boton.Size = UDim2.new(0, 150, 0, 50)
boton.Position = UDim2.new(0, 20, 0, 100)
boton.Text = "Activar Velocidad"
boton.BackgroundColor3 =
Color3.fromRGB(0, 170, 255)
boton.TextColor3 = Color3.new(1, 1, 1)
boton.Font = Enum.Font.SourceSans
boton.TextSize = 18

local velocidadActiva = false

boton.MouseButton1Click:Connect(function()
  
  local Player =
  game.Players.LocalPlayer
  local char = Player.Character or Player.CharacterAdded:Wait()
  local humanoid =
  char:FindFirstChildOfClass("Humanoid")
  
  if humanoid then
    if velocidadActiva then
     humanoid.WalkSpeed = 16
     boton.Text = "Activar Velocidad"
     
     velocidadActiva = false
     else 
       humanoid.WalkSpeed = 50 
       boton.Text = "Desactivar Velocidad"
       
       velocidadActiva = true 
    end
  end
end)