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
-- Korthia Functions

local function InvasiveMawshroom()
    local i,s,_,_,_,n,t = 0,{64351,64354,64355,64356,64357},GetQuestObjectiveInfo(64376,0,false)
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 5 Mawshooms looted. ' .. n .. '/' .. t .. ' Tasty turned in.')
end

local function NestOfUnusualMaterials()
    local i,s,_,_,_,t = 0, {64358,63459,64360,64361,64362}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 5 Nests looted.')
end

local function MawswornCache()
    local i,s,_,_,_,t = 0,{64021,64363,64364}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 3 Mawsworn Caches looted.')
end

local function PileOfBonesShardHideStashesRelicChests()
    local i,s,_,_,_,t=0,{64309,64316,64317,64318,64564}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 5 Pile Of Bones, Shardhide Stashes, Relic Chests looted.')
end

local function RiftboundCaches()
    local i,s,_,_,_,t=0,{64456,64470,64471,64472}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 4 Riftbound Caches looted.')
end

local function RelicGorgerRelicGatherer()
    local i,s,_,_,_,t=0,{64433,64434,64435,64436}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 4 Relic Gorgers/Gatherers looted.')
end

-- TODO: Find quest ids for anima vessels
-- local function AnimaVessels()
--     local i,s,_,_,_,t=0,{}
--     for _,q in ipairs(s) do 
--         i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
--     end
--     print('Anima Vessels looted today: '..i..' of 5.')
-- end

local function HelswornChest()
    local i,s,_,_,_,t=0,{64256}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q)and 1 or 0)
    end
    print(i .. ' / 1 Helsworn Chest looted.')
end

local function SpectralKeys()
    local i,s,_,_,_,t=0,{64249,64250,64248}
    for _,q in ipairs(s) do 
        i=i+(C_QuestLog.IsQuestFlaggedCompleted(q) and 1 or 0)
    end
    local c=(C_QuestLog.IsQuestFlaggedCompleted(64247) and "yes" or "no")
    print(i .. ' / 3 Spectral Keys looted. Chest looted ' .. c)
end

local function ResearchReportRelicExaminationTechniques()
    if C_QuestLog.IsQuestFlaggedCompleted(64367) ~= true then
        print('Obtain Research Report: Relic Examination Techniques for faster reputation gains')
    end
end

local function ShowKorthiaDailyCaps()
    -- 5 Invasive Mawshrooms (no longer spawn for the day once looted)
    InvasiveMawshroom()
    -- 5 Nests of Unusual Materials (no longer spawn for the day once looted)
    NestOfUnusualMaterials()
    -- 3 Mawsworn Caches (no longer spawn for the day once looted)
    MawswornCache()
    -- 5 of either Pile of Bones, Shardhide Stashes or Relic Chests (can be looted but will no longer give Relic Fragment past cap)
    PileOfBonesShardHideStashesRelicChests()
    -- 4 Riftbound Caches (no longer spawn for the day once looted)
    RiftboundCaches()
    -- 4 Relic Gorger/Relic Gatherer Rares (no longer tracked for the day once past cap)
    RelicGorgerRelicGatherer()
    -- 5 Anima Vessels (no longer spawn for the day once looted)
    -- TODO
    -- 1 Helsworn Chest (no longer spawn for the day once looted)
    HelswornChest()
    -- 15 Enemies tracked via Research Report: All-Seeing Crystal (rewards diminish the more you kill, no longer tracked after 15).
    -- TODO

    -- Spectral chest/keys
    SpectralKeys()

    -- Obtain Research Report for each character for faster reputation gains
    ResearchReportRelicExaminationTechniques()
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
        elseif arg1 == "korthia" then
            ShowKorthiaDailyCaps()
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
