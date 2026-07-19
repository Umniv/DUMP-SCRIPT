--[[
  Made By: Umniv
]]--

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentServerId = game.JobId
local currentSort = "fastest"

local gameName = "Unknown Game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(PlaceId)
    if info and info.Name then
        gameName = info.Name
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedServerHopGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, -1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 50)
mainFrameCorner.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0.2
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 20
closeButton.Parent = mainFrame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 15)
closeButtonCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    local exitTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -200, -1, 0), BackgroundTransparency = 1})
    exitTween:Play()
    exitTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hopper"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 28
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = mainFrame

local gameNameLabel = Instance.new("TextLabel")
gameNameLabel.Size = UDim2.new(1, 0, 0, 25)
gameNameLabel.Position = UDim2.new(0, 0, 0, 40)
gameNameLabel.BackgroundTransparency = 1
gameNameLabel.Text = "Current Game: " .. gameName
gameNameLabel.Font = Enum.Font.SourceSans
gameNameLabel.TextSize = 20
gameNameLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
gameNameLabel.Parent = mainFrame

local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0, 100, 0, 30)
refreshButton.Position = UDim2.new(1, -110, 0, 110)
refreshButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
refreshButton.BackgroundTransparency = 0
refreshButton.Text = "Refresh"
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 20
refreshButton.TextColor3 = Color3.new(1, 1, 1)
refreshButton.Parent = mainFrame

local refreshButtonCorner = Instance.new("UICorner")
refreshButtonCorner.CornerRadius = UDim.new(0, 15)
refreshButtonCorner.Parent = refreshButton

refreshButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(refreshButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
end)
refreshButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(refreshButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
    tween:Play()
end)

local filterFrame = Instance.new("Frame")
filterFrame.Size = UDim2.new(1, 0, 0, 40)
filterFrame.Position = UDim2.new(0, 0, 0, 70)
filterFrame.BackgroundTransparency = 1
filterFrame.Parent = mainFrame

local filterButtons = {}
local sortOptions = {
    { Name = "Fastest Ping", key = "fastest" },
    { Name = "Lowest Players", key = "lowPlayers" },
    { Name = "Max Players", key = "maxPlayers" },
}
local buttonWidth = 120
for i, option in ipairs(sortOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, buttonWidth, 0, 30)
    btn.Position = UDim2.new(0, (i - 1) * (buttonWidth + 10) + 10, 0, 5)
    btn.BackgroundColor3 = (currentSort == option.key) and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
    btn.Text = option.Name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = filterFrame
    filterButtons[option.key] = btn
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 15)
    btnCorner.Parent = btn
    btn.MouseEnter:Connect(function()
        local tween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 120, 120)})
        tween:Play()
    end)
    btn.MouseLeave:Connect(function()
        local newColor = (option.key == currentSort) and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
        local tween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = newColor})
        tween:Play()
    end)
    btn.MouseButton1Click:Connect(function()
        currentSort = option.key
        for key, button in pairs(filterButtons) do
            local newColor = (key == currentSort) and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = newColor})
            tween:Play()
        end
        loadServerList()
    end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 115)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Loading servers..."
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 20
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Parent = mainFrame

local statusTween = TweenService:Create(statusLabel, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.5})
statusTween:Play()

local serverListFrame = Instance.new("ScrollingFrame")
serverListFrame.Size = UDim2.new(1, -20, 1, -170)
serverListFrame.Position = UDim2.new(0, 10, 0, 150)
serverListFrame.BackgroundTransparency = 0.5
serverListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
serverListFrame.BorderSizePixel = 0
serverListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
serverListFrame.ScrollBarThickness = 8
serverListFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = serverListFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

local drag = loadstring(game:HttpGet("https://raw.githubusercontent.com/lumpiasallad/MobileSuport_Drag_UI_Script-/refs/heads/main/Drag_UI_Mobile.lua"))()
drag(mainFrame)

local function fetchServers(callback, cursor)
    local baseUrl = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&excludeFullGames=true", PlaceId)
    if cursor and cursor ~= "" then
        baseUrl = baseUrl .. "&cursor=" .. cursor
    end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(baseUrl))
    end)
    if success and result and result.data then
        callback(result.data, result.nextPageCursor)
    else
        statusLabel.Text = "Error fetching server list."
        warn("Error fetching servers:", result)
    end
end

local function sortServers(servers, currentSort)
    if currentSort == "fastest" then
        table.sort(servers, function(a, b)
            return (a.ping or 9999) < (b.ping or 9999)
        end)
    elseif currentSort == "lowPlayers" then
        table.sort(servers, function(a, b)
            return a.playing < b.playing
        end)
    elseif currentSort == "maxPlayers" then
        table.sort(servers, function(a, b)
            return a.playing > b.playing
        end)
    end
    return servers
end

local function renderServerList(servers)
    for _, child in ipairs(serverListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    for i, server in ipairs(servers) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, -10, 0, 40)
        entry.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(60, 60, 60)
        entry.BorderSizePixel = 0
        entry.Parent = serverListFrame
        local entryLayout = Instance.new("UIListLayout", entry)
        entryLayout.FillDirection = Enum.FillDirection.Horizontal
        entryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        entryLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local indexLabel = Instance.new("TextLabel")
        indexLabel.Size = UDim2.new(0, 40, 1, 0)
        indexLabel.BackgroundTransparency = 1
        indexLabel.Text = tostring(i)
        indexLabel.Font = Enum.Font.SourceSans
        indexLabel.TextSize = 18
        indexLabel.TextColor3 = Color3.new(1, 1, 1)
        indexLabel.Parent = entry
        local playersLabel = Instance.new("TextLabel")
        playersLabel.Size = UDim2.new(0, 80, 1, 0)
        playersLabel.BackgroundTransparency = 1
        playersLabel.Text = string.format("%d/%d", server.playing, server.maxPlayers)
        playersLabel.Font = Enum.Font.SourceSans
        playersLabel.TextSize = 18
        playersLabel.TextColor3 = Color3.new(1, 1, 1)
        playersLabel.Parent = entry
        local pingLabel = Instance.new("TextLabel")
        pingLabel.Size = UDim2.new(0, 80, 1, 0)
        pingLabel.BackgroundTransparency = 1
        pingLabel.Text = "Ping: " .. tostring(server.ping or "N/A")
        pingLabel.Font = Enum.Font.SourceSans
        pingLabel.TextSize = 18
        pingLabel.TextColor3 = Color3.new(1, 1, 1)
        pingLabel.Parent = entry
        local regionLabel = Instance.new("TextLabel")
        regionLabel.Size = UDim2.new(0, 100, 1, 0)
        regionLabel.BackgroundTransparency = 1
        regionLabel.Text = "Region: " .. tostring(server.location or "Unknown") -- I wanted to implement a region system where this script would locate what region the server is at. I could but its too hard and i gave up 
        regionLabel.Font = Enum.Font.SourceSans
        regionLabel.TextSize = 18
        regionLabel.TextColor3 = Color3.new(1, 1, 1)
        regionLabel.Parent = entry
        local joinButton = Instance.new("TextButton")
        joinButton.Size = UDim2.new(0, 80, 1, 0)
        joinButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        joinButton.Text = "Join"
        joinButton.Font = Enum.Font.SourceSansBold
        joinButton.TextSize = 18
        joinButton.TextColor3 = Color3.new(1, 1, 1)
        joinButton.Parent = entry
        local joinButtonCorner = Instance.new("UICorner")
        joinButtonCorner.CornerRadius = UDim.new(0, 10)
        joinButtonCorner.Parent = joinButton
        if server.id == CurrentServerId then
            joinButton.Text = "Current"
            joinButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            joinButton.AutoButtonColor = false
            joinButton.Active = false
        else
            joinButton.MouseButton1Click:Connect(function()
                statusLabel.Text = "Teleporting..."
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                end)
            end)
        end
    end
    local contentHeight = (#servers) * 45
    serverListFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    statusLabel.Text = "Loaded " .. tostring(#servers) .. " servers."
end

function loadServerList()
    statusLabel.Text = "Loading servers..."
    fetchServers(function(servers, nextPage)
        if #servers == 0 then
            statusLabel.Text = "No servers found."
            return
        end
        local sortedServers = sortServers(servers, currentSort)
        renderServerList(sortedServers)
    end, "")
end

refreshButton.MouseButton1Click:Connect(function()
    loadServerList()
end)

local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -200, 0.5, -250)})
entranceTween:Play()

loadServerList()

--intro 
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Server Hop",
    Text = " Made by:Lumpiasallad",
    Duration = 5
})

--============================================================
-- NEW: Open/Close Toggle Button (added, nothing above changed)
--============================================================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 15, 0, 15)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Text = "≡"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 28
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Active = true
toggleButton.Draggable = false
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui

local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(1, 0)
toggleButtonCorner.Parent = toggleButton

toggleButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 90)})
    tween:Play()
end)
toggleButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
    tween:Play()
end)

local uiIsOpen = true

local function openUI()
    mainFrame.Visible = true
    local openTween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -200, 0.5, -250), BackgroundTransparency = 0.3 }
    )
    openTween:Play()
    uiIsOpen = true
end

local function closeUI()
    local closeTween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, -200, -1, 0) }
    )
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if not uiIsOpen then
            mainFrame.Visible = false
        end
    end)
    uiIsOpen = false
end

toggleButton.MouseButton1Click:Connect(function()
    if uiIsOpen then
        closeUI()
    else
        openUI()
    end
end)
