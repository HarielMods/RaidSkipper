------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

local _, RaidSkipper = ...
local GetRealZoneText = GetRealZoneText

addon_name = "RaidSkipper"
RaidSkipper.debug = false
RaidSkipper.queryQuests = {}

local ICON_COMPLETE = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local ICON_INCOMPLETE = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"
local ICON_IN_PROGRESS = "|TInterface\\RaidFrame\\ReadyCheck-Waiting:0|t"
local ICON_QUEST = "|TInterface\\Minimap\\Tracking\\TrivialQuests:0|t"

-- Db and Save Skip

if raid_skipper_db == nil then
    raid_skipper_db = { }
end

local function DBMigrations()
    for playerName, values in pairs(raid_skipper_db) do
        local playerName, realmName = string.match(playerName, "(.+)-(.+)")

        if values["version"] == nil then

        elseif values["version"] < 120 then
            local raids = values["raids"]
            for k, raid in raids do

            end
        end


        if playerName and realmName then
            raid_skipper_db[playerName .. "-" .. realmName] = values
            raid_skipper_db[playerName] = nil
        end
    end
end

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

RaidSkipper.Contains = function(self, table, element)
    return table[tostring(element)] ~= nil
end

RaidSkipper.Split = function(self, input, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

RaidSkipper.GetArgs = function(args, pos)
    if type(args) == "string" then
        args = RaidSkipper:Split(args, " ")
    end

    if args[pos] ~= nil then
        return args[pos]
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
    if (id ~= nil) then
        if type(id) ~= "number" then
            id = tonumber(id)
        end
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    else
        return nil
    end
end

local function IsQuestInQuestLog(id)
    return (C_QuestLog.GetLogIndexForQuestID(id) ~= nil)
end

local function IsAchievementComplete(id)
    if (id ~= nil) then
        if type(id) ~= "number" then
            id = tonumber(id)
        end
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(id)
        return completed
    else
        return nil
    end
end

-- CHAT DISPLAY FUNCTIONS

local function ShowQuestProgress(id)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(id, 1, false)
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
        local numQuestObjectives = C_QuestLog.GetNumQuestObjectives(id)
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
    RaidSkipper:Print("  /rs tww --> The War Within")
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

local function GetQuestStatusFromGame(questId)
    local questComplete, inLog = IsQuestComplete(questId), IsQuestInQuestLog(questId)
    local status, statusText = "", ""
    if questComplete then
        status = COMPLETE
    elseif inLog then
        status = IN_PROGRESS
        
        local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questId, 1, false)
        statusText = fulfilled .. "/" .. required

        -- Get in progress status
        -- local numQuestObjectives = C_QuestLog.GetNumQuestObjectives(questId)
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

local function SaveCharacterData()
    RaidSkipper:Debug("SaveCharacterData")

    local playerName = UnitName("player");
    local class, classFilename, _ = UnitClass(playerName);
    local classColor = GetClassColor(classfilename)
    local realmName = GetRealmName();
    local playerRealm = GetPlayerRealmName(playerName, realmName)
    local level = UnitLevel("player")
    local race, raceFilename = UnitRace("player")

    raid_skipper_db[playerRealm] = {
        ["version"] = 120,
        ["playerName"] = playerName,
        ["realmName"] = realmName,
        ["class"] = class,
        ["classFilename"] = classFilename,
        ["color"] = classColor,
        ["level"] = level,
        ["race"] = race,
        ["raceFilename"] = raceFilename,
        ["quests"] = { },
        ["achievements"] = { }
    }

    for name, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        for key, raid in ipairs(expansion.raids) do
            -- Exception raids: Battle of Dazar'alor, Siege of Orgrimmar
            if raid.instanceId == 2070 or raid.instanceId == 1136 then                
                raid_skipper_db[playerRealm]["achievements"][raid.achievementId] = {
                    ["status"] = GetAchievementStatusFromGame(raid.achievementId)
                }
            else
                -- Mythic
                if raid.mythicId then
                    raid_skipper_db[playerRealm]["quests"][raid.mythicId] = GetQuestStatusFromGame(raid.mythicId)
                end
                -- Heroic
                if raid.heroicId then
                    raid_skipper_db[playerRealm]["quests"][raid.heroicId] = GetQuestStatusFromGame(raid.heroicId)
                end
                -- Normal
                if raid.normalId then
                    raid_skipper_db[playerRealm]["quests"][raid.normalId] = GetQuestStatusFromGame(raid.normalId)
                end
            end
        end
    end
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

    for key, character in pairs(raid_skipper_db) do
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
        -- local numQuestObjectives = C_QuestLog.GetNumQuestObjectives(id)
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
    local questStatus = raid_skipper_db[characterKey]["quests"][questId]
    if questStatus then
        return questStatus
    end
end

local function GetAchievementStatusFromVars(characterKey, achievementId)
    local achievementStatus = raid_skipper_db[characterKey]["achievements"][achievementId]
    if achievementStatus then
        return achievementStatus
    end
end

-- Show the character's raid skip status
RaidSkipper.UIShowCharacter = function(characterKey)
    RaidSkipper:Debug("UIShowCharacter")

    local character = raid_skipper_db[characterKey]
    local characterNameDisplay = characterKey
    if character.classFilename then
        characterNameDisplay = "\124c" .. GetClassColor(character.classFilename) .. characterKey .. "\124r"
    end
    local blob = characterNameDisplay  .. "\n"

    if character.version < 120 then
        blob = blob .. "Character data is out of date. Please log in with this character to update the data."
        RaidSkipper.frame.textBlob:SetText(blob)
        return
    end

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
            if raid.instanceId == 2070 or raid.instanceId == 1136 then
                local achievementStatus = raid_skipper_db[characterKey]["achievements"][raid.achievementId].status
                if achievementStatus == COMPLETE then
                    raidLine = raidLine .. RaidSkipper.TextColor(COMPLETE, COMPLETE)
                else
                    raidLine = raidLine .. RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE)
                end
            else
                local mythicQuest = raid_skipper_db[characterKey]["quests"][raid.mythicId]
                raidLine = raidLine .. GetQuestStatusTextFromVars(mythicQuest, PLAYER_DIFFICULTY6)
                if mythicQuest.status ~= COMPLETE then
                    local heroicQuest = raid_skipper_db[characterKey]["quests"][raid.heroicId]
                    raidLine = raidLine .. " " .. GetQuestStatusTextFromVars(heroicQuest, PLAYER_DIFFICULTY2)
                    if heroicQuest.status ~= COMPLETE then
                        local normalQuest = raid_skipper_db[characterKey]["quests"][raid.normalId]
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
            
            for playerRealmKey, playerData in pairs(raid_skipper_db) do
                if playerData.version == 120 and playerData["quests"] and type(playerData["quests"][mythicId]) ~= "boolean" then
                    
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

    if arg1 then
        arg1 = arg1:lower()
        
        if arg1 == "all" then
            ShowExpansions()
        elseif arg1 == "mop" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME4))
        elseif arg1 == "wod" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME5))
        elseif arg1 == "legion" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME6))
        elseif arg1 == "bfa" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME7))
        elseif arg1 == "sl" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME8))
        elseif arg1 == "df" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME9))
        elseif arg1 == "tww" then
            ShowExpansion(GetExpansionDataFromName(EXPANSION_NAME10))
        elseif arg1 == "list" then
            showMySkips()
        elseif arg1 == "show" then
            CreateWindow()
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

function IsCompleteHandler(args)
    RaidSkipper:Debug("IsCompleteHandler")
    local argsTable = RaidSkipper:Split(args, " ")

    RaidSkipper:Print("--------------------")
    for key, arg in ipairs(argsTable) do   
        -- Attempt to load quest data     
        RaidSkipper.queryQuests[arg] = true
        C_QuestLog.RequestLoadQuestByID(arg)
        -- Result will be handled by QUEST_DATA_LOAD_RESULT event

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
    local arg1 = RaidSkipper.GetArgs(args, 1)

    if arg1 then
        ShowAchievementInfo(arg1)
    end
end

function IsQuestCompleteHandler(args)
    RaidSkipper:Debug("IsQuestCompleteHandler")
    local arg1 = RaidSkipper.GetArgs(args, 1)

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

function events:ZONE_CHANGED_NEW_AREA()
    OnChangeZone()
end

function events:PLAYER_LOGIN()
    SaveCharacterData()
end

function events:QUEST_DATA_LOAD_RESULT(...)
    RaidSkipper:Debug("QUEST_DATA_LOAD_RESULT")
    local questID, success = ...
    if RaidSkipper:Contains(RaidSkipper.queryQuests, questID) then
        table.remove(RaidSkipper.queryQuests, questID)

        local completed = C_QuestLog.IsQuestFlaggedCompleted(questID)
        local name = ""
        if success then
            name = C_QuestLog.GetTitleForQuestID(questID)
            if name == nil then
                name = "Unknown quest"
            end
        end

        RaidSkipper:Print("--------------------")
        if completed then
            RaidSkipper:Print("Quest Id: " .. questID .. " " .. RaidSkipper.TextColor(COMPLETE, COMPLETE) .. " " .. name)
        else
            RaidSkipper:Print("Quest Id: " .. questID .. " " .. RaidSkipper.TextColor(INCOMPLETE, INCOMPLETE) .. " " .. name)
        end
        RaidSkipper:Print("--------------------")
    end    
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
