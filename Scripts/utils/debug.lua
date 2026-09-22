-- DEBUG: dump all mesh components belonging to the player (default F9)

local Debug = {}

function Debug.dumpPlayerMeshComponents()
    local player = FindFirstOf("BP_PlayerCharacter_C")
    if not player or not player:IsValid() then
        print("[FPC-DUMP] player not found")
        return
    end

    local function belongsToPlayer(c)
        local okOwner, owner = pcall(function() return c:GetOwner() end)
        if okOwner and owner and owner:IsValid() then
            local okName1, n1 = pcall(function() return owner:GetFullName() end)
            local okName2, n2 = pcall(function() return player:GetFullName() end)
            if okName1 and okName2 then
                return n1 == n2
            end
        end
        return false
    end

    local function dumpList(components, label)
        local count = 0
        print("[FPC-DUMP] === " .. label .. " ===")
        for _, c in ipairs(components) do
            if c and c:IsValid() and belongsToPlayer(c) then
                count = count + 1
                local ok, name = pcall(function() return c:GetFName():ToString() end)
                name = ok and name or "?"

                local asset = "-"
                local okSkin, skinned = pcall(function() return c.SkinnedAsset end)
                if okSkin and skinned and skinned:IsValid() then
                    asset = skinned:GetFullName()
                else
                    local okStatic, staticMesh = pcall(function() return c.StaticMesh end)
                    if okStatic and staticMesh and staticMesh:IsValid() then
                        asset = staticMesh:GetFullName()
                    end
                end

                local okVis, vis = pcall(function() return c.bVisible end)
                vis = okVis and tostring(vis) or "?"

                local parentName = "(none)"
                local okParent, parent = pcall(function() return c:GetAttachParent() end)
                if okParent and parent and parent:IsValid() then
                    local okPName, pName = pcall(function() return parent:GetFName():ToString() end)
                    parentName = okPName and pName or "?"
                end

                print(string.format(
                    "[FPC-DUMP] name=%s | asset=%s | visible=%s | parent=%s",
                    name, asset, vis, parentName
                ))
            end
        end
        print("[FPC-DUMP] " .. label .. " belonging to player: " .. count)
    end

    local okSkel, skelComponents = pcall(function() return FindAllOf("SkeletalMeshComponent") end)
    if okSkel and skelComponents then
        dumpList(skelComponents, "SkeletalMeshComponent")
    else
        print("[FPC-DUMP] failed FindAllOf SkeletalMeshComponent: " .. tostring(skelComponents))
    end

    local okStat, statComponents = pcall(function() return FindAllOf("StaticMeshComponent") end)
    if okStat and statComponents then
        dumpList(statComponents, "StaticMeshComponent")
    else
        print("[FPC-DUMP] failed FindAllOf StaticMeshComponent: " .. tostring(statComponents))
    end

    print("[FPC-DUMP] finished.")
end

return Debug