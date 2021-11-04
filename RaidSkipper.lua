------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

local _, RaidSkipper = ...
addon_name = "RaidSkipper"

local raid_skip_quests = {
    {
        name = "Warlords of Draenor",
        raids = {
            { name = "Blackrock Foundary", instanceId = 1205,  mythicId = 37031, heroicId = 37030, normalId = 37029 },
            { name = "Hellfire Citadel Lower", instanceId = 1448, mythicId = 39501, heroicId = 39500, normalId = 39499 },
            { name = "Hellfire Citadel Upper", instanceId = 1448, mythicId = 39505, heroicId = 39504, normalId = 39502 }
        }
    },
    {
        name = "Legion",
        raids = {
            { name = "The Emerald Nightmare", instanceId = 1520, mythicId = 44285, heroicId = 44284, normalId = 44283 },
            { name = "The Nighthold", instanceId = 1530, mythicId = 45383, heroicId = 45382, normalId = 45381 },
            { name = "Tomb of Sargeras", instanceId = 1676, mythicId = 47727, heroicId = 47726, normalId = 47725 },
            { name = "Burning Throne Lower", instanceId = 1712, mythicId = 49076, heroicId = 49075, normalId = 49032 },
            { name = "Burning Throne Upper", instanceId = 1712, mythicId = 49135, heroicId = 49134, normalId = 49133 }
        }
    },
    {
        name = "Battle for Azeroth",
        raids = {
            { name = "Battle of Dazar'alor", instanceId = 2070, mythicId = 316476 },
            { name = "Ny'alotha, the Waking City", instanceId = 2217, mythicId = 58375, heroicId = 58374, normalId = 58373 }
        }
    },
    {
        name = "Shadowlands",
        raids = {
            { name = "Castle Nathria", instanceId = 2296, mythicId = 62056, heroicId = 62055, normalId = 62054 },
            { name = "Sanctum of Domination", instanceId = 2450, mythicId = 64599, heroicId = 64598, normalId = 64597 }
        }
    }
}

local tmp_data = {}

RaidSkipper.AceAddon = LibStub("AceAddon-3.0"):NewAddon("RaidSkipper", "AceConsole-3.0", "AceEvent-3.0")

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

    for key, raid in ipairs(data.raids) do
        ShowRaidSkip(raid)
    end
end

local function ShowRaid(data)
    
    ShowRaidSkip(data)
end

local function ShowExpansions()
    for name, data in ipairs(raid_skip_quests) do
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

local function ShowRaidInstanceById(id)
    local output = ""
    local found = false
    for expansionKey, expansionData in ipairs(raid_skip_quests) do
        for raidKey, raidData in ipairs(expansionData.raids) do
            if (raidData.instanceId == id) then
                if not found then
                    RaidSkipper:Print(expansionData.name)
                end
                ShowRaidSkip(raidData)
                found = true
            end
        end
    end
end

local function InRaid() 
    local instanceType = select(2, GetInstanceInfo())
    return instanceType == "raid"
end

local function OnChangeZone()
    local in_raid = InRaid()
    local instanceID = select(8, GetInstanceInfo())
    if in_raid then
        ShowRaidInstanceById(instanceID)
    end
end

local function ShowCurrentRaid() 
    local instanceID = select(8, GetInstanceInfo())
    ShowRaidInstanceById(instanceID)
end

function SlashHandler(args)
    local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    if arg1 then
        arg1 = arg1:lower()
        
        if arg1 == "all" then
            ShowExpansions()
        elseif arg1 == "wod" then
            ShowExpansion(raid_skip_quests[1])
        elseif arg1 == "legion" then
            ShowExpansion(raid_skip_quests[2])
        elseif arg1 == "bfa" then
            ShowExpansion(raid_skip_quests[3])
        elseif arg1 == "sl" then
            ShowExpansion(raid_skip_quests[4])
        else
            PrintHelp()
        end
    else
        if InRaid() then
            ShowCurrentRaid()
        else
            ShowExpansions()
        end
    end
end

function RaidSkipper.AceAddon:OnInitialize()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", OnChangeZone)
    self:RegisterChatCommand("raidskipper", SlashHandler)
    self:RegisterChatCommand("rs", SlashHandler)
end

function RaidSkipper.AceAddon:OnEnable()
end
