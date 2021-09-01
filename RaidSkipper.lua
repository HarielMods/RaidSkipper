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

            [4] = { name = "Burning Throne Lower", mythicId = 49076, heroicId = 49075, normalId = 49032 },
            [5] = { name = "Burning Throne Upper", mythicId = 49135, heroicId = 49134, normalId = 49133 }
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
        raids = {
            [1] = { name = "Castle Nathria", mythicId = 62056, heroicId = 62055, normalId = 62054 },
            [2] = { name = "Sanctum of Domination", mythicId = 64599, heroicId = 64598, normalId = 64597 }
        }
    }
}

local div = "------------------------------"

local function is_complete(id)
    if (id ~= nil) then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    else
        return nil
    end
end

local function is_in_progress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
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

local function is_quest_in_quest_log(id)
    return (C_QuestLog.GetLogIndexForQuestID(id) ~= nil)
end

local function get_progress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
    return fulfilled .. "/" .. required
end

local function get_quest_info(id, difficulty)
    if (is_complete(id)) then
        -- Player has completed this quest
        return text_color("green", difficulty)
    elseif (is_quest_in_quest_log(id)) then
            -- Player has this quest in the quest log
            return text_color("blue", difficulty .. " " .. get_progress(id))
    else
        -- Player has not completed this quest does not have quest in the quest log
        return text_color("red", difficulty)
    end
end

local function show_expansion(expansion)
    if (expansion ~= nil and #(expansion.raids) > 0) then
        print (expansion.name)
        for _, raid in ipairs(expansion.raids) do
            local output = "   " .. raid.name .. ": "
            output = output .. get_quest_info(raid.mythicId, "Mythic")

            -- If mythic is completed, there is no need to find out if heroic or normal is completed
            if (not is_complete(raid.mythicId) and raid.heroicId ~= nil) then    
                output = output .. " " .. get_quest_info(raid.heroicId, "Heroic")
                -- If heroic is completed, there is no need to find out if normal is completed
                if (not is_complete(raid.heroicId) and raid.normalId ~= nil) then
                    output = output .. " " .. get_quest_info(raid.normalId, "Normal")
                end
            end
            print(output)
        end
    end
end

local function print_key()
    print("Key: " .. text_color("blue", "In progress") .. " " .. text_color("green", "Completed") .. " " .. text_color("red", "Not completed"))
    print("Use '/rs help' to display more help")
end

local function print_help()
    print(text_color("green", "Raid Skipper:") .. " Arguments to /rs :")
    print("   wod - Warlords of Draenor")
    print("   legion - Legion")
    print("   bfa - Battle for Azeroth")
    print("   sl - Shadowlands")
    print("Color Key:")
    print(text_color("blue", "   Blue") .. ": In progress")
    print(text_color("green", "   Green") .. ": Completed")
    print(text_color("red", "   Red") .. ": Not completed")
    print("Lower difficulties can be skipped if a higher difficulty skip is completed.")
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

    print(text_color("yellow", "== Raid Skipper =="))
    for _, expansion in ipairs(expansions) do
        show_expansion(expansion)
    end
end

SLASH_RAIDSKIPPER1, SLASH_RAIDSKIPPER2 = "/raidskipper", "/rs"
SlashCmdList["RAIDSKIPPER"] = RaidSkipperHandler

