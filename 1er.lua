local gui = Instance.new("ScreenGui")
gui.Name = "VelocidadGui"
gui.Parent =
game.Players.LocalPlayer:WaitForChild
("PlayerGui")

local boton =
Instance.new("TextButton")
boton.Parent = gui 
boton.Size = UDim2.new(0, 120, 0, 40)
boton.Position = UDim2.new(0, 10, 0, 10)
boton.Text = ("Velocidad x3")
boton.BackgroundColor3 =
Color3.fromRGB(0, 170, 255)
boton.TextColor3 = Color3.new(1, 1, 1)
boton.Font = Enum.Font.SourceSans
boton.TextSize = 18

boton.MouseButton1Click:Connect(function()
  local player = 
  game.Players.LocalPlayer 
  local char = player.Character or
  player.CharacterAdded:Wait()
  local humanoid =
  char:WaitForChild("Humanoid")
  humanoid.WalkSpeed = 50
end)