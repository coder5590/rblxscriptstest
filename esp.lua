-- services
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

------------------------------------------------------------------
--  esp folder
------------------------------------------------------------------
local EspFolder = Instance.new("Folder")
EspFolder.Name  = "ESP"
EspFolder.Parent= game:GetService("CoreGui")

------------------------------------------------------------------
--  state tables
------------------------------------------------------------------
local EspEnabled     = false
local playerEspData  = {}  -- [player] = {Adorns, Billboard, HealthText, Character}

------------------------------------------------------------------
--  helper: only true for living characters (skip ragdolls)
------------------------------------------------------------------
local function isAlive(char)
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

------------------------------------------------------------------
--  outline creator
------------------------------------------------------------------
local function createOutline(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee       = part
    box.AlwaysOnTop   = true
    box.ZIndex        = 10
    box.Transparency  = 0.5
    box.Color3        = Color3.fromRGB(0,255,0)
    box.Size          = part.Size + Vector3.new(.05,.05,.05)
    box.Parent        = EspFolder
    return box
end

------------------------------------------------------------------
--  health billboard
------------------------------------------------------------------
local function createBillboard(char)
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bill = Instance.new("BillboardGui")
    bill.Size           = UDim2.new(0,100,0,40)
    bill.StudsOffset    = Vector3.new(0,2.5,0)
    bill.AlwaysOnTop    = true
    bill.MaxDistance    = 50
    bill.Adornee        = head
    bill.Parent         = EspFolder

    local txt = Instance.new("TextLabel", bill)
    txt.Size                = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency=1
    txt.Font                = Enum.Font.SourceSansBold
    txt.TextSize            = 18
    txt.TextColor3          = Color3.new(1,1,1)
    txt.TextStrokeColor3    = Color3.new(0,0,0)
    txt.TextStrokeTransparency=0
    txt.Text                = "Health: 0"

    return bill, txt
end

------------------------------------------------------------------
--  clear esp for one player
------------------------------------------------------------------
local function clearEsp(plr)
    local data = playerEspData[plr]
    if not data then return end
    for _,a in pairs(data.Adorns) do a:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    playerEspData[plr] = nil
end

------------------------------------------------------------------
--  setup esp for one player
------------------------------------------------------------------
local function setupEsp(plr)
    if not EspEnabled then return end
    if plr == LocalPlayer or playerEspData[plr] then return end
    if not plr.Character or not isAlive(plr.Character) then return end

    local char   = plr.Character
    local adorns = {}
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            adorns[#adorns+1] = createOutline(part)
        end
    end
    local bill, txt = createBillboard(char)
    if not bill then return end

    playerEspData[plr] = {Adorns=adorns,Billboard=bill,HealthText=txt,Character=char}
end

------------------------------------------------------------------
--  master enable / disable
------------------------------------------------------------------
local function enableEsp()
    if EspEnabled then return end
    EspEnabled = true
    -- give esp to everyone currently alive
    for _,p in ipairs(Players:GetPlayers()) do setupEsp(p) end
end

local function disableEsp()
    EspEnabled = false
    for p in pairs(playerEspData) do clearEsp(p) end
end

------------------------------------------------------------------
--  gui (minimal toggle + exit)  – unchanged from before
------------------------------------------------------------------
local screen = Instance.new("ScreenGui",LocalPlayer.PlayerGui)
local frame  = Instance.new("Frame",screen)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active,frame.Draggable=true,true
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local toggle = Instance.new("TextButton",frame)
toggle.Size = UDim2.new(0,200,0,50)
toggle.Position=UDim2.new(0.5,-100,0,10)
toggle.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggle.Font=Enum.Font.SourceSansBold toggle.TextSize=22
toggle.TextColor3=Color3.new(1,1,1) toggle.Text="ESP: OFF"

local exit = toggle:Clone()
exit.Parent=frame exit.Position=UDim2.new(0.5,-100,0,70) exit.Text="Exit"

toggle.MouseButton1Click:Connect(function()
    if EspEnabled then
        disableEsp()
        toggle.Text="ESP: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(70,70,70)
    else
        enableEsp()
        toggle.Text="ESP: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    end
end)

exit.MouseButton1Click:Connect(function()
    disableEsp()
    screen:Destroy()
end)

------------------------------------------------------------------
--  update health text every frame
------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not EspEnabled then return end
    for plr,data in pairs(playerEspData) do
        local hum = data.Character and data.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            data.HealthText.Text = "Health: " .. math.floor(hum.Health)
        end
    end
end)

------------------------------------------------------------------
--  connections for joins / respawns / ragdoll cleanup
------------------------------------------------------------------
Players.PlayerAdded:Connect(function(plr)
    -- give esp if already enabled once their rig spawns
    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        if EspEnabled then
            clearEsp(plr)
            setupEsp(plr)
        end
    end)
end)

Players.PlayerRemoving:Connect(clearEsp)

-- heartbeat: remove dead bodies, add missing live ones
RunService.Heartbeat:Connect(function()
    if not EspEnabled then return end
    for plr,data in pairs(playerEspData) do
        if not isAlive(plr.Character) then
            clearEsp(plr)
        end
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        setupEsp(plr)
    end
end)
