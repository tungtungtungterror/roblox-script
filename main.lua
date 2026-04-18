local ws = game:GetService("Workspace")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local pps = game:GetService("ProximityPromptService")
local plrs = game:GetService("Players")
local lighting = game:GetService("Lighting")
local cg = game:GetService("CoreGui")

local cam = ws.CurrentCamera
local lplr = plrs.LocalPlayer

local toggles = {
    AimAssist = false,
    ESP = false,
    Hitboxes = false,
    Fullbright = false,
    InstantInteract = false,
    DelCorpses = false,
    UltraPotato = false,
    Speed = false,
}

local cfg = {
    aimStrength = 0.5,
    fov = 60,
    targetPart = "Head",
    maxDist = 500,
    delCorpses = true,
    maxEsp = 10,
    espFill = Color3.fromRGB(255, 0, 0),
    espOutline = Color3.fromRGB(255, 255, 255),
    fillTrans = 0.5,
    outTrans = 0,
    scanRate = 0.5,
    speed = 16,
}

local hitboxCfg = {
    enabled = true,
    part = "Head",
    size = Vector3.new(2, 2, 2),
    show = true,
    color = BrickColor.new("Bright red"),
    trans = 0.7,
    refreshRate = 1
}

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "OmniMenu"
gui.Parent = cg
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame")
main.Name = "main"
main.Parent = gui
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.Size = UDim2.new(0.2, 0, 0.6, 0)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.Parent = main
sizeConstraint.MinSize = Vector2.new(150, 250)
sizeConstraint.MaxSize = Vector2.new(250, 600)

local title = Instance.new("TextLabel")
title.Parent = main
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.Text = "FOOL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14

local minBtn = Instance.new("TextButton")
minBtn.Parent = main
minBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Parent = main
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 0, 0, 35)
scroll.Size = UDim2.new(1, 0, 1, -35)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 2
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

local isMin = false
local origSize = main.Size

minBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        origSize = main.Size
        scroll.Visible = false
        title.Visible = false
        main.BackgroundTransparency = 1
        main.ClipsDescendants = false
        main.Size = UDim2.new(0, 30, 0, 30)
        main.Active = false
        minBtn.Text = "+"
        minBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    else
        main.Size = origSize
        scroll.Visible = true
        title.Visible = true
        main.BackgroundTransparency = 0
        main.ClipsDescendants = true
        main.Active = true
        minBtn.Position = UDim2.new(1, -30, 0, 0)
        minBtn.Text = "-"
        minBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

local function createToggle(name, key)
    local b = Instance.new("TextButton")
    b.Parent = scroll
    b.BackgroundColor3 = toggles[key] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Font = Enum.Font.Gotham
    b.Text = name .. (toggles[key] and ": ON" or ": OFF")
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.BorderSizePixel = 0

    b.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        b.Text = name .. (toggles[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = toggles[key] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)

        if key == "ESP" and not toggles.ESP then
            for _, v in ipairs(ws:GetDescendants()) do
                if v.Name == "NPCHighlight" then v:Destroy() end
            end
        end
    end)
end

local function createSlider(name, minV, maxV, def, cb)
    local container = Instance.new("Frame")
    container.Parent = scroll
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.Size = UDim2.new(0.9, 0, 0, 45)
    container.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel")
    lbl.Parent = container
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0.5, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = name .. ": " .. tostring(def)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 10

    local back = Instance.new("Frame")
    back.Parent = container
    back.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    back.Position = UDim2.new(0.1, 0, 0.6, 0)
    back.Size = UDim2.new(0.8, 0, 0, 8)
    back.BorderSizePixel = 0

    local fill = Instance.new("Frame")
    fill.Parent = back
    fill.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
    fill.Size = UDim2.new((def - minV) / (maxV - minV), 0, 1, 0)
    fill.BorderSizePixel = 0

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = minV + (maxV - minV) * pos
        val = math.floor(val * 100) / 100
        lbl.Text = name .. ": " .. tostring(val)
        if cb then cb(val) end
    end

    back.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- Toggles
createToggle("Aim Assist", "AimAssist")
createToggle("Visuals (ESP)", "ESP")
createToggle("Big Hitboxes", "Hitboxes")
createToggle("Fullbright", "Fullbright")
createToggle("Instant Interact", "InstantInteract")
createToggle("Del Corpses", "DelCorpses")
createToggle("Ultra Potato", "UltraPotato")
createToggle("Speed Modifier", "Speed")

-- Sliders
createSlider("Aim Strength", 0.01, 1.0, cfg.aimStrength, function(v) cfg.aimStrength = v end)
createSlider("FOV", 10, 300, cfg.fov, function(v) cfg.fov = v end)
createSlider("Hitbox Size", 1, 20, hitboxCfg.size.X, function(v) hitboxCfg.size = Vector3.new(v, v, v) end)
createSlider("Walk Speed", 1, 100, cfg.speed, function(v) cfg.speed = v end)

-- Toggle menu visibility
uis.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

-- Speed modifier
local lastSpeed = false

uis.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        if toggles.Speed then
            local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)

uis.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        if toggles.Speed then
            local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = cfg.speed end
        end
    end
end)

rs.Heartbeat:Connect(function()
    local char = lplr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if toggles.Speed ~= lastSpeed then
        lastSpeed = toggles.Speed
        if not toggles.Speed then
            hum.WalkSpeed = 16
        end
    end

    local shiftHeld = uis:IsKeyDown(Enum.KeyCode.LeftShift) or uis:IsKeyDown(Enum.KeyCode.RightShift)
    if toggles.Speed and not shiftHeld then
        hum.WalkSpeed = cfg.speed
    end
end)

-- Instant Interact
local validTargets = {}

pps.PromptShown:Connect(function(prompt)
    if toggles.InstantInteract then
        prompt.HoldDuration = 0
    end
end)

-- ESP
local function applyEsp(model)
    if not toggles.ESP then return end
    local hl = model:FindFirstChild("NPCHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "NPCHighlight"
        hl.Parent = model
    end
    hl.FillColor = cfg.espFill
    hl.OutlineColor = cfg.espOutline
    hl.FillTransparency = cfg.fillTrans
    hl.OutlineTransparency = cfg.outTrans
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

-- Crosshair
local crossX = Drawing.new("Line")
local crossY = Drawing.new("Line")
crossX.Visible, crossY.Visible = true, true
crossX.Thickness, crossY.Thickness = 2, 2
crossX.Color, crossY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)

local function refreshTargets()
    local tTargets = {}
    local inRange = {}
    local pPos = cam.CFrame.Position

    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
        pPos = lplr.Character.HumanoidRootPart.Position
    end

    for _, obj in ipairs(ws:GetChildren()) do
        if not obj:IsA("Model") then continue end

        local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
        local objPos = root and root.Position
        local dist = objPos and (objPos - pPos).Magnitude or math.huge

        if dist > cfg.maxDist then
            local old = obj:FindFirstChild("NPCHighlight")
            if old then old:Destroy() end
            continue
        end

        local hum = obj:FindFirstChildOfClass("Humanoid")
        if hum then
            if toggles.DelCorpses and hum.Health <= 0 then continue end

            local part = obj:FindFirstChild(cfg.targetPart)
            if hum.Health > 0 and part and not obj:FindFirstChild("REVIVE") then
                inRange[#inRange + 1] = {model = obj, dist = dist}
            else
                local old = obj:FindFirstChild("NPCHighlight")
                if old then old:Destroy() end
            end
        end
    end

    table.sort(inRange, function(a, b) return a.dist < b.dist end)

    for i, data in ipairs(inRange) do
        tTargets[#tTargets + 1] = data.model
        if i <= cfg.maxEsp then
            applyEsp(data.model)
        else
            local old = data.model:FindFirstChild("NPCHighlight")
            if old then old:Destroy() end
        end
    end
    validTargets = tTargets
end

-- Delete corpses loop
task.spawn(function()
    while true do
        if toggles.DelCorpses then
            for _, obj in ipairs(ws:GetChildren()) do
                if obj:IsA("Model") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then
                        obj:Destroy()
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Target scan loop
task.spawn(function()
    while true do
        refreshTargets()
        task.wait(cfg.scanRate)
    end
end)

-- Aim assist + crosshair
rs.RenderStepped:Connect(function(dt)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    crossX.From = Vector2.new(center.X - 10, center.Y)
    crossX.To = Vector2.new(center.X + 10, center.Y)
    crossY.From = Vector2.new(center.X, center.Y - 10)
    crossY.To = Vector2.new(center.X, center.Y + 10)

    if not toggles.AimAssist then
        crossX.Color, crossY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)
        return
    end

    local bestTorso = nil
    local shortest = cfg.fov
    local ignore = { lplr.Character }

    for _, npc in ipairs(validTargets) do
        ignore[#ignore + 1] = npc
    end

    for _, npc in ipairs(validTargets) do
        local torso = npc:FindFirstChild(cfg.targetPart)
        if torso then
            local sPos, onScreen = cam:WorldToViewportPoint(torso.Position)
            if onScreen then
                local dist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
                if dist < shortest then
                    local obscuring = cam:GetPartsObscuringTarget({ torso.Position }, ignore)
                    local blocked = false
                    for _, part in ipairs(obscuring) do
                        local parent = part.Parent
                        local parentName = parent and parent.Name:lower() or ""
                        local isDoor = parentName:find("wooden door") or part.Name:lower():find("door")
                        if isDoor then continue end

                        local isGui = false
                        local guiCheck = part.Parent
                        while guiCheck and guiCheck ~= ws do
                            if guiCheck:IsA("GuiObject") or guiCheck:IsA("BasePlayerGui") or guiCheck:IsA("ScreenGui") then
                                isGui = true
                                break
                            end
                            guiCheck = guiCheck.Parent
                        end
                        if isGui then continue end

                        local ancestor = part.Parent
                        local inRoom = false
                        while ancestor and ancestor ~= ws do
                            local n = ancestor.Name:lower()
                            if ancestor:IsA("Model") and (n:find("room") or n:find("start") or n:find("bossfight")) then
                                inRoom = true
                                break
                            end
                            ancestor = ancestor.Parent
                        end

                        if inRoom then
                            blocked = true
                            break
                        end
                    end
                    if not blocked then
                        bestTorso = torso
                        shortest = dist
                    end
                end
            end
        end
    end

    if bestTorso then
        crossX.Color, crossY.Color = Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0)
        local root = bestTorso.Parent and bestTorso.Parent:FindFirstChild("HumanoidRootPart")
        local vel = root and root.AssemblyLinearVelocity or Vector3.zero
        local pingComp = 0.055
        local predictedPos = bestTorso.Position + vel * pingComp

        local sPos = cam:WorldToViewportPoint(predictedPos)
        local dx = sPos.X - center.X
        local dy = sPos.Y - center.Y
        local dist2D = math.sqrt(dx * dx + dy * dy)

        if dist2D > 0.5 then
            local distScale = math.clamp(dist2D / 80, 0.65, 1.0)
            local strength = cfg.aimStrength * distScale

            if mousemoverel and not uis.TouchEnabled then
                mousemoverel(dx * strength, dy * strength)
            else
                local lerpAlpha = math.clamp(strength * dt * 18, 0, 0.5)
                local targetCF = CFrame.new(cam.CFrame.Position, predictedPos)
                cam.CFrame = cam.CFrame:Lerp(targetCF, lerpAlpha)
            end
        end
    else
        crossX.Color, crossY.Color = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)
    end
end)

-- Hitboxes
task.spawn(function()
    while true do
        for _, obj in ipairs(ws:GetChildren()) do
            if plrs:GetPlayerFromCharacter(obj) then continue end
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local tPart = obj:FindFirstChild(hitboxCfg.part)

                if tPart then
                    if toggles.Hitboxes and hum and hum.Health > 0 then
                        if not tPart:GetAttribute("OrigSize") then
                            tPart:SetAttribute("OrigSize", tPart.Size)
                            tPart:SetAttribute("OrigTrans", tPart.Transparency)
                            tPart:SetAttribute("OrigColor", tPart.BrickColor.Name)
                        end
                        if tPart.Size ~= hitboxCfg.size then
                            tPart.Size = hitboxCfg.size
                            tPart.CanCollide = false
                            tPart.Massless = true
                            if hitboxCfg.show then
                                tPart.Transparency = hitboxCfg.trans
                                tPart.BrickColor = hitboxCfg.color
                            end
                        end
                    elseif not toggles.Hitboxes then
                        if tPart:GetAttribute("OrigSize") and tPart.Size ~= tPart:GetAttribute("OrigSize") then
                            tPart.Size = tPart:GetAttribute("OrigSize")
                            tPart.Transparency = tPart:GetAttribute("OrigTrans")
                            tPart.BrickColor = BrickColor.new(tPart:GetAttribute("OrigColor"))
                        end
                    end
                end
            end
        end
        task.wait(hitboxCfg.refreshRate)
    end
end)

-- Fullbright
lighting.Changed:Connect(function()
    if not toggles.Fullbright then return end
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.fromRGB(178, 178, 178)
    lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
end)

-- AI State Disabler
task.spawn(function()
    local bannedStates = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.Swimming,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll
    }
    while true do
        task.wait(2)
        local i = 0
        for _, obj in ipairs(ws:GetDescendants()) do
            if obj:IsA("Humanoid") and not plrs:GetPlayerFromCharacter(obj.Parent) then
                if obj.Health > 0 then
                    for _, state in ipairs(bannedStates) do
                        obj:SetStateEnabled(state, false)
                    end
                end
            end
            i += 1
            if i % 50 == 0 then task.wait() end
        end
    end
end)

-- Always-on: Low Visuals
lighting.GlobalShadows = false
for _, v in ipairs(lighting:GetChildren()) do
    if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
    end
end

-- Always-on: Particle Cap
task.spawn(function()
    while true do
        task.wait(5)
        for _, v in ipairs(ws:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Rate = math.min(v.Rate, 5)
            end
        end
    end
end)

-- Always-on: Instance Optimizer
task.spawn(function()
    while true do
        task.wait(5)
        local i = 0
        for _, v in ipairs(ws:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.RenderFidelity = Enum.RenderFidelity.Performance
            end
            if v:IsA("BasePart") and not v.Anchored then
                local sz = v.Size
                if sz.X < 1 and sz.Y < 1 and sz.Z < 1 then
                    v.CanTouch = false
                    v.CanQuery = false
                end
            end
            i += 1
            if i % 100 == 0 then task.wait() end
        end
    end
end)

-- Ultra Potato
local cachedTextures = {}

local function applyUltraPotato(state)
    for _, v in ipairs(ws:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            if state then
                cachedTextures[v] = v.Texture
                v.Texture = ""
            else
                if cachedTextures[v] then
                    v.Texture = cachedTextures[v]
                    cachedTextures[v] = nil
                end
            end
        end
    end
end

local lastUltraPotato = false
rs.Heartbeat:Connect(function()
    if toggles.UltraPotato ~= lastUltraPotato then
        lastUltraPotato = toggles.UltraPotato
        applyUltraPotato(toggles.UltraPotato)
    end
end)

-- F1 Deep Clean
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        local cleaned = 0
        local i = 0
        for _, v in ipairs(ws:GetChildren()) do
            if v:IsA("BasePart") and not v.Anchored and not plrs:GetPlayerFromCharacter(v.Parent) then
                v:Destroy()
                cleaned += 1
            end
            i += 1
            if i % 50 == 0 then task.wait() end
        end
        print("Deep Clean done, removed " .. cleaned .. " parts")
    end
end)
