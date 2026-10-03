-- YBA FARM MOBILE LOADER V2
-- One-Click Loader for Arceus X, Delta, CodeX
-- Auto-download, cache, and execute

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    SCRIPT_URL = "https://raw.githubusercontent.com/iqmaxxxed/repo/main/farm.lua",
    CACHE_FILE = "yba_farm_cache.lua",
    TIMEOUT = 10,
    RETRY_COUNT = 3
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

-- Main loader function
local function loadFarm()
    print("=" .. string.rep("=", 48) .. "=")
    print("🚀 YBA Complete Autofarm V2 - Mobile Loader")
    print("=" .. string.rep("=", 48) .. "=")
    
    -- Step 1: Try to load from cache
    local scriptContent = loadFromCache()
    
    -- Step 2: If no cache, download
    if not scriptContent then
        scriptContent = downloadScript()
        
        if not scriptContent then
            print("❌ FATAL: Could not download or load script!")
            print("⚙️ Make sure your internet is working")
            print("⚙️ Check if the repo URL is correct")
            return false
        end
        
        -- Save for next time
        saveToCache(scriptContent)
    end
    
    -- Step 3: Execute the script
    print("⚡ Executing farm script...")
    local success, result = pcall(function()
        local fn = loadstring(scriptContent)
        if not fn then
            error("Failed to parse script content")
        end
        return fn()
    end)
    
    if success then
        print("=" .. string.rep("=", 48) .. "=")
        print("✅ FARM LOADER COMPLETE - Script is running!")
        print("=" .. string.rep("=", 48) .. "=")
        return true
    else
        print("❌ Execution error: " .. tostring(result))
        print("=" .. string.rep("=", 48) .. "=")
        return false
    end
end

-- Run the loader
loadFarm()
