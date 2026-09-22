local State = require("core.state")
local Player = require("core.player")

local Camera = {}

function Camera.enterFirstPerson()
    local player, cam, boom, mesh = Player.getParts()
    if not player then return end

    print("[FPC] before: " .. Player.describeParent(cam))
    print("[FPC] socket '" .. State.HEAD_SOCKET .. "' exists? " .. tostring(mesh:DoesSocketExist(FName(State.HEAD_SOCKET))))

    -- 2 = SnapToTarget for location, rotation, scale
    cam:K2_AttachToComponent(mesh, FName(State.HEAD_SOCKET), 2, 2, 2, false)


    -- Offset camera slightly forward/up relative to head socket to prevent
    -- clipping through body/neck when looking down. Uses Lua table {X,Y,Z}
    local okOffset, errOffset = pcall(function()
        cam:K2_SetRelativeLocation({ X = State.CAM_OFFSET_FORWARD, Y = 0, Z = State.CAM_OFFSET_UP }, false, {}, false)
    end)
    print("[FPC] set camera offset: " .. tostring(okOffset) .. " | error: " .. tostring(errOffset))

    -- follow mouse/controller rotation instead of head bone animation
    cam.bUsePawnControlRotation = true
    State.evadeCamFollowing = false
    State.evadeToken = State.evadeToken + 1

    State.doubleJumpCamFollowing = false
    State.doubleJumpToken = State.doubleJumpToken + 1

    -- body follows camera direction (yaw)
    local move = player.CharacterMovement
    if not State.saved then
        State.saved = { yaw = player.bUseControllerRotationYaw }
        if move and move:IsValid() then
            State.saved.orient = move.bOrientRotationToMovement
            State.saved.desired = move.bUseControllerDesiredRotation
        end
    end
    player.bUseControllerRotationYaw = true
    if move and move:IsValid() then
        move.bOrientRotationToMovement = false
        move.bUseControllerDesiredRotation = false
    end

    Player.setHeadHidden(player, true)
    State.isFirstPerson = true
    print("[FPC] first-person ON: " .. Player.describeParent(cam))
end

function Camera.exitFirstPerson()
    local player, cam, boom, mesh = Player.getParts()
    if not player then return end

    cam.bUsePawnControlRotation = false
    State.evadeCamFollowing = false
    State.evadeToken = State.evadeToken + 1

    State.doubleJumpCamFollowing = false
    State.doubleJumpToken = State.doubleJumpToken + 1

    cam:K2_AttachToComponent(boom, FName("SpringEndpoint"), 2, 2, 2, false)

    if State.saved then
        player.bUseControllerRotationYaw = State.saved.yaw
        local move = player.CharacterMovement
        if move and move:IsValid() then
            if State.saved.orient ~= nil then move.bOrientRotationToMovement = State.saved.orient end
            if State.saved.desired ~= nil then move.bUseControllerDesiredRotation = State.saved.desired end
        end
        State.saved = nil
    end

    Player.setHeadHidden(player, false)
    State.isFirstPerson = false
    print("[FPC] first-person OFF: " .. Player.describeParent(cam))
end

function Camera.toggleFirstPerson()
    if State.isFirstPerson then
        Camera.exitFirstPerson()
    else
        Camera.enterFirstPerson()
    end
end

return Camera