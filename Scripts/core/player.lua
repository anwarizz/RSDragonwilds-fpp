local State = require("core.state")
local DoubleJump = require("hooks.double_jump")

local Player = {}

function Player.getParts()
    local player = FindFirstOf("BP_PlayerCharacter_C")
    if not player or not player:IsValid() then
        print("[FPC] player not found")
        return nil
    end

    DoubleJump.checkAndInstall(player)

    local cam = player.FollowCamera
    local boom = player.CameraBoom
    local mesh = player.Mesh
    if not (cam and cam:IsValid() and boom and boom:IsValid() and mesh and mesh:IsValid()) then
        print("[FPC] FollowCamera / CameraBoom / Mesh is invalid")
        return nil
    end
    return player, cam, boom, mesh
end

function Player.setHeadHidden(player, hidden)
    for _, name in ipairs(State.HEAD_PARTS) do
        local c = player[name]
        if c and c:IsValid() then
            if State.HIDE_MODE == "mainpass" then
                pcall(function() c:SetRenderInMainPass(not hidden) end)
            else
                c:SetOwnerNoSee(hidden)
            end
            -- continue casting shadows even when hidden
            local ok = pcall(function() c:SetCastHiddenShadow(hidden) end)
            if not ok then c.bCastHiddenShadow = hidden end
        end
    end
    State.headHidden = hidden
    print("[FPC] head " .. (hidden and "hidden" or "shown") .. " (mode: " .. State.HIDE_MODE .. ")")
end

function Player.describeParent(cam)
    local p = cam:GetAttachParent()
    if p and p:IsValid() then
        return p:GetFullName() .. " @ " .. cam:GetAttachSocketName():ToString()
    end
    return "(none)"
end

return Player