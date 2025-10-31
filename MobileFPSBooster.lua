-- PHẦN 1: DEBUG SYSTEM PRO (ModuleScript)
-- Lưu file này dưới dạng ModuleScript tên "DebugSystem" (ví dụ: đặt vào ReplicatedStorage)
-- Cuối file return DebugSystem để script chính require()

local DebugSystem = {}
local logs = {}
local maxLogs = 200
local debugEnabled = true
local currentFilter = "ALL" -- "ALL", "INFO", "WARNING", "ERROR", "SUCCESS"
local startTime = tick()

-- GLOBAL ERROR CATCHER - Bắt lỗi tự động
pcall(function()
    game:GetService("ScriptContext").Error:Connect(function(msg, stack)
        if debugEnabled then
            table.insert(logs, string.format("[%s] ⚡ RUNTIME ERROR: %s", os.date("%H:%M:%S"), tostring(msg)))
            if #logs > maxLogs then table.remove(logs, 1) end
        end
    end)
end)

local function createDebugGUI()
    local ok, player = pcall(function() return game.Players.LocalPlayer end)
    if not ok or not player then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 260)
    mainFrame.Position = UDim2.new(1, -350, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.15
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
    header.Text = "🔍 DEBUG PRO"
    header.TextColor3 = Color3.fromRGB(0, 255, 100)
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local uptimeLabel = Instance.new("TextLabel")
    uptimeLabel.Name = "Uptime"
    uptimeLabel.Size = UDim2.new(1, 0, 0, 18)
    uptimeLabel.Position = UDim2.new(0, 0, 0, 28)
    uptimeLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    uptimeLabel.BorderSizePixel = 0
    uptimeLabel.Text = "⏱ Uptime: 00:00"
    uptimeLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    uptimeLabel.TextSize = 10
    uptimeLabel.Font = Enum.Font.Gotham
    uptimeLabel.Parent = mainFrame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -10, 1, -110)
    scrollFrame.Position = UDim2.new(0, 5, 0, 48)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
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

    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, 0, 0, 28)
    filterFrame.Position = UDim2.new(0, 0, 1, -58)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = mainFrame

    local filterButtons = {
        {text = "ALL", pos = 0},
        {text = "✅", pos = 0.2, filter = "SUCCESS"},
        {text = "❌", pos = 0.4, filter = "ERROR"},
        {text = "⚠️", pos = 0.6, filter = "WARNING"},
        {text = "ℹ️", pos = 0.8, filter = "INFO"}
    }

    for _, btn in ipairs(filterButtons) do
        local filterBtn = Instance.new("TextButton")
        filterBtn.Size = UDim2.new(0.18, 0, 1, 0)
        filterBtn.Position = UDim2.new(btn.pos, 0, 0, 0)
        filterBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        filterBtn.Text = btn.text
        filterBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        filterBtn.TextSize = 11
        filterBtn.Font = Enum.Font.GothamBold
        filterBtn.Parent = filterFrame

        local fbCorner = Instance.new("UICorner")
        fbCorner.CornerRadius = UDim.new(0, 5)
        fbCorner.Parent = filterBtn

        filterBtn.MouseButton1Click:Connect(function()
            currentFilter = btn.filter or "ALL"
            for _, b in ipairs(filterFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end
            end
            filterBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        end)
    end

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 26)
    buttonFrame.Position = UDim2.new(0, 0, 1, -28)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "ClearButton"
    clearBtn.Size = UDim2.new(0.32, 0, 1, 0)
    clearBtn.Position = UDim2.new(0.01, 0, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    clearBtn.Text = "Xóa"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.TextSize = 11
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = buttonFrame

    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 5)
    clearCorner.Parent = clearBtn

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0.32, 0, 1, 0)
    toggleBtn.Position = UDim2.new(0.34, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    toggleBtn.Text = "Ẩn/Hiện"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = buttonFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggleBtn

    local saveBtn = Instance.new("TextButton")
    saveBtn.Name = "SaveButton"
    saveBtn.Size = UDim2.new(0.32, 0, 1, 0)
    saveBtn.Position = UDim2.new(0.67, 0, 0, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    saveBtn.Text = "💾"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.Parent = buttonFrame

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 5)
    saveCorner.Parent = saveBtn

    clearBtn.MouseButton1Click:Connect(function()
        logs = {}
        logText.Text = ""
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        DebugSystem.info("Logs cleared from GUI", "DEBUG_GUI")
    end)

    local visible = true
    toggleBtn.MouseButton1Click:Connect(function()
        visible = not visible
        mainFrame.Visible = visible
        DebugSystem.info("Debug GUI visibility toggled: " .. tostring(visible), "DEBUG_GUI")
    end)

    saveBtn.MouseButton1Click:Connect(function()
        if writefile and isfolder then
            if not isfolder("DebugLogs") then makefolder("DebugLogs") end
            local filename = "DebugLogs/" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".txt"
            writefile(filename, table.concat(logs, "\n"))
            saveBtn.Text = "✓"
            DebugSystem.success("Saved debug logs to " .. filename, "DEBUG_GUI")
            task.wait(1)
            saveBtn.Text = "💾"
        else
            saveBtn.Text = "✗"
            DebugSystem.warn("Cannot save logs (writefile/isfolder not available)", "DEBUG_GUI")
            task.wait(1)
            saveBtn.Text = "💾"
        end
    end)

    screenGui.Parent = player:WaitForChild("PlayerGui")
    return logText, scrollFrame, uptimeLabel
end

-- tạo GUI an toàn (pcall)
local ok, logTextLabel, scrollFrame, uptimeLabel = pcall(function()
    return createDebugGUI()
end)
-- nếu createDebugGUI trả về nil thì biến sẽ không được dùng nhưng module vẫn hoạt động

-- Uptime tracker
task.spawn(function()
    while task.wait(1) do
        if uptimeLabel then
            local elapsed = math.floor(tick() - startTime)
            local min = math.floor(elapsed / 60)
            local sec = elapsed % 60
            uptimeLabel.Text = string.format("⏱ Uptime: %02d:%02d", min, sec)
        end
    end
end)

local lastUpdateTime = 0
local function updateLogDisplay()
    if tick() - lastUpdateTime < 0.05 then return end
    lastUpdateTime = tick()

    local filtered = {}
    for _, msg in ipairs(logs) do
        if currentFilter == "ALL" then
            table.insert(filtered, msg)
        elseif currentFilter == "SUCCESS" and string.find(msg, "✅") then
            table.insert(filtered, msg)
        elseif currentFilter == "ERROR" and string.find(msg, "❌") then
            table.insert(filtered, msg)
        elseif currentFilter == "WARNING" and string.find(msg, "⚠️") then
            table.insert(filtered, msg)
        elseif currentFilter == "INFO" and string.find(msg, "ℹ️") then
            table.insert(filtered, msg)
        end
    end

    if logTextLabel then
        logTextLabel.Text = table.concat(filtered, "\n")
        local textSize = game:GetService("TextService"):GetTextSize(
            logTextLabel.Text,
            logTextLabel.TextSize,
            logTextLabel.Font,
            Vector2.new(logTextLabel.AbsoluteSize.X, math.huge)
        )
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textSize.Y + 10)
        -- Smooth scroll to bottom
        pcall(function()
            game:GetService("TweenService"):Create(
                scrollFrame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)}
            ):Play()
        end)
    end
end

-- LOG với SOURCE TAG
function DebugSystem.log(message, level, source)
    if not debugEnabled then return end
    level = level or "INFO"
    source = source or "MAIN"

    local timestamp = os.date("%H:%M:%S")
    local prefix = level == "ERROR" and "❌" or level == "SUCCESS" and "✅" or level == "WARNING" and "⚠️" or "ℹ️"

    local logMessage = string.format("[%s][%s] %s %s", timestamp, source, prefix, tostring(message))
    table.insert(logs, logMessage)

    if #logs > maxLogs then table.remove(logs, 1) end

    updateLogDisplay()
    -- fallback print to output in case GUI not available
    pcall(function() print(logMessage) end)
end

function DebugSystem.info(msg, src) DebugSystem.log(msg, "INFO", src) end
function DebugSystem.error(msg, src) DebugSystem.log(msg, "ERROR", src) end
function DebugSystem.success(msg, src) DebugSystem.log(msg, "SUCCESS", src) end
function DebugSystem.warn(msg, src) DebugSystem.log(msg, "WARNING", src) end

function DebugSystem.try(func, funcName)
    funcName = funcName or "Unknown"
    DebugSystem.info("Chạy: " .. funcName, "TRY")
    local success, result = pcall(func)
    if success then
        DebugSystem.success(funcName .. " OK", "TRY")
        return true, result
    else
        DebugSystem.error(funcName .. " LỖI: " .. tostring(result), "TRY")
        return false, result
    end
end

function DebugSystem.setFilter(filter)
    currentFilter = filter
    DebugSystem.success("Bộ lọc: " .. filter, "SYSTEM")
    updateLogDisplay()
end

-- Performance monitor (tùy chọn)
local perfMonEnabled = false -- bật true nếu muốn
if perfMonEnabled then
    task.spawn(function()
        local run = game:GetService("RunService")
        local stats = game:GetService("Stats")
        while task.wait(10) do
            local ok, fps = pcall(function() return math.floor(1 / run.Heartbeat:Wait()) end)
            local ok2, ping = pcall(function() return math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ok and ok2 then
                DebugSystem.info(string.format("FPS:%d Ping:%dms", fps, ping), "PERF")
            end
        end
    end)
end

DebugSystem.success("Debug System Pro khởi động!", "SYSTEM")
