local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Toggles = {
	AimAssist = false,
	ESP = false,
	Hitboxes = false,
	Fullbright = false,
	InstantInteract = false
}

local SETTINGS = {
	AIM_STRENGTH = 0.4,
	FOV_RADIUS = 60,
	TARGET_PART = "Head",
	MAX_DISTANCE = 300,
	DELETE_CORPSES = true,
	ESP_ENABLED = true,
	MAX_ESP_COUNT = 10,
	FILL_COLOR = Color3.fromRGB(255, 0, 0),
	OUTLINE_COLOR = Color3.fromRGB(255, 255, 255),
	FILL_TRANSPARENCY = 0.5,
	OUTLINE_TRANSPARENCY = 0,
	SCAN_RATE = 0.5
}

local HITBOX_SETTINGS = {
	ENABLED = true,
	TARGET_PART = "Head",
	SIZE = Vector3.new(2, 2, 2),
	SHOW_HITBOX = true,
	HITBOX_COLOR = BrickColor.new("Bright red"),
	HITBOX_TRANSPARENCY = 0.7,
	REFRESH_RATE = 1
}

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ButtonList = Instance.new("UIListLayout")

ScreenGui.Name = "OmniMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "FOOL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

MinimizeBtn.Name = "Minimize"
MinimizeBtn.Parent = Title
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0

local minimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		MainFrame.Size = UDim2.new(0, 180, 0, 30)
		MinimizeBtn.Text = "+"
		MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
	else
		MainFrame.Size = originalSize
		MinimizeBtn.Text = "-"
		MinimizeBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
	end
end)

ButtonList.Parent = MainFrame
ButtonList.Padding = UDim.new(0, 5)
ButtonList.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonList.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggle(name, stateKey)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Parent = MainFrame
	btn.BackgroundColor3 = Toggles[stateKey] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Font = Enum.Font.Gotham
	btn.Text = name .. (Toggles[stateKey] and ": ON" or ": OFF")
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 12
	btn.BorderSizePixel = 0

	btn.MouseButton1Click:Connect(function()
		Toggles[stateKey] = not Toggles[stateKey]
		btn.Text = name .. (Toggles[stateKey] and ": ON" or ": OFF")
		btn.BackgroundColor3 = Toggles[stateKey] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
		if stateKey == "ESP" and not Toggles.ESP then
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v.Name == "NPCHighlight" then v:Destroy() end
			end
		end
	end)
end

local function CreateSlider(name, min, max, default, callback)
	local container = Instance.new("Frame")
	container.Name = name .. "Container"
	container.Parent = MainFrame
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.Size = UDim2.new(0.9, 0, 0, 45)
	container.BorderSizePixel = 0
	container.Active = true

	local label = Instance.new("TextLabel")
	label.Parent = container
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.Font = Enum.Font.Gotham
	label.Text = name .. ": " .. tostring(default)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 12

	local sliderBack = Instance.new("Frame")
	sliderBack.Parent = container
	sliderBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	sliderBack.Position = UDim2.new(0.1, 0, 0.6, 0)
	sliderBack.Size = UDim2.new(0.8, 0, 0, 10)
	sliderBack.BorderSizePixel = 0
	sliderBack.Active = true

	local sliderFill = Instance.new("Frame")
	sliderFill.Parent = sliderBack
	sliderFill.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BorderSizePixel = 0
	sliderFill.Active = true

	local dragging = false

	local function updateSlider(input)
		local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
		sliderFill.Size = UDim2.new(pos, 0, 1, 0)
		local value = min + (max - min) * pos
		value = math.floor(value * 100) / 100
		label.Text = name .. ": " .. tostring(value)
		if callback then callback(value) end
	end

	sliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input)
		end
	end)
end

CreateToggle("Aim Assist", "AimAssist")
CreateToggle("Visuals (ESP)", "ESP")
CreateToggle("Big Hitboxes", "Hitboxes")
CreateToggle("Fullbright", "Fullbright")
CreateToggle("Instant Interact", "InstantInteract")

CreateSlider("Aim Strength", 0.01, 1.0, SETTINGS.AIM_STRENGTH, function(val)
	SETTINGS.AIM_STRENGTH = val
end)

CreateSlider("Hitbox Size", 1, 20, HITBOX_SETTINGS.SIZE.X, function(val)
	HITBOX_SETTINGS.SIZE = Vector3.new(val, val, val)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

local UniversalTargetSet = {}

ProximityPromptService.PromptShown:Connect(function(prompt)
	if Toggles.InstantInteract then
		prompt.HoldDuration = 0
	end
end)

local function applyESP(model)
	if not Toggles.ESP then return end
	local highlight = model:FindFirstChild("NPCHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "NPCHighlight"
		highlight.Parent = model
	end
	highlight.FillColor = SETTINGS.FILL_COLOR
	highlight.OutlineColor = SETTINGS.OUTLINE_COLOR
	highlight.FillTransparency = SETTINGS.FILL_TRANSPARENCY
	highlight.OutlineTransparency = SETTINGS.OUTLINE_TRANSPARENCY
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local lineX = Drawing.new("Line")
local lineY = Drawing.new("Line")
lineX.Visible, lineY.Visible = true, true
lineX.Thickness, lineY.Thickness = 2, 2
lineX.Color, lineY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)

local function EvaluateWorld()
	local tempTargets = {}
	local npcsInRange = {}
	local playerPos = Camera.CFrame.Position
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		playerPos = LocalPlayer.Character.HumanoidRootPart.Position
	end
	local children = Workspace:GetChildren()
	for i = 1, #children do
		local obj = children[i]
		if not obj:IsA("Model") then continue end
		local objPos = (obj.PrimaryPart and obj.PrimaryPart.Position) or (obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart.Position)
		local dist = objPos and (objPos - playerPos).Magnitude or math.huge
		if dist > SETTINGS.MAX_DISTANCE then
			local oldH = obj:FindFirstChild("NPCHighlight")
			if oldH then oldH:Destroy() end
			continue
		end
		local hum = obj:FindFirstChildOfClass("Humanoid")
		if hum then
			if SETTINGS.DELETE_CORPSES and hum.Health <= 0 then
				obj:Destroy()
				continue
			end
			local part = obj:FindFirstChild(SETTINGS.TARGET_PART)
			if hum.Health > 0 and part and not obj:FindFirstChild("REVIVE") then
				table.insert(npcsInRange, {model = obj, distance = dist})
			else
				local oldH = obj:FindFirstChild("NPCHighlight")
				if oldH then oldH:Destroy() end
			end
		end
	end
	table.sort(npcsInRange, function(a, b) return a.distance < b.distance end)
	for index, npcData in ipairs(npcsInRange) do
		local obj = npcData.model
		table.insert(tempTargets, obj)
		if index <= SETTINGS.MAX_ESP_COUNT then
			applyESP(obj)
		else
			local oldH = obj:FindFirstChild("NPCHighlight")
			if oldH then oldH:Destroy() end
		end
	end
	UniversalTargetSet = tempTargets
end

task.spawn(function()
	while true do
		EvaluateWorld()
		task.wait(SETTINGS.SCAN_RATE)
	end
end)

RunService.RenderStepped:Connect(function()
	local mouseLoc = UserInputService:GetMouseLocation()
	lineX.From = Vector2.new(mouseLoc.X - 10, mouseLoc.Y)
	lineX.To = Vector2.new(mouseLoc.X + 10, mouseLoc.Y)
	lineY.From = Vector2.new(mouseLoc.X, mouseLoc.Y - 10)
	lineY.To = Vector2.new(mouseLoc.X, mouseLoc.Y + 10)

	if not Toggles.AimAssist then
		lineX.Color, lineY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)
		return
	end

	local closestTorso = nil
	local shortestDist = SETTINGS.FOV_RADIUS

	local ignoreList = { LocalPlayer.Character }
	for _, npc in ipairs(UniversalTargetSet) do
		table.insert(ignoreList, npc)
	end

	for _, npc in ipairs(UniversalTargetSet) do
		local torso = npc:FindFirstChild(SETTINGS.TARGET_PART)
		if torso then
			local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
				if dist < shortestDist then
					local obscuring = Camera:GetPartsObscuringTarget({ torso.Position }, ignoreList)
					if #obscuring == 0 then
						closestTorso = torso
						shortestDist = dist
					end
				end
			end
		end
	end

	if closestTorso then
		lineX.Color, lineY.Color = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0)
		local screenPos = Camera:WorldToViewportPoint(closestTorso.Position)
		if mousemoverel then
			mousemoverel((screenPos.X - mouseLoc.X) * SETTINGS.AIM_STRENGTH, (screenPos.Y - mouseLoc.Y) * SETTINGS.AIM_STRENGTH)
		end
	else
		lineX.Color, lineY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)
	end
end)

task.spawn(function()
	while true do
		for _, obj in ipairs(Workspace:GetChildren()) do
			if Players:GetPlayerFromCharacter(obj) then continue end
			if obj:IsA("Model") then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local targetPart = obj:FindFirstChild(HITBOX_SETTINGS.TARGET_PART)
				if targetPart then
					if Toggles.Hitboxes and hum and hum.Health > 0 then
						if not targetPart:GetAttribute("OriginalSize") then
							targetPart:SetAttribute("OriginalSize", targetPart.Size)
							targetPart:SetAttribute("OriginalTransparency", targetPart.Transparency)
							targetPart:SetAttribute("OriginalColor", targetPart.BrickColor.Name)
						end
						if targetPart.Size ~= HITBOX_SETTINGS.SIZE then
							targetPart.Size = HITBOX_SETTINGS.SIZE
							targetPart.CanCollide = false
							targetPart.Massless = true
							if HITBOX_SETTINGS.SHOW_HITBOX then
								targetPart.Transparency = HITBOX_SETTINGS.HITBOX_TRANSPARENCY
								targetPart.BrickColor = HITBOX_SETTINGS.HITBOX_COLOR
							end
						end
					elseif not Toggles.Hitboxes then
						if targetPart:GetAttribute("OriginalSize") and targetPart.Size ~= targetPart:GetAttribute("OriginalSize") then
							targetPart.Size = targetPart:GetAttribute("OriginalSize")
							targetPart.Transparency = targetPart:GetAttribute("OriginalTransparency")
							targetPart.BrickColor = BrickColor.new(targetPart:GetAttribute("OriginalColor"))
						end
					end
				end
			end
		end
		task.wait(HITBOX_SETTINGS.REFRESH_RATE)
	end
end)

local function applyFullbright()
	if not Toggles.Fullbright then return end
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
end

Lighting.Changed:Connect(applyFullbright)
