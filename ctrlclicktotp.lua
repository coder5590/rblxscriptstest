-- PRESS CONTROL + CLICK TO TP ANYWHERE MOUSE IS 

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

Mouse.Button1Down:Connect(function()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local hit = Mouse.Hit
		if hit and hit.Position then
			local character = LocalPlayer.Character
			if character then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					rootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 5, 0)) -- slight offset up
				end
			end
		end
	end
end)
