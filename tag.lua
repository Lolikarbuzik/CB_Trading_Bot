local function stripTag(Tag)
    Tag = Tag.." | "
    local Tags = Tag:split(" | ")
    return {Weapon = Tags[1],Skin = Tags[2]}
end

local stripped = stripTag("Falchion Knife | Topaz")
print(stripped.Skin,stripped.Weapon)