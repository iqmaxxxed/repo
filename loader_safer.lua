-- YBA FARM MOBILE LOADER V4 (SAFER VERSION)
-- One-Click Loader for Arceus X, Delta, CodeX
-- Auto-download, cache, and execute - MOBILE OPTIMIZED
-- Uses farm_safer.lua for slower, safer farming

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    SCRIPT_URL = "https://raw.githubusercontent.com/iqmaxxxed/repo/main/farm_safer.lua",
    CACHE_FILE = "yba_farm_safer_cache.lua",
    TIMEOUT = 10,
    RETRY_COUNT = 3,
    MOBILE_MODE = true
}

-- Check if executor supports caching
local function getCachePath()
    -- Arceus X / Delta support writefile
    if writefile and readfile then
        return CONFIG.CACHE_FILE
    end
    return nil
end

-- Load from cache if available
local function loadFromCache()
    local cachePath = getCachePath()
    if not cachePath then return nil end
    
    local success, cached = pcall(function()
        return readfile(cachePath)
    end)
    
    if success and cached then
        print("📦 Loading from cache...")
        return cached
    end
    return nil
end

-- Save to cache for next time
local function saveToCache(scriptContent)
    local cachePath = getCachePath()
    if not cachePath then return end
    
    local success = pcall(function()
        writefile(cachePath, scriptContent)
    end)
    
    if success then
        print("💾 Script cached for next load")
    end
end

-- Download script with retry logic
local function downloadScript()
    local lastError
    
    for attempt = 1, CONFIG.RETRY_COUNT do
        print("🔄 Downloading farm script (Attempt " .. attempt .. "/" .. CONFIG.RETRY_COUNT .. ")...")
        
        local success, result = pcall(function()
            return game:HttpGet(CONFIG.SCRIPT_URL, true)
        end)
        
        if success and result and #result > 100 then
            print("✅ Download successful!")
            return result
        end
        
        lastError = result or "Empty response"
        print("⚠️ Download failed: " .. tostring(lastError))
        
        if attempt < CONFIG.RETRY_COUNT then
            task.wait(2)
        end
    end
    
    return nil, lastError
end

-- Mobile-optimized notification
local function notifyMobile(title, message)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        local notification = Instance.new("ScreenGui")
        notification.Name = "MobileNotification"
        notification.ResetOnSpawn = false
        notification.Parent = LocalPlayer:FindFirstChild("PlayerGui")
        
        local bg = Instance.new("Frame", notification)
        bg.Size = UDim2.new(1, 0, 0, 80)
        bg.Position = UDim2.new(0, 0, 0, 0)
        bg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        bg.BorderSizePixel = 2
        bg.BorderColor3 = Color3.fromRGB(100, 200, 255)
        
        local titleLabel = Instance.new("TextLabel", bg)
        titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
        titleLabel.Text = title
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        
        local msgLabel = Instance.new("TextLabel", bg)
        msgLabel.Size = UDim2.new(1, 0, 0.5, 0)
        msgLabel.Position = UDim2.new(0, 0, 0.5, 0)
        msgLabel.Text = message
        msgLabel.BackgroundTransparency = 1
        msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        msgLabel.TextSize = 14
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextWrapped = true
        
        game:GetService("Debris"):AddItem(notification, 4)
    end
end

-- Main loader function
local function loadFarm()
    print("=" .. string.rep("=", 50) .. "=")
    print("🚀 YBA Safe Autofarm - Mobile Loader V4")
    print("=" .. string.rep("=", 50) .. "=")
    
    notifyMobile("YBA Farm Loader", "Initializing SAFER version...")
    
    -- Step 1: Try to load from cache
    local scriptContent = loadFromCache()
    
    -- Step 2: If no cache, download
    if not scriptContent then
        scriptContent = downloadScript()
        
        if not scriptContent then
            print("❌ FATAL: Could not download or load script!")
            print("⚙️ Make sure your internet is working")
            print("⚙️ Check if the repo URL is correct")
            notifyMobile("❌ ERROR", "Failed to download script")
            return false
        end
        
        -- Save for next time
        saveToCache(scriptContent)
    end
    
    -- Step 3: Execute the script
    print("⚡ Executing farm script (SAFER VERSION)...")
    notifyMobile("Loading", "Executing script...")
    
    local success, result = pcall(function()
        local fn = loadstring(scriptContent)
        if not fn then
            error("Failed to parse script content")
        end
        return fn()
    end)
    
    if success then
        print("=" .. string.rep("=", 50) .. "=")
        print("✅ FARM LOADER COMPLETE - Script is running!")
        print("📱 Using SAFER (slower) version")
        print("🐢 Gradual teleportation enabled by default")
        print("=" .. string.rep("=", 50) .. "=")
        notifyMobile("✅ SUCCESS", "Farm script loaded! (SAFER)")
        return true
    else
        print("❌ Execution error: " .. tostring(result))
        print("=" .. string.rep("=", 50) .. "=")
        notifyMobile("❌ ERROR", "Script execution failed")
        return false
    end
end

-- Run the loader
loadFarm()
