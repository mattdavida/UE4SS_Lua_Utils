---@meta
-- UE4SS Live Execution REPL
-- Minimal debugger focused on live code execution for the Python playground

local UE4SSDebugger = {}

-- Simple server state
local server = nil
local client = nil
local running = false

-- Socket communication
local socket = nil

-- Configuration
local config = {
    port = 8172,
    timeout = 0, -- Non-blocking
}

-- Helper functions
local function log(message)
    -- Minimal logging for performance - only critical messages
end

local function log_important(message)
    print("[UE4SS REPL] " .. tostring(message))
end

local function safe_require(module_name)
    local success, result = pcall(require, module_name)
    if success then
        return result
    else
        log_important("Failed to require " .. module_name .. ": " .. tostring(result))
        return nil
    end
end

local function initialize_socket()
    socket = safe_require("socket")
    if not socket then
        log_important("ERROR: luasocket not found! Make sure socket.dll is in the game's ue4ss/Mods/shared/ directory")
        return false
    end
    return true
end

-- Simple JSON serialization for responses
local function serialize_response(data)
    if type(data) == "table" then
        local parts = {}
        for k, v in pairs(data) do
            local key = '"' .. tostring(k) .. '"'
            local value
            if type(v) == "string" then
                value = '"' .. v:gsub('"', '\\"'):gsub('[\r\n]', '\\n') .. '"'
            elseif type(v) == "boolean" then
                value = tostring(v)
            else
                value = '"' .. tostring(v) .. '"'
            end
            table.insert(parts, key .. ":" .. value)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return '{"error":"Invalid data"}'
end

local function send_response(message)
    if not client then return false end
    
    local json_str = serialize_response(message)
    local success, err = client:send(json_str .. "\n")
    if not success then
        return false
    end
    return true
end

-- Core evaluation function - this is what our REPL uses
function UE4SSDebugger.evaluate_expression(expression)
    -- Execute in the main Lua context with proper environment
    local func, compile_err = load("return " .. expression, "repl_eval", "t", _G)
    if not func then
        func, compile_err = load(expression, "repl_eval", "t", _G)
    end
    
    if not func then
        send_response({
            type = "eval_result",
            success = false,
            error = "Compile error: " .. tostring(compile_err)
        })
        return
    end
    
    local success, result = pcall(func)
    send_response({
        type = "eval_result", 
        success = success,
        result = success and tostring(result) or ("Error: " .. tostring(result))
    })
end

-- Handle incoming messages from Python client
local function handle_client_message(message_str)
    -- Simple message parsing for evaluation requests
    if message_str:find('"type":"evaluate"') then
        local expr = message_str:match('"expression":"([^"]*)"')
        if expr then
            UE4SSDebugger.evaluate_expression(expr)
        end
    end
end

-- Update server - check for messages
local function update_server()
    if not server or not running then return end

    -- Accept new connections
    if not client then
        local new_client = server:accept()
        if new_client then
            client = new_client
            client:settimeout(config.timeout)
            log_important("Client connected!")
            
            send_response({
                type = "connected",
                message = "UE4SS REPL ready!"
            })
        end
    end

    -- Receive messages
    if client then
        local msg, err = client:receive("*l")
        if msg and msg ~= "" then
            handle_client_message(msg)
        elseif err == "closed" then
            log_important("Client disconnected")
            client = nil
        end
    end
end

-- Public API

---Start the REPL server
---@param user_config? table Configuration options
---@return boolean success Whether the server started successfully
function UE4SSDebugger.start(user_config)
    if running then
        return true
    end

    -- Merge configuration
    if user_config then
        for k, v in pairs(user_config) do
            config[k] = v
        end
    end

    -- Initialize socket
    if not initialize_socket() then
        return false
    end

    -- Create server
    server = socket.bind("localhost", config.port)
    if not server then
        log_important("ERROR: Failed to bind to port " .. config.port)
        return false
    end

    server:settimeout(config.timeout)
    running = true

    log_important("🚀 REPL server started on port " .. config.port)

    return true
end

---Stop the REPL server
function UE4SSDebugger.stop()
    if client then
        client:close()
        client = nil
    end

    if server then
        server:close()
        server = nil
    end

    running = false
end

---Check if server is running
---@return boolean
function UE4SSDebugger.is_running()
    return running
end

---Update the server (call this regularly, preferably every frame)
function UE4SSDebugger.update()
    if running then
        update_server()
    end
end

return UE4SSDebugger
 