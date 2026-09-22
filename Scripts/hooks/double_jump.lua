local State = require("core.state")

local DoubleJump = {}

function DoubleJump.checkAndInstall(player)
    if not State.doubleJumpHookInstalled then
        local okHookDJ, errHookDJ = pcall(function()
            RegisterHook("/Game/Gameplay/Character/Player/BP_PlayerCharacter.BP_PlayerCharacter_C:OnDoubleJump", function(Context)
                local ok, self = pcall(function() return Context:get() end)
                if not ok or not self or not self:IsValid() then return end

                State.doubleJumpToken = State.doubleJumpToken + 1
                local myToken = State.doubleJumpToken

                print("[FPC-DJUMP] OnDoubleJump (BP) called, token=" .. myToken)

                local cam = self.FollowCamera
                if cam and cam:IsValid() and State.isFirstPerson then
                    cam.bUsePawnControlRotation = false
                    State.doubleJumpCamFollowing = true

                    ExecuteInGameThreadWithDelay(380, function()
                        if myToken == State.doubleJumpToken and State.doubleJumpCamFollowing then
                            local cam2 = self.FollowCamera
                            if cam2 and cam2:IsValid() then
                                cam2.bUsePawnControlRotation = true
                            end
                            State.doubleJumpCamFollowing = false
                            print("[FPC-DJUMP] fallback timeout -> returning to mouse-look, token=" .. myToken)
                        end
                    end)
                end
            end)
        end)
        State.doubleJumpHookInstalled = true
        print("[FPC-DJUMP] registered OnDoubleJump hook (lazy): " .. tostring(okHookDJ) .. " | error: " .. tostring(errHookDJ))
    end
end

return DoubleJump