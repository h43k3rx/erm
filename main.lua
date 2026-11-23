
--==================================================
-- LOW RESOURCE OPTIMIZER
-- Single-file Roblox LocalScript / Executor script
--==================================================

--==================================================
-- IN-GAME LOADING SCREEN
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LowResourceLoading"
LoadingGui.IgnoreGuiInset = true
LoadingGui.ResetOnSpawn = false
LoadingGui.DisplayOrder = 2000
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LoadingBackground = Instance.new("Frame")
LoadingBackground.Size = UDim2.fromScale(1, 1)
LoadingBackground.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LoadingBackground.BorderSizePixel = 0
LoadingBackground.Parent = LoadingGui

local LoadingPanel = Instance.new("Frame")
LoadingPanel.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingPanel.Position = UDim2.fromScale(0.5, 0.5)
LoadingPanel.Size = UDim2.fromOffset(360, 142)
LoadingPanel.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
LoadingPanel.BorderSizePixel = 0
LoadingPanel.Parent = LoadingBackground

local LoadingPanelCorner = Instance.new("UICorner")
LoadingPanelCorner.CornerRadius = UDim.new(0, 12)
LoadingPanelCorner.Parent = LoadingPanel

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Position = UDim2.fromOffset(20, 16)
LoadingTitle.Size = UDim2.new(1, -40, 0, 26)
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.Text = "LOW RESOURCE OPTIMIZER"
LoadingTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
LoadingTitle.TextSize = 16
LoadingTitle.TextXAlignment = Enum.TextXAlignment.Left
LoadingTitle.Parent = LoadingPanel

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Position = UDim2.fromOffset(20, 53)
LoadingStatus.Size = UDim2.new(1, -40, 0, 18)
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.Text = "INITIALIZING..."
LoadingStatus.TextColor3 = Color3.fromRGB(165, 165, 175)
LoadingStatus.TextSize = 11
LoadingStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadingStatus.Parent = LoadingPanel

local LoadingBarBackground = Instance.new("Frame")
LoadingBarBackground.Position = UDim2.fromOffset(20, 84)
LoadingBarBackground.Size = UDim2.new(1, -40, 0, 9)
LoadingBarBackground.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
LoadingBarBackground.BorderSizePixel = 0
LoadingBarBackground.ClipsDescendants = true
LoadingBarBackground.Parent = LoadingPanel

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(1, 0)
LoadingBarCorner.Parent = LoadingBarBackground

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(45, 190, 105)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Parent = LoadingBarBackground

local LoadingFillCorner = Instance.new("UICorner")
LoadingFillCorner.CornerRadius = UDim.new(1, 0)
LoadingFillCorner.Parent = LoadingBarFill

local LoadingPercent = Instance.new("TextLabel")
LoadingPercent.BackgroundTransparency = 1
LoadingPercent.Position = UDim2.fromOffset(20, 101)
LoadingPercent.Size = UDim2.new(1, -40, 0, 20)
LoadingPercent.Font = Enum.Font.GothamSemibold
LoadingPercent.Text = "0%"
LoadingPercent.TextColor3 = Color3.fromRGB(190, 190, 200)
LoadingPercent.TextSize = 11
LoadingPercent.TextXAlignment = Enum.TextXAlignment.Right
LoadingPercent.Parent = LoadingPanel

local function ParentLoadingGui()
    local success = pcall(function()
        LoadingGui.Parent = game:GetService("CoreGui")
    end)

    if not success or not LoadingGui.Parent then
        LoadingGui.Parent = PlayerGui
    end
end

ParentLoadingGui()

local LoadingDuration = 15
local LoadingStart = os.clock()

while true do
    local progress = math.clamp((os.clock() - LoadingStart) / LoadingDuration, 0, 1)
    local percent = math.floor(progress * 100)

    LoadingPercent.Text = tostring(percent) .. "%"
    TweenService:Create(
        LoadingBarFill,
        TweenInfo.new(0.12, Enum.EasingStyle.Linear),
        {Size = UDim2.new(progress, 0, 1, 0)}
    ):Play()

    if progress >= 1 then
        break
    end

    task.wait(0.1)
end

LoadingStatus.Text = "READY"
LoadingStatus.TextColor3 = Color3.fromRGB(75, 220, 130)
LoadingPercent.TextColor3 = Color3.fromRGB(75, 220, 130)

--==================================================
-- AUTO RUN + RE-QUEUE AFTER EVERY TELEPORT
--==================================================

local SCRIPT_URL =
    "https://raw.githubusercontent.com/h43k3rx/erm/refs/heads/main/main.lua"

local ExecutorEnv = _G
pcall(function()
    if type(getgenv) == "function" then
        ExecutorEnv = getgenv()
    end
end)

local QueueFunction =
    queue_on_teleport
    or queueonteleport
    or (type(ExecutorEnv) == "table" and (
        ExecutorEnv.queue_on_teleport
        or ExecutorEnv.queueonteleport
    ))

if type(QueueFunction) == "function" then
    local queuedCode = string.format(
        'repeat task.wait(0.25) until game:IsLoaded(); loadstring(game:HttpGet(%q))()',
        SCRIPT_URL
    )

    local queued, queueError = pcall(function()
        QueueFunction(queuedCode)
    end)

    if queued then
        print("[LowResource] Re-queue registered for next server.")
    else
        warn("[LowResource] Queue registration failed:", queueError)
    end
else
    warn("[LowResource] No supported queue_on_teleport function found.")
end

--==================================================
-- ORIGINAL OPTIMIZER
--==================================================

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

--==================================================
-- CONFIG
--==================================================

local Defaults = {
    FPS = 10,
    Grayscale = true,
    Shadows = true,
    Particles = true,
    Lights = true,
    BlackScreen = false,
    AutoEnable = true,
    Mode = "CUSTOM"
}

local Presets = {
    BALANCED = {
        FPS = 30,
        Grayscale = false,
        Shadows = true,
        Particles = true,
        Lights = false,
        BlackScreen = false
    },
    PERFORMANCE = {
        FPS = 60,
        Grayscale = true,
        Shadows = true,
        Particles = true,
        Lights = true,
        BlackScreen = false
    },
    ULTRA_LOW = {
        FPS = 15,
        Grayscale = true,
        Shadows = true,
        Particles = true,
        Lights = true,
        BlackScreen = false
    }
}

local Config = {}

for k, v in pairs(Defaults) do
    Config[k] = v
end

local Folder = "LowResource"
local ConfigFile = Folder .. "/config.json"

local Enabled = false
local SavedSettings = {}
local Processed = {}
local Connections = {}

local OriginalFPS = nil
local ScanId = 0
local SaveId = 0

--==================================================
-- FILE SYSTEM
--==================================================

local function HasFileSystem()
    return type(makefolder) == "function"
        and type(writefile) == "function"
        and type(readfile) == "function"
end

local function SaveConfig()
    if not HasFileSystem() then
        return false
    end

    local success = pcall(function()
        if type(isfolder) == "function" then
            if not isfolder(Folder) then
                makefolder(Folder)
            end
        else
            pcall(makefolder, Folder)
        end

        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end)

    return success
end

local function LoadConfig()
    if not HasFileSystem() then
        return
    end

    local success, data = pcall(function()
        if type(isfile) == "function" and not isfile(ConfigFile) then
            return nil
        end

        return HttpService:JSONDecode(readfile(ConfigFile))
    end)

    if not success or type(data) ~= "table" then
        return
    end

    if type(data.FPS) == "number" then
        Config.FPS = math.clamp(math.floor(data.FPS), 5, 120)
    end

    for key, default in pairs(Defaults) do
        if key ~= "FPS" and key ~= "Mode" and type(data[key]) == "boolean" then
            Config[key] = data[key]
        end
    end

    if type(data.Mode) == "string"
    and (Presets[data.Mode] or data.Mode == "CUSTOM") then
        Config.Mode = data.Mode
    end
end

local function AutoSave()
    SaveId += 1
    local currentId = SaveId

    task.delay(0.4, function()
        if currentId == SaveId then
            SaveConfig()
        end
    end)
end

LoadConfig()

--==================================================
-- FPS
--==================================================

pcall(function()
    if type(getfpscap) == "function" then
        OriginalFPS = getfpscap()
    end
end)

local function ApplyFPS()
    if type(setfpscap) == "function" then
        pcall(setfpscap, Config.FPS)
    end
end

local function RestoreFPS()
    if OriginalFPS and type(setfpscap) == "function" then
        pcall(setfpscap, OriginalFPS)
    end
end

--==================================================
-- PROPERTY SAVE / RESTORE
--==================================================

local function SaveProperty(obj, property, value)
    SavedSettings[obj] = SavedSettings[obj] or {}

    if SavedSettings[obj][property] == nil then
        local success, original = pcall(function()
            return obj[property]
        end)

        if success then
            SavedSettings[obj][property] = original
        end
    end

    pcall(function()
        obj[property] = value
    end)
end

local function RestoreSettings()
    for obj, properties in pairs(SavedSettings) do
        if obj and obj.Parent then
            for property, original in pairs(properties) do
                pcall(function()
                    obj[property] = original
                end)
            end
        end
    end

    table.clear(SavedSettings)
    table.clear(Processed)
end

local function ToGray(color)
    local gray = color.R * 0.299
        + color.G * 0.587
        + color.B * 0.114

    return Color3.new(gray, gray, gray)
end

--==================================================
-- OBJECT OPTIMIZATION
--==================================================

local function OptimizeObject(obj)
    if not Enabled or Processed[obj] then
        return
    end

    Processed[obj] = true

    if Config.Grayscale then
        if obj:IsA("BasePart") then
            SaveProperty(obj, "Color", ToGray(obj.Color))
            SaveProperty(obj, "Material", Enum.Material.SmoothPlastic)

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            SaveProperty(obj, "Color3", ToGray(obj.Color3))
        end
    end

    if Config.Shadows and obj:IsA("BasePart") then
        SaveProperty(obj, "CastShadow", false)
    end

    if Config.Particles then
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles") then
            SaveProperty(obj, "Enabled", false)
        end
    end

    if Config.Lights then
        if obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
            SaveProperty(obj, "Enabled", false)
        end
    end

    if Config.Lights and obj:IsA("PostEffect") then
        SaveProperty(obj, "Enabled", false)
    end
end

local function ApplyLighting()
    if Config.Shadows then
        SaveProperty(Lighting, "GlobalShadows", false)
    end

    if Config.Grayscale then
        -- Không thay đổi toàn bộ màu Lighting để tránh ảnh hưởng quá mức.
    end

    if Config.Particles then
        local terrain = Workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            SaveProperty(terrain, "Decoration", false)
        end
    end
end

local function ApplyAll()
    if not Enabled then
        return
    end

    ScanId += 1
    local thisScan = ScanId

    ApplyFPS()
    ApplyLighting()

    task.spawn(function()
        local descendants = Workspace:GetDescendants()

        for i, obj in ipairs(descendants) do
            if not Enabled or thisScan ~= ScanId then
                return
            end

            OptimizeObject(obj)

            if i % 100 == 0 then
                task.wait()
            end
        end
    end)
end

local function Reapply()
    if not Enabled then
        return
    end

    ScanId += 1
    RestoreSettings()
    ApplyAll()
end

--==================================================
-- BLACK SCREEN
--==================================================

local BlackGui = Instance.new("ScreenGui")
BlackGui.Name = "LowResourceBlackScreen"
BlackGui.IgnoreGuiInset = true
BlackGui.ResetOnSpawn = false
BlackGui.DisplayOrder = 900
BlackGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local BlackFrame = Instance.new("Frame")
BlackFrame.Name = "Black"
BlackFrame.Size = UDim2.fromScale(1, 1)
BlackFrame.Position = UDim2.fromScale(0, 0)
BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BlackFrame.BackgroundTransparency = 0
BlackFrame.BorderSizePixel = 0
BlackFrame.Visible = false
BlackFrame.Active = false
BlackFrame.ZIndex = 1
BlackFrame.Parent = BlackGui

local function ApplyBlackScreen()
    BlackFrame.Visible = Enabled and Config.BlackScreen
end

--==================================================
-- ENABLE / DISABLE
--==================================================

local function EnableOptimizer()
    if Enabled then
        return
    end

    Enabled = true

    table.clear(SavedSettings)
    table.clear(Processed)

    ApplyAll()
    ApplyBlackScreen()
end

local function DisableOptimizer()
    if not Enabled then
        return
    end

    Enabled = false
    ScanId += 1

    RestoreSettings()
    RestoreFPS()
    ApplyBlackScreen()
end

local function ToggleOptimizer()
    if Enabled then
        DisableOptimizer()
    else
        EnableOptimizer()
    end
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LowResourceOptimizer"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 1000
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(330, 510)
Main.Position = UDim2.new(0.5, -165, 0.5, -255)
Main.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(65, 65, 75)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local function MakeLabel(parent, text, position, size, textSize)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.TextSize = textSize or 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function MakeButton(parent, text, position, size)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(43, 43, 52)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 245)
    button.TextSize = 12
    button.AutoButtonColor = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

-- Header: only this area can drag the window.
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

MakeLabel(
    Header,
    "LOW RESOURCE OPTIMIZER",
    UDim2.fromOffset(15, 0),
    UDim2.new(1, -30, 1, 0),
    14
).Font = Enum.Font.GothamBold

local Status = MakeLabel(
    Main,
    "STATUS: DISABLED",
    UDim2.fromOffset(15, 61),
    UDim2.new(1, -30, 0, 20),
    12
)

local function UpdateStatus()
    if Enabled then
        Status.Text = "STATUS: ENABLED"
        Status.TextColor3 = Color3.fromRGB(100, 220, 140)
    else
        Status.Text = "STATUS: DISABLED"
        Status.TextColor3 = Color3.fromRGB(230, 110, 110)
    end

    EnableButton.Text = Enabled and "DISABLE OPTIMIZER [F]" or "ENABLE OPTIMIZER [F]"
end

EnableButton = MakeButton(
    Main,
    "ENABLE OPTIMIZER [F]",
    UDim2.fromOffset(15, 88),
    UDim2.new(1, -30, 0, 35)
)

EnableButton.BackgroundColor3 = Color3.fromRGB(55, 105, 75)

EnableButton.MouseButton1Click:Connect(function()
    ToggleOptimizer()
    UpdateStatus()
end)

--==================================================
-- MODE PRESETS
--==================================================

local ModeButtons = {}
local ModeNames = {
    {"BALANCED", "BALANCED"},
    {"PERFORMANCE", "PERFORMANCE"},
    {"ULTRA LOW", "ULTRA_LOW"}
}

local function UpdateModeUI()
    for mode, button in pairs(ModeButtons) do
        local selected = Config.Mode == mode
        button.BackgroundColor3 = selected
            and Color3.fromRGB(55, 105, 75)
            or Color3.fromRGB(43, 43, 52)
    end
end

for index, item in ipairs(ModeNames) do
    local button = MakeButton(
        Main,
        item[1],
        UDim2.new(0, 15 + (index - 1) * 101, 0, 188),
        UDim2.fromOffset(96, 28)
    )
    button.TextSize = 10
    ModeButtons[item[2]] = button
end

UpdateModeUI()

--==================================================
-- FPS SLIDER
--==================================================

MakeLabel(
    Main,
    "FPS LIMIT",
    UDim2.fromOffset(15, 135),
    UDim2.fromOffset(100, 20),
    12
)

local FPSValue = MakeLabel(
    Main,
    tostring(Config.FPS),
    UDim2.new(1, -75, 0, 135),
    UDim2.fromOffset(60, 20),
    12
)

FPSValue.TextXAlignment = Enum.TextXAlignment.Right

local SliderBack = Instance.new("Frame")
SliderBack.Position = UDim2.fromOffset(15, 165)
SliderBack.Size = UDim2.new(1, -30, 0, 8)
SliderBack.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
SliderBack.BorderSizePixel = 0
SliderBack.Parent = Main

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderBack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((Config.FPS - 5) / 115, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(1, 0, 0, 24)
SliderButton.Position = UDim2.new(0, 0, 0.5, -12)
SliderButton.BackgroundTransparency = 1
SliderButton.Text = ""
SliderButton.Parent = SliderBack

local Sliding = false

local function SetFPSFromX(x)
    local left = SliderBack.AbsolutePosition.X
    local width = SliderBack.AbsoluteSize.X

    local alpha = math.clamp((x - left) / width, 0, 1)
    local value = math.floor((5 + alpha * 115) / 5 + 0.5) * 5

    Config.FPS = math.clamp(value, 5, 120)
    Config.Mode = "CUSTOM"
    UpdateModeUI()

    local progress = (Config.FPS - 5) / 115

    SliderFill.Size = UDim2.new(progress, 0, 1, 0)
    FPSValue.Text = tostring(Config.FPS)

    if Enabled then
        ApplyFPS()
    end

    AutoSave()
end

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Sliding = true
        SetFPSFromX(input.Position.X)
    end
end)

Connections.SliderChanged = UIS.InputChanged:Connect(function(input)
    if Sliding then
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            SetFPSFromX(input.Position.X)
        end
    end
end)

Connections.SliderEnded = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Sliding = false
    end
end)

--==================================================
-- SETTING TOGGLES
--==================================================

local function MakeToggle(name, key, y)
    local button = MakeButton(
        Main,
        "",
        UDim2.fromOffset(15, y),
        UDim2.new(1, -30, 0, 32)
    )

    local function Update()
        local state = Config[key]

        button.Text = name .. "     [" .. (state and "ON" or "OFF") .. "]"

        if state then
            button.TextColor3 = Color3.fromRGB(120, 220, 150)
        else
            button.TextColor3 = Color3.fromRGB(210, 210, 215)
        end
    end

    button.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Config.Mode = "CUSTOM"
        UpdateModeUI()

        Update()

        if key == "BlackScreen" then
            ApplyBlackScreen()
        elseif Enabled then
            Reapply()
        end

        AutoSave()
    end)

    Update()

    return Update
end

local UpdateGrayscale = MakeToggle("GRAYSCALE", "Grayscale", 224)
local UpdateShadows = MakeToggle("DISABLE SHADOWS", "Shadows", 262)
local UpdateParticles = MakeToggle("DISABLE PARTICLES", "Particles", 300)
local UpdateLights = MakeToggle("DISABLE LIGHTS", "Lights", 338)
local UpdateBlackScreen = MakeToggle("BLACK SCREEN", "BlackScreen", 376)

--==================================================
-- CONFIG BUTTONS
--==================================================

local LoadConfigButton = MakeButton(
    Main,
    "LOAD CONFIG",
    UDim2.fromOffset(15, 390),
    UDim2.new(0.5, -20, 0, 30)
)

local ResetConfigButton = MakeButton(
    Main,
    "RESET CONFIG",
    UDim2.new(0.5, 5, 0, 390),
    UDim2.new(0.5, -20, 0, 30)
)

local function UpdateConfigUI()
    FPSValue.Text = tostring(Config.FPS)
    SliderFill.Size = UDim2.new((Config.FPS - 5) / 115, 0, 1, 0)
    UpdateModeUI()

    UpdateGrayscale()
    UpdateShadows()
    UpdateParticles()
    UpdateLights()
    UpdateBlackScreen()

    if Enabled then
        Reapply()
    else
        ApplyBlackScreen()
    end
end

for mode, button in pairs(ModeButtons) do
    button.MouseButton1Click:Connect(function()
        local preset = Presets[mode]

        for key, value in pairs(preset) do
            Config[key] = value
        end

        Config.Mode = mode
        UpdateConfigUI()
        AutoSave()
        print("[LowResource] Mode selected:", mode)
    end)
end

LoadConfigButton.Position = UDim2.fromOffset(15, 414)
ResetConfigButton.Position = UDim2.new(0.5, 5, 0, 414)

LoadConfigButton.MouseButton1Click:Connect(function()
    LoadConfig()
    UpdateConfigUI()
    print("[LowResource] Config loaded.")
end)

ResetConfigButton.MouseButton1Click:Connect(function()
    for key, value in pairs(Defaults) do
        Config[key] = value
    end

    UpdateConfigUI()
    AutoSave()
    print("[LowResource] Config reset to defaults.")
end)

MakeLabel(
    Main,
    "CONFIG AUTO-SAVES WHEN SETTINGS CHANGE",
    UDim2.fromOffset(15, 452),
    UDim2.new(1, -30, 0, 18),
    9
).TextColor3 = Color3.fromRGB(120, 220, 150)

MakeLabel(
    Main,
    "F: Toggle optimizer     T: Hide / Show UI",
    UDim2.fromOffset(15, 476),
    UDim2.new(1, -30, 0, 20),
    10
).TextColor3 = Color3.fromRGB(145, 145, 155)

--==================================================
-- DRAG WINDOW
--==================================================

local Dragging = false
local DragStart = nil
local StartPosition = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
    end
end)

Connections.DragChanged = UIS.InputChanged:Connect(function(input)
    if Dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end
end)

Connections.DragEnded = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

--==================================================
-- PARENT GUI
--==================================================

local function SetGuiParent(gui)
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)

    if not success or not gui.Parent then
        gui.Parent = PlayerGui
    end
end

SetGuiParent(BlackGui)
SetGuiParent(ScreenGui)

-- Fade the loading screen away to reveal the main optimizer UI.
task.spawn(function()
    local fadeInfo = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, object in ipairs(LoadingGui:GetDescendants()) do
        if object:IsA("Frame") then
            TweenService:Create(object, fadeInfo, {BackgroundTransparency = 1}):Play()
        elseif object:IsA("TextLabel") then
            TweenService:Create(object, fadeInfo, {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play()
        elseif object:IsA("UIStroke") then
            TweenService:Create(object, fadeInfo, {Transparency = 1}):Play()
        end
    end

    TweenService:Create(LoadingBackground, fadeInfo, {BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    LoadingGui:Destroy()
end)

--==================================================
-- HOTKEYS
--==================================================

Connections.Hotkeys = UIS.InputBegan:Connect(function(input, gameProcessed)
    -- Không dùng gameProcessed để tránh game chặn phím F/T.
    if UIS:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        ToggleOptimizer()
        UpdateStatus()

    elseif input.KeyCode == Enum.KeyCode.T then
        Main.Visible = not Main.Visible
    end
end)

--==================================================
-- NEW OBJECTS
--==================================================

Connections.DescendantAdded = Workspace.DescendantAdded:Connect(function(obj)
    if Enabled then
        task.defer(function()
            if Enabled then
                OptimizeObject(obj)
            end
        end)
    end
end)

--==================================================
-- INITIALIZE
--==================================================

UpdateStatus()
ApplyBlackScreen()

task.delay(1, function()
    if Config.AutoEnable then
        EnableOptimizer()
        UpdateStatus()
    end
end)

print("[LowResource] Loaded successfully.")
print("[LowResource] F = Toggle optimizer | T = Toggle UI")
