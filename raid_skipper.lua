local function is_complete(v)
    return C_QuestLog.IsQuestFlaggedCompleted(v)
end

local function make_color(color, msg)
    if (color == "yellow") then
        return "\124cffffff00" .. msg .. "\124r"
    elseif (color == "red") then
        return "\124cffff0000" .. msg .. "\124r"
    elseif (color == "blue") then
        return "\124cff0000ff" .. msg .. "\124r"
    end
end

local function print_entry(label, value)
    local v
    if (value) then
        v = make_color("yellow", "Completed")
    else 
        v = make_color("red", "Not completed")
    end
    print(format("%s: %s", label, v))
end

local expansions = {
    [1] = {
        label = "Warlords of Draenor",
        raids = {
            [1] = { label = "Blackrock Foundary", mythic = 37031, heroic = 37030, normal = 37029 },
            [2] = { label = "Hellfire Citadel Lower", mythic = 39501, heroic = 39500, normal = 39499 },
            [3] = { label = "Hellfire Citadel Upper", mythic = 39505, heroic = 39504, normal = 39502 }
        }
    },
    [2] = {
        label = "Legion",
        raids = {
            [1] = { label = "The Emerald Nightmare", mythic = 44285, heroic = 44284, normal = 44283 },
            [2] = { label = "The Nighthold", mythic = 45383, heroic = 45382, normal = 45381 },
            [3] = { label = "Tomb of Sargeras", mythic = 47727, heroic = 47726, normal = 47725 },
            [4] = { label = "Anotrus, the Burning Throne Lower", mythic = 49135, heroic = 49134, normal = 49133 },
            [5] = { label = "Anotrus, the Burning Throne Upper", mythic = 49076, heroic = 49075, normal = 49032 }
        }
    },
    [3] = {
        label = "Battle for Azeroth",
        raids = {
            [1] = { label = "Battle of Dazar'alor", mythic = 316476 },
            [2] = { label = "Ny'alotha, the Waking City", mythic = 58375, heroic = 58374, normal = 58373 },
        }
    }
}

local function help() {
    print("/rs or /raidskipper")
    print("/rs Warlords - Display only Warlords raids")
    print("/rs Legion - Display only Legion raids")
    print("/rs BfA - Display only Battle for Azeroth raids")
    print("/rs Shadowlands - Display only Shadowlands raids")
    print("/ic or /iscomplete")
    print("/ic 43256 - Shows if player has completed quest or achievement 43256")

}

local function raid_skipper(msg)

    if (string.len(msg) > 0) then
        -- /rs expansion, raid, help, 
        if (msg == "help") then
        end
    else
        for e in pairs(expansions) do
            local expansion = expansions[e]
            local raids = expansion.raids
            print(expansion.label)
            for s in pairs(raids) do
                local skip = raids[s]
                local l,m,h,n = skip.label, is_complete(skip.mythic), is_complete(skip.heroic), is_complete(skip.normal)
                print(
                    format("    %s: %s %s %s", l, 
                        make_color(m and "yellow" or "red", "Mythic"),
                        not m and make_color(h and "yellow" or "red", "Heroic") or "",
                        not m and not h and make_color(n and "yellow" or "red", "Normal") or ""
                    )
                )
            end
        end
    end

    
end

SLASH_RAIDSKIPPER1, SLASH_RAIDSKIPPER2 = "/raidskipper", "/rs"
SlashCmdList["RAIDSKIPPER"] = raid_skipper