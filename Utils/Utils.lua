local Utils = {}

---@param text string
---@param substring string
---@return boolean or nil
function Utils.StringContains(text, substring)
    -- The 'true' argument disables pattern matching for a plain text search, which is faster.
    return string.find(text, substring, 1, true) ~= nil
end


-- A logging helper to print to both the in-game console and the debug log
function Utils.Log(Ar, Message)
    print(Message)
    if Ar and Ar:IsValid() then
        Ar:Log(Message)
    end
end


return Utils

