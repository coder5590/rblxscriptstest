--// SERVICES
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

--// ESP FOLDER
local EspFolder = Instance.new("Folder")
EspFolder.Name  = "ESP"
EspFolder.Parent= game:GetService("CoreGui")

--// STATE
local EspEnabled    = false
local playerEspData = {}

--// HELPERS ----------------------------------------------------
local function isAlive(char)
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function createOutline(part)
    local a = Instance.new("BoxHandleAdornment")
    a.Adornee, a.AlwaysOnTop, a.ZIndex = part, true, 10
    a.Transparency, a.Color3 = 0.5, Color3.fromRGB(0,255,0)
    a.Size, a.Parent = part.Size + Vector3.new(.05,.05,.05), EspFolder
    return a
end

local function createBillboard(char)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Adornee, bill.Size = head, UDim2.new(0,100,0,40)
    bill.StudsOffset, bill.AlwaysOnTop, bill.MaxDistance = Vector3.new(0,2.5,0), true, 50
    bill.Parent = EspFolder

    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Font, txt.TextSize = Enum.Font.SourceSansBold, 18
    txt.TextColor3, txt.TextStrokeColor3 = Color3.new(1,1,1), Color3.new(0,0,0)
    txt.TextStrokeTransparency, txt.Text = 0, "Health: 0"

    return bill, txt
end

local function clearEsp(plr)
    local d = playerEspData[plr]
    if not d then return end
    for _,a in pairs(d.Adorns) do a:Destroy() end
    if d.Billboard then d.Billboard:Destroy() end
    playerEspData[plr] = nil
end

local function setupEsp(plr)
    if not EspEnabled or plr==LocalPlayer or playerEspData[plr] then return end
    if not plr.Character or not isAlive(plr.Character) then return end

    local adorns = {}
    for _,p in ipairs(plr.Character:GetChildren()) do
        if p:IsA("BasePart") then adorns[#adorns+1] = createOutline(p) end
    end
    local bill, txt = createBillboard(plr.Character)
    if not bill then return end

    playerEspData[plr] = {Adorns=adorns,Billboard=bill,HealthText=txt,Character=plr.Character}
end

local function enableEsp()
    if EspEnabled then return end
    EspEnabled = true
    for _,p in ipairs(Players:GetPlayers()) do setupEsp(p) end
end
local function disableEsp()
    EspEnabled = false
    for p in pairs(playerEspData) do clearEsp(p) end
end

--// GUI --------------------------------------------------------
local gui    = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local frame  = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active, frame.Draggable = true, true
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0,200,0,50)
toggle.Position = UDim2.new(0.5,-100,0,10)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 22
toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)

local exit = toggle:Clone()
exit.Parent = frame
exit.Position = UDim2.new(0.5,-100,0,70)
exit.Text = "Exit"

--▼ NEW: helper keeps button visuals in sync
local function refreshToggleVisual()
    if EspEnabled then
        toggle.Text = "ESP: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggle.Text = "ESP: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(70,70,70)
    end
end
refreshToggleVisual() -- set correct state at startup

toggle.MouseButton1Click:Connect(function()
    if EspEnabled then disableEsp() else enableEsp() end
    refreshToggleVisual()
end)

exit.MouseButton1Click:Connect(function()
    disableEsp()
    gui:Destroy()
end)

--// UPDATE LOOPS ----------------------------------------------
RunService.RenderStepped:Connect(function()
    if not EspEnabled then return end
    for plr,data in pairs(playerEspData) do
        local hum = data.Character and data.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then data.HealthText.Text = "Health: " .. math.floor(hum.Health) end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        if EspEnabled then clearEsp(plr) setupEsp(plr) end
    end)
end)
Players.PlayerRemoving:Connect(clearEsp)

RunService.Heartbeat:Connect(function()
    if not EspEnabled then return end
    for plr,data in pairs(playerEspData) do
        if not isAlive(plr.Character) then clearEsp(plr) end
    end
    for _,plr in ipairs(Players:GetPlayers()) do setupEsp(plr) end
end)

