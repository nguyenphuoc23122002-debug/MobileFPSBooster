-- ============================================
-- PHẦN 1: DEBUG SYSTEM
-- Copy phần này TRƯỚC, paste vào đầu script
-- ============================================

local DebugSystem = {}
local logs = {}
local maxLogs = 50
local debugEnabled = true

local function createDebugGUI()
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 220)
    mainFrame.Position = UDim2.new(1, -330, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    header.BorderSizePixel = 0
    header.Text = "🔍 DEBUG LOG"
    header.TextColor3 = Color3.fromRGB(0, 255, 0)
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -68)
    scrollFrame.Position = UDim2.new(0, 5, 0, 32)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame
    
    local logText = Instance.new("TextLabel")
    logText.Name = "LogText"
    logText.Size = UDim2.new(1, -10, 1, 0)
    logText.BackgroundTransparency = 1
    logText.Text = ""
    logText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logText.TextSize = 10
    logText.Font = Enum.Font.Code
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
    logText.Parent = scrollFrame
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 32)
    buttonFrame.Position = UDim2.new(0, 0, 1, -32)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "ClearButton"
    clearBtn.Size = UDim2.new(0.48, 0, 1, -5)
    clearBtn.Position = UDim2.new(0.01, 0, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    clearBtn.Text = "Xóa"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = buttonFrame
    
    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = clearBtn
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0.48, 0, 1, -5)
    toggleBtn.Position = UDim2.new(0.51, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    toggleBtn.Text = "Ẩn/Hiện"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = buttonFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn
    
    clearBtn.MouseButton1Click:Connect(function()
        logs = {}
        logText.Text = ""
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end)
    
    local visible = true
    toggleBtn.MouseButton1Click:Connect(function()
        visible = not visible
        mainFrame.Visible = visible
    end)
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    return logText, scrollFrame
end

local logTextLabel, scrollFrame = createDebugGUI()

local function updateLogDisplay()
    local text = table.concat(logs, "\n")
    logTextLabel.Text = text
    local textSize = game:GetService("TextService"):GetTextSize(
        text, logTextLabel.TextSize, logTextLabel.Font,
        Vector2.new(logTextLabel.AbsoluteSize.X, math.huge)
    )
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 10)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

function DebugSystem.log(message, level)
    if not debugEnabled then return end
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local prefix = level == "ERROR" and "❌" or level == "SUCCESS" and "✅" or level == "WARNING" and "⚠️" or "ℹ️"
    local logMessage = string.format("[%s] %s %s", timestamp, prefix, tostring(message))
    table.insert(logs, logMessage)
    if #logs > maxLogs then table.remove(logs, 1) end
    updateLogDisplay()
    print(logMessage)
end

function DebugSystem.info(msg) DebugSystem.log(msg, "INFO") end
function DebugSystem.error(msg) DebugSystem.log(msg, "ERROR") end
function DebugSystem.success(msg) DebugSystem.log(msg, "SUCCESS") end
function DebugSystem.warn(msg) DebugSystem.log(msg, "WARNING") end

function DebugSystem.try(func, funcName)
    funcName = funcName or "Unknown"
    DebugSystem.info("Chạy: " .. funcName)
    local success, result = pcall(func)
    if success then
        DebugSystem.success(funcName .. " OK")
        return true, result
    else
        DebugSystem.error(funcName .. " LỖI: " .. tostring(result))
        return false, result
    end
end

DebugSystem.success("Debug System khởi động!")

-- ============================================
-- HẾT PHẦN 1 - Giờ copy PHẦN 2
-- ============================================
-- ============================================
-- PHẦN 2: AIMBOT SCRIPT
-- Copy phần này SAU, paste ngay sau PHẦN 1
-- ============================================

DebugSystem.info("Bắt đầu load Aimbot...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

-- AUTO FIX LAG
DebugSystem.info("Đang tối ưu đồ họa...")
DebugSystem.try(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    DebugSystem.success("Tắt hiệu ứng đồ họa")
end, "Tối ưu Lighting")

DebugSystem.try(function()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
            count = count + 1
        elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
    end
    DebugSystem.success("Xóa " .. count .. " hiệu ứng")
end, "Tối ưu Workspace")

local Settings = {
    Enabled = false,
    MaxDistance = 800,
    WallCheck = true,
    AimPart = "Head",
    Smoothness = 0.2,
    EvasionEnabled = true,
    EvasionDistance = 15,
    MovementSpeed = 25,
    TargetUpdateInterval = 0.1,
    RadarEnabled = true,
    RadarRange = 30,
    RadarDangerZone = 15,
    RadarWarningZone = 25
}

DebugSystem.info("Cấu hình: MaxDist=" .. Settings.MaxDistance .. "m")

local CurrentTarget = nil
local Connection = nil
local RadarConnection = nil
local OriginalWalkSpeed = 16
local LastTargetUpdate = 0
local NearestThreat = nil

local function IsPlayer(model)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character == model then return true end
    end
    return false
end

local function CheckWall(targetPart)
    local char = LocalPlayer.Character
    if not char then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(rayOrigin, rayDirection.Unit * rayDirection.Magnitude, rayParams)
    if result and result.Instance and not result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function PredictPosition(targetPart, time)
    local hrp = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if not hrp then return targetPart.Position end
    return targetPart.Position + hrp.Velocity * time
end

local function GetClosestMob()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest = nil
    local shortestDist = Settings.MaxDistance
    local allObjects = {}
    local function collectMobs(parent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("Model") and obj ~= char and not IsPlayer(obj) then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(allObjects, obj)
                end
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                collectMobs(obj)
            end
        end
    end
    collectMobs(Workspace)
    table.sort(allObjects, function(a, b)
        local hrpA = a:FindFirstChild("HumanoidRootPart")
        local hrpB = b:FindFirstChild("HumanoidRootPart")
        if not hrpA or not hrpB then return false end
        return (hrp.Position - hrpA.Position).Magnitude < (hrp.Position - hrpB.Position).Magnitude
    end)
    for _, obj in pairs(allObjects) do
        local targetPart = obj:FindFirstChild(Settings.AimPart) or obj:FindFirstChild("Head")
        local hrpMob = obj:FindFirstChild("HumanoidRootPart")
        if targetPart and hrpMob then
            local distance = (hrp.Position - hrpMob.Position).Magnitude
            if distance < shortestDist then
                if not Settings.WallCheck or not CheckWall(targetPart) then
                    closest = obj
                    shortestDist = distance
                end
            end
        end
    end
    return closest
end

local function ScanNearbyThreats()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestThreat = nil
    local closestDistance = Settings.RadarRange
    local function scanFolder(parent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("Model") and obj ~= char and not IsPlayer(obj) then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local hrpMob = obj:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and hrpMob then
                    local distance = (hrp.Position - hrpMob.Position).Magnitude
                    if distance <= Settings.RadarRange and distance < closestDistance then
                        closestThreat = {Model = obj, Distance = distance, Health = humanoid.Health, Name = obj.Name}
                        closestDistance = distance
                    end
                end
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                scanFolder(obj)
            end
        end
    end
    scanFolder(Workspace)
    return closestThreat
end

local function AimAt(target)
    if not target or not target.Parent then return end
    local targetPart = target:FindFirstChild(Settings.AimPart) or target:FindFirstChild("Head")
    if not targetPart then return end
    local predictedPosition = PredictPosition(targetPart, 0.2)
    local camPos = Camera.CFrame.Position
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, predictedPosition), Settings.Smoothness)
end

local function SmartMove()
    local char = LocalPlayer.Character
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not char or not humanoid or not hrp or humanoid.Health <= 0 then return end
    local threatToEvade = nil
    local distanceToEvade = math.huge
    if NearestThreat and NearestThreat.Model and NearestThreat.Model.Parent then
        threatToEvade = NearestThreat.Model:FindFirstChild("HumanoidRootPart")
        distanceToEvade = NearestThreat.Distance
    elseif CurrentTarget then
        threatToEvade = CurrentTarget:FindFirstChild("HumanoidRootPart")
        if threatToEvade then distanceToEvade = (hrp.Position - threatToEvade.Position).Magnitude end
    end
    if threatToEvade and distanceToEvade < Settings.EvasionDistance then
        local direction = (hrp.Position - threatToEvade.Position).Unit
        humanoid.WalkSpeed = Settings.MovementSpeed
        humanoid:Move(Vector3.new(direction.X, 0, direction.Z).Unit, false)
    else
        humanoid.WalkSpeed = OriginalWalkSpeed
    end
end

local function TurnOn()
    DebugSystem.info("Bật Aimbot...")
    Settings.Enabled = true
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            OriginalWalkSpeed = humanoid.WalkSpeed
            DebugSystem.info("WalkSpeed gốc: " .. OriginalWalkSpeed)
        end
    end
    
    DebugSystem.try(function()
        Connection = RunService.RenderStepped:Connect(function()
            if not Settings.Enabled then return end
            local currentTime = tick()
            if currentTime - LastTargetUpdate >= Settings.TargetUpdateInterval then
                LastTargetUpdate = currentTime
                local needsUpdate = false
                if not CurrentTarget or not CurrentTarget.Parent then
                    needsUpdate = true
                else
                    local humanoid = CurrentTarget:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        needsUpdate = true
                    else
                        local targetPart = CurrentTarget:FindFirstChild(Settings.AimPart) or CurrentTarget:FindFirstChild("Head")
                        if targetPart and Settings.WallCheck and CheckWall(targetPart) then needsUpdate = true end
                    end
                end
                if needsUpdate then 
                    CurrentTarget = GetClosestMob()
                    if CurrentTarget then
                        DebugSystem.success("Khóa mục tiêu: " .. CurrentTarget.Name)
                    end
                end
            end
            if CurrentTarget then AimAt(CurrentTarget) end
            if Settings.EvasionEnabled then SmartMove() end
        end)
        DebugSystem.success("RenderStepped kết nối")
    end, "Kết nối Aimbot Loop")
    
    if Settings.RadarEnabled then
        DebugSystem.try(function()
            RadarConnection = RunService.Heartbeat:Connect(function()
                if Settings.Enabled then NearestThreat = ScanNearbyThreats() end
            end)
            DebugSystem.success("Radar kích hoạt")
        end, "Kết nối Radar")
    end
end

local function TurnOff()
    DebugSystem.warn("Tắt Aimbot...")
    Settings.Enabled = false
    CurrentTarget = nil
    NearestThreat = nil
    if Connection then 
        Connection:Disconnect() 
        Connection = nil
        DebugSystem.info("Disconnect RenderStepped")
    end
    if RadarConnection then 
        RadarConnection:Disconnect() 
        RadarConnection = nil
        DebugSystem.info("Disconnect Radar")
    end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            humanoid.WalkSpeed = OriginalWalkSpeed
            DebugSystem.info("Reset WalkSpeed")
        end
    end
end

DebugSystem.info("Tạo GUI Aimbot...")
DebugSystem.try(function()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local TitleCorner = Instance.new("UICorner")
    local ToggleBtn = Instance.new("TextButton")
    local BtnCorner = Instance.new("UICorner")
    local StatusLabel = Instance.new("TextLabel")
    local TargetInfoLabel = Instance.new("TextLabel")
    local RadarLabel = Instance.new("TextLabel")
    local WarningLabel = Instance.new("TextLabel")

    ScreenGui.Name = "AimbotGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 240, 0, 230)
    MainFrame.Active = true
    MainFrame.Draggable = true

    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎯 AIMBOT v2.5"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18

    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title

    ToggleBtn.Parent = MainFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    ToggleBtn.Position = UDim2.new(0.1, 0, 0.18, 0)
    ToggleBtn.Size = UDim2.new(0.8, 0, 0, 38)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 20

    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = ToggleBtn

    TargetInfoLabel.Parent = MainFrame
    TargetInfoLabel.BackgroundTransparency = 1
    TargetInfoLabel.Position = UDim2.new(0, 0, 0.39, 0)
    TargetInfoLabel.Size = UDim2.new(1, 0, 0, 22)
    TargetInfoLabel.Font = Enum.Font.Gotham
    TargetInfoLabel.Text = "🎯 Target: None"
    TargetInfoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    TargetInfoLabel.TextSize = 12

    RadarLabel.Parent = MainFrame
    RadarLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    RadarLabel.Position = UDim2.new(0.05, 0, 0.51, 0)
    RadarLabel.Size = UDim2.new(0.9, 0, 0, 35)
    RadarLabel.Font = Enum.Font.GothamBold
    RadarLabel.Text = "📡 RADAR: Clear"
    RadarLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    RadarLabel.TextSize = 14

    local RadarCorner = Instance.new("UICorner")
    RadarCorner.CornerRadius = UDim.new(0, 6)
    RadarCorner.Parent = RadarLabel

    WarningLabel.Parent = MainFrame
    WarningLabel.BackgroundTransparency = 1
    WarningLabel.Position = UDim2.new(0, 0, 0.70, 0)
    WarningLabel.Size = UDim2.new(1, 0, 0, 28)
    WarningLabel.Font = Enum.Font.GothamBold
    WarningLabel.Text = "✅ AN TOÀN"
    WarningLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    WarningLabel.TextSize = 16

    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Status: Offline"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 11

    ToggleBtn.MouseButton1Click:Connect(function()
        if Settings.Enabled then
            TurnOff()
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            StatusLabel.Text = "Status: Offline"
            TargetInfoLabel.Text = "🎯 Target: None"
            RadarLabel.Text = "📡 RADAR: Offline"
            WarningLabel.Text = "✅ AN TOÀN"
        else
            TurnOn()
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
            StatusLabel.Text = "Status: Active 🎯"
        end
    end)

    spawn(function()
        while wait(0.08) do
            if Settings.Enabled then
                local char = LocalPlayer.Character
                if char and CurrentTarget and CurrentTarget.Parent then
                    local humanoid = CurrentTarget:FindFirstChildOfClass("Humanoid")
                    local hrpTarget = CurrentTarget:FindFirstChild("HumanoidRootPart")
                    local hrpPlayer = char:FindFirstChild("HumanoidRootPart")
                    if humanoid and hrpTarget and hrpPlayer and humanoid.Health > 0 then
                        local distance = (hrpPlayer.Position - hrpTarget.Position).Magnitude
                        StatusLabel.Text = "🎯 Locked: " .. CurrentTarget.Name
                        TargetInfoLabel.Text = string.format("🎯 HP: %.0f | %.1fm", humanoid.Health, distance)
                    end
                else
                    StatusLabel.Text = "🔍 Searching..."
                end
                if NearestThreat and NearestThreat.Model and NearestThreat.Model.Parent then
                    local d = NearestThreat.Distance
                    RadarLabel.Text = string.format("📡 %s | %.1fm", NearestThreat.Name, d)
                    if d < Settings.RadarDangerZone then
                        RadarLabel.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
                        WarningLabel.Text = "🚨 NGUY HIỂM!"
                        WarningLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif d < Settings.RadarWarningZone then
                        RadarLabel.BackgroundColor3 = Color3.fromRGB(180, 140, 0)
                        WarningLabel.Text = "⚠️ CẢNH GIÁC!"
                        WarningLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                    else
                        RadarLabel.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
                        WarningLabel.Text = "✅ AN TOÀN"
                        WarningLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                else
                    RadarLabel.Text = "📡 RADAR: Clear ✓"
                    RadarLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end
            end
        end
    end)
    
    DebugSystem.success("GUI tạo thành công!")
end, "Tạo GUI")

DebugSystem.success("✅ AIMBOT LOAD XONG!")
print("✅ Fix Lag: AUTO (Luôn bật)")
print("🎯 Aimbot: Bấm ON để kích hoạt")
print("🔍 Debug: Xem góc phải màn hình")

-- ============================================
-- HẾT PHẦN 2 - XONG!
-- ============================================
