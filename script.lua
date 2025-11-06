local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
character.PrimaryPart = hrp

-- ===== フラグ =====
local AutoAimEnabled, HeadTPEnabled, FlyEnabled, InfJumpEnabled = false, false, false, false
local FlySpeed = 50
local SuperPunchEnabled, KillAuraEnabled, ExplodingPunchEnabled = false, false, false
local NoClipEnabled, GravityEnabled, SpeedBurstEnabled = false, false, false
local JumpPowerValue = 50

-- ===== Rayfield UI =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "HrMk Hub V4",
	LoadingTitle = "Loading HrMk Hub V4",
	LoadingSubtitle = "by HrMk_Noob",
	ConfigurationSaving = {Enabled = false},
	Discord = {Enabled = false},
	KeySystem = false
})

-- ===== Tabs =====
local MainTab = Window:CreateTab("Main", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ServerTab = Window:CreateTab(" Server", 4483362458)
local FunTab = Window:CreateTab("Fun", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local CreditTab = Window:CreateTab("Credit", 4483362458)
CreditTab:CreateLabel("Created by HrMk_Noob  V4")

-- ===== Helper Functions =====
local function GetNearestPlayer()
	local nearest
	local shortest = math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearest = p
			end
		end
	end
	return nearest
end

-- ===== Main Tab =====
MainTab:CreateToggle({Name = "Auto Aim", CurrentValue = false, Callback = function(V) AutoAimEnabled = V end})
MainTab:CreateToggle({Name = "Head TP", CurrentValue = false, Callback = function(V) HeadTPEnabled = V end})

local flyBV, flyBG = nil, nil
local function FlyOn()
	if flyBV or flyBG then return end
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	flyBV.Velocity = Vector3.new(0, 0, 0)
	flyBV.Parent = hrp

	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	flyBG.CFrame = hrp.CFrame
	flyBG.Parent = hrp
end

MainTab:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = function(V)
		FlyEnabled = V
		if V then
			FlyOn()
		else
			if flyBV then flyBV:Destroy(); flyBV = nil end
			if flyBG then flyBG:Destroy(); flyBG = nil end
		end
	end
})

MainTab:CreateSlider({Name = "Fly Speed", Range = {1, 9999}, Increment = 1, CurrentValue = FlySpeed, Callback = function(V) FlySpeed = V end})
MainTab:CreateSlider({Name = "Walk Speed", Range = {1, 9999}, Increment = 1, CurrentValue = humanoid.WalkSpeed, Callback = function(V) humanoid.WalkSpeed = V end})
MainTab:CreateButton({
	Name = "TP Nearest Player",
	Callback = function()
		local nearest = GetNearestPlayer()
		if nearest then hrp.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0) end
	end
})

-- ===== Misc Tab =====
MiscTab:CreateSlider({Name = "Jump Power", Range = {50, 9999}, Increment = 10, CurrentValue = humanoid.JumpPower, Callback = function(V) JumpPowerValue = V humanoid.JumpPower = V end})
MiscTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(V) InfJumpEnabled = V end})
MiscTab:CreateToggle({Name = "NoClip", CurrentValue = false, Callback = function(V) NoClipEnabled = V end})
MiscTab:CreateToggle({Name = "Low Gravity", CurrentValue = false, Callback = function(V) GravityEnabled = V end})
MiscTab:CreateToggle({Name = "Speed Burst", CurrentValue = false, Callback = function(V) SpeedBurstEnabled = V end})

-- ===== Attack Toggles =====
MainTab:CreateToggle({Name = "Super Punch", CurrentValue = false, Callback = function(V) SuperPunchEnabled = V end})
MainTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(V) KillAuraEnabled = V end})
MainTab:CreateToggle({Name = "Exploding Punch", CurrentValue = false, Callback = function(V) ExplodingPunchEnabled = V end})

-- ===== Infinite Jump =====
uis.JumpRequest:Connect(function()
	if InfJumpEnabled then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ===== Main Loop =====
rs.RenderStepped:Connect(function()
	-- Fly
	if FlyEnabled and flyBV then
		local dir = Vector3.new()
		local cam = workspace.CurrentCamera
		if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
		if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then flyBV.Velocity = dir.Unit * FlySpeed end
		flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
	end

	-- Head TP
	if HeadTPEnabled then
		local nearest = GetNearestPlayer()
		if nearest then hrp.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0) end
	end

	-- Auto Aim
	if AutoAimEnabled and not HeadTPEnabled then
		local nearest = GetNearestPlayer()
		if nearest then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearest.Character.HumanoidRootPart.Position)
		end
	end

	-- No Clip
	if NoClipEnabled then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end

	-- Gravity
	workspace.Gravity = GravityEnabled and 10 or 196.2

	-- Speed Burst
	if SpeedBurstEnabled then humanoid.WalkSpeed = 100 end

	-- Super Punch / Kill Aura / Exploding Punch
	if SuperPunchEnabled or KillAuraEnabled or ExplodingPunchEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < 10 then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						if SuperPunchEnabled then hum:TakeDamage(20) end
						if KillAuraEnabled then hum.Health = 0 end
						if ExplodingPunchEnabled then
							local bv = Instance.new("BodyVelocity")
							bv.Velocity = Vector3.new(0, 50, 0)
							bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
							bv.Parent = p.Character.HumanoidRootPart
							game:GetService("Debris"):AddItem(bv, 0.5)
						end
					end
				end
			end
		end
	end
end)

-- ===== Fun Tab =====
local SpinEnabled, DanceEnabled, RainbowEnabled, FloatEnabled = false, false, false, false
local spinSpeed = 5

-- 🌈 虹色変化
task.spawn(function()
	while true do
		if RainbowEnabled then
			local hue = tick() % 5 / 5
			local color = Color3.fromHSV(hue, 1, 1)
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Color = color
				end
			end
		end
		task.wait(0.05)
	end
end)

-- Float処理
task.spawn(function()
	while true do
		if FloatEnabled then
			local pos = hrp.Position
			hrp.Velocity = Vector3.new(0, 0, 0)
			hrp.CFrame = CFrame.new(pos.X, pos.Y + math.sin(tick()) * 0.5, pos.Z)
		end
		task.wait(0.02)
	end
end)

FunTab:CreateToggle({
	Name = "Spin",
	CurrentValue = false,
	Callback = function(v)
		SpinEnabled = v
		if v then
			task.spawn(function()
				while SpinEnabled do
					character:SetPrimaryPartCFrame(hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0))
					task.wait()
				end
			end)
		end
	end
})

FunTab:CreateSlider({
	Name = "Spin Speed",
	Range = {1, 30},
	Increment = 1,
	CurrentValue = spinSpeed,
	Callback = function(v)
		spinSpeed = v
	end
})

FunTab:CreateToggle({
	Name = "Dance (Loop)",
	CurrentValue = false,
	Callback = function(v)
		DanceEnabled = v
		if v then
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://3189773368"
			local track = humanoid:LoadAnimation(anim)
			track:Play()
			task.spawn(function()
				while DanceEnabled and track.IsPlaying do
					task.wait()
				end
				track:Stop()
			end)
		end
	end
})

FunTab:CreateToggle({
	Name = "Rainbow Body",
	CurrentValue = false,
	Callback = function(v)
		RainbowEnabled = v
	end
})

FunTab:CreateToggle({
	Name = "Float",
	CurrentValue = false,
	Callback = function(v)
		FloatEnabled = v
	end
})

-- ===== Misc2 Tab =====
ServerTab:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	end
})

MiscTab:CreateButton({
	Name = "Reset Character",
	Callback = function()
		player.Character:BreakJoints()
	end
})

ServerTab:CreateButton({
	Name = "Server Hop (Random)",
	Callback = function()
		local tp = game:GetService("TeleportService")
		local http = game:GetService("HttpService")
		local servers = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
		for _, s in pairs(servers.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				tp:TeleportToPlaceInstance(game.PlaceId, s.id)
				break
			end
		end
	end
})
local PlayerESPEnabled = false
local MoreESPEnabled = false
local ESPObjects = {}
local MoreESPObjects = {}

-- Player ESP
ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(v)
        PlayerESPEnabled = v
    end
})

-- More ESP (名前・体力・距離表示)
ESPTab:CreateToggle({
    Name = "More ESP",
    CurrentValue = false,
    Callback = function(v)
        MoreESPEnabled = v
    end
})

-- ESP 更新処理
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrpTarget = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChildOfClass("Humanoid")

                -- ===== Player ESP =====
                if PlayerESPEnabled then
                    if not ESPObjects[p] then
                        ESPObjects[p] = {}
                        for _, part in pairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local box = Instance.new("BoxHandleAdornment")
                                box.Adornee = part
                                box.Size = part.Size
                                box.Color3 = Color3.fromRGB(255,0,0)
                                box.Transparency = 0.5
                                box.AlwaysOnTop = true
                                box.ZIndex = 2
                                box.Parent = part -- パーツ自体の子に置く
                                table.insert(ESPObjects[p], box)
                            end
                        end
                    end
                else
                    if ESPObjects[p] then
                        for _, box in pairs(ESPObjects[p]) do box:Destroy() end
                        ESPObjects[p] = nil
                    end
                end

                -- ===== More ESP =====
                if MoreESPEnabled then
                    if not MoreESPObjects[p] then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "ESPBillboard"
                        bill.Adornee = hrpTarget
                        bill.Size = UDim2.new(0,200,0,50)
                        bill.AlwaysOnTop = true
                        bill.StudsOffset = Vector3.new(0,3,0)
                        bill.Parent = hrpTarget -- Character配下に置く

                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255,255,255)
                        label.Font = Enum.Font.SourceSansBold
                        label.TextScaled = false
                        label.TextSize = 14
                        label.Parent = bill

                        MoreESPObjects[p] = {bill = bill, label = label}
                    end

                    local info = MoreESPObjects[p]
                    if hum then
                        info.label.Text = p.Name.." | HP:"..math.floor(hum.Health).." | Dist:"..math.floor((hrpTarget.Position - hrp.Position).Magnitude)
                    end
                else
                    if MoreESPObjects[p] then
                        MoreESPObjects[p].bill:Destroy()
                        MoreESPObjects[p] = nil
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
