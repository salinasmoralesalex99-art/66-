-- LocalScript dentro de StarterGui
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- Frame contenedor (compacto)
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 180, 0, 160)
menuFrame.Position = UDim2.new(0, 20, 0, 50)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.BorderSizePixel = 0
menuFrame.Parent = screenGui

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,0,0,25)
titleLabel.Position = UDim2.new(0,0,0,0)
titleLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Fast Steal🔥"
titleLabel.TextColor3 = Color3.fromRGB(0,255,0)
titleLabel.TextScaled = true
titleLabel.Parent = menuFrame

-- Hacer menú movible
local dragging = false
local dragStart, startPos, dragInput

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

runService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Función para crear botones
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,160,0,35)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.BackgroundColor3 = Color3.fromRGB(255,0,0) -- Apagado: rojo
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.TextScaled = true
    btn.Parent = menuFrame
    return btn
end

-- Botones
local noclipButton = createButton("👻 Noclip: OFF", 35)
local boostButton = createButton("⚡ Super Boost: OFF", 75)
local mapButton = createButton("⬇ Go Down", 115)

-- Variables
local noclipEnabled = false
local boostEnabled = false
local belowMap = false
local savedPosition = nil

-- Hitbox
local hitbox = Instance.new("Part")
hitbox.Size = Vector3.new(4,4,4)
hitbox.Shape = Enum.PartType.Ball
hitbox.Anchored = true
hitbox.CanCollide = false
hitbox.Material = Enum.Material.Neon
hitbox.Color = Color3.fromRGB(255,0,0)
hitbox.Parent = workspace
hitbox.Transparency = 1

-- Función para actualizar color del botón
local function updateButtonColor(button, enabled)
    button.BackgroundColor3 = enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end

-- Noclip 👻
noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "👻 Noclip: ON" or "👻 Noclip: OFF"
    updateButtonColor(noclipButton, noclipEnabled)
    
    if noclipEnabled then
        runService.Stepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(11)
            end
        end)
    end
end)

-- Super Boost ⚡
boostButton.MouseButton1Click:Connect(function()
    boostEnabled = not boostEnabled
    boostButton.Text = boostEnabled and "⚡ Super Boost: ON" or "⚡ Super Boost: OFF"
    updateButtonColor(boostButton, boostEnabled)

    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.JumpPower = boostEnabled and 150 or 50
        humanoid.WalkSpeed = boostEnabled and 50 or 16
    end
end)

-- Bajar debajo del mapa / volver
mapButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    if not belowMap then
        savedPosition = hrp.Position
        hrp.CFrame = CFrame.new(hrp.Position.X, -500, hrp.Position.Z)
        belowMap = true
        mapButton.Text = "⬆ Return Up"
        hitbox.Transparency = 0
        updateButtonColor(mapButton, true)
    else
        hrp.CFrame = CFrame.new(savedPosition)
        belowMap = false
        mapButton.Text = "⬇ Go Down"
        hitbox.Transparency = 1
        updateButtonColor(mapButton, false)
    end
end)

-- Actualizar hitbox
runService.RenderStepped:Connect(function()
    if belowMap and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        hitbox.Position = player.Character.HumanoidRootPart.Position
        hitbox.Color = Color3.fromRGB(0,255,0)
    end
end)
