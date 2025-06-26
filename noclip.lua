local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- create the UI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = Player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 140)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

-- noclip button
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0, 200, 0, 50)
noclipButton.Position = UDim2.new(0.5, -100, 0, 10)
noclipButton.BackgroundColor3 = Color3.fromRGB(77, 77, 77)
noclipButton.TextColor3 = Color3.new(1,1,1)
noclipButton.Text = "Noclip: Off"
noclipButton.Parent = mainFrame

local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0, 10)
noclipCorner.Parent = noclipButton

-- exit button
local exitButton = Instance.new("TextButton")
exitButton.Size = UDim2.new(0, 200, 0, 50)
exitButton.Position = UDim2.new(0.5, -100, 0, 80)
exitButton.BackgroundColor3 = Color3.fromRGB(77, 77, 77)
exitButton.TextColor3 = Color3.new(1,1,1)
exitButton.Text = "Exit"
exitButton.Parent = mainFrame

local exitCorner = Instance.new("UICorner")
exitCorner.CornerRadius = UDim.new(0, 10)
exitCorner.Parent = exitButton

-- noclip logic
local noclipOn = false
local originalCollisions = {}

local function toggleNoclip()
    noclipOn = not noclipOn
    noclipButton.Text = noclipOn and "Noclip: On" or "Noclip: Off"
    
    if noclipOn then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollisions[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    else
        for part, canCollide in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        originalCollisions = {}
    end
end

-- keep noclip working even when jumping or moving
RunService.Stepped:Connect(function()
    if noclipOn and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- handle character respawns
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    if noclipOn then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

noclipButton.MouseButton1Click:Connect(toggleNoclip)

exitButton.MouseButton1Click:Connect(function()
    if noclipOn then toggleNoclip() end
    screenGui:Destroy()
end)
