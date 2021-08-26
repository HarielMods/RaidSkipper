
local function is_complete(v)
    if (v ~= nil) then
        return C_QuestLog.IsQuestFlaggedCompleted(v)
    else
        return nil
    end
end

local function text_color(color, msg)
    local colors = {
        ["yellow"] = "ffffff00",
        ["red"] = "ffff0000",
        ["green"] = "ff00ff00",
        ["blue"] = "ff0000ff",
    }
    return "\124c" .. colors[color] .. msg .. "\124r"
end

local function print_entry(label, value)
    local v
    if (value) then
        v = text_color("yellow", "Completed")
    else 
        v = text_color("red", "Not completed")
    end
    print(format("%s: %s", label, v))
end

local div = "------------------------------"

local data = {
    [1] = { 
        name = "Warlords of Draenor",
        raids = {
            [1] = { name = "Blackrock Foundary", mythicId = 37031, heroicId = 37030, normalId = 37029 },
            [2] = { name = "Hellfire Citadel Lower", mythicId = 39501, heroicId = 39500, normalId = 39499 },
            [3] = { name = "Hellfire Citadel Upper", mythicId = 39505, heroicId = 39504, normalId = 39502 }
        }
    },
    [2] = { 
        name = "Legion",
        raids = {
            [1] = { name = "The Emerald Nightmare", mythicId = 44285, heroicId = 44284, normalId = 44283 },
            [2] = { name = "The Nighthold", mythicId = 45383, heroicId = 45382, normalId = 45381 },
            [3] = { name = "Tomb of Sargeras", mythicId = 47727, heroicId = 47726, normalId = 47725 },

            [4] = { name = "Anotrus, the Burning Throne Lower", mythicId = 49076, heroicId = 49075, normalId = 49032 },
            [5] = { name = "Anotrus, the Burning Throne Upper", mythicId = 49135, heroicId = 49134, normalId = 49133 }
        }
    },
    [3] = { 
        name = "Battle for Azeroth",
        raids = {
            [1] = { name = "Battle of Dazar'alor", mythicId = 316476 },
            [2] = { name = "Ny'alotha, the Waking City", mythicId = 58375, heroicId = 58374, normalId = 58373 }
        }
    },
    [4] = { 
        name = "Shadowlands",
        raids = {}
    }
}

local function get_skip_text(id, label)
    if (id ~= nil) then
        local is_quest_complete = is_complete(id)
        return text_color(is_quest_complete and "green" or "red", label)
    else
        return ""
    end
end

local function show_expansion(expansion)
    if (expansion ~= nil and #(expansion.raids) > 0) then
        print (expansion.name)
        for _, raid in ipairs(expansion.raids) do
            local output = "   " .. raid.name .. ": " .. get_skip_text(raid.mythicId, "Mythic")
            if (not is_complete(raid.mythicId)) then    
                output = output .. " " .. get_skip_text(raid.heroicId, "Heroic")
                if (not is_complete(raid.heroicId)) then
                    output = output .. " " .. get_skip_text(raid.normalId, "Normal")
                end
            end
            print(output)
        end
    end
end

local function print_key()
    print("Key: " .. text_color("green", "Completed") .. " " .. text_color("red", "Not completed"))
end

local function print_help()
    print("Raid Skipper Help")
    print("  Usage: /raidskipper or /rs")
    print(" ")
    print("  For single expansions use:")
    print("    /rs wod")
    print("    /rs legion")
    print("    /rs bfa")
    print("    /rs sl")
    print("  Completed is " .. text_color("green", "green"))
    print("  Not completed is " .. text_color("red", "red"))
end

local function RaidSkipperHandler(msg)
    local expansions = data
    if (string.len(msg) > 0) then
        local m = string.lower(msg)
        if (m == "help") then
            print_help()
            do return end
        elseif (m == "wod" or m == "1") then 
            expansions = { [1] = data[1] }
        elseif (m == "legion" or m == "2") then
            expansions = { [1] = data[2] }
        elseif (m == "bfa" or m == "3") then
            expansions = { [1] = data[3] }
        elseif (m == "sl" or m == "4") then
            expansions = { [1] = data[4] }
        end
    end

    print_key()
    for _, expansion in ipairs(expansions) do
        show_expansion(expansion)
    end

end

SLASH_RAIDSKIPPER1, SLASH_RAIDSKIPPER2 = "/raidskipper", "/rs"
SlashCmdList["RAIDSKIPPER"] = RaidSkipperHandler
