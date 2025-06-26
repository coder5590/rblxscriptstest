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
    if playerEspData[player] then return end -- already setup

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

    -- setup existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            setupEspForPlayer(player)
        end
        -- connect to CharacterAdded to setup esp if player respawns
        player.CharacterAdded:Connect(function()
            if EspEnabled then
                setupEspForPlayer(player)
            end
        end)
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

    -- constantly check for any players missing esp (handles edge cases and late joins)
    coroutine.wrap(function()
        while EspEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    setupEspForPlayer(player)
                end
            end
            wait(1) -- check every second
        end
    end)()
end

local function disableEsp()
    EspEnabled = false
    for player, _ in pairs(playerEspData) do
        clearEspForPlayer(player)
    end
end

-- gui setup, toggle, render update stays same
-- ...

