-- Arcane Notification System (Standalone)
-- Extracted from Arcane UI Library

local NotificationSystem = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local GuiInset = GuiService:GetGuiInset().Y
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Utility functions
local gethui = gethui or function() return CoreGui end

local function ToVector2(Value)
    if typeof(Value) == "Vector2" then return Value end
    if type(Value) == "table" then return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0) end
    return Vector2.new(0, 0)
end

-- Theme colors
local Themes = {
    ["Dark"] = {
        Background = Color3.fromRGB(16, 16, 18),
        Topbar = Color3.fromRGB(22, 22, 26),
        Section = Color3.fromRGB(21, 20, 25),
        Element = Color3.fromRGB(27, 26, 33),
        Accent = Color3.fromRGB(254, 0, 67),
        Text = Color3.fromRGB(255, 255, 255),
        DimText = Color3.fromRGB(120, 120, 130),
        Border = Color3.fromRGB(30, 29, 34),
        Selected = Color3.fromRGB(29, 28, 37),
        ToggleOff = Color3.fromRGB(35, 25, 38)
    },
    ["Light"] = {
        Background = Color3.fromRGB(228, 228, 233),
        Topbar = Color3.fromRGB(235, 235, 240),
        Section = Color3.fromRGB(245, 245, 249),
        Element = Color3.fromRGB(230, 230, 236),
        Accent = Color3.fromRGB(254, 0, 67),
        Text = Color3.fromRGB(24, 24, 30),
        DimText = Color3.fromRGB(140, 140, 150),
        Border = Color3.fromRGB(205, 205, 214),
        Selected = Color3.fromRGB(216, 216, 224),
        ToggleOff = Color3.fromRGB(210, 202, 206)
    }
}

-- Font loading
local CustomFont = {}
function CustomFont:New(Name, Weight, Style, Data)
    if not isfile(Name .. ".ttf") then
        writefile(Name .. ".ttf", game:HttpGet(Data.Url))
    end
    
    local FontData = {
        name = Name,
        faces = {{
            name = "Regular",
            weight = Weight,
            style = Style,
            assetId = getcustomasset(Name .. ".ttf")
        }}
    }
    
    if not isfile(Name .. ".font") then
        writefile(Name .. ".font", HttpService:JSONEncode(FontData))
    end
    
    return Font.new(getcustomasset(Name .. ".font"))
end

local Success, Result = pcall(function()
    return CustomFont:New("ArcaneInter", 600, "Normal", {
        Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/InterSemibold.ttf"
    })
end)

local Font = Success and Result or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)

-- Create holders
local Holder = Instance.new("ScreenGui")
Holder.Name = "\0"
Holder.Parent = gethui()
Holder.ZIndexBehavior = Enum.ZIndexBehavior.Global
Holder.ResetOnSpawn = false
Holder.IgnoreGuiInset = true

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "\0"
NotifHolder.Parent = Holder
NotifHolder.AnchorPoint = Vector2.new(1, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Position = UDim2.new(1, 0, 0, GuiInset)
NotifHolder.Size = UDim2.new(0, 0, 1, 0)
NotifHolder.BorderSizePixel = 0
NotifHolder.AutomaticSize = Enum.AutomaticSize.X

Instance.new("UIPadding").Parent = NotifHolder
NotifHolder.UIPadding.PaddingTop = UDim.new(0, 15)
NotifHolder.UIPadding.PaddingRight = UDim.new(0, 15)

local UIList = Instance.new("UIListLayout")
UIList.Parent = NotifHolder
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)

local UIScale = Instance.new("UIScale")
UIScale.Parent = Holder
UIScale.Scale = 1

-- Update scale for mobile
local function UpdateScale()
    local Scale = 1
    if IsMobile and workspace.CurrentCamera then
        local Viewport = workspace.CurrentCamera.ViewportSize
        Scale = math.clamp(math.min((Viewport.X * 0.94) / 526, (Viewport.Y * 0.94) / 515), 0.4, 1)
    end
    UIScale.Scale = Scale
end

UpdateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    task.wait()
    UpdateScale()
end)

-- Notification function
function NotificationSystem.Show(Params)
    Params = Params or {}
    
    local Name = Params.Name or Params.name or "Notification"
    local Description = Params.Description or Params.description or ""
    local Duration = Params.Duration or Params.duration or 5
    local Icon = Params.Icon or Params.icon
    local Accent = Params.Color or Params.color or Color3.fromRGB(254, 0, 67)
    
    local Height = 73
    local Items = {}
    
    -- Main notification frame
    Items.Notification = Instance.new("Frame")
    Items.Notification.Parent = NotifHolder
    Items.Notification.Name = "\0"
    Items.Notification.Size = UDim2.new(0, 0, 0, Height)
    Items.Notification.ClipsDescendants = true
    Items.Notification.BorderSizePixel = 0
    Items.Notification.BackgroundColor3 = Color3.fromRGB(21, 20, 25)
    
    local Corner = Instance.new("UICorner")
    Corner.Parent = Items.Notification
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Items.Notification
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = Color3.fromRGB(30, 29, 34)
    Stroke.Transparency = 0.4
    
    local TitleX = 12
    
    -- Icon (if provided)
    if Icon then
        Items.Icon = Instance.new("ImageLabel")
        Items.Icon.Parent = Items.Notification
        Items.Icon.Name = "\0"
        Items.Icon.ImageColor3 = Accent
        Items.Icon.BackgroundTransparency = 1
        Items.Icon.Position = UDim2.new(0, 12, 0, 13)
        Items.Icon.Size = UDim2.new(0, 18, 0, 18)
        Items.Icon.BorderSizePixel = 0
        Items.Icon.Image = "rbxassetid://" .. tostring(Icon)
        TitleX = 38
    end
    
    -- Title
    Items.Title = Instance.new("TextLabel")
    Items.Title.Parent = Items.Notification
    Items.Title.Name = "\0"
    Items.Title.FontFace = Font
    Items.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Items.Title.Text = Name
    Items.Title.TextSize = 14
    Items.Title.BackgroundTransparency = 1
    Items.Title.Position = UDim2.new(0, TitleX, 0, 12)
    Items.Title.Size = UDim2.new(0, 260 - TitleX - 12, 0, 18)
    Items.Title.TextXAlignment = Enum.TextXAlignment.Left
    Items.Title.TextTruncate = Enum.TextTruncate.AtEnd
    Items.Title.BorderSizePixel = 0
    
    -- Description
    Items.Description = Instance.new("TextLabel")
    Items.Description.Parent = Items.Notification
    Items.Description.Name = "\0"
    Items.Description.FontFace = Font
    Items.Description.TextColor3 = Color3.fromRGB(120, 120, 130)
    Items.Description.TextTransparency = 0.35
    Items.Description.Text = Description
    Items.Description.TextSize = 13
    Items.Description.BackgroundTransparency = 1
    Items.Description.Position = UDim2.new(0, 12, 0, 36)
    Items.Description.Size = UDim2.new(0, 150, 0, 15)
    Items.Description.TextXAlignment = Enum.TextXAlignment.Left
    Items.Description.TextTruncate = Enum.TextTruncate.AtEnd
    Items.Description.BorderSizePixel = 0
    
    -- Duration
    Items.Duration = Instance.new("TextLabel")
    Items.Duration.Parent = Items.Notification
    Items.Duration.Name = "\0"
    Items.Duration.FontFace = Font
    Items.Duration.TextColor3 = Color3.fromRGB(120, 120, 130)
    Items.Duration.Text = Duration .. "s"
    Items.Duration.TextSize = 13
    Items.Duration.BackgroundTransparency = 1
    Items.Duration.AnchorPoint = Vector2.new(1, 0)
    Items.Duration.Position = UDim2.new(1, -12, 0, 36)
    Items.Duration.Size = UDim2.new(0, 60, 0, 15)
    Items.Duration.TextXAlignment = Enum.TextXAlignment.Right
    Items.Duration.BorderSizePixel = 0
    
    -- Liner (progress bar)
    Items.Liner = Instance.new("Frame")
    Items.Liner.Parent = Items.Notification
    Items.Liner.Name = "\0"
    Items.Liner.Position = UDim2.new(0, 12, 0, 59)
    Items.Liner.Size = UDim2.new(1, -24, 0, 4)
    Items.Liner.BorderSizePixel = 0
    Items.Liner.BackgroundColor3 = Accent
    
    local LinerCorner = Instance.new("UICorner")
    LinerCorner.Parent = Items.Liner
    LinerCorner.CornerRadius = UDim.new(1, 0)
    
    -- Setup fade data
    local Fades = {}
    local function AddFade(Object, Property)
        table.insert(Fades, { Object = Object, Property = Property, Original = Object[Property] })
    end
    
    for _, Child in Items.Notification:GetDescendants() do
        if Child:IsA("ImageLabel") then
            AddFade(Child, "ImageTransparency")
        elseif Child:IsA("TextLabel") then
            AddFade(Child, "TextTransparency")
        elseif Child:IsA("Frame") then
            AddFade(Child, "BackgroundTransparency")
        end
    end
    
    -- Set initial transparency
    for _, Fade in Fades do
        Fade.Object[Fade.Property] = 1
    end
    
    local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local Alive = true
    
    coroutine.wrap(function()
        -- Animate in
        local Tween1 = TweenService:Create(Items.Notification, Info, { Size = UDim2.new(0, 260, 0, Height) })
        Tween1:Play()
        
        for _, Fade in Fades do
            local Tween = TweenService:Create(Fade.Object, Info, { [Fade.Property] = Fade.Original })
            Tween:Play()
        end
        
        -- Animate progress bar
        local ProgressTween = TweenService:Create(Items.Liner, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 4)
        })
        ProgressTween:Play()
        
        -- Update duration text
        local Remaining = Duration
        while Alive and Remaining > 0 do
            task.wait(0.1)
            Remaining = math.max(Remaining - 0.1, 0)
            if Items.Duration and Items.Duration.Parent then
                Items.Duration.Text = string.format("%.1f", Remaining) .. "s"
            end
        end
        
        -- Wait and fade out
        task.wait(0.1)
        Alive = false
        
        for _, Fade in Fades do
            local Tween = TweenService:Create(Fade.Object, Info, { [Fade.Property] = 1 })
            Tween:Play()
        end
        
        local Tween2 = TweenService:Create(Items.Notification, Info, { Size = UDim2.new(0, 0, 0, 0) })
        Tween2:Play()
        
        task.wait(0.5)
        Items.Notification:Destroy()
    end)()
end

-- Success notification helper
function NotificationSystem.Success(Params)
    Params = Params or {}
    Params.Color = Params.Color or Color3.fromRGB(52, 255, 164)
    Params.Icon = Params.Icon or "10709790644"  -- Checkmark
    return NotificationSystem.Show(Params)
end

-- Error notification helper
function NotificationSystem.Error(Params)
    Params = Params or {}
    Params.Color = Params.Color or Color3.fromRGB(255, 60, 60)
    Params.Icon = Params.Icon or "10709806226"  -- X mark
    return NotificationSystem.Show(Params)
end

-- Warning notification helper
function NotificationSystem.Warning(Params)
    Params = Params or {}
    Params.Color = Params.Color or Color3.fromRGB(255, 200, 50)
    Params.Icon = Params.Icon or "10709806590"  -- Warning
    return NotificationSystem.Show(Params)
end

-- Info notification helper
function NotificationSystem.Info(Params)
    Params = Params or {}
    Params.Color = Params.Color or Color3.fromRGB(50, 150, 255)
    Params.Icon = Params.Icon or "10709819133"  -- Info
    return NotificationSystem.Show(Params)
end

-- Return the notification system
return NotificationSystem
