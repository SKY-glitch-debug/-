-- CometHub status panel. Load this after mm2.lua (or let mm2.lua load it).
-- It reads the shared getgenv().CometHubStatus table; no game remotes are used here.

if getgenv().CometStatusUI then return end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local cfg = getgenv().CometHub or {}
local performance = cfg["Performance"] or {}
if performance["Low CPU"] then
	local existingMask = plr.PlayerGui:FindFirstChild("CometLowCPUMask")
	if existingMask then existingMask:Destroy() end

	local maskGui = Instance.new("ScreenGui")
	maskGui.Name = "CometLowCPUMask"
	maskGui.ResetOnSpawn = false
	maskGui.IgnoreGuiInset = true
	maskGui.DisplayOrder = 998
	maskGui.Parent = plr.PlayerGui

	local mask = Instance.new("Frame")
	mask.Name = "Blackout"
	mask.Size = UDim2.fromScale(1, 1)
	mask.BackgroundColor3 = Color3.new(0, 0, 0)
	mask.BorderSizePixel = 0
	mask.Parent = maskGui
end

local gui = Instance.new("ScreenGui")
gui.Name = "CometStatusUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = plr:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(330, 295)
panel.Position = UDim2.new(0, 18, 0.5, -148)
panel.BackgroundColor3 = Color3.fromRGB(9, 11, 13)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(47, 220, 86)
stroke.Thickness = 2
stroke.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = panel

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 13)
pad.PaddingBottom = UDim.new(0, 13)
pad.Parent = panel

local function row(name)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, -28, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(241, 241, 241)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel
	return label
end

local fields = {
	User = row("User"), Level = row("Level"), Bag = row("Bag"), Coins = row("Coins"),
	Shells = row("Shells"), Quest = row("Quest"), Crates = row("Crates"), Uptime = row("Uptime"),
}

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -28, 0, 2)
divider.BackgroundColor3 = Color3.fromRGB(47, 220, 86)
divider.BorderSizePixel = 0
divider.Parent = panel

fields.Status = row("Status")
fields.Status.Position = UDim2.new()

local function value(v)
	return v == nil and "—" or tostring(v)
end

local function elapsed(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%02d:%02d:%02d", seconds / 3600, (seconds / 60) % 60, seconds % 60)
end

task.spawn(function()
	while gui.Parent do
		local s = getgenv().CometHubStatus or {}
		fields.User.Text = "👤 User: " .. value(s.User or plr.Name)
		local level = value(s.Level)
		local levelMax = value(s.LevelMax or 100)
		fields.Level.Text = "⭐ Level: " .. level .. " / " .. levelMax
		fields.Bag.Text = "💰 Coins in Bag: " .. value(s.Bag)
		fields.Coins.Text = "💵 Total Coins: " .. value(s.Coins)
		fields.Shells.Text = "🐚 Shells: " .. value(s.Shells)
		fields.Quest.Text = "📋 Daily Quest: " .. value(s.Quest)
		fields.Crates.Text = "📦 Crates Opened: " .. value(s.Crates or 0)
		fields.Uptime.Text = "🕘 Uptime: " .. elapsed(s.Uptime)
		fields.Status.Text = "🔄 Status: " .. value(s.Status or "Loading")
		task.wait(0.5)
	end
end)

-- Drag on desktop; works harmlessly on touch devices.
local dragging, start, origin
panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging, start, origin = true, input.Position, panel.Position
	end
end)
panel.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - start
		panel.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
	end
end)
panel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

getgenv().CometStatusUI = gui
