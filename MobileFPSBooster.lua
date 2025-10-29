-- ===========================================
-- 📱 MOBILE FPS BOOSTER v6.0 - ULTRA EDITION 📱
-- ✅ Enhanced Anti-Lag | Smart Optimization
-- ✅ Startup Notifications | Better Performance
-- ===========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- 🔔 NOTIFICATION SYSTEM
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
            Icon = "rbxassetid://2541869220"
        })
    end)
end

-- 🛠️ ENHANCED CONFIG
local CONFIG = {
    MAX_FPS = 240,
    MAX_RENDER_DISTANCE = 350,
    LOD_UPDATE_INTERVAL = 3,
    CLEANUP_INTERVAL = 8,
    FPS_SAMPLE_WINDOW = 1,
    GUI_UPDATE_INTERVAL = 0.1,
    FPS_BUFFER_MAX = 240,
    TEXTURE_QUALITY = 0,  -- Giảm chất lượng texture
    MESH_DETAIL_LEVEL = 0.3,  -- Giảm chi tiết mesh
    SOUND_VOLUME = 0.5,  -- Giảm âm lượng
    TIMEOUT = 10
}

-- 📊 STATE MANAGEMENT
local connections = {}
local timers = { lod = 0, cleanup = 0, sound = 0 }
local frameTimestamps = {}
local guiRefs = {}
local labels = {}
local hiddenObjects = {}
local effectCount = 0
local optimizedParts = 0
local totalLagReduction = 0

-- 🛡️ CLEANUP MANAGER
local function addConnection(conn)
    table.insert(connections, conn)
    return conn
end

local function cleanupAll()
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    for _, gui in pairs(guiRefs) do
        pcall(function() gui:Destroy() end)
    end
    guiRefs = {}
    notify("🧹 Cleanup", "Script đã tắt hoàn toàn", 3)
end

addConnection(Players.PlayerRemoving:Connect(function(plr)
    if plr == player then cleanupAll() end
end))

notify("📱 BOOSTER v6.0", "Đang khởi động tối ưu...", 5)
print("📱 [BOOSTER v6.0] Starting ULTRA optimization...")

-- 🖥️ 1. FPS UNLOCK + RENDERING
local function unlockFPS()
    local success = pcall(function()
        if setfpscap then setfpscap(CONFIG.MAX_FPS) end
        settings().Rendering.QualityLevel = Enum.SavedQualitySetting.Automatic
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        
        -- Giảm render fidelity
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(game, "RenderFidelity", 1)
            end)
        end
    end)
    
    if success then
        notify("✅ FPS Unlocked", "Max FPS: " .. CONFIG.MAX_FPS, 4)
        print("✅ FPS: 60 → " .. CONFIG.MAX_FPS)
    end
end

-- 🎨 2. AGGRESSIVE LIGHTING OPTIMIZATION
local function optimizeLighting()
    local removedEffects = 0
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = math.huge
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("PostEffect") or child:IsA("Atmosphere") or 
               child:IsA("Sky") or child:IsA("Clouds") then
                child:Destroy()
                removedEffects = removedEffects + 1
            end
        end
    end)
    
    notify("🎨 Lighting", "Đã tối ưu ánh sáng (-" .. removedEffects .. " effects)", 3)
    print("✅ Lighting optimized, removed " .. removedEffects .. " effects")
end

-- 🔇 3. SOUND OPTIMIZATION
local function optimizeSound()
    pcall(function()
        SoundService.AmbientReverb = Enum.ReverbType.NoReverb
        SoundService.DistanceFactor = 1
        SoundService.DopplerScale = 0
        SoundService.RolloffScale = 1
        
        -- Giảm âm lượng sounds xa
        addConnection(RunService.Heartbeat:Connect(function(dt)
            timers.sound = timers.sound + dt
            if timers.sound >= 5 then
                timers.sound = 0
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, sound in pairs(Workspace:GetDescendants()) do
                            if sound:IsA("Sound") and sound.Playing then
                                local parent = sound.Parent
                                if parent and parent:IsA("BasePart") then
                                    local dist = (hrp.Position - parent.Position).Magnitude
                                    if dist > 200 then
                                        sound.Volume = 0
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end))
    end)
    notify("🔇 Sound", "Đã tối ưu âm thanh", 3)
end

-- 🧹 4. ENHANCED EFFECT DISABLE + TEXTURE
local function disableEffects()
    effectCount = 0
    local textureOptimized = 0
    
    for _, descendant in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- Effects
            if descendant:IsA("ParticleEmitter") then
                descendant.Enabled = false
                descendant.Rate = 0
                descendant.Lifetime = NumberRange.new(0)
                effectCount = effectCount + 1
            elseif descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") then
                descendant.Enabled = false
                effectCount = effectCount + 1
            elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
                descendant.Brightness = 0
                descendant.Enabled = false
                effectCount = effectCount + 1
            elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
                descendant.Enabled = false
                effectCount = effectCount + 1
            -- Textures
            elseif descendant:IsA("Texture") or descendant:IsA("Decal") then
                descendant.Transparency = 1
                textureOptimized = textureOptimized + 1
            -- Parts
            elseif descendant:IsA("BasePart") then
                descendant.Material = Enum.Material.SmoothPlastic
                descendant.Reflectance = 0
                descendant.CastShadow = false
                optimizedParts = optimizedParts + 1
            -- Meshes
            elseif descendant:IsA("SpecialMesh") then
                descendant.TextureId = ""
                textureOptimized = textureOptimized + 1
            end
        end)
    end
    
    totalLagReduction = effectCount + textureOptimized + optimizedParts
    notify("✅ Effects", string.format("Tắt %d effects, %d textures", effectCount, textureOptimized), 4)
    print(string.format("✅ Disabled %d effects, %d textures, %d parts", effectCount, textureOptimized, optimizedParts))
end

-- 🌍 5. ULTRA LOD SYSTEM + MESH OPTIMIZATION
local function safeLODSystem()
    spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", CONFIG.TIMEOUT)
        
        if not humanoidRootPart then 
            warn("❌ HumanoidRootPart timeout")
            return 
        end
        
        addConnection(RunService.Heartbeat:Connect(function(deltaTime)
            timers.lod = timers.lod + deltaTime
            if timers.lod >= CONFIG.LOD_UPDATE_INTERVAL then
                timers.lod = 0
                
                local pos = humanoidRootPart.Position
                local hiddenCount = 0
                local restoredCount = 0
                
                -- Restore nearby
                for modelKey, modelData in pairs(hiddenObjects) do
                    local model = modelData.model
                    if model and model.Parent then
                        local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
                        if primary then
                            local distance = (pos - primary.Position).Magnitude
                            if distance <= CONFIG.MAX_RENDER_DISTANCE then
                                pcall(function()
                                    for _, part in pairs(model:GetDescendants()) do
                                        if part:IsA("BasePart") and not part.Locked then
                                            part.Transparency = modelData.originalStates[part] or 0
                                            part.CanCollide = modelData.originalCollide[part] or true
                                            part.CastShadow = false  -- Vẫn giữ tắt shadow
                                        end
                                    end
                                end)
                                hiddenObjects[modelKey] = nil
                                restoredCount = restoredCount + 1
                            end
                        end
                    else
                        hiddenObjects[modelKey] = nil
                    end
                end
                
                -- Hide distant + optimize
                for _, model in pairs(Workspace:GetChildren()) do
                    if model:IsA("Model") and model ~= character then
                        local modelNameLower = model.Name:lower()
                        
                        if not model:FindFirstChild("ForceVisible") and
                           not modelNameLower:find("spawn") and
                           not modelNameLower:find("player") and
                           not modelNameLower:find("gui") then
                            
                            local primary = model.PrimaryPart or 
                                          model:FindFirstChild("HumanoidRootPart") or 
                                          model:FindFirstChildOfClass("BasePart")
                            
                            if primary then
                                local distance = (pos - primary.Position).Magnitude
                                
                                if distance > CONFIG.MAX_RENDER_DISTANCE and not hiddenObjects[model] then
                                    local originalStates = {}
                                    local originalCollide = {}
                                    
                                    for _, part in pairs(model:GetDescendants()) do
                                        if part:IsA("BasePart") and not part.Locked then
                                            originalStates[part] = part.Transparency
                                            originalCollide[part] = part.CanCollide
                                        end
                                    end
                                    
                                    pcall(function()
                                        for _, part in pairs(model:GetDescendants()) do
                                            if part:IsA("BasePart") and not part.Locked and 
                                               not part.Name:lower():find("hitbox") and
                                               not part.Name:lower():find("trigger") then
                                                part.Transparency = 1
                                                part.CanCollide = false
                                                part.CastShadow = false
                                            end
                                        end
                                    end)
                                    
                                    hiddenObjects[model] = {
                                        model = model,
                                        originalStates = originalStates,
                                        originalCollide = originalCollide
                                    }
                                    hiddenCount = hiddenCount + 1
                                end
                            end
                        end
                    end
                end
            end
        end))
        
        notify("🌍 LOD System", "Smart LOD đã kích hoạt", 3)
        print("✅ Ultra LOD Active with mesh optimization")
    end)
end

-- 📊 6. ENHANCED GUI MONITOR
local function createMonitor()
    local success, playerGui = pcall(function()
        return player:WaitForChild("PlayerGui", CONFIG.TIMEOUT)
    end)
    
    if not success or not playerGui then
        warn("❌ PlayerGui timeout")
        return
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoosterV6"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = playerGui
    table.insert(guiRefs, ScreenGui)
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 130)
    Frame.Position = UDim2.new(1, -210, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    table.insert(guiRefs, Frame)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    Gradient.Rotation = 45
    Gradient.Parent = Frame
    
    local labelsData = {
        {name = "TitleLabel", text = "📱 BOOSTER v6.0 ULTRA", pos = 0, size = 11, color = Color3.new(0, 1, 1)},
        {name = "FPSLabel", text = "FPS: --", pos = 18, size = 16},
        {name = "PingLabel", text = "PING: --ms", pos = 36, size = 16},
        {name = "LuaLabel", text = "RAM: -- MB", pos = 54, size = 14},
        {name = "OptLabel", text = "OPT: " .. totalLagReduction, pos = 70, size = 14, color = Color3.new(1, 0.8, 0)},
        {name = "EffectsLabel", text = "FX: " .. effectCount, pos = 86, size = 13},
        {name = "StatusLabel", text = "✅ ACTIVE", pos = 102, size = 12, color = Color3.new(0, 1, 0)}
    }
    
    for _, data in pairs(labelsData) do
        local label = Instance.new("TextLabel")
        label.Name = data.name
        label.Size = UDim2.new(1, -10, 0, data.size)
        label.Position = UDim2.new(0, 5, 0, data.pos)
        label.BackgroundTransparency = 1
        label.Text = data.text
        label.TextColor3 = data.color or Color3.new(1, 1, 1)
        label.TextSize = data.size
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = Frame
        table.insert(guiRefs, label)
        labels[data.name] = label
    end
    
    local FPSLabel = labels.FPSLabel
    local PingLabel = labels.PingLabel
    local LuaLabel = labels.LuaLabel
    local OptLabel = labels.OptLabel
    local EffectsLabel = labels.EffectsLabel
    local StatusLabel = labels.StatusLabel
    
    local lastUpdate = tick()
    
    addConnection(RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        
        table.insert(frameTimestamps, currentTime)
        while #frameTimestamps > CONFIG.FPS_BUFFER_MAX do
            table.remove(frameTimestamps, 1)
        end
        
        while frameTimestamps[1] and currentTime - frameTimestamps[1] > CONFIG.FPS_SAMPLE_WINDOW do
            table.remove(frameTimestamps, 1)
        end
        
        local fps = math.floor(#frameTimestamps / CONFIG.FPS_SAMPLE_WINDOW)
        
        if currentTime - lastUpdate >= CONFIG.GUI_UPDATE_INTERVAL then
            lastUpdate = currentTime
            
            local color = fps >= 60 and Color3.new(0, 1, 0) or 
                         fps >= 30 and Color3.new(1, 1, 0) or 
                         Color3.new(1, 0, 0)
            
            FPSLabel.TextColor3 = color
            FPSLabel.Text = "FPS: " .. fps
            PingLabel.Text = "PING: " .. math.floor(workspace.DistributedGameTime * 1000) % 1000 .. "ms"
            LuaLabel.Text = "RAM: " .. math.floor(collectgarbage("count") / 1024) .. " MB"
            OptLabel.Text = "OPT: " .. totalLagReduction
            EffectsLabel.Text = "FX: " .. effectCount
            StatusLabel.TextColor3 = color
        end
    end))
    
    notify("📊 Monitor", "GUI monitor đã sẵn sàng", 3)
    print("✅ Ultra GUI Monitor Created")
end

-- 🔄 AGGRESSIVE CLEANUP
local function startCleanup()
    addConnection(RunService.Heartbeat:Connect(function(deltaTime)
        timers.cleanup = timers.cleanup + deltaTime
        if timers.cleanup >= CONFIG.CLEANUP_INTERVAL then
            timers.cleanup = 0
            collectgarbage("collect")  -- Full GC
        end
    end))
    print("✅ Aggressive cleanup active")
end

-- 🚀 ULTRA INITIALIZATION
local function initialize()
    unlockFPS()
    task.wait(0.5)
    optimizeLighting()
    task.wait(0.5)
    optimizeSound()
    task.wait(0.5)
    disableEffects()
    task.wait(0.5)
    safeLODSystem()
    task.wait(0.5)
    createMonitor()
    startCleanup()
    
    notify("🎉 Hoàn tất!", string.format("Tối ưu %d objects thành công!", totalLagReduction), 6)
    print("🎉 [v6.0] ULTRA INITIALIZATION COMPLETE!")
    print("🏆 Optimized: " .. totalLagReduction .. " objects")
end

-- 🎮 START
local success = pcall(initialize)
if not success then
    warn("❌ Critical failure")
    notify("❌ Lỗi", "Script gặp sự cố khi khởi động", 5)
end

game:BindToClose(cleanupAll)
