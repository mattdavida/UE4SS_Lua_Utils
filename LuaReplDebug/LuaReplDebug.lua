---@meta
--[[
UE4SS Live Execution REPL
Minimal debugger focused on live code execution for the Python playground

Socket communication based on LuaSocket 3.1-5.4.7
LuaSocket: https://lunarmodules.github.io/luasocket/
TCP server implementation following standard luasocket patterns and documentation

Original luasocket library by Diego Nehab and contributors
This implementation uses luasocket for TCP communication between UE4SS and Python backend
--]]

local debugger = require("ue4ss_debugger")
print("🧪 Testing UE4SS Debugger...")

-- Start the debugger
local success = debugger.start({
    port = 8172,
    timeout = 0
})

if success then
    print("------------ ✅ Debugger started successfully! ------------ ")
else
    print("------------ ❌ Failed to start debugger ------------ ")
    return
end

-- Background update loop using ExecuteInGameThread  
ExecuteInGameThread(function()
    local function background_update()
        if debugger.is_running() then
            debugger.update()
        end
        
        -- Schedule next update
        ExecuteWithDelay(100, background_update) -- Update every 100ms
    end
    
    background_update()
    print("🔄 Background update loop started")
end)