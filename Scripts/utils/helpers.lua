
local Helpers = {}

function Helpers.getScriptDir()
    local okInfo, info = pcall(function() return debug.getinfo(1, "S") end)
    if okInfo and info and info.source then
        local src = info.source
        if src:sub(1, 1) == "@" then src = src:sub(2) end
        local dir = src:match("^(.*[/\\])")
        if dir then return dir end
    end
    return ""
end

function Helpers.getParentDir(dir)
    if dir == "" then return "" end
    local path = dir:gsub("[/\\]$", "")
    local parent = path:match("^(.*[/\\])[^/\\]+$")
    if parent then
        return parent
    end
    return dir
end

function Helpers.getModRootDir()
    local scriptDir = Helpers.getScriptDir()
    
    local normalized = scriptDir:gsub("\\", "/")
    
    local scriptsPos = normalized:find("/Scripts/", 1, true)
    if scriptsPos then
        return normalized:sub(1, scriptsPos) 
    end
    
    return Helpers.getParentDir(Helpers.getParentDir(scriptDir))
end

return Helpers