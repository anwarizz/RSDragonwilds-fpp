-- Evade: camera follows animation rotation during evade, then returns to mouse-look

local State = require("core.state")
local Player = require("core.player")

local Evade = {}

local function getFollowCameraFromComponentOwner(self)
    local okOwner, owner = pcall(function() return self:GetOwner() end)
    if not okOwner or not owner or not owner:IsValid() then return nil end
    local cam = owner.FollowCamera
    if cam and cam:IsValid() then return cam end
    return nil
end

local function restoreMouseLook(reason)
    local player, cam = Player.getParts()
    if cam and cam:IsValid() then
        cam.bUsePawnControlRotation = true
    end
    State.evadeCamFollowing = false
    print("[FPC-EVADE] returned to mouse-look (" .. reason .. ")")
end

function Evade.registerAll()
    RegisterHook("/Script/Dominion.PlayerEvadeComponent:Multicast_StartEvade", function(Context)
        local ok, self = pcall(function() return Context:get() end)
        if not ok or not self or not self:IsValid() then return end

        State.evadeToken = State.evadeToken + 1
        local myToken = State.evadeToken

        print("[FPC-EVADE] Multicast_StartEvade called, token=" .. myToken)

        local cam = getFollowCameraFromComponentOwner(self)
        if cam and State.isFirstPerson then
            cam.bUsePawnControlRotation = false
            State.evadeCamFollowing = true

            -- safety fallback: force return after 600ms if EvadeTimerExpired
            -- is never called / unreliable in marking the end of evade
            ExecuteInGameThreadWithDelay(600, function()
                if myToken == State.evadeToken and State.evadeCamFollowing then
                    restoreMouseLook("fallback timeout, token=" .. myToken)
                end
            end)
        end
    end)

    RegisterHook("/Script/Dominion.PlayerEvadeComponent:EvadeTimerExpired", function(Context)
        local ok, self = pcall(function() return Context:get() end)
        if not ok or not self or not self:IsValid() then return end

        print("[FPC-EVADE] EvadeTimerExpired called, evadeCamFollowing=" .. tostring(State.evadeCamFollowing))

        if State.evadeCamFollowing and State.isFirstPerson then
            restoreMouseLook("EvadeTimerExpired")
        end
    end)
end

return Evade