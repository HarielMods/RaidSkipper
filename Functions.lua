-- local BSRS, L = unpack((select(2, ...)))
local addonName, BSRS = ...


-- Blizz functions
local GetDifficultyInfo, GetInstanceInfo, GetQuestObjectiveInfo, GetRealZoneText, InRaid = GetDifficultyInfo, GetInstanceInfo, GetQuestObjectiveInfo, GetRealZoneText, InRaid

-- Icons
local ICON_DONE = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local ICON_NOTDONE = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"
local ICON_PROGRESS = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:0|t"
local ICON_QUEST = "|TInterface\\Minimap\\Tracking\\TrivialQuests:0|t"

local ICON_QUEST_CHECK_MARK = '\124A:UI-LFG-ReadyMark:14:14\124a'
local ICON_QUEST_TURN_IN = '\124A:QuestTurnin:14:14\124a'
local ICON_QUEST_NORMAL = '\124A:QuestNormal:14:14\124a'
local ICON_QUEST_DAILY = '\124A:QuestDaily:14:14\124a'
local ICON_QUEST_REPEATABLE = '\124A:QuestRepeatable:14:14\124a'
local ICON_QUEST_INVISIBLE = '\124A:QuestTurnin:14:14\124a'


-- Difficulty IDs used from https://wowpedia.fandom.com/wiki/DifficultyID
local DIFFICULTY_MYTHIC_ID = 16
local DIFFICULTY_HEROIC_ID = 15
local DIFFICULTY_NORMAL_ID = 14

local DIFFICULTY_MYTHIC_TEXT = ({GetDifficultyInfo(DIFFICULTY_MYTHIC_ID)})[1]
local DIFFICULTY_HEROIC_TEXT = ({GetDifficultyInfo(DIFFICULTY_HEROIC_ID)})[1]
local DIFFICULTY_NORMAL_TEXT = ({GetDifficultyInfo(DIFFICULTY_NORMAL_ID)})[1]

local difficulty_text = {
    [DIFFICULTY_MYTHIC_ID] = DIFFICULTY_MYTHIC_TEXT,
    [DIFFICULTY_HEROIC_ID] = DIFFICULTY_HEROIC_TEXT,
    [DIFFICULTY_NORMAL_ID] = DIFFICULTY_NORMAL_TEXT
}

-- Database Functions

local function saveSkip(raid, skip, status)
    local playerName = UnitName("player");
    local _, classfilename, _ = UnitClass(playerName);
    local realmName = GetRealmName();
    local playerRealm = playerName .. "-" .. realmName;
    local color = nil

    if classfilename ~= nil then
        color = RAID_CLASS_COLORS[classfilename]
    end
    local cc = color or {colorStr = 'ffff0000'}
    
    -- Rename existing playername to one with realm
    if raid_skipper_db[playerName] ~= nil and raid_skipper_db[playerRealm] == nil then 
        raid_skipper_db[playerRealm] = raid_skipper_db[playerName];
        raid_skipper_db[playerName] = nil;
    end

    if raid_skipper_db[playerRealm] == nil or raid_skipper_db[playerRealm]["version"] == nil then
        raid_skipper_db[playerRealm] = {
            ["version"] = 110,
            ["class"] = classfilename,
            ["color"] = cc.colorStr,
            ["raids"] = { }
        }
    end

    raid_skipper_db[playerRealm]["raids"][raid .. " - " .. skip] = {
        ["name"] = raid,
        ["status"] = status,
        ["difficulty"] = skip
    }   
end

local function showMySkips()
    for char, values in pairs(raid_skipper_db) do
        local color = values.color;
        print("\124c" .. color .. char)
        for raid, info in pairs(values.raids) do
            local status_color = "ffffff00";
            if info.status == COMPLETE then
                status_color = "ff00ff00"
            end
            print("     \124c" .. status_color .. "- " .. info.name .. " - " .. info.difficulty .. " (" .. info.status .. ")")
        end
    end
end

-- TEXT FUNCTIONS

local function TextColor(color, msg)
    local colors = {
        [COMPLETE] = "ff00ff00",
        [INCOMPLETE] = "ffff0000",
        [IN_PROGRESS] = "ff00ffff",
        ["yellow"] = "ffffff00",
        ["red"] = "ffff0000",
        ["green"] = "ff00ff00",
        ["blue"] = "ff0000ff",
    }
    return "\124c" .. colors[color] .. msg .. "\124r"
end

local function normal(text)
    if text == nil then return "" end
    return NORMAL_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function highlight(text)
    if text == nil then return "" end
    return HIGHLIGHT_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function muted(text)
    if text == nil then return "" end
    return DISABLED_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function yellow_text(text)
    if text == nil then return "" end
    return YELLOW_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function red_text(text)
    if text == nil then return "" end
    return RED_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function green_text(text)
    if text == nil then return "" end
    return GREEN_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

local function bn_text(text)
    if text == nil then return "" end
    return BATTLENET_FONT_COLOR_CODE .. text .. FONT_COLOR_CODE_CLOSE;
end

-- QUEST FUNCTIONS

local function quest_status(id, refresh, heroRealm)
    if not id then return 0 end

    local savedStatus = 0
    if refresh then
        savedStatus = C_QuestLog.IsQuestFlaggedCompleted(id) and 2
        if not savedStatus then
            savedStatus = C_QuestLog.IsOnQuest(id) and 1
        end
    else
        heroRealm = heroRealm or BSRS.playerRealm

        savedStatus = BSRaidSkipperData["heroes"][heroRealm]["quests"][id]["status"] or 0
    end

    return savedStatus

    -- if C_QuestLog.IsQuestFlaggedCompleted(id) then
    -- if savedStatus then
    --     return 2 -- COMPLETED
    -- elseif C_QuestLog.IsOnQuest(id) then
    --     return 1 -- IN_PROGRESS
    -- else
    --     return 0 -- NOT_STARTED
    -- end
end

local function achievement_status(id, heroRealm)
    -- Is achievement completed by this toon?
    local completedAccount = ({GetAchievementInfo(id)})[4]
    local completedByMe = ({GetAchievementInfo(id)})[13]
    
    if completedAccount then
        return 2 -- COMPLETED
    else
        return 0 -- NOT_STARTED
    end
end

-- DISPLAY FUNCTIONS

function BSRS:Debug(text)
    if BSRS.debug then
        print(red_text("BSRaidSkipper: ") .. tostring(text))
    end
end

function BSRS:Print(text)
    print(muted("BSRaidSkipper: ") .. tostring(text))
end

local function get_icon(icon)
	if not icon then icon = [[Interface\Icons\Temp]] end
	return "  |T" .. icon .. ":0:4|t "
end

local function quest_title(questId)
    local title = C_QuestLog.GetTitleForQuestID(questId)
    if title ~= nil then
        return title
    end
    return "No title yet"
end

local function quest_progress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
    return fulfilled .. "/" .. required
end

-- local function ShowQuestInfo(id, difficulty, raidName)
--     if (quest_status(id) == 2) then
--         -- Player has completed this quest
--         saveSkip(raidName, difficulty, COMPLETE)
--         return RS.TextColor(COMPLETE, difficulty)
--     elseif (IsQuestInQuestLog(id)) then
--         saveSkip(raidName, difficulty, IN_PROGRESS .. " " .. ShowQuestProgress(id))
--         -- Player has this quest in their quest log
--         return RS.TextColor(IN_PROGRESS, difficulty .. " " .. ShowQuestProgress(id))
--     else
--         -- Player has not completed this quest does not have quest in the quest log
--         return RS.TextColor(INCOMPLETE, difficulty)
--     end
-- end

local function ShowAchievementInfo(id)
    if (achievement_status(id) == 2) then
        -- Player has completed achievement
        BSRS:Print(COMPLETE)
    else
        BSRS:Print(INCOMPLETE)
    end
end

local function ShowRaidSkip(raid)
    local line = "  " .. GetRealZoneText(raid.instanceId) .. ": "
    -- Battle of Dazar'alor uses an Achievement, not quests
    if raid.instanceId == 2070 then
        local completed = IsAchievementComplete(raid.achievementId)
        if completed then
            line = line .. RS.TextColor(COMPLETE, COMPLETE)
        else
            line = line .. RS.TextColor(INCOMPLETE, INCOMPLETE)
        end
    else
        -- Mythic
        line = line .. ShowQuestInfo(raid.mythicId, PLAYER_DIFFICULTY6, GetRealZoneText(raid.instanceId))
        -- Heroic, if Mythic is complete Heroic and Normal can be skipped
        if (not IsQuestComplete(raid.mythicId) and raid.heroicId ~= nil) then
            line = line .. " " .. ShowQuestInfo(raid.heroicId, PLAYER_DIFFICULTY2, GetRealZoneText(raid.instanceId))
            -- Normal, if Heroic is complete Normal can be skipped
            if (not IsQuestComplete(raid.heroicId) and raid.normalId ~= nil) then
                line = line .. " " .. ShowQuestInfo(raid.normalId, PLAYER_DIFFICULTY1, GetRealZoneText(raid.instanceId))
            end
        end
    end
    RS:Print(line)
end

local function ShowExpansion(data)
    RS:Print(data.name)
    for key, raid in ipairs(data.raids) do
        ShowRaidSkip(raid)
    end
end

local function ShowRaid(data)
    ShowRaidSkip(data)
end

local function ShowExpansions()
    for name, data in ipairs(Engine.raid_skip_quests) do
        ShowExpansion(data)
    end
end

local function ShowKey()
    Print("Key: " .. TextColor("blue", IN_PROGRESS) .. " " .. TextColor("green", COMPLETE) .. " " .. TextColor("red", INCOMPLETE))
    Print("Use '/rs help' to display more help")
end

local function PrintHelp()
    BSRS:Print("slash commands:")
    BSRS:Print("  /rs wod --> Warlords of Draenor")
    BSRS:Print("  /rs legion --> Legion")
    BSRS:Print("  /rs bfa --> Battle for Azeroth")
    BSRS:Print("  /rs sl --> Shadowlands")
    BSRS:Print("  /rs df --> Dragonflight")
    BSRS:Print("  /rs list --> List my chars status")
end

local function InRaid() 
    local instanceType = select(2, GetInstanceInfo())
    return instanceType == "raid"
end

local function ShowCurrentRaid() 
    local instanceID = select(8, GetInstanceInfo())
    ShowRaidInstanceById(instanceID)
end


-- Test functions

local function ChtMsgTablePerLine(tbl)
    for k, v in pairs(tbl) do
        BSRS:Print(v)
    end
end

local function FormatSingleQuestStatus(status, questId, difficultyId, title)
    local str = ""
    local brf_ids = {37031, 37030, 37029} -- these quests already include difficulty in the title

    -- this is not working
    if brf_ids[questId] == nil then
        title = "(" .. difficulty_text[difficultyId] .. ") " .. title
    end

    if status == 2 then
        str = ICON_DONE .. yellow_text(title)
    elseif status == 1 then
        str = ICON_PROGRESS .. green_text(title .. " (" .. quest_progress(questId) .. ")")
    else
        str = ICON_NOTDONE .. muted(title)
    end
    
    -- if BSRS.debug then
    --     str = " (" .. questId .. ")" .. str
    -- end
    return str
end

local function GetRaidQuestsStatuses(mythicQuestId, heroicQuestId, normalQuestId, heroRealm)
    local output = {}
    local mythicQuestStatus = quest_status(mythicQuestId, false, heroRealm)
    local mythicQuestTitle = quest_title(mythicQuestId)
    
    -- BSRS:Print(FormatSingleQuestStatus(mythicQuestStatus, mythicQuestId, DIFFICULTY_MYTHIC_ID, mythicQuestTitle))
    table.insert(output, FormatSingleQuestStatus(mythicQuestStatus, mythicQuestId, DIFFICULTY_MYTHIC_ID, mythicQuestTitle))
    -- table.insert(BSRS.PLAYER_WINDOW_CONTENT, FormatSingleQuestStatus(mythicQuestStatus, mythicQuestId, DIFFICULTY_MYTHIC_ID, mythicQuestTitle))

    if mythicQuestStatus < 2 then
        -- show heroic
        local heroicQuestStatus = quest_status(heroicQuestId, false, heroRealm)
        local heroicQuestTitle = quest_title(heroicQuestId)
        -- BSRS:Print(FormatSingleQuestStatus(heroicQuestStatus, heroicQuestId, DIFFICULTY_HEROIC_ID, heroicQuestTitle))
        table.insert(output, FormatSingleQuestStatus(heroicQuestStatus, heroicQuestId, DIFFICULTY_HEROIC_ID, heroicQuestTitle))
        -- table.insert(BSRS.PLAYER_WINDOW_CONTENT, FormatSingleQuestStatus(heroicQuestStatus, heroicQuestId, DIFFICULTY_HEROIC_ID, heroicQuestTitle))

        if heroicQuestStatus < 2 then                
            -- show normal
            local normalQuestStatus = quest_status(normalQuestId, false, heroRealm)
            local normalQuestTitle = quest_title(normalQuestId)
            -- BSRS:Print(FormatSingleQuestStatus(normalQuestStatus, normalQuestId, DIFFICULTY_NORMAL_ID, normalQuestTitle))
            table.insert(output, FormatSingleQuestStatus(normalQuestStatus, normalQuestId, DIFFICULTY_NORMAL_ID, normalQuestTitle))
            -- table.insert(BSRS.PLAYER_WINDOW_CONTENT, FormatSingleQuestStatus(normalQuestStatus, normalQuestId, DIFFICULTY_NORMAL_ID, normalQuestTitle))
        end
    end
    return output
end

local function GetAchievementStatus(achievementId, heroRealm)
    local status = ""
    -- Siege of Orgimmar and Battle of Dazar'alor
    local achievement_title = ({GetAchievementInfo(achievementId)})[2]
    if achievement_status(achievementId, heroRealm) == 2 then
        -- BSRS:Print(ICON_DONE .. yellow_text(achievement_title))
        status = " " .. ICON_DONE .. yellow_text(achievement_title)
        -- table.insert(BSRS.PLAYER_WINDOW_CONTENT, ICON_DONE .. yellow_text(achievement_title))
    else
        -- BSRS:Print(ICON_NOTDONE .. muted(achievement_title))
        status = " " .. ICON_NOTDONE .. muted(achievement_title)
        -- table.insert(BSRS.PLAYER_WINDOW_CONTENT, ICON_NOTDONE .. muted(achievement_title))
    end
    return status
end

function BSRS:GetHeroStatuses(heroRealm)
    local hero = heroRealm or BSRS.playerRealm
    local statuses = {}
    for expansionIndex, expansionData in ipairs(BSRS.raid_skip_quests) do -- loop through expansions        
        local info = GetExpansionDisplayInfo(expansionData.expid)
        
        -- table.insert(statuses, get_icon(info.logo) .. " " .. bn_text(expansionData.name))
        table.insert(statuses,  bn_text(expansionData.name).. " " .. get_icon(info.logo))

        if expansionData.raids ~= nil then
            local raids = expansionData.raids
            local sortedRaidIds = {}
            for k in pairs(raids) do
                table.insert(sortedRaidIds, k)
            end
            table.sort(sortedRaidIds)
            
            for _, raidId in pairs(sortedRaidIds) do -- loop through raids
                table.insert(statuses, highlight(GetRealZoneText(raidId)))
                if raids[raidId].achievementId ~= nil then
                    -- skip is an account wide achievement
                    local achievementStatus = GetAchievementStatus(raids[raidId].achievementId, heroRealm)
                    table.insert(statuses, achievementStatus)
                else
                    -- skip is a quest or multiple quests
                    for _, questGroupData in ipairs(raids[raidId].questGroups) do -- loop through quests in raids
                        local raidQuestStatuses = GetRaidQuestsStatuses(questGroupData.mythicId, questGroupData.heroicId, questGroupData.normalId, heroRealm)
                        for _, v in ipairs(raidQuestStatuses) do
                            table.insert(statuses, v)
                        end
                    end
                end
                table.insert(statuses, "")
            end
        end
        table.insert(statuses, "")
    end
    return statuses
end

local function ChtMsgPlayerStatus()
    BSRS:Debug("ChtMsgPlayerStatus()")
    local statuses = BSRS:GetHeroStatuses()
    for _, v in ipairs(statuses) do
        BSRS:Print(v)
    end
end

local function setContains(set, key)
    return set[key] ~= nil
end

-- this will no longer print
local function ShowRaidInstanceById(id)
    local output = ""
    for _, expansionData in ipairs(BSRS.raid_skip_quests) do
        for raidId, raidData in pairs(expansionData.raids) do
            if (raidId == id) then
                BSRS:Print(GetRealZoneText(raidId))
                if raidData.achievementId ~= nil then
                    GetAchievementStatus(raidData.achievementId)
                elseif raidData.questGroups ~= nil then
                    for _, questGroup in ipairs(raidData.questGroups) do
                        GetRaidQuestsStatuses(questGroup.mythicId, questGroup.heroicId, questGroup.normalId)
                    end
                end
            end
        end
    end
end

function BSRS:PreLoadQuestTitles()
    BSRS:Debug("BSRS:PreLoadQuestTitles()")
    for _, questId in ipairs(BSRS.quests) do
        local title = C_QuestLog.GetTitleForQuestID(questId)
        BSRS:Debug(tostring(questId) .. " " .. tostring(title))
    end
end

function BSRS:InitPlayerData()
    local playerQuestsData = {}
    for _, questId in ipairs(BSRS.quests) do
        local status = quest_status(questId, true)
        playerQuestsData[questId] = {
            ["status"] = status,
            ["progress"] = nil
        }

        if status == 1 then
            local progress = quest_progress(questId)
            playerQuestsData[questId]["progress"] = progress
        end
    end

    if BSRaidSkipperData == nil then
        BSRaidSkipperData = {}
    end

    if BSRaidSkipperData["heroes"] == nil then
        BSRaidSkipperData["heroes"] = {}
    end

    if BSRaidSkipperData["heroes"][BSRS.playerRealm] == nil then
        BSRaidSkipperData["heroes"][BSRS.playerRealm] = {}
    end

    BSRaidSkipperData["heroes"][BSRS.playerRealm] = {
        ["version"] = 110,
        ["name"] = BSRS.playerName,
        ["realm"] = BSRS.realmName,
        ["class"] = BSRS.playerClass,
        ["faction"] = BSRS.playerFaction,
        ["color"] = BSRS.playerColor,
        ["quests"] = playerQuestsData
    }
end

-- Handler Functions

-- TODO: Add quest turn in handler: QUEST_TURNED_IN
-- TODO: Add achievement completed handler: 

function BSRS:OnChangeZone()
    -- TODO: limit to only our raids
    local in_raid = InRaid()
    if in_raid then
        local instanceID = select(8, GetInstanceInfo())
        ShowRaidInstanceById(instanceID)
    end
end

function BSRS:EventHandler(args)

end

function BSRS:SlashHandler(args)
    BSRS:Debug("BSRS:SlashHandler()")
    

    -- if type(args) == "table" then
    --     BSRS:Debug("args: is table")
    -- else
    --     BSRS:Debug("args: " .. tostring(args))
    -- end


    -- local arg1 = BSRS.AceAddon:GetArgs(args, 1)
    -- BSRS:Debug(arg1)


    -- ChtMsgPlayerStatus()
    BSRS:OpenHeroes()
    
    do return end


    if arg1 then
        arg1 = arg1:lower()
        
        if arg1 == "all" then
            ChtMsgPlayerStatus()
        elseif arg1 == "wod" or arg1 == LE_EXPANSION_WARLORDS_OF_DRAENOR then
            ShowExpansion(Engine.raid_skip_quests[1])
        elseif arg1 == "legion" or arg1 == LE_EXPANSION_LEGION then
            ShowExpansion(Engine.raid_skip_quests[2])
        elseif arg1 == "bfa" or arg1 == LE_EXPANSION_BATTLE_FOR_AZEROTH then
            ShowExpansion(Engine.raid_skip_quests[3])
        elseif arg1 == "sl" or arg1 == LE_EXPANSION_SHADOWLANDS then
            ShowExpansion(Engine.raid_skip_quests[4])
        elseif arg1 == "df" or arg1 == LE_EXPANSION_DRAGONFLIGHT then
            ShowExpansion(Engine.raid_skip_quests[5])
        -- elseif arg1 == "list" then
        --     update_quest_data()
        -- elseif arg1 == "save" then
        --     update_quest_data()
        else
            PrintHelp()
        end
    else
        if InRaid() then
            ShowCurrentRaid()
        else
            ChtMsgPlayerStatus()
        end
    end

end

function IsAchievementCompleteHandler(args)
    -- local arg1 = RS.AceAddon:GetArgs(args, 1)
    local arg1 = BSRS:GetArgs(args, 1)

    if arg1 then
        ShowAchievementInfo(arg1)
    end
end

function IsQuestCompleteHandler(args)
    -- local arg1 = RS.AceAddon:GetArgs(args, 1)
    local arg1 = BSRS:GetArgs(args, 1)

    if arg1 then
        local quest = GetTitleForQuestID(arg1)
        if quest_status(arg1) == 2 then
            RS:Print(ICON_DONE .. " " .. quest .. " " .. COMPLETE)
        elseif quest_status(arg1) == 1 then
            RS:Print(ICON_PROGRESS .. " " .. quest .. " " .. IN_PROGRESS)
        else
            RS:Print(ICON_NOTDONE .. " " .. quest .. " " .. INCOMPLETE)
        end
    end
end