------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

-- TODO: add quests to tracker upon entering raid
-- TODO: create settings screen
    -- settings option: add quest to tracker upon entering raid


local _, RaidSkipper = ...
addon_name = "RaidSkipper"
RaidSkipper.debug = false
RaidSkipper.DBVersion = 200


-- localize Blizzard functions
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount
local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local GetNumQuestObjectives = C_QuestLog.GetNumQuestObjectives
local GetRealZoneText = GetRealZoneText
local GetInstanceInfo = GetInstanceInfo
local GetRealmName = GetRealmName
local GetQuestObjectiveInfo = GetQuestObjectiveInfo
local GetAchievementInfo = GetAchievementInfo
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitName = UnitName
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitRace = UnitRace
local PLAYER_DIFFICULTY1 = PLAYER_DIFFICULTY1
local PLAYER_DIFFICULTY2 = PLAYER_DIFFICULTY2
local PLAYER_DIFFICULTY6 = PLAYER_DIFFICULTY6

local ICON_COMPLETE = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local ICON_INCOMPLETE = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"
local ICON_IN_PROGRESS = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:0|t"
local ICON_QUEST = "|TInterface\\Minimap\\Tracking\\TrivialQuests:0|t"

local ACCOUNT_WIDE_DB_KEY = "accountWideData"
local DB_VERSION_KEY = "DBVersion"

RaidSkipper.CurrentPlayer = {}

RaidSkipper.defaultPlayerData = {
    ["version"] = RaidSkipper.DBVersion,
    ["playerName"] = "",
    ["realmName"] = "",
    ["playerRealm"] = "",
    ["class"] = "",
    ["classFilename"] = "",
    ["color"] = "",
    ["level"] = "",
    ["race"] = "",
    ["raceFilename"] = "",
    ["quests"] = {}
}

RaidSkipper.accountWideData = {
    ["achievements"] = { 
        8482, -- Siege of Orgrimmar
        13314 -- Battle of Dazar'alor
    }
}

-- DATABASE -------------------------------------------------------------------

-- Database namespace
local DB = {}

function DB.init()
    if raid_skipper_db == nil then
        raid_skipper_db = {
            ["characters"] = {},
            [ACCOUNT_WIDE_DB_KEY] = {},
            ["DBVersion"] = RaidSkipper.DBVersion
        }
    end
    
    if raid_skipper_db["quests"] ~= nil then
        raid_skipper_db["quests"] = nil
    end
    
    if raid_skipper_db["requestedQuests"] ~= nil then
        raid_skipper_db["requestedQuests"] = nil
    end

    if raid_skipper_db["characters"] == nil then
        raid_skipper_db["characters"] = { }
    end

    if raid_skipper_db[ACCOUNT_WIDE_DB_KEY] == nil then
        raid_skipper_db[ACCOUNT_WIDE_DB_KEY] = { }
    end

    if raid_skipper_db[DB_VERSION_KEY] == nil then
        raid_skipper_db[DB_VERSION_KEY] = RaidSkipper.DBVersion
    end
    
    DB.migrations()
end

function DB.migrations()

    if raid_skipper_db["DBVersion"] == 200 then
        return
    end

    -- First ever stored variables for current character
    if raid_skipper_db[playerName] ~= nil and raid_skipper_db[playerRealm] == nil then
        raid_skipper_db["characters"][playerRealm] = raid_skipper_db[playerName];
        raid_skipper_db[playerName] = nil;
    end

    -- Move top level characters to raid_skipper_db["characters"]
    for k, v in pairs(raid_skipper_db) do
        RaidSkipper:Debug("raid_skipper_db["..k.."]")

        if k ~= "quests" and k ~= "requestedQuests" and k ~= "characters" then
            raid_skipper_db["characters"][k] = v
            raid_skipper_db[k] = nil            
        end
    end

    if raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"] == nil then
        raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"] = {}
    end

    for character, characterData in ipairs(raid_skipper_db["characters"]) do
        for quest, questData in ipairs(characterData["quests"]) do
            if raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest] == nil then
                raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest] = {
                    ["status"] = questData["status"],
                    ["completedBy"] = {}
                }
            end
            if raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest]["completedBy"] == nil then
                raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest]["completedBy"] = {}
            end
            
            if status == COMPLETE then
                raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest] = {
                    ["status"] = COMPLETE,
                    ["completedBy"] = table.insert(raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest]["completedBy"], character)
                }
            elseif status == IN_PROGRESS then
                raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest] = {
                    ["status"] = IN_PROGRESS,
                    ["inProgressBy"] = table.insert(raid_skipper_db[ACCOUNT_WIDE_DB_KEY]["quests"][quest]["completedBy"], {character, characterData["quests"][quest]["statusText"]})
                }
            else
            end
        end
    end
end

function DB.getCharacters()
    if raid_skipper_db["characters"] == nil then
        raid_skipper_db["characters"] = {}
        for k, v in pairs(raid_skipper_db) do
            if k ~= "quests" and k ~= "requestedQuests" and k ~= "characters" then
                raid_skipper_db["characters"][k] = v
                raid_skipper_db[k] = nil
            end
        end
    end
    return raid_skipper_db["characters"]
end

function DB.getCharacterByPlayerRealm(playerRealm)
    local characters = DB.getCharacters()
    if characters[playerRealm] ~= nil then
        return characters[playerRealm]
    end
    return RaidSkipper.defaultPlayerData
end

function DB.saveCharacterData(key, data)
    if raid_skipper_db["characters"] == nil then
        raid_skipper_db["characters"] = {}
    end
    raid_skipper_db["characters"][key] = data
end

-- Deprecated: Save skip status for a raid
local function saveSkip(raid, skip, status)
    local playerName = UnitName("player");
    local class, classfilename, _ = UnitClass(playerName);
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

-- Deprecated: Show completed skips for all characters
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

-- UTILITY FUNCTIONS

RaidSkipper.Print = function(self, text)
    print("|cFF00FF00" .. addon_name .. ":|r " .. text)
end

RaidSkipper.Debug = function(self, text)
    if RaidSkipper.debug then
        print("|cFFFF0000" .. addon_name .. ":|r " .. text)
    end
end

RaidSkipper.TextColor = function(color, msg)
    local colors = {
        [COMPLETE] = "ff00ff00",
        [INCOMPLETE] = "ffff0000",
        [IN_PROGRESS] = "ffffff00", -- "ff00ffff",
        ["yellow"] = "ffffff00",
        ["red"] = "ffff0000",
        ["green"] = "ff00ff00",
        ["blue"] = "ff0000ff",
        ["EXPANSION_NAME"] = "ff00ffff"
    }
    return "\124c" .. colors[color] .. msg .. "\124r"
end

-- Check if a table contains an element
RaidSkipper.Contains = function(table, element)
    return table[element] ~= nil
end

-- Split a string into a table
RaidSkipper.Split = function(self, input, sep)
    if input == nil then return {} end
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- Get arguments from a string or table
RaidSkipper.GetArgs = function(args)
    if type(args) == "table" then
        return args
    elseif type(args) == "string" then
        args = RaidSkipper:Split(args, " ")
    else
        return {}
    end
end

-- Get argument from a string or table
RaidSkipper.GetArg = function(args, pos)
    local a = RaidSkipper:GetArgs(args)
    if a[pos] ~= nil then
        return a[pos]
    else
        return nil
    end
end

local function GetClassColor(classFilename)
    if RAID_CLASS_COLORS[classFilename] then
        return RAID_CLASS_COLORS[classFilename].colorStr
    end
    return 'ffff0000'
end

local function GetPlayerRealmName(playerName, realmName)
    return playerName .. "-" .. realmName
end

local function InRaid() 
    local instanceType = select(2, GetInstanceInfo())
    return instanceType == "raid"
end

-- QUEST AND ACHIEVEMENT FUNCTIONS

local function IsQuestComplete(id)
    return id and IsQuestFlaggedCompleted(id)
end

local function IsQuestInQuestLog(id)
    return id and (GetLogIndexForQuestID(id) ~= nil)
end

local function IsAchievementComplete(id)
    if (id ~= nil) then
        if type(id) ~= "number" then
            id = tonumber(id)
        end
        -- id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
        local _, _, _, completed, _, _, _, _, _, _, _, _, _, _, _ = GetAchievementInfo(id)
        return completed
    else
        return nil
    end
end

-- CHAT DISPLAY FUNCTIONS

local function ShowQuestProgress(id)
    -- TODO: Expand for multiple objectives

    -- text, objectiveType, finished, fulfilled, required
    local _, _, _, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
    return fulfilled .. "/" .. required
end

local function ShowQuestInfo(id, difficulty, raidName)
    if (IsQuestComplete(id)) then
        -- Player has completed this quest
        --(raidName, difficulty, COMPLETE)
        return RaidSkipper.TextColor(COMPLETE, difficulty)
    elseif (IsQuestInQuestLog(id)) then
        --saveSkip(raidName, difficulty, IN_PROGRESS .. " " .. ShowQuestProgress(id))
        -- Player has this quest in their quest log
        local numQuestObjectives = GetNumQuestObjectives(id)
        if numQuestObjectives > 0 then
            local objectives = {}
            for i = 1, numQuestObjectives do
                local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, i, false)
                table.insert(objectives, RaidSkipper.TextColor(IN_PROGRESS, " " .. text))
            end
            if objectives == nil or #objectives == 0 then
                return RaidSkipper.TextColor(IN_PROGRESS, difficulty)
            else
                return table.concat(objectives)
            end
        else
            return RaidSkipper.TextColor(IN_PROGRESS, difficulty)
        end
        return RaidSkipper.TextColor(IN_PROGRESS, difficulty .. " " .. ShowQuestProgress(id))
    else
        -- Player has not completed this quest does not have quest in the quest log
        return RaidSkipper.TextColor(INCOMPLETE, difficulty)
    end
end

local function ShowAchievementInfo(id)
    if (IsAchievementComplete(id)) then
        -- Player has completed achievement
        RaidSkipper:Print(COMPLETE)
    else
        RaidSkipper:Print(INCOMPLETE)
    end
end

local function ShowRaidSkip(raid)
    local line = "  " .. GetRealZoneText(raid.instanceId) .. ": "
    -- Battle of Dazar'alor uses an Achievement, not quests
    if raid.instanceId == 2070 then
        local completed = IsAchievementComplete(raid.achievementId)
        if completed then
            line = line .. RaidSkipper.TextColor(COMPLETE, COMPLETE)
        else
            line = line .. RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE)
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
    RaidSkipper:Print(line)
    return line
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
    Print("Key: " .. TextColor("blue", IN_PROGRESS) .. " " .. TextColor("green", COMPLETE) .. " " .. TextColor("red", INCOMPLETE))
    Print("Use '/rs help' to display more help")
end

local function PrintHelp()
    RaidSkipper:Print("slash commands:")
    RaidSkipper:Print("  use /rs or /raidskipper")
    RaidSkipper:Print("  /rs wod --> Warlords of Draenor")
    RaidSkipper:Print("  /rs legion --> Legion")
    RaidSkipper:Print("  /rs bfa --> Battle for Azeroth")
    RaidSkipper:Print("  /rs sl --> Shadowlands")
    RaidSkipper:Print("  /rs df --> Dragonflight")
    RaidSkipper:Print("  /rs ww --> War Within")
    RaidSkipper:Print("  /rs list --> List my chars status")
    RaidSkipper:Print("  /rs show --> Open RaidSkipper window")
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

local function ShowCurrentRaid() 
    local instanceID = select(8, GetInstanceInfo())
    ShowRaidInstanceById(instanceID)
end

-- Event Hooks ----------------------------------------------------------------

local function OnChangeZone()
    local in_raid = InRaid()
    local instanceID = select(8, GetInstanceInfo())
    if in_raid then
        ShowRaidInstanceById(instanceID)
    end
end

local function OnRaidInstanceWelcome()
    RaidSkipper:Debug("OnRaidInstanceWelcome")
    local instanceID = select(8, GetInstanceInfo())
    ShowRaidInstanceById(instanceID)
end

local function GetQuestStatusFromGame(questId)
    local questComplete, inLog = IsQuestComplete(questId), IsQuestInQuestLog(questId)
    local status, statusText = "", ""
    if questComplete then
        status = COMPLETE
    elseif inLog then
        status = IN_PROGRESS
        
        local numQuestObjectives = GetNumQuestObjectives(questId)
        local objectives = {}
        for i = 1, numQuestObjectives do
            local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questId, i, false)
            table.insert(objectives, RaidSkipper.TextColor(IN_PROGRESS, " " .. text))
            -- statusText = fulfilled .. "/" .. required
        end
        local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questId, 1, false)
        statusText = fulfilled .. "/" .. required

        -- Get in progress status
        -- local numQuestObjectives = GetNumQuestObjectives(questId)
        -- if numQuestObjectives > 0 then
        --     local objectives = {}
        --     for i = 1, numQuestObjectives do
        --         local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questId, i, false)
        --         table.insert(objectives, RaidSkipper.TextColor(IN_PROGRESS, " " .. text))
        --     end
        --     if objectives == nil or #objectives == 0 then
        --         statusText = RaidSkipper.TextColor(IN_PROGRESS, IN_PROGRESS)
        --     else
        --         statusText = table.concat(objectives, "\n")
        --     end
        -- else
        --     statusText = RaidSkipper.TextColor(IN_PROGRESS, difficulty)
        -- end
    else
        status = INCOMPLETE
    end

    return {
        ["status"] = status,
        ["statusText"] = statusText
    }
end

local function GetAchievementStatusFromGame(achievementId)
    if (IsAchievementComplete(achievementId)) then
        -- Player account has completed achievement
        return COMPLETE
    else
        return INCOMPLETE
    end
end

-- Save the current character's raid skip status
local function SaveCurrentCharacterData()
    RaidSkipper:Debug("SaveCurrentCharacterData")

    local playerName = UnitName("player");
    local class, classFilename, _ = UnitClass(playerName);
    local classColor = GetClassColor(classfilename)
    local realmName = GetRealmName();
    local playerRealm = GetPlayerRealmName(playerName, realmName)
    local level = UnitLevel("player")
    local race, raceFilename = UnitRace("player")

    RaidSkipper.CurrentPlayer = {
        ["version"] = RaidSkipper.DBVersion,
        ["playerName"] = playerName,
        ["realmName"] = realmName,
        ["playerRealm"] = playerRealm,
        ["class"] = class,
        ["classFilename"] = classFilename,
        ["color"] = classColor,
        ["level"] = level,
        ["race"] = race,
        ["raceFilename"] = raceFilename,
        ["quests"] = {}
    }

    -- Achievement statuses
    if raid_skipper_db["accountWideData"] == nil then
        raid_skipper_db["accountWideData"] = {}
    end
    if raid_skipper_db["accountWideData"]["achievements"] == nil then
        raid_skipper_db["accountWideData"]["achievements"] = {}
    end
    for key, achievementId in ipairs(RaidSkipper.accountWideData.achievements) do
        if raid_skipper_db["accountWideData"]["achievements"][achievementId] == nil then
            raid_skipper_db["accountWideData"]["achievements"][achievementId] = INCOMPLETE
        end
        local achievementStatus = GetAchievementStatusFromGame(achievementId)
        raid_skipper_db["accountWideData"]["achievements"][achievementId] = achievementStatus
    end

    -- Quest statuses
    for name, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        for key, raid in ipairs(expansion.raids) do
            -- Exception raids: Battle of Dazar'alor, Siege of Orgrimmar
            -- if raid.instanceId == 2070 or raid.instanceId == 1136 then
            --     RaidSkipper.CurrentPlayer["achievements"] = {
            --         [raid.achievementId] = GetAchievementStatusFromGame(raid.achievementId)
            --     }
            --     RaidSkipper.CurrentPlayer["achievements"][raid.achievementId] = {
            --         ["status"] = GetAchievementStatusFromGame(raid.achievementId)
            --     }
            -- else
                -- Mythic
                if raid.mythicId then
                    -- GetQuestTitle(raid.mythicId)
                    RaidSkipper.CurrentPlayer["quests"][raid.mythicId] = GetQuestStatusFromGame(raid.mythicId)
                end
                -- Heroic
                if raid.heroicId then
                    -- GetQuestTitle(raid.heroicId)
                    RaidSkipper.CurrentPlayer["quests"][raid.heroicId] = GetQuestStatusFromGame(raid.heroicId)
                end
                -- Normal
                if raid.normalId then
                    -- GetQuestTitle(raid.normalId)
                    RaidSkipper.CurrentPlayer["quests"][raid.normalId] = GetQuestStatusFromGame(raid.normalId)
                end
            -- end
        end
    end
    DB.saveCharacterData(playerRealm, RaidSkipper.CurrentPlayer)
end

-- UI -------------------------------------------------------------------------

local function CreateWindow()
    local frame = CreateFrame("Frame", "RaidSkipperFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(600, 500)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("RaidSkipper")

    -- Close button
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

    -- Character select dropdown
    frame.CharacterSelect = CreateFrame("Frame", "CharacterSelect", frame, "UIDropDownMenuTemplate")
    frame.CharacterSelect:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -30)
    UIDropDownMenu_SetWidth(frame.CharacterSelect, 150)
    UIDropDownMenu_Initialize(frame.CharacterSelect, RaidSkipper.CharacterSelect_Menu)
    UIDropDownMenu_SetText(frame.CharacterSelect, "Select Character")

    -- Expansion select dropdown
    frame.ExpansionSelect = CreateFrame("Frame", "ExpansionSelect", frame, "UIDropDownMenuTemplate")
    frame.ExpansionSelect:SetPoint("TOPLEFT", frame.CharacterSelect, "TOPRIGHT", -20, 0)
    UIDropDownMenu_SetWidth(frame.ExpansionSelect, 150)
    UIDropDownMenu_Initialize(frame.ExpansionSelect, RaidSkipper.ExpansionSelect_Menu)
    UIDropDownMenu_SetText(frame.ExpansionSelect, "Select Expansion")

    -- Raid select dropdown
    frame.RaidSelect = CreateFrame("Frame", "RaidSelect", frame, "UIDropDownMenuTemplate")
    frame.RaidSelect:SetPoint("TOPLEFT", frame.ExpansionSelect, "TOPRIGHT", -20, 0)
    UIDropDownMenu_SetWidth(frame.RaidSelect, 150)
    UIDropDownMenu_Initialize(frame.RaidSelect, RaidSkipper.RaidSelect_Menu)
    UIDropDownMenu_SetText(frame.RaidSelect, "Select Raid")

    -- Raid status text area
    frame.textBlob = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.textBlob:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
    frame.textBlob:SetSpacing(5)
    
    RaidSkipper.frame = frame

    -- Set to current character
    RaidSkipper.UIShowCharacter(UnitName("player") .. "-" .. GetRealmName())
end

-- Create the dropdown menu for character selection
RaidSkipper.CharacterSelect_Menu = function(frame, level, menuList)
    RaidSkipper:Debug("CharacterSelect_Menu")
    local info = UIDropDownMenu_CreateInfo()
    info.func = RaidSkipper.CharacterSelect_SetValue

    -- info.text, info.arg1, info.arg2, info.checked = "All", "all", nil, false
    -- UIDropDownMenu_AddButton(info)

    for key, character in pairs(DB.getCharacters()) do
        info.text, info.arg1, info.arg2, info.checked = key, key, nil, false
        UIDropDownMenu_AddButton(info)
    end
end

-- Handle character dropdown menu selection
RaidSkipper.CharacterSelect_SetValue = function(self, arg1, arg2, checked)
    RaidSkipper:Debug("CharacterSelect_SetValue")
    UIDropDownMenu_SetText(RaidSkipper.frame.CharacterSelect, arg1)
    RaidSkipper.UIShowCharacter(arg1)
    CloseDropDownMenus()
end

-- Create the dropdown menu for expansion selection
RaidSkipper.ExpansionSelect_Menu = function(frame, level, menuList)
    RaidSkipper:Debug("ExpansionSelect_Menu")
    local info = UIDropDownMenu_CreateInfo()
    info.func = RaidSkipper.ExpansionSelect_SetValue
    
    -- info.text, info.arg1, info.arg2, info.checked = "All", "all", nil, false
    -- UIDropDownMenu_AddButton(info)

    for index, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        info.text, info.arg1, info.arg2, info.checked = expansion.name, expansion.name, nil, false
        UIDropDownMenu_AddButton(info)
    end
end

-- Handle expansion dropdown menu selection
RaidSkipper.ExpansionSelect_SetValue = function(self, arg1, arg2, checked)
    RaidSkipper:Debug("ExpansionSelect_SetValue")
    UIDropDownMenu_SetText(RaidSkipper.frame.ExpansionSelect, arg1)
    RaidSkipper.UIShowExpansion(arg1)
    CloseDropDownMenus()
end

-- Create the dropdown menu for raid selection
RaidSkipper.RaidSelect_Menu = function(frame, level, menuList)
    RaidSkipper:Debug("RaidSelect_Menu")
    local info = UIDropDownMenu_CreateInfo()
    info.func = RaidSkipper.RaidSelect_SetValue

    -- info.text, info.arg1, info.arg2, info.checked = "All", "all", nil, false
    -- UIDropDownMenu_AddButton(info)

    for index, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        for key, raid in ipairs(expansion.raids) do
            info.text, info.arg1, info.checked = GetRealZoneText(raid.instanceId), raid.instanceId, false
            UIDropDownMenu_AddButton(info)
        end        
    end
end

-- Handle raid dropdown menu selection
RaidSkipper.RaidSelect_SetValue = function(self, arg1, arg2, checked)
    RaidSkipper:Debug("RaidSelect_SetValue")
    UIDropDownMenu_SetText(RaidSkipper.frame.RaidSelect, GetRealZoneText(arg1))
    CloseDropDownMenus()
end

-- Get the status text for a quest from the saved variables
local function GetQuestStatusTextFromVars(questObject, text)
    if questObject.status == COMPLETE then
        return "    " .. RaidSkipper.TextColor(COMPLETE, text .. " " .. ICON_COMPLETE)
    elseif questObject.status == IN_PROGRESS then
        return "    " .. RaidSkipper.TextColor(IN_PROGRESS, text .. " " .. ICON_IN_PROGRESS)
        -- local numQuestObjectives = GetNumQuestObjectives(id)
        -- if numQuestObjectives > 0 then
        --     local objectives = {}
        --     for i = 1, numQuestObjectives do
        --         local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, i, false)
        --         table.insert(objectives, RaidSkipper.TextColor(IN_PROGRESS, " " .. text))
        --     end
        --     if objectives == nil or #objectives == 0 then
        --         return RaidSkipper.TextColor(IN_PROGRESS, difficulty)
        --     else
        --         return table.concat(objectives)
        --     end
        -- else
        --     return RaidSkipper.TextColor(IN_PROGRESS, difficulty)
        -- end
    else
        return "    " .. RaidSkipper.TextColor(INCOMPLETE, text .. " " .. ICON_INCOMPLETE)
    end
end

local function GetQuestStatusFromVars(characterKey, questId)
    local character = DB.getCharacterByPlayerRealm(characterKey)
    local questStatus = character["quests"][questId]
    if questStatus then
        return questStatus
    end
end

-- local function GetAchievementStatusFromVars(characterKey, achievementId)
--     local character = DB.getCharacterByPlayerRealm(characterKey)
--     local achievementStatus = character["achievements"][achievementId]
--     if achievementStatus then
--         return achievementStatus
--     end
-- end

-- Show the character's raid skip status
RaidSkipper.UIShowCharacter = function(characterKey)
    RaidSkipper:Debug("UIShowCharacter")

    local character = DB.getCharacterByPlayerRealm(characterKey)

    local characterNameDisplay = characterKey
    if character.classFilename then
        characterNameDisplay = "\124c" .. GetClassColor(character.classFilename) .. characterKey .. "\124r"
    end
    local blob = characterNameDisplay  .. "\n"

    if character.version < RaidSkipper.DBVersion then
        blob = blob .. "Character data is out of date. Please log in with this character to update the data."
        RaidSkipper.frame.textBlob:SetText(blob)
        return
    end

    local accountWideAchievements = raid_skipper_db["accountWideData"]["achievements"]

    for name, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        -- local expansionInfo = GetExpansionDisplayInfo(expansion.expansionId)
        
        local expansionIcon = ""
        -- if expansionInfo and expansionInfo.logo then
        --     expansionIcon = " |T" .. expansionInfo.logo .. ":0:6|t"
        -- end

        blob = blob .. "    " .. RaidSkipper.TextColor("EXPANSION_NAME", expansion.name) .. expansionIcon .. "\n"

        for key, raid in ipairs(expansion.raids) do
            local raidLine = "        " .. GetRealZoneText(raid.instanceId) .. ": "
            -- Check SOO and BoD
            if raid.achievementId ~= nil then
                local achievementStatus = accountWideAchievements[raid.achievementId]
                raidLine = raidLine .. RaidSkipper.TextColor(achievementStatus, achievementStatus)
            else
                local mythicQuest = character["quests"][raid.mythicId]
                raidLine = raidLine .. GetQuestStatusTextFromVars(mythicQuest, PLAYER_DIFFICULTY6)
                if mythicQuest.status ~= COMPLETE then
                    local heroicQuest = character["quests"][raid.heroicId]
                    raidLine = raidLine .. " " .. GetQuestStatusTextFromVars(heroicQuest, PLAYER_DIFFICULTY2)
                    if heroicQuest.status ~= COMPLETE then
                        local normalQuest = character["quests"][raid.normalId]
                        raidLine = raidLine .. " " .. GetQuestStatusTextFromVars(normalQuest, PLAYER_DIFFICULTY1)
                    end
                end
            end

            blob = blob .. raidLine .. "\n"
        end
    end
    
    RaidSkipper.frame.textBlob:SetText(blob)
end

RaidSkipper.UIShowExpansion = function(expansion)
    local expansionData
    for index, value in ipairs(RaidSkipper.raid_skip_quests) do
        if value.name == expansion then
            expansionData = value
        end
    end
    
    local output = ""
    for key, raid in ipairs(expansionData.raids) do
        RaidSkipper:Debug("raid: " .. GetRealZoneText(raid.instanceId))

        output = output .. GetRealZoneText(raid.instanceId) .. "\n" -- Show raid name as title, list characters below
        if raid.instanceId == 2070 or raid.instanceId == 1136 then
            if IsAchievementComplete(raid.achievementId) then
                output = output .. "    " .. "All: " .. COMPLETE .. "\n"
            else
                output = output .. "    " .. "All: " .. INCOMPLETE .. "\n"
            end
        else
            local mythicId = raid.mythicId
            local heroicId = raid.heroicId
            local normalId = raid.normalId
            
            for playerRealmKey, playerData in pairs(DB.getCharacters()) do
                if playerData.version == RaidSkipper.DBVersion and playerData["quests"] and type(playerData["quests"][mythicId]) ~= "boolean" then
                    
                    -- RaidSkipper:Debug("type: " .. type(playerData["quests"][mythicId]))
                    -- RaidSkipper:Debug("playerRealmKey: " .. playerRealmKey)
                    
                    local mythicStatus = playerData["quests"][mythicId]
                    local heroicStatus = playerData["quests"][heroicId]
                    local normalStatus = playerData["quests"][normalId]
                    
                    if mythicStatus.status == COMPLETE then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY6 .. ") " .. RaidSkipper.TextColor(COMPLETE, COMPLETE) .. "\n"
                    elseif mythicStatus.status == IN_PROGRESS then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY6 .. ") " .. RaidSkipper.TextColor(IN_PROGRESS, IN_PROGRESS .. " " .. mythicStatus.inLogStatus) .. "\n"
                    end
                    
                    if mythicStatus.status ~= COMPLETE and heroicStatus.status == COMPLETE then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY2 .. ") " .. RaidSkipper.TextColor(COMPLETE, COMPLETE) .. "\n"
                    elseif heroicStatus.status == IN_PROGRESS then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY2 .. ") " .. RaidSkipper.TextColor(IN_PROGRESS, IN_PROGRESS .. " " .. heroicStatus.inLogStatus) .. "\n"
                    end
                    
                    if mythicStatus.status ~= COMPLETE and heroicStatus.status ~= COMPLETE and normalStatus.status == COMPLETE then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY1 .. ") " .. RaidSkipper.TextColor(COMPLETE, COMPLETE) .. "\n"
                    elseif normalStatus.status == IN_PROGRESS then
                        output = output .. "    " .. playerRealmKey .. " (" .. PLAYER_DIFFICULTY1 .. ") " .. RaidSkipper.TextColor(IN_PROGRESS, IN_PROGRESS .. " " .. normalStatus.inLogStatus) .. "\n"
                    end
                end
            end
        end
    end
    RaidSkipper.frame.textBlob:SetText(output)
end
-- ----------------------------------------------------------------------------



-- RaidSkipper: Mists of Pandaria
-- RaidSkipper:   Siege of Orgrimmar: Completed
-- RaidSkipper: Warlords of Draenor
-- RaidSkipper:   Blackrock Foundry: Completed
-- RaidSkipper:   Hellfire Citadel Lower: Completed
-- RaidSkipper:   Hellfire Citadel Upper: Completed
-- RaidSkipper: Legion
-- RaidSkipper:   The Emerald Nightmare: Completed
-- RaidSkipper:   The Nighthold: Completed
-- RaidSkipper:   Tomb of Sargeras: Completed
-- RaidSkipper:   Antorus, the Burning Throne Lower: Completed
-- RaidSkipper:   Antorus, the Burning Throne Upper: Completed
-- RaidSkipper: Battle for Azeroth
-- RaidSkipper:   Battle of Dazar'alor: Completed
-- RaidSkipper:   Ny'alotha, the Waking City: Completed
-- RaidSkipper: Shadowlands
-- RaidSkipper:   Castle Nathria: Completed
-- RaidSkipper:   Sanctum of Domination: Completed
-- RaidSkipper:   Sepulcher of the First Ones: Completed
-- RaidSkipper: Dragonflight
-- RaidSkipper:   Vault of the Incarnates
-- RaidSkipper:   Aberrus, the Shadowed Crucible
-- RaidSkipper:   Amirdrassil, the Dream's Hope
-- RaidSkipper: War Within
-- RaidSkipper:   Nerub-ar Palace

-- [Completed|Incomplete|In Progress] [Difficulty]

local function SimpleChatPrint()

    local completedText = RaidSkipper.TextColor(COMPLETE, COMPLETE)
    local incompleteText = RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE)
    local inprogressText = RaidSkipper.TextColor(IN_PROGRESS, IN_PROGRESS)

    for expansion, expansionData in ipairs(RaidSkipper.raid_skip_quests) do
        RaidSkipper:Print(expansionData.name)
        for raid, raidData in ipairs(expansionData.raids) do
            RaidSkipper:Print("  " .. GetRealZoneText(raidData.instanceId))
            if raidData.achievementId then
                -- id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
                local _, name, _, completed, _, _, _, _, _, _, _, _, _, _, _ = GetAchievementInfo(raidData.achievementId)
                RaidSkipper:Print("    " .. name .. ": " .. (completed and COMPLETE or INCOMPLETE))
            end

            local completed = false
            if raidData.mythicId then
                completed = IsQuestFlaggedCompletedOnAccount(raidData.mythicId)
                RaidSkipper:Print("    " .. PLAYER_DIFFICULTY6 .. ": " .. (completed and COMPLETE or INCOMPLETE))
            end
            if not completed and raidData.heroicId then
                completed = IsQuestFlaggedCompletedOnAccount(raidData.heroicId)
                RaidSkipper:Print("    " .. PLAYER_DIFFICULTY2 .. ": " .. (completed and COMPLETE or INCOMPLETE))
            end
            if not completed and raidData.normalId then
                completed = IsQuestFlaggedCompletedOnAccount(raidData.normalId)
                RaidSkipper:Print("    " .. PLAYER_DIFFICULTY1 .. ": " .. (completed and COMPLETE or INCOMPLETE))
            end
        end
    end
end

-- ----------------------------------------------------------------------------


local function GetExpansionDataFromName(expansionName)
    for index, value in ipairs(RaidSkipper.raid_skip_quests) do
        if value.name == expansionName then
            return value
        end
    end
end

function SlashHandler(args)
    RaidSkipper:Debug("SlashHandler")

    local argsTable = RaidSkipper:Split(args, " ")
    local arg1 = argsTable[1]
    local expansionAbbreviations = {
        ["mop"] = EXPANSION_NAME4,
        ["wod"] = EXPANSION_NAME5,
        ["legion"] = EXPANSION_NAME6,
        ["bfa"] = EXPANSION_NAME7,
        ["sl"] = EXPANSION_NAME8,
        ["df"] = EXPANSION_NAME9,
        ["ww"] = EXPANSION_NAME10,
    }

    -- TODO: /rs help, /rs config should show a config and help window

    if arg1 == nil or #argsTable == 0 then
        ShowExpansions()
    elseif arg1 and RaidSkipper.Contains(expansionAbbreviations, arg1:lower()) then
        arg1 = ShowExpansion(GetExpansionDataFromName(expansionAbbreviations[arg1]))
    elseif arg1 and arg1:lower() == "all" then
        ShowExpansions()
    elseif arg1 and arg1:lower() == "list" then
        showMySkips()
    elseif arg1 and arg1:lower() == "show" then
        CreateWindow()
    elseif arg1 and arg1:lower() == "help" then
        PrintHelp()
    elseif arg1 and arg1:lower() == "test" then
        SimpleChatPrint()
    else
        ShowExpansions()
    end

    -- if arg1 then
    --     arg1 = arg1:lower()
        
    --     if arg1 == "all" then
    --         ShowExpansions()
    --     elseif arg1 == "mop" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME4))
    --     elseif arg1 == "wod" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME5))
    --     elseif arg1 == "legion" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME6))
    --     elseif arg1 == "bfa" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME7))
    --     elseif arg1 == "sl" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME8))
    --     elseif arg1 == "df" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME9))
    --     elseif arg1 == "tww" then
    --         ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME10))
    --     elseif arg1 == "list" then
    --         showMySkips()
    --     elseif arg1 == "show" then
    --         CreateWindow()
    --     else
    --         PrintHelp()
    --     end
    -- else
    --     if InRaid() then
    --         ShowCurrentRaid()
    --     else
    --         ShowExpansions()
    --     end
    -- end
end

-- Event Handler when user invokes /ic command
function IsCompleteHandler(args)
    RaidSkipper:Debug("IsCompleteHandler")
    local argsTable = RaidSkipper:Split(args, " ")

    RaidSkipper:Print("--------------------")
    for key, arg in ipairs(argsTable) do   
        
        -- Check for quest
        local questComplete = IsQuestComplete(arg)
        if questComplete ~= nil then
            if questComplete then
                RaidSkipper:Print("Quest " .. arg .. " " .. RaidSkipper.TextColor(COMPLETE, COMPLETE))
            else
                RaidSkipper:Print("Quest " .. arg .. " " .. RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE))
            end
        end        

        -- Check Achievement
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(arg)
        if id ~= nil then
            if completed then
                RaidSkipper:Print("Achievement " .. arg .. " " .. RaidSkipper.TextColor(COMPLETE, COMPLETE))
            else
                RaidSkipper:Print("Achievement " .. arg .. " " .. RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE))
            end
        else
            RaidSkipper:Print("Achievement " .. arg .. " not found")
        end
    end
    RaidSkipper:Print("--------------------")
end

function IsAchievementCompleteHandler(args)
    RaidSkipper:Debug("IsAchievementCompleteHandler")
    local arg1 = RaidSkipper.GetArg(args, 1)

    if arg1 then
        ShowAchievementInfo(arg1)
    end
end

function IsQuestCompleteHandler(args)
    RaidSkipper:Debug("IsQuestCompleteHandler")
    local arg1 = RaidSkipper.GetArg(args, 1)

    if arg1 then
        if IsQuestComplete(arg1) then
            RaidSkipper:Print(COMPLETE)
        else
            RaidSkipper:Print(INCOMPLETE)
        end
    end
end

-- Register events ------------------------------------------------------------

local frame, events = CreateFrame("Frame"), {}

function events:RAID_INSTANCE_WELCOME()
    OnRaidInstanceWelcome()
end

-- function events:ZONE_CHANGED_NEW_AREA()
--     OnChangeZone()
-- end

function events:PLAYER_LOGIN()
    DB.init()
    SaveCurrentCharacterData()
end

-- Async event when requested quest data is returned
function events:QUEST_DATA_LOAD_RESULT(...)
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

-- Slash Commands -------------------------------------------------------------
SLASH_RAIDSKIPPER1 = "/raidskipper"
SLASH_RAIDSKIPPER2 = "/rs"

SlashCmdList["RAIDSKIPPER"] = SlashHandler

SLASH_ISCOMPLETE1 = "/ic"

SlashCmdList["ISCOMPLETE"] = IsCompleteHandler
