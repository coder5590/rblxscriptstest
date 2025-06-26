local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local EspFolder = Instance.new("Folder")
EspFolder.Name = "ESP"
EspFolder.Parent = game:GetService("CoreGui")

local EspEnabled = false
local playerEspData = {}

local function createOutline(part)
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.AlwaysOnTop = true
    adorn.ZIndex = 10
    adorn.Transparency = 0.5
    adorn.Color3 = Color3.fromRGB(0, 255, 0)
    adorn.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
    adorn.Parent = EspFolder
    return adorn
end

local function createHealthBillboard(character)
    local head = character:WaitForChild("Head")
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 50
    billboard.Parent = EspFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = false
    textLabel.TextSize = 18
    textLabel.Text = "Health: 0"
    textLabel.Parent = billboard

    return billboard, textLabel
end

local function setupEspForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local character = player.Character

    local adorns = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            adorns[part] = createOutline(part)
        end
    end

    local billboard, healthText = createHealthBillboard(character)

    playerEspData[player] = {
        Adorns = adorns,
        Billboard = billboard,
        HealthText = healthText,
        Character = character,
    }
end

local function clearEspForPlayer(player)
    if playerEspData[player] then
        for _, adorn in pairs(playerEspData[player].Adorns) do
            adorn:Destroy()
        end
        if playerEspData[player].Billboard then
            playerEspData[player].Billboard:Destroy()
        end
        playerEspData[player] = nil
    end
end

local function enableEsp()
    if EspEnabled then return end
    EspEnabled = true

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            setupEspForPlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            if EspEnabled then
                setupEspForPlayer(player)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        clearEspForPlayer(player)
    end)
end

local function disableEsp()
    EspEnabled = false
    for player, _ in pairs(playerEspData) do
        clearEspForPlayer(player)
    end
end

-- gui setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.Text = "ESP: OFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22
ToggleButton.Parent = MainFrame

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0, 200, 0, 50)
ExitButton.Position = UDim2.new(0.5, -100, 0, 70)
ExitButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ExitButton.Text = "Exit"
ExitButton.TextColor3 = Color3.new(1,1,1)
ExitButton.Font = Enum.Font.SourceSansBold
ExitButton.TextSize = 22
ExitButton.Parent = MainFrame

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 10)
UICorner1.Parent = ToggleButton

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = ExitButton

ToggleButton.MouseButton1Click:Connect(function()
    if EspEnabled then
        disableEsp()
        ToggleButton.Text = "ESP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    else
        enableEsp()
        ToggleButton.Text = "ESP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

ExitButton.MouseButton1Click:Connect(function()
    if EspEnabled then
        disableEsp()
    end
    ScreenGui:Destroy()
end)

RunService.RenderStepped:Connect(function()
    if not EspEnabled then return end
    for player, data in pairs(playerEspData) do
        if data.Character and data.HealthText then
            local humanoid = data.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                data.HealthText.Text = "Health: " .. math.floor(humanoid.Health)
            else
                data.HealthText.Text = "Health: N/A"
            end
        end
    end
end)
