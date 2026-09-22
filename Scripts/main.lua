local Config = require("config")
local State  = require("core.state")
local Player = require("core.player")
local Camera = require("core.camera")
local Evade  = require("hooks.evade")
local Debug  = require("utils.debug")

-- Load Keybind Configuration
print("[FPC-CFG] keybinds.cfg path: " .. Config.KEYBIND_CONFIG_PATH)
local keybindCfg = Config.load()

local KEY_TOGGLE     = Config.resolveKey(keybindCfg.toggle, Config.DEFAULTS.toggle)
local KEY_FP_ON      = Config.resolveKey(keybindCfg.first_person_on, Config.DEFAULTS.first_person_on)
local KEY_FP_OFF     = Config.resolveKey(keybindCfg.first_person_off, Config.DEFAULTS.first_person_off)
local KEY_HEAD_DEBUG = Config.resolveKey(keybindCfg.toggle_head_debug, Config.DEFAULTS.toggle_head_debug)
local KEY_DUMP_DEBUG = Config.resolveKey(keybindCfg.dump_mesh_debug, Config.DEFAULTS.dump_mesh_debug)

-- UFunction Hook Registration
Evade.registerAll()

-- Keybind Registration
RegisterKeyBind(KEY_TOGGLE, function()
    ExecuteInGameThread(function() Camera.toggleFirstPerson() end)
end)

RegisterKeyBind(KEY_FP_ON, function()
    ExecuteInGameThread(function() Camera.enterFirstPerson() end)
end)

RegisterKeyBind(KEY_FP_OFF, function()
    ExecuteInGameThread(function() Camera.exitFirstPerson() end)
end)

RegisterKeyBind(KEY_HEAD_DEBUG, function()
    ExecuteInGameThread(function()
        local player = FindFirstOf("BP_PlayerCharacter_C")
        if not player or not player:IsValid() then return end
        Player.setHeadHidden(player, not State.headHidden)
    end)
end)

RegisterKeyBind(KEY_DUMP_DEBUG, function()
    ExecuteInGameThread(function()
        Debug.dumpPlayerMeshComponents()
    end)
end)

print("[FPC] ready. Active keybinds (from " .. Config.KEYBIND_CONFIG_PATH .. "): toggle=" .. keybindCfg.toggle ..
    " | ON=" .. keybindCfg.first_person_on .. " | OFF=" .. keybindCfg.first_person_off ..
    " | head-debug=" .. keybindCfg.toggle_head_debug .. " | dump-debug=" .. keybindCfg.dump_mesh_debug)

print("[FPC] +++++++++++++++++++++++++++++++++++++++ V First Person Camera by daoa (https://www.curseforge.com/members/daoa/projects) successfully loaded +++++++++++++++++++++++++++++++++++++++")