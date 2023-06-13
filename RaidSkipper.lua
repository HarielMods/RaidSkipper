------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

local _, RaidSkipper = ...
addon_name = "RaidSkipper"

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

local function IsQuestComplete(id)
    if (id ~= nil) then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    else
        return nil
    end
end

local function IsAchievementComplete(id)
    if (id ~= nil) then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(id)
        return completed
    else
        return nil
    end
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
    if (IsQuestComplete(id)) then
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

local function ShowAchievementInfo(id)
    if (IsAchievementComplete(id)) then
        -- Player has completed achievement
        RaidSkipper:Print("completed")
    else
        RaidSkipper:Print("not completed")
    end
end

local function ShowRaidSkip(raid)
    local line = "  " .. raid.name .. ": "

    -- Battle of Dazar'alor uses an Achievement, not quests
    if raid.instanceId == 2070 then
        local completed = IsAchievementComplete(raid.achievementId)
        if completed then
            line = line .. RaidSkipper.TextColor("complete", "completed")
        else
            line = line .. RaidSkipper.TextColor("incomplete", "not completed")
        end
    else
        -- Mythic
        line = line .. ShowQuestInfo(raid.mythicId, "Mythic")
        
        -- Heroic, if Mythic is complete Heroic and Normal can be skipped
        if (not IsQuestComplete(raid.mythicId) and raid.heroicId ~= nil) then
            line = line .. " " .. ShowQuestInfo(raid.heroicId, "Heroic")
            -- Normal, if Heroic is complete Normal can be skipped
            if (not IsQuestComplete(raid.heroicId) and raid.normalId ~= nil) then
                line = line .. " " .. ShowQuestInfo(raid.normalId, "Normal")
            end
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
    for name, data in ipairs(RaidSkipper.raid_skip_quests) do
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
    RaidSkipper:Print("  /rs df --> Dragonflight")
end

local function ShowRaidInstanceById(id)
    local output = ""
    local found = false
    for expansionKey, expansionData in ipairs(RaidSkipper.raid_skip_quests) do
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

-- ----------------------------------------------------------------------------------------------------

function SlashHandler(args)
    local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    if arg1 then
        arg1 = arg1:lower()
        
        if arg1 == "all" then
            ShowExpansions()
        elseif arg1 == "wod" then
            ShowExpansion(RaidSkipper.raid_skip_quests[1])
        elseif arg1 == "legion" then
            ShowExpansion(RaidSkipper.raid_skip_quests[2])
        elseif arg1 == "bfa" then
            ShowExpansion(RaidSkipper.raid_skip_quests[3])
        elseif arg1 == "sl" then
            ShowExpansion(RaidSkipper.raid_skip_quests[4])
        elseif arg1 == "df" then
            ShowExpansion(RaidSkipper.raid_skip_quests[5])
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

function IsAchievementCompleteHandler(args)
    local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    if arg1 then
        ShowAchievementInfo(arg1)
    end
end

function IsQuestCompleteHandler(args)
    local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    if arg1 then
        if IsQuestComplete(arg1) then
            RaidSkipper:Print("completed")
        else
            RaidSkipper:Print("not completed")
        end
    end
end

function RaidSkipper.AceAddon:OnInitialize()
    
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", OnChangeZone)
    
    self:RegisterChatCommand("raidskipper", SlashHandler)
    self:RegisterChatCommand("rs", SlashHandler)
    self:RegisterChatCommand("iac", IsAchievementCompleteHandler)
    self:RegisterChatCommand("iqc", IsQuestCompleteHandler)
end

function RaidSkipper.AceAddon:OnEnable()
end
