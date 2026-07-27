getgenv().UI = true
game:GetService("RunService"):Set3dRenderingEnabled(false)

local gui = Instance.new("ScreenGui")
gui.Name = tostring(math.random(100000,999999))
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")
gui.Enabled = true

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Name = tostring(math.random(100000,999999))
frame.Parent = gui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.3, 0)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "https://discord.gg/uVZgQcQWgn"
title.Font = Enum.Font.GothamBold
title.TextSize = 50
title.TextColor3 = Color3.fromRGB(175, 187, 230)
title.Name = tostring(math.random(100000,999999))
title.Parent = frame

-- FIX 1: renamed "Total SnowToken" -> "Total Summer Keys"
local stats = {"Play Time", "Total Summer Keys", "Coins Bag", "Game Started"}
local statLabels = {}
local colors = {
    Color3.fromRGB(200, 0, 0),
    Color3.fromRGB(0, 200, 0),
    Color3.fromRGB(68, 0, 255),
    Color3.fromRGB(0, 217, 255),
}

for i, stat in ipairs(stats) do
    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0.4 + (i-1)*0.1, 0)
    label.Size = UDim2.new(0.6, 0, 0, 40)
    label.BackgroundTransparency = 1
    label.Text = stat..": 0"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 36
    label.TextColor3 = colors[i]
    label.Name = stat
    label.Parent = frame
    statLabels[stat] = label
end

local plr = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- FIX 2: pull ProfileData directly so Summer Keys count is live
local ProfileData = require(ReplicatedStorage
    :WaitForChild("Modules")
    :WaitForChild("ProfileData"))

local function GetSummerKeys()
    return ProfileData.Materials.Owned.SummerKey2026 or 0
end

local function GetCoinsBag()
    local pcFull = plr.PlayerGui:FindFirstChild("MainGUI")
        and plr.PlayerGui.MainGUI:FindFirstChild("Lobby")
        and plr.PlayerGui.MainGUI.Lobby:FindFirstChild("Dock")
        and plr.PlayerGui.MainGUI.Lobby.Dock:FindFirstChild("CoinBags")
        and plr.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container
        and plr.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container.Coin
        and plr.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container.Coin.CurrencyFrame.Icon.Coins
    local mobileFull = plr.PlayerGui:FindFirstChild("MainGUI")
        and plr.PlayerGui.MainGUI:FindFirstChild("Game")
        and plr.PlayerGui.MainGUI.Game:FindFirstChild("CoinBags")
        and plr.PlayerGui.MainGUI.Game.CoinBags.Container
        and plr.PlayerGui.MainGUI.Game.CoinBags.Container.Coin
        and plr.PlayerGui.MainGUI.Game.CoinBags.Container.Coin.CurrencyFrame.Icon.Coins
    return (pcFull and pcFull.ContentText) or (mobileFull and mobileFull.ContentText)
end

local function CheckStartGame()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:GetAttribute("MapID") then return true end
    end
    return false
end

local startTime = tick()

task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - startTime
        local hours   = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        local playTime = string.format("%02dh %02dm %02ds", hours, minutes, seconds)

        if statLabels["Play Time"] then
            statLabels["Play Time"].Text = "Play Time: " .. playTime
        end
        -- FIX 3: actually update the label every tick with the live count
        if statLabels["Total Summer Keys"] then
            statLabels["Total Summer Keys"].Text = "Total Summer Keys: " .. tostring(GetSummerKeys())
        end
        if statLabels["Coins Bag"] then
            statLabels["Coins Bag"].Text = "Coins Bag: " .. tostring(GetCoinsBag())
        end
        if statLabels["Game Started"] then
            statLabels["Game Started"].Text = "Game Started: " .. tostring(CheckStartGame())
        end
    end
end)
