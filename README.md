# UE4SS Lua Mod Utilities

A curated collection of essential utilities and development tools for UE4SS Lua modding. This repository contains battle-tested debugging tools, core utilities, and convenient third-party libraries that are hard to find elsewhere, all designed to accelerate your modding workflow.

## 🚀 Features

### Core Utilities
- **Utils**: Essential string manipulation and logging utilities
- **JSON Support**: Full-featured JSON encoding/decoding with dkjson library (included for convenience)
- **Socket Communication**: LuaSocket integration for network operations and external tool communication

### Development & Debugging
- **Live REPL Debugger**: Real-time Lua code execution and testing via socket communication
- **Background Update System**: Efficient game thread integration for continuous operations
- **Comprehensive Logging**: Multi-target logging system for both console and debug output

### Data & Networking
- **JSON Support**: Full-featured JSON encoding/decoding with dkjson library
- **Socket Communication**: LuaSocket integration for network operations and external tool communication

## 📁 Repository Structure

```
├── Utils/
│   └── Utils.lua                 # Core utility functions
├── LuaReplDebug/
│   ├── LuaReplDebug.lua         # Live debugging client
│   └── socket/                   # LuaSocket core components
├── dkjson.lua                    # JSON library (included for convenience)
├── socket.lua                    # LuaSocket helper module
└── ue4ss_debugger.lua           # REPL debugger backend
```

## 🛠 Installation

1. Copy all files and directories from this repository into your existing UE4SS `shared` folder:
   ```
   YourGame/Binaries/Win64/ue4ss/Mods/shared/
   ```
   
   Example installation path:
   ```
   C:\Program Files (x86)\Steam\steamapps\common\Lies of P\LiesofP\Binaries\Win64\ue4ss\Mods\shared\
   ```

2. In your mod's `main.lua`, require the utilities you need:
   ```lua
   local Utils = require("Utils/Utils")
   local json = require("dkjson")
   local debugger = require("ue4ss_debugger")
   ```

## 📖 Usage Guide

### Basic Utilities

```lua
local Utils = require("Utils/Utils")

-- String operations
local contains = Utils.StringContains("Hello World", "World") -- true

-- Logging to both console and debug output
Utils.Log(SomeUObjectWithLog, "Debug message")
```

### Live REPL Debugger

The REPL debugger enables real-time Lua code execution and testing:

```lua
-- In your mod's main.lua
local debugger = require("ue4ss_debugger")

-- Start the debugger server
debugger.start({
    port = 8172,
    timeout = 0
})

-- Set up background updates
ExecuteInGameThread(function()
    local function update_loop()
        if debugger.is_running() then
            debugger.update()
        end
        ExecuteWithDelay(100, update_loop)
    end
    update_loop()
end)
```

Connect to the debugger from external tools on `localhost:8172` for live code execution and testing.

### JSON Operations

```lua
local json = require("dkjson")

-- Encode table to JSON
local data = {name = "Player", level = 10}
local jsonString = json.encode(data)

-- Decode JSON to table
local decoded = json.decode(jsonString)
```

### Socket Communication

```lua
local socket = require("socket")

-- Create TCP connection
local client = socket.connect("localhost", 8080)
if client then
    client:send("Hello Server\n")
    local response = client:receive()
    client:close()
end
```

## 🔧 Components Detail

### Utils.lua
Core utility functions including:
- `StringContains(text, substring)`: Fast plain-text string searching
- `Log(Ar, Message)`: Dual-output logging system

### ue4ss_debugger.lua
Live REPL debugger featuring:
- TCP server for external connections
- Real-time Lua code evaluation
- JSON-based communication protocol
- Non-blocking socket operations
- Error handling and connection management

### dkjson.lua
Full-featured JSON library (Version 2.8) supporting:
- Lua 5.1 - 5.4 compatibility
- Complete JSON specification compliance
- High-performance encoding/decoding
- Extensive customization options

## 🎯 Use Cases

- **Live Development**: Real-time code testing and debugging without game restarts
- **Rapid Prototyping**: Quick iteration with REPL-style development
- **Data Management**: JSON-based configuration and save systems with readily available libraries
- **Network Integration**: Socket communication for external tool integration
- **Enhanced Logging**: Multi-target debugging output for complex mod development

## 🤝 Contributing

This repository represents utilities extracted from multiple successful modding projects. Contributions should maintain the focus on:
- **Reliability**: Battle-tested, production-ready code
- **Performance**: Minimal overhead in game environments
- **Compatibility**: Broad UE4SS version support
- **Documentation**: Clear usage examples and API documentation

## 📜 License

Individual components maintain their original licenses:
- **dkjson.lua**: MIT License (David Heiko Kolf)
- **socket.lua**: LuaSocket License (Diego Nehab)
- **Custom utilities**: Available for use in UE4SS modding projects

## 🔗 Related Projects

These utilities have been successfully used in advanced modding projects for:
- Live debugging and development workflows
- JSON-based save state and configuration management
- Real-time mod testing and iteration
- External tool integration via socket communication

---

*Built for the UE4SS modding community with ❤️* 