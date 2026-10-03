-- YBA COMPLETE AUTOFARM SYSTEM V2 (SLOWER / HUMAN-LIKE VERSION)
-- Auto-Rejoin + Time Tracker + All Items Farm + Smart Stop
-- Optimized for Mobile (CodeX, Arceus X, Delta)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = function()
    return Player.Character or Player.CharacterAdded:Wait()
end

local HRP = function()
    return Character():WaitForChild("HumanoidRootPart")
end

local PlayerStats = Player:WaitForChild("PlayerStats")

local CONFIG = {
    PLACE_ID = 2809202155,
    SAFE_SPOT = CFrame.new(978, -42, -49),
    SERVER_HOP_DELAY = 180,
    STAY_TIME_UNDER_ITEM = 0.8,
    FAST_PICKUP_DELAY = 0.2,
    NORMAL_PICKUP_DELAY = 0.4,
    GUI_SIZE_X = 320,
    GUI_SIZE_Y = 320,
    BUTTON_HEIGHT = 35,
    MONEY_THRESHOLD = 1000000,
    LUCKY_ARROW_TARGET = 10,
    LUCKY_ARROW_PRICE = 75000,
    LUCKY_ARROW_NAME = "1x Lucky Arrow"
}

local FARMABLE_ITEMS = {
    { name = "Gold Coin", value = 120, maxCount = 999 },
    { name = "Mysterious Arrow", value = 200, maxCount = 999 },
    { name = "Diamond", value = 500, maxCount = 999 },
    { name = "Rokakaka Fruit", value = 600, maxCount = 999 },
    { name = "Ancient Scroll", value = 1000, maxCount = 999 },
    { name = "Dio's Diary", value = 1000, maxCount = 999 },
    { name = "Quinton's Glove", value = 1000, maxCount = 999 },
    { name = "Steel Ball", value = 1000, maxCount = 999 },
    { name = "Stone Mask", value = 1000, maxCount = 999 },
    { name = "Caesar's Headband", value = 1000, maxCount = 999 },
    { name = "Rib Cage of The Saint's Corpse", value = 1200, maxCount = 999 },
    { name = "Pure Rokakaka", value = 1500, maxCount = 999 }
}

local STATE = {
    SpeedModeEnabled = false,
    FarmingEnabled = true,
    IsFarming = false,
    TrackedItems = {},
    ItemsCollected = {},
    StartTime = tick(),
    IsAutoStopped = false,
    LuckyArrowCount = 0,
    RandomOffset = 0
}

for _, item in ipairs(FARMABLE_ITEMS) do
    STATE.ItemsCollected[item.name] = 0
end

local function RNG(min, max)
    return math.random() * (max - min) + min
end

local function createMobileGUI()
    local gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
    gui.Name = "YBA_Mobile_Farm_V2"
    gui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, CONFIG.GUI_SIZE_X, 0, CONFIG.GUI_SIZE_Y)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Text = "YBA COMPLETE FARM"

    local status = Instance.new("TextLabel", mainFrame)
    status.Name = "Status"
    status.Size = UDim2.new(1, -10, 0, 20)
    status.Position = UDim2.new(0, 5, 0, 32)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(0, 255, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.Text = "Status: Idle"

    local money = Instance.new("TextLabel", mainFrame)
    money.Name = "Money"
    money.Size = UDim2.new(1, -10, 0, 18)
    money.Position = UDim2.new(0, 5, 0, 52)
    money.BackgroundTransparency = 1
    money.TextColor3 = Color3.fromRGB(255, 255, 0)
    money.Font = Enum.Font.Gotham
    money.TextSize = 11
    money.Text = "Money: $0"

    local timeLabel = Instance.new("TextLabel", mainFrame)
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, -10, 0, 18)
    timeLabel.Position = UDim2.new(0, 5, 0, 70)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 11
    timeLabel.Text = "Time: 0h 0m 0s"

    local luckyCounter = Instance.new("TextLabel", mainFrame)
    luckyCounter.Name = "LuckyCounter"
    luckyCounter.Size = UDim2.new(1, -10, 0, 18)
    luckyCounter.Position = UDim2.new(0, 5, 0, 88)
    luckyCounter.BackgroundTransparency = 1
    luckyCounter.TextColor3 = Color3.fromRGB(255, 200, 100)
    luckyCounter.Font = Enum.Font.Gotham
    luckyCounter.TextSize = 11
    luckyCounter.Text = "Lucky Arrows: 0/10"

    local itemLabel = Instance.new("TextLabel", mainFrame)
    itemLabel.Name = "ItemLabel"
    itemLabel.Size = UDim2.new(1, -10, 0, 18)
    itemLabel.Position = UDim2.new(0, 5, 0, 106)
    itemLabel.BackgroundTransparency = 1
    itemLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    itemLabel.Font = Enum.Font.Gotham
    itemLabel.TextSize = 11
    itemLabel.Text = "Item: None"

    local debug = Instance.new("TextLabel", mainFrame)
    debug.Name = "Debug"
    debug.Size = UDim2.new(1, -10, 0, 40)
    debug.Position = UDim2.new(0, 5, 0, 124)
    debug.BackgroundTransparency = 1
    debug.TextColor3 = Color3.fromRGB(150, 150, 150)
    debug.Font = Enum.Font.Gotham
    debug.TextSize = 10
    debug.Text = "Debug: Ready\nItems Found: 0"
    debug.TextWrapped = true

    local farmToggle = Instance.new("TextButton", mainFrame)
    farmToggle.Name = "FarmToggle"
    farmToggle.Size = UDim2.new(0.48, -3, 0, CONFIG.BUTTON_HEIGHT)
    farmToggle.Position = UDim2.new(0, 5, 1, -CONFIG.BUTTON_HEIGHT - 5)
    farmToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    farmToggle.TextColor3 = Color3.new(1, 1, 1)
    farmToggle.Font = Enum.Font.GothamBold
    farmToggle.TextSize = 13
    farmToggle.Text = "FARM: ON"
    farmToggle.BorderSizePixel = 1
    farmToggle.BorderColor3 = Color3.fromRGB(0, 200, 150)

    farmToggle.MouseButton1Click:Connect(function()
        STATE.FarmingEnabled = not STATE.FarmingEnabled
        STATE.IsAutoStopped = false
        farmToggle.BackgroundColor3 = STATE.FarmingEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 50, 50)
        farmToggle.Text = "FARM: " .. (STATE.FarmingEnabled and "ON" or "OFF")
    end)

    local speedToggle = Instance.new("TextButton", mainFrame)
    speedToggle.Name = "SpeedToggle"
    speedToggle.Size = UDim2.new(0.48, -3, 0, CONFIG.BUTTON_HEIGHT)
    speedToggle.Position = UDim2.new(0.52, 0, 1, -CONFIG.BUTTON_HEIGHT - 5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    speedToggle.TextColor3 = Color3.new(1, 1, 1)
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.TextSize = 13
    speedToggle.Text = "SPEED: OFF"
    speedToggle.BorderSizePixel = 1
    speedToggle.BorderColor3 = Color3.fromRGB(150, 150, 0)

    speedToggle.MouseButton1Click:Connect(function()
        STATE.SpeedModeEnabled = not STATE.SpeedModeEnabled
        speedToggle.BackgroundColor3 = STATE.SpeedModeEnabled and Color3.fromRGB(150, 150, 0) or Color3.fromRGB(100, 100, 50)
        speedToggle.Text = "SPEED: " .. (STATE.SpeedModeEnabled and "ON" or "OFF")
    end)

    return {
        gui = gui,
        status = status,
        money = money,
        timeLabel = timeLabel,
        luckyCounter = luckyCounter,
        itemLabel = itemLabel,
        debug = debug,
        farmToggle = farmToggle,
        speedToggle = speedToggle
    }
end

local GUI = createMobileGUI()

local function updateGUI(statusText, debugText, itemText)
    pcall(function()
        if GUI.status and statusText then
            GUI.status.Text = "Status: " .. statusText
        end
        if GUI.money then
            if PlayerStats and PlayerStats.Money then
                GUI.money.Text = "Money: $" .. tostring(math.floor(PlayerStats.Money.Value))
            end
        end
        if GUI.itemLabel and itemText then
            GUI.itemLabel.Text = "Item: " .. itemText
        end
        if GUI.debug and debugText then
            GUI.debug.Text = "Debug: " .. debugText
        end
    end)
end

local function updateTimeDisplay()
    pcall(function()
        local elapsed = tick() - STATE.StartTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        GUI.timeLabel.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
    end)
end

local function updateLuckyArrowCounter()
    pcall(function()
        GUI.luckyCounter.Text = string.format("Lucky Arrows: %d/%d", STATE.LuckyArrowCount, CONFIG.LUCKY_ARROW_TARGET)
    end)
end

local function countLuckyArrows()
    pcall(function()
        local count = 0
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, "Lucky Arrow") then
                count = count + 1
            end
        end
        local char = Character()
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name, "Lucky Arrow") then
                    count = count + 1
                end
            end
        end
        STATE.LuckyArrowCount = count
        updateLuckyArrowCounter()
    end)
end

local function checkAutoStopCondition()
    countLuckyArrows()
    local money = PlayerStats and PlayerStats.Money and PlayerStats.Money.Value or 0
    local hasEnoughMoney = money >= CONFIG.MONEY_THRESHOLD
    local hasEnoughArrows = STATE.LuckyArrowCount >= CONFIG.LUCKY_ARROW_TARGET
    local allItemsCollected = true

    for _, item in ipairs(FARMABLE_ITEMS) do
        if STATE.ItemsCollected[item.name] == 0 then
            allItemsCollected = false
            break
        end
    end

    if hasEnoughMoney and hasEnoughArrows and allItemsCollected then
        STATE.FarmingEnabled = false
        STATE.IsAutoStopped = true
        GUI.farmToggle.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        GUI.farmToggle.Text = "AUTO STOPPED"
        updateGUI("AUTO STOPPED", "Goal reached! Phone safe 📱", nil)
        print("✅ AUTO FARM STOPPED - Goal Reached!")
        print("💰 Money: $" .. math.floor(money))
        print("🎯 Lucky Arrows: " .. STATE.LuckyArrowCount)
        return true
    end

    return false
end

RunService.Stepped:Connect(function()
    pcall(function()
        local char = Character()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

local ItemFolder = Workspace:WaitForChild("Item_Spawns"):WaitForChild("Items")

local function trackItem(itemModel)
    if not itemModel:IsA("Model") then return end

    local prompt = itemModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    local part = itemModel:FindFirstChildWhichIsA("BasePart", true)

    if prompt and part and prompt.ObjectText and prompt.ObjectText ~= "" then
        local itemName = prompt.ObjectText
        local isFarmable = false

        for _, item in ipairs(FARMABLE_ITEMS) do
            if item.name == itemName then
                isFarmable = true
                break
            end
        end

        if isFarmable then
            table.insert(STATE.TrackedItems, {
                model = itemModel,
                prompt = prompt,
                part = part,
                name = itemName,
                position = part.Position
            })
            updateGUI("Tracking", "New item found: " .. itemName, itemName)
        end
    end
end

for _, item in ipairs(ItemFolder:GetChildren()) do
    task.spawn(function()
        trackItem(item)
    end)
end

ItemFolder.ChildAdded:Connect(function(item)
    task.wait(0.2)
    trackItem(item)
end)

local function instantTeleport(cframe)
    pcall(function()
        local hrp = HRP()
        if hrp then
            hrp.CFrame = cframe
        end
    end)
end

local function holdE(duration)
    local pickupTime = STATE.SpeedModeEnabled and CONFIG.FAST_PICKUP_DELAY or CONFIG.NORMAL_PICKUP_DELAY
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(pickupTime + RNG(0.05, 0.3))
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function pickupItem(item)
    STATE.IsFarming = true
    updateGUI("Farming", "Teleporting...", item.name)

    pcall(function()
        local hrp = HRP()
        if hrp and item and item.position then
            hrp.CFrame = CFrame.new(item.position + Vector3.new(RNG(-1, 1), 3, RNG(-1, 1)))
        end
    end)

    task.wait(0.25 + RNG(0.05, 0.25))
    updateGUI("Picking", "Holding E", item.name)
    holdE(0.25)

    pcall(function()
        if item.prompt then
            fireproximityprompt(item.prompt)
        end
    end)

    STATE.ItemsCollected[item.name] = (STATE.ItemsCollected[item.name] or 0) + 1
    task.wait(CONFIG.STAY_TIME_UNDER_ITEM + RNG(0.1, 0.6))
    STATE.IsFarming = false
end

local function quickSell()
    pcall(function()
        local char = Character()
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end

        hum:UnequipTools()
        task.wait(0.3 + RNG(0.1, 0.5))

        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and not string.find(tool.Name, "Lucky Arrow") then
                hum:EquipTool(tool)
                local timeout = tick() + 1.5
                repeat
                    task.wait(0.2)
                until char:FindFirstChild(tool.Name) or tick() > timeout

                if char:FindFirstChild(tool.Name) then
                    char.RemoteEvent:FireServer("EndDialogue", {
                        NPC = "Merchant",
                        Dialogue = "Dialogue5",
                        Option = "Option2"
                    })
                    task.wait(0.5 + RNG(0.1, 0.4))
                    updateGUI("Selling", "Sold: " .. tool.Name, nil)
                end
            end
        end
    end)
end

local function buyLucky()
    pcall(function()
        if PlayerStats and PlayerStats.Money and PlayerStats.Money.Value >= CONFIG.LUCKY_ARROW_PRICE then
            if STATE.LuckyArrowCount < CONFIG.LUCKY_ARROW_TARGET then
                Character().RemoteEvent:FireServer("PurchaseShopItem", { ItemName = CONFIG.LUCKY_ARROW_NAME })
                updateGUI("Buying", "Lucky Arrow Bought!", nil)
                task.wait(0.8 + RNG(0.1, 0.5))
                countLuckyArrows()
            end
        end
    end)
end

local function getClosestItem()
    local closest, minDist
    pcall(function()
        local pos = HRP().Position
        for i, item in ipairs(STATE.TrackedItems) do
            if item and item.model and item.prompt and item.part then
                local dist = (item.position - pos).Magnitude
                if not minDist or dist < minDist then
                    closest = i
                    minDist = dist
                end
            end
        end
    end)
    return closest
end

task.spawn(function()
    while true do
        task.wait(0.8)
        updateTimeDisplay()
        countLuckyArrows()

        if checkAutoStopCondition() then
            break
        end

        if not STATE.FarmingEnabled then
            updateGUI("Paused", "Farming disabled", nil)
            continue
        end

        local closest = getClosestItem()
        if closest then
            local item = STATE.TrackedItems[closest]
            table.remove(STATE.TrackedItems, closest)
            pickupItem(item)
        else
            if STATE.LuckyArrowCount < CONFIG.LUCKY_ARROW_TARGET then
                quickSell()
                buyLucky()
            else
                updateGUI("Idle", "All arrows collected!", nil)
            end
            updateGUI("Idle", "Waiting for items...", nil)
        end
    end
end)

Player.CharacterAdded:Connect(function()
    print("✅ Rejoined game! Restarting farm...")
    task.wait(2)
    if STATE.FarmingEnabled and not STATE.IsAutoStopped then
        updateGUI("Rejoined", "Farm resuming...", nil)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        updateGUI("PANIC!", "Teleporting to safe spot!", nil)
        instantTeleport(CONFIG.SAFE_SPOT)
    end
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.SERVER_HOP_DELAY + RNG(10, 30))
        if not STATE.IsFarming and STATE.FarmingEnabled and not STATE.IsAutoStopped then
            updateGUI("ServerHop", "Switching servers...", nil)
            pcall(function()
                local servers = HttpService:JSONDecode(
                    game:HttpGet("https://games.roblox.com/v1/games/" .. CONFIG.PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100")
                ).data

                local choices = {}
                for _, s in ipairs(servers) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(choices, s.id)
                    end
                end

                if #choices > 0 then
                    TeleportService:TeleportToPlaceInstance(CONFIG.PLACE_ID, choices[math.random(1, #choices)], Player)
                end
            end)
        end
    end
end)

task.spawn(function()
    task.wait(2)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
    end)
end)

print("✅ YBA Complete Autofarm V2 Loaded!")
print("📱 Optimized for Mobile (CodeX, Arceus X, Delta)")
print("💰 Lucky Arrow Price: 75,000")
print("⏰ Will auto-stop at: $1M + 10 Lucky Arrows + All Items")
print("⌨️ Press P to panic teleport")
