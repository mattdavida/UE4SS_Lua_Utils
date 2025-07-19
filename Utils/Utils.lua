---@class Utils
---@field StringContains fun(text: string, substring: string): boolean
---@field Log fun(Ar: any, Message: string): nil
---@field Summon fun(ObjectName: string, OptionalLocation?: FVector, OptionalRotation?: FRotator): AActor|nil
---@field PrintUEVersion fun(): nil
---@field SetInterval fun(callback: function, delay_seconds: number): number
---@field ClearInterval fun(interval_id: number): boolean
local Utils = {}

local UEHelpers = require('UEHelpers.UEHelpers')
local active_intervals = {}
local interval_id_counter = 0


---Checks if a string contains a substring
---@param text string The text to search in
---@param substring string The substring to search for
---@return boolean found True if substring is found, false otherwise
function Utils.StringContains(text, substring)
    -- The 'true' argument disables pattern matching for a plain text search, which is faster.
    return string.find(text, substring, 1, true) ~= nil
end

---A logging helper to print to both the in-game console and the debug log
---@param Ar any Archive or logging object (type unknown - has IsValid() and Log() methods)
---@param Message string The message to log
function Utils.Log(Ar, Message)
    print(Message)
    if Ar and Ar:IsValid() then
        Ar:Log(Message)
    end
end

---Spawns an actor at specified location
---@param ObjectName string Full path to the actor class
---@param OptionalLocation? FVector Spawn location (defaults to player location)
---@param OptionalRotation? FRotator Spawn rotation (defaults to player rotation)
---@return AActor|nil SpawnedActor The spawned actor or nil if failed
function Utils.Summon(ObjectName, OptionalLocation, OptionalRotation)
    local world = UEHelpers.GetWorld()
    local pc = UEHelpers.GetPlayerController()

    if world and pc and pc.Pawn then
        -- Use provided location or default to player
        local spawn_loc = OptionalLocation or pc.Pawn:K2_GetActorLocation()
        local spawn_rot = OptionalRotation or pc.Pawn:K2_GetActorRotation()

        local summon_class = StaticFindObject(ObjectName)
        print('Class to summon: ' .. tostring(summon_class and summon_class:GetFullName() or 'NOT_FOUND'))

        if summon_class then
            local new_summon = world:SpawnActor(summon_class, spawn_loc, spawn_rot)
            if new_summon then
                print('✅ Spawned: ' .. tostring(new_summon:GetFullName()))
                print('   Location: ' .. tostring(spawn_loc))
                return new_summon -- Return for further manipulation
            else
                print('❌ Failed to spawn: ' .. ObjectName)
            end
        else
            print('❌ Class not found: ' .. ObjectName)
        end
    else
        print('❌ Missing world/player/pawn')
    end
    return nil
end

---Prints the current Unreal Engine version
function Utils.PrintUEVersion()
    print('UNREAL VERSION: ' .. tostring(UnrealVersion:GetMajor()) .. '.' .. tostring(UnrealVersion:GetMinor()))
end

---Creates a repeating timer that executes a callback function at regular intervals
---@param callback function The function to execute repeatedly
---@param delay_seconds number Time in seconds between executions
---@return number interval_id Unique identifier for this interval (use with ClearInterval)
---@example
--- ```lua
--- -- Create a timer that prints every 2 seconds
--- local my_timer = Utils.SetInterval(function()
---     print('Every 5 seconds')
--- end, 2)
--- ```
function Utils.SetInterval(callback, delay_seconds)
    local cron = require('cron')

    -- Generate unique ID for this interval
    interval_id_counter = interval_id_counter + 1
    local interval_id = interval_id_counter

    -- Create the clock using the provided callback and delay
    local clock_from_cron = cron.every(delay_seconds, callback)
    
    -- Store it so we can clear it later
    active_intervals[interval_id] = clock_from_cron

    -- Background update loop
    ExecuteInGameThread(function()
        local function background_update()
            -- Update all active intervals
            for id, timer in pairs(active_intervals) do
                if timer then
                    timer:update(0.1)
                end
            end

            -- Schedule the next update
            ExecuteWithDelay(100, background_update)
        end

        -- Start the loop
        background_update()
        print("Background update loop started")
    end)
    
    -- Return the ID so it can be cleared later
    return interval_id
end



---Stops a repeating timer created with SetInterval
---@param interval_id number The ID returned by SetInterval
---@return boolean success True if interval was found and cleared, false otherwise
---@example
--- ```lua
--- -- Stop the timer when CAPS_LOCK is pressed
--- RegisterKeyBind(Key.CAPS_LOCK, {}, function()
---     Utils.ClearInterval(my_timer)
--- end)
--- ```
function Utils.ClearInterval(interval_id)
    if active_intervals[interval_id] then
        active_intervals[interval_id] = nil
        print("Cleared interval " .. interval_id)
        return true
    end
    return false
end


return Utils
