local State = {
    HEAD_SOCKET = "head",
    CAM_OFFSET_FORWARD = 10,
    CAM_OFFSET_UP = 0,

    -- Method to hide the head from the player:
    -- "ownernosee" = SetOwnerNoSee (default)
    -- "mainpass"   = disable main pass rendering
    HIDE_MODE = "ownernosee",
    HEAD_PARTS = { "HeadMesh", "HairZone1Mesh", "InvisHairMesh", "FacialHairZone1Mesh", "OutfitHeadMesh" },
    
    saved = nil, -- original body rotation values, used for F7
    headHidden = false,
    isFirstPerson = false,

    evadeCamFollowing = false,
    evadeToken = 0,

    doubleJumpCamFollowing = false,
    doubleJumpHookInstalled = false,
    doubleJumpToken = 0,
}

return State