local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")

local player            = Players.LocalPlayer
local character         = player.Character or player.CharacterAdded:Wait()
local humanoid          = character:WaitForChild("Humanoid")

--------------------------------------------------
-- global flags
--------------------------------------------------
local draggingSlider = false   -- true while any slider is being dragged

--------------------------------------------------
-- screen-gui container
--------------------------------------------------
local gui        = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local main       = Instance.new("Frame", gui)
main.Size        = UDim2.new(0, 450, 0, 150)
main.Position    = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
main.BorderSizePixel  = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Text  = "Speed & Jump Sliders"
title.Font  = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Size  = UDim2.new(0, 280, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------
-- slider factory
--------------------------------------------------
local yOffset = 40
local function newSlider(labelText, minV, maxV, defaultV, setter)
    local frame = Instance.new("Frame", main)
    frame.Size       = UDim2.new(0, 390, 0, 40)
    frame.Position   = UDim2.new(0, 5, 0, yOffset)
    frame.BackgroundTransparency = 1
    yOffset += 45

    local label = Instance.new("TextLabel", frame)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.Size  = UDim2.new(0, 140, 0, 30)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. defaultV

    local bar = Instance.new("Frame", frame)
    bar.Size  = UDim2.new(0, 170, 0, 12)
    bar.Position = UDim2.new(0, 150, 0, 14)
    bar.BackgroundColor3 = Color3.fromRGB(100,100,100)
    bar.ClipsDescendants = true
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(0,150,255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

    local knob = Instance.new("Frame", bar)
    knob.Size  = UDim2.new(0, 14, 1, 0)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,7)

    local input = Instance.new("TextBox", frame)
    input.Size  = UDim2.new(0, 55, 0, 26)
    input.Position = UDim2.new(0, 355, 0, 7)
    input.BackgroundColor3 = Color3.fromRGB(70,70,70)
    input.TextColor3 = Color3.new(1,1,1)
    input.Font  = Enum.Font.SourceSans
    input.TextSize = 18
    input.ClearTextOnFocus = false
    Instance.new("UICorner",input).CornerRadius = UDim.new(0,8)

    --------------------------------------------------
    -- helpers
    --------------------------------------------------
    local function apply(val)
        val = math.clamp(val, minV, maxV)
        local pct = (val - minV) / (maxV - minV)
        fill.Size      = UDim2.new(pct, 0, 1, 0)
        knob.Position  = UDim2.new(pct, 0, 0.5, 0)
        label.Text     = labelText .. ": " .. val
        input.Text     = tostring(val)
        setter(val)
    end
    apply(defaultV)  -- init visuals

    --------------------------------------------------
    -- dragging
    --------------------------------------------------
    local dragging = false
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider, dragging = true, true
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    draggingSlider, dragging = false, false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp(inp.Position.X - bar.AbsolutePosition.X,
                                    0,
                                    bar.AbsoluteSize.X)          -- keep knob fully visible
            local pct  = relX / bar.AbsoluteSize.X
            local val  = math.floor(minV + pct * (maxV - minV) + 0.5)
            apply(val)
        end
    end)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local v = tonumber(input.Text)
            if v then apply(v) else apply(defaultV) end
        end
    end)

    return apply
end

--------------------------------------------------
-- create sliders
--------------------------------------------------
local resetWalk = newSlider("Walk Speed", 8, 100, humanoid.WalkSpeed,
                            function(v) humanoid.WalkSpeed = v end)

local resetJump = newSlider("Jump Power", 20, 200, humanoid.JumpPower,
                            function(v) humanoid.JumpPower = v end)

--------------------------------------------------
-- reset button
--------------------------------------------------
local resetBtn = Instance.new("TextButton", main)
resetBtn.Size = UDim2.new(0,150,0,28)
resetBtn.Position = UDim2.new(0,165,0,117)
resetBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.SourceSansBold
resetBtn.TextSize = 18
resetBtn.Text = "Reset Values"
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,6)

resetBtn.MouseButton1Click:Connect(function()
    resetWalk(16)
    resetJump(50)
end)

--------------------------------------------------
-- exit button
--------------------------------------------------
local exitBtn = Instance.new("TextButton", main)
exitBtn.Size = UDim2.new(0,38,0,38)
exitBtn.Position = UDim2.new(1,-44,0,5)
exitBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
exitBtn.TextColor3 = Color3.new(1,1,1)
exitBtn.Text = "X"
exitBtn.Font = Enum.Font.SourceSansBold
exitBtn.TextSize = 30
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,8)

exitBtn.MouseButton1Click:Connect(function()
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    gui:Destroy()
end)

--------------------------------------------------
-- drag whole gui (blocked when dragging slider)
--------------------------------------------------
local guiDragging = false
local guiStartPos, startPos

main.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and not draggingSlider then
        guiDragging = true
        guiStartPos = inp.Position
        startPos    = main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState==Enum.UserInputState.End then guiDragging=false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if guiDragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d = inp.Position - guiStartPos
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                  startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
