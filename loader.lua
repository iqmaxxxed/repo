-- YBA FARM LOADER
-- Simple loader to execute the farm script

local HttpService = game:GetService("HttpService")

-- Load farm script from repository
local function loadFarmScript()
    local success, result = pcall(function()
        local farmScript = game:HttpGet("https://raw.githubusercontent.com/iqmaxxxed/repo/main/farm.lua")
        return farmScript
    end)
    
    if success and result then
        -- Execute the farm script
        local loadedScript = loadstring(result)
        if loadedScript then
            loadedScript()
            print("✅ Farm script loaded successfully!")
            return true
        else
            print("❌ Failed to parse farm script")
            return false
        end
    else
        print("❌ Failed to download farm script: " .. tostring(result))
        return false
    end
end

-- Start loader
print("🔄 Loading YBA Farm Script...")
loadFarmScript()
