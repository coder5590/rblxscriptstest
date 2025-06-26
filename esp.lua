--// services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// cleanup old esp
local oldFolder = CoreGui:FindFirstChild("ESP")
if oldFolder then oldFolder:Destroy() end

--// esp folder
local EspFolder = Instance.new("Folder")
EspFolder.Name = "ESP"
EspFolder.Parent = CoreGui

--// state
local EspEnabled = false
local playerEspData = {}

--// outline box
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

--// health label
local function createHealthBillboard(character)
	local head = character:FindFirstChild("Head")
	if not head then return end

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
	textLabel.TextSize = 18
	textLabel.Text = "Health: 0"
	textLabel.Parent = billboard

	return billboard, textLabel
end

--// setup esp
local function setupEspForPlayer(player)
	if not EspEnabled or playerEspData[player] or player == LocalPlayer then return end
	if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character:FindFirstChild("Dead") then return end

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

--// clear esp
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

--// enable
local function enableEsp()
	if EspEnabled then return end
	EspEnabled = true

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			setupEspForPlayer(player)
		end
	end
end

--// disable
local function disableEsp()
	EspEnabled = false
	for player, _ in pairs(playerEspData) do
		clearEspForPlayer(player)
	end
	EspFolder:ClearAllChildren()
end

--// gui
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.Name = "ESPGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 10)
toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 22
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

local exit = Instance.new("TextButton", frame)
exit.Size = UDim2.new(0, 200, 0, 50)
exit.Position = UDim2.new(0.5, -100, 0, 70)
exit.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
exit.TextColor3 = Color3.new(1,1,1)
exit.Font = Enum.Font.SourceSansBold
exit.TextSize = 22
exit.Text = "Exit"
Instance.new("UICorner", exit).CornerRadius = UDim.new(0, 10)

-- set button state on load
local function updateToggleUI()
	if EspEnabled then
		toggle.Text = "ESP: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		toggle.Text = "ESP: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end

updateToggleUI()

toggle.MouseButton1Click:Connect(function()
	if EspEnabled then
		disableEsp()
	else
		enableEsp()
	end
	updateToggleUI()
end)

exit.MouseButton1Click:Connect(function()
	disableEsp()
	gui:Destroy()
end)

--// update health every frame
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

--// character respawn handling
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if EspEnabled then
			task.wait(1) -- wait for char to fully load
			setupEspForPlayer(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	clearEspForPlayer(player)
end)

--// keep checking for valid targets
RunService.Heartbeat:Connect(function()
	if not EspEnabled then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if not playerEspData[player] then
				setupEspForPlayer(player)
			end
		end
	end
end)
