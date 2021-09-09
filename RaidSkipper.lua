------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

local _, RaidSkipper = ...;
addon_name = "RaidSkipper";

local raid_skip_quests = {
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

RaidSkipper.AceAddon = LibStub("AceAddon-3.0"):NewAddon("RaidSkipper", "AceConsole-3.0");

-- Workaround to keep the nice RaidSkipper:Print function.
RaidSkipper.Print = function(self, text) RaidSkipper.AceAddon:Print(text) end

-- UTILITY FUNCTIONS

RaidSkipper.TextColor = function(color, msg)
    local colors = {
        ["complete"] = "ff00ff00",
        ["incomplete"] = "ffff0000",
        ["inprogress"] = "ff00ffff",
        ["yellow"] = "ffffff00",
        ["red"] = "ffff0000",
        ["green"] = "ff00ff00",
        ["blue"] = "ff0000ff",
    }
    return "\124c" .. colors[color] .. msg .. "\124r"
end

-- QUEST FUNCTIONS

local function IsComplete(id)
    if (id ~= nil) then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    else
        return nil
    end
end

local function IsInProgress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
end

local function IsQuestInQuestLog(id)
    return (C_QuestLog.GetLogIndexForQuestID(id) ~= nil)
end

-- DISPLAY FUNCTIONS

local function ShowQuestProgress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
    return fulfilled .. "/" .. required
end

local function ShowQuestInfo(id, difficulty)
    if (IsComplete(id)) then
        -- Player has completed this quest
        return RaidSkipper.TextColor("complete", difficulty)
    elseif (IsQuestInQuestLog(id)) then
        -- Player has this quest in their quest log
        return RaidSkipper.TextColor("inprogress", difficulty .. " " .. ShowQuestProgress(id))
    else
        -- Player has not completed this quest does not have quest in the quest log
        return RaidSkipper.TextColor("incomplete", difficulty)
    end
end

local function ShowRaidSkip(raid)
    local line = "  " .. raid.name .. ": "
    
    -- Mythic
    line = line .. ShowQuestInfo(raid.mythicId, "Mythic")
    
    -- Heroic, if Mythic is complete Heroic and Normal can be skipped
    if (not IsComplete(raid.mythicId) and raid.heroicId ~= nil) then
        line = line .. " " .. ShowQuestInfo(raid.heroicId, "Heroic")
        -- Normal, if Heroic is complete Normal can be skipped
        if (not IsComplete(raid.heroicId) and raid.normalId ~= nil) then
            line = line .. " " .. ShowQuestInfo(raid.normalId, "Normal")
        end
    end
    
    RaidSkipper:Print(line)
end

local function ShowExpansion(data)
    
    RaidSkipper:Print(data.name)

    for key, raid in pairs(data.raids) do
        ShowRaidSkip(raid)
    end
end

local function ShowExpansions()
    for name, data in pairs(raid_skip_quests) do
        ShowExpansion(data)
    end
end

local function ShowKey()
    Print("Key: " .. TextColor("blue", "In progress") .. " " .. TextColor("green", "Completed") .. " " .. TextColor("red", "Not completed"))
    Print("Use '/rs help' to display more help")
end

local function PrintHelp()
    RaidSkipper:Print("slash commands:")
    RaidSkipper:Print("  /rs wod --> Warlords of Draenor")
    RaidSkipper:Print("  /rs legion --> Legion")
    RaidSkipper:Print("  /rs bfa --> Battle for Azeroth")
    RaidSkipper:Print("  /rs sl --> Shadowlands")
end

function SlashHandler(args)
    local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    if arg1 then
        arg1 = arg1:lower()
        
        if arg1 == "wod" then
            ShowExpansion(raid_skip_quests[1])
        elseif arg1 == "legion" then
            ShowExpansion(raid_skip_quests[2])
        elseif arg1 == "bfa" then
            ShowExpansion(raid_skip_quests[3])
        elseif arg1 == "sl" then
            ShowExpansion(raid_skip_quests[4])
        elseif arg1 == "help" then
            PrintHelp()
        end
    else
        ShowExpansions()
    end
end

function RaidSkipper.AceAddon:OnInitialize()
    self:Print("Raid Skipper Initialized");

    self:RegisterChatCommand("raidskipper", SlashHandler);
    self:RegisterChatCommand("rs", SlashHandler);

end

function RaidSkipper.AceAddon:OnEnable()
end
