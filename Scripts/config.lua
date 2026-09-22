local Helpers = require("utils.helpers")

local Config = {}

local MOD_ROOT_DIR = Helpers.getModRootDir()
Config.KEYBIND_CONFIG_PATH = MOD_ROOT_DIR .. "keybinds.txt"

Config.DEFAULTS = {
    toggle = "V",
    first_person_on = "F6",
    first_person_off = "F7",
    toggle_head_debug = "F8",
    dump_mesh_debug = "F9",
}

function Config.load()
    local result = {}
    for k, v in pairs(Config.DEFAULTS) do result[k] = v end

    local okOpen, f = pcall(io.open, Config.KEYBIND_CONFIG_PATH, "r")
    if not okOpen or not f then
        print("[FPC-CFG] cannot open " .. Config.KEYBIND_CONFIG_PATH .. " (okOpen=" .. tostring(okOpen) .. ", f=" .. tostring(f) .. "), using defaults")
        return result
    end

    local linesRead = 0
    for line in f:lines() do
        linesRead = linesRead + 1
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^#") then
            local key, value = trimmed:match("^([%w_]+)%s*=%s*([%w_]+)$")
            if key and value and result[key] ~= nil then
                result[key] = value
                print("[FPC-CFG] " .. key .. " = " .. value)
            end
        end
    end
    f:close()
    print("[FPC-CFG] " .. Config.KEYBIND_CONFIG_PATH .. " successfully read (" .. linesRead .. " lines)")
    return result
end

function Config.resolveKey(name, fallbackName)
    local okKey, k = pcall(function() return Key[name] end)
    if okKey and k then
        return k
    end
    print("[FPC-CFG] unknown key name '" .. tostring(name) .. "', using default '" .. fallbackName .. "'")
    return Key[fallbackName]
end

return Config