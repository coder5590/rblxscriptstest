--//  TP-to-Player Gui  /////////////////////////////////////////////
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local me       = Players.LocalPlayer
local humanoid = (me.Character or me.CharacterAdded:Wait()):WaitForChild("Humanoid")
--------------------------------------------------------------------
-- main gui container
--------------------------------------------------------------------
local gui  = Instance.new("ScreenGui", me:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size  = UDim2.new(0, 300, 0, 120)
main.Position = UDim2.new(0, 10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(50,50,50)
main.BorderSizePixel  = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", main)
title.Text  = "TP to Player"
title.Font  = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Size  = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------------------------
-- draggable gui (blocked while typing)
--------------------------------------------------------------------
local dragging, dragStart, startPos
main.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = inp.Position
		startPos  = main.Position
		inp.Changed:Connect(function()
			if inp.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(inp)
	if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
		local d = inp.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
		                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

--------------------------------------------------------------------
-- input box for target name
--------------------------------------------------------------------
local nameBox = Instance.new("TextBox", main)
nameBox.Size  = UDim2.new(1, -20, 0, 28)
nameBox.Position = UDim2.new(0, 10, 0, 40)
nameBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.Font = Enum.Font.SourceSansBold
nameBox.TextSize = 18
nameBox.PlaceholderText = "username / display / partial"
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

--------------------------------------------------------------------
-- TP button
--------------------------------------------------------------------
local tpBtn = Instance.new("TextButton", main)
tpBtn.Size = UDim2.new(0.5, -15, 0, 30)
tpBtn.Position = UDim2.new(0, 10, 0, 80)
tpBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.Font = Enum.Font.SourceSansBold
tpBtn.TextSize = 18
tpBtn.Text = "TP"
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

--------------------------------------------------------------------
-- Exit button
--------------------------------------------------------------------
local exitBtn = Instance.new("TextButton", main)
exitBtn.Size = UDim2.new(0.5, -15, 0, 30)
exitBtn.Position = UDim2.new(0.5, 5, 0, 80)
exitBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
exitBtn.TextColor3 = Color3.new(1,1,1)
exitBtn.Font = Enum.Font.SourceSansBold
exitBtn.TextSize = 18
exitBtn.Text = "Exit"
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,6)

--------------------------------------------------------------------
-- helper to find player by partial / display
--------------------------------------------------------------------
local function findPlayer(query)
	query = query:lower()
	for _,plr in ipairs(Players:GetPlayers()) do
		local user = plr.Name:lower()
		local disp = (plr.DisplayName or ""):lower()
		if user == query or disp == query or user:find(query,1,true) or disp:find(query,1,true) then
			return plr
		end
	end
	return nil
end

--------------------------------------------------------------------
-- teleport logic
--------------------------------------------------------------------
tpBtn.MouseButton1Click:Connect(function()
	local targetName = nameBox.Text
	if targetName == "" then return end
	local target = findPlayer(targetName)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local myChar = me.Character or me.CharacterAdded:Wait()
		local hrp    = myChar:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) -- small offset
		end
	else
		nameBox.Text = "Player not found!"
	end
end)

exitBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
