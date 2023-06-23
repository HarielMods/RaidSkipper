------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

-- Function style
--   Use PascalCase for API functions
--   Use camelCase for local functions

local addonName, RaidSkipper = ...
local friendlyAddonName = "Raid Skipper"

local GetRealZoneText = GetRealZoneText
local UnitName = UnitName
local UnitClass = UnitClass
local GetRealmName = GetRealmName
local GetQuestObjectiveInfo = GetQuestObjectiveInfo
local GetClassColor = GetClassColor
local GetQuestLink = GetQuestLink
local GetAchievementLink = GetAchievementLink


local BATTLE_OF_DAZAR_ALOR_INSTANCE_ID = 2070


-- Current character info
local PLAYER_NAME = ""
local PLAYER_CLASS_NAME = ""
local PLAYER_CLASS_FILENAME = ""
local PLAYER_CLASS_ID = nil
local REALM_NAME = ""

local questsInProgress = {}

-- Db and Save Skip

local DBVERSION = 110

if raid_skipper_db == nil then
    raid_skipper_db = { }
end

local function saveSkip2(expansionName, instanceId)
    
    -- update whole instance or expansion?
    -- local questTitle = C_QuestLog.GetTitleForQuestID(questId)
    -- local questStatus = RaidSkipper.getRaidStatus()

    -- if instanceId == BATTLE_OF_DAZAR_ALOR_INSTANCE_ID then
    --     -- Achievement based progression
    -- else
    --     -- Quest based progression

    --     raid_skipper_db[REALM_NAME][PLAYER_NAME][expansionName][tostring(instanceId)] = {}
    --     local raid = RaidSkipper.raid_skip_quests[expansionName]

    --     table.insert(
    --         raid_skipper_db[REALM_NAME][PLAYER_NAME][expansionName][tostring(instanceId)],
    --         questTitle .. "" .. questStatus
    --     )
    -- end

    
end

local function saveSkip(playerRealm, raid, skip, status)
    local playerName = UnitName("player")
    local class, _, _ = UnitClass(playerName)
    local realmName = GetRealmName()
    local playerRealm = playerName .. "-" .. realmName
    local color = nil

    if class ~= nil then
        if class == "Demon Hunter" then
            class = "DEMONHUNTER"
        elseif class == "Death Knight" then
            class = "DEATHKNIGHT"
        end
        color = RAID_CLASS_COLORS[string.upper(class)]
    end
    local cc = color or {colorStr = 'ffff0000'}

    -- Rename existing playername to one with realm
    if raid_skipper_db[playerName] ~= nil and raid_skipper_db[playerRealm] == nil then
        raid_skipper_db[playerRealm] = raid_skipper_db[playerName]
        raid_skipper_db[playerName] = nil
    end

    if raid_skipper_db[playerRealm] == nil or raid_skipper_db[playerRealm]["version"] == nil then
        raid_skipper_db[playerRealm] = {
            ["version"] = DBVERSION,
            ["class"] = class,
            ["color"] = cc.colorStr,
            ["raids"] = { }
        }
    end

    raid_skipper_db[playerRealm]["raids"][raid .. " - " .. skip] = {
        ["name"] = raid,
        ["status"] = status,
        ["difficulty"] = skip
    }

    print("saved: playerRealm: " .. playerRealm .. " raid: " .. raid .. " skip: " .. skip)
end

local function getRaidStatus(mythicId, heroicId, normalId)
    if (RaidSkipper.isQuestComplete(mythicId)) then
        return PLAYER_DIFFICULTY6 .. " " .. COMPLETE
    elseif (RaidSkipper.isQuestComplete(heroicId)) then
        return PLAYER_DIFFICULTY2 .. " " .. COMPLETE
    elseif (RaidSkipper.isQuestComplete(normalId)) then
        return PLAYER_DIFFICULTY1 .. " " .. COMPLETE
    end

    if (RaidSkipper.isQuestInQuestLog(mythicId)) then
        return PLAYER_DIFFICULTY6 .. " " .. IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(mythicId)
    elseif (RaidSkipper.isQuestInQuestLog(heroicId)) then
        return PLAYER_DIFFICULTY2 .. " " .. IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(heroicId)
    elseif (RaidSkipper.isQuestInQuestLog(normalId)) then
        return PLAYER_DIFFICULTY1 .. " " .. IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(normalId)
    end
    return nil
end

local function populatePlayerDb()
    local defaultObj = {
        ["version"] = DBVERSION,
        [REALM_NAME] = {
            [PLAYER_NAME] = {
                ["class"] = PLAYER_CLASS_FILENAME,
                ["version"] = DBVERSION,
                ["skips"] = {
                    [EXPANSION_NAME5] = { -- "Warlords of Draenor"
                        ["1205"] = {}, -- Blackrock Foundary
                        ["1448"] = {}, -- Hellfire Citadel (lower and upper)
                    },
                    [EXPANSION_NAME6] = { -- "Legion"
                        ["1520"] = {}, -- The Emerald Nightmare
                        ["1530"] = {}, -- The Nighthold
                        ["1676"] = {}, -- Tomb of Sargeras
                        ["1712"] = {}, -- Antorus, The Burning Throne (lower and upper)
                    },
                    [EXPANSION_NAME7] = { -- "Battle for Azeroth"
                        ["2070"] = {}, -- Battle of Dazar'alor
                        ["2217"] = {}, -- Ny'alotha, the Waking City
                    },
                    [EXPANSION_NAME8] = { -- "Shadowlands"
                        ["2296"] = {}, -- Castle Nathria
                        ["2450"] = {}, -- Sanctum of Domination
                        ["2481"] = {}, -- Sepulcher of the First Ones
                    },
                    [EXPANSION_NAME9] = { -- "Dragonflight"
                        ["2522"] = {}, -- Vault of the Incarnates
                        ["2569"] = {}, -- Aberrus, the Shadowed Crucible
                    }
                }
            }
        }
    }

    raid_skipper_db[REALM_NAME][PLAYER_NAME] = defaultObj

    for index, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        for i, raid in ipairs(expansion.raids) do
            -- Get skip status
            if raid.instanceId == BATTLE_OF_DAZAR_ALOR_INSTANCE_ID then

            else
                if (RaidSkipper.isQuestComplete(raid.mythicId)) then
                    saveSkip2(expansion, raid.instanceId, raid.mythicId, COMPLETE)
                elseif (RaidSkipper.isQuestComplete(raid.heroicId)) then
                    saveSkip2(expansion, raid.instanceId, raid.heroicId, COMPLETE)
                elseif (RaidSkipper.isQuestComplete(raid.normalId)) then
                    saveSkip2(expansion, raid.instanceId, raid.normalId, COMPLETE)
                end

                if (RaidSkipper.isQuestInQuestLog(raid.mythicId)) then
                    saveSkip2(expansion, raid.instanceId, raid.mythicId, IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(raid.mythicId))
                elseif (RaidSkipper.isQuestInQuestLog(raid.heroicId)) then
                    saveSkip2(expansion, raid.instanceId, raid.heroicId, IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(raid.heroicId))
                elseif (RaidSkipper.isQuestInQuestLog(raid.normalId)) then
                    saveSkip2(expansion, raid.instanceId, raid.normalId, IN_PROGRESS .. " " .. RaidSkipper.getQuestProgress(raid.normalId))
                end
            end
            
        end
    end
end

local function initDb()
    PLAYER_NAME = UnitName("player") or ""
    REALM_NAME = GetRealmName()
    PLAYER_CLASS_NAME, PLAYER_CLASS_FILENAME, PLAYER_CLASS_ID = UnitClass(PLAYER_NAME)
    local playerRealm = PLAYER_NAME .. "-" .. REALM_NAME
    local color = nil

    -- if PLAYER_CLASS_FILENAME ~= nil then
    --     color = RAID_CLASS_COLORS[PLAYER_CLASS_FILENAME]
    -- end
    -- local cc = color or {colorStr = 'ffff0000'}

    -- Reorganize DB from [playerRealm] to [REALM][PLAYER]
    -- (migrate to db version 120)
    if raid_skipper_db[playerRealm] ~= nil or raid_skipper_db[PLAYER_NAME] ~= nil then
        -- clear old db values
        raid_skipper_db[playerRealm] = nil
        raid_skipper_db[PLAYER_NAME] = nil
    end

    -- populate db values
    RaidSkipper.populatePlayerDb()

    -- Rename existing playername to one with realm 
    -- (migrate to db version 110)
    -- if raid_skipper_db[PLAYER_NAME] ~= nil and raid_skipper_db[playerRealm] == nil then
    --     raid_skipper_db[playerRealm] = raid_skipper_db[PLAYER_NAME]
    --     raid_skipper_db[PLAYER_NAME] = nil
    -- end

    -- if raid_skipper_db[playerRealm] == nil or raid_skipper_db[playerRealm]["version"] == nil then
    --     raid_skipper_db[playerRealm] = {
    --         ["version"] = DBVERSION,
    --         ["class"] = class,
    --         ["color"] = cc.colorStr,
    --         ["raids"] = { }
    --     }
    -- end

    print("RaidSkipper: init done")
end

local function showMySkips()
    for char, values in pairs(raid_skipper_db) do
        local classColor = values.color;
        RaidSkipper:print("\124c" .. classColor .. char)
        for raid, info in pairs(values.raids) do
            local statusText = RaidSkipper.getColorText((info.status == "Complete" and COMPLETE or IN_PROGRESS), info.status)
            RaidSkipper:print("     " .. info.name .. " - " .. info.difficulty .." - (" .. statusText .. ")")
        end
    end
end



-- UTILITY FUNCTIONS

RaidSkipper.print = function(self, msg)
    print(self.friendlyAddonName .. ": " .. msg)
end

local function hasValue(tbl, value)
    for k, v in ipairs(tbl) do
        if tonumber(v) == tonumber(value) or (type(v) == "table" and hasValue(v, value)) then
            return true
        end
    end
    return false
end

RaidSkipper.getColorText = function(color, msg)
    local colors = {
        [COMPLETE] = "ff00ff00",
        [INCOMPLETE] = "ffff0000",
        [IN_PROGRESS] = "ff00ffff",
        ["yellow"] = "ffffff00",
        ["red"] = "ffff0000",
        ["green"] = "ff00ff00",
        ["blue"] = "ff0000ff",
        ["white"] = "ffffffff",
    }
    return "\124c" .. colors[color] .. msg .. "\124r"
end

-- QUEST FUNCTIONS

local function isQuestComplete(id)
    if (id ~= nil) then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    else
        return nil
    end
end

local function isAchievementComplete(id)
    if (id ~= nil) then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(id)
        -- return completed
        return {completed, wasEarnedByMe}
    else
        return nil
    end
end

local function isQuestInQuestLog(id)
    return (C_QuestLog.GetLogIndexForQuestID(id) ~= nil)
end

local function getQuestTitle(questId)
    return C_QuestLog.GetTitleForQuestID(questId) or nil
end

local function getQuestIdsAsArray(data)
    local ids = {}
    for name, instances in pairs(RaidSkipper.raid_skip_quests) do
        for key, raid in pairs(instances.raids) do
            table.insert(ids, raid.mythicId)
            table.insert(ids, raid.heroicId)
            table.insert(ids, raid.normalId)
        end
    end
    return ids
end

-- DISPLAY FUNCTIONS

local function getQuestProgress(questId)
    local text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questId, 1, false)
    return fulfilled .. "/" .. required
end

local function getQuestInfo(id, difficulty, raidName)
    if (isQuestComplete(id)) then
        -- saveSkip(raidName, difficulty, "Complete")
        -- Player has completed this quest
        return RaidSkipper.getColorText(COMPLETE, difficulty)
    elseif (isQuestInQuestLog(id)) then
        -- saveSkip(raidName, difficulty, "In Progress " .. getQuestProgress(id))
        -- Player has this quest in their quest log
        return RaidSkipper.getColorText(IN_PROGRESS, difficulty .. " " .. getQuestProgress(id))
    else
        -- Player has not completed this quest does not have quest in the quest log
        return RaidSkipper.getColorText(INCOMPLETE, difficulty)
    end
end

local function showAchievementInfo(achievementId)
    if achievementId then
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(id)
        RaidSkipper:print("Achievment: " .. name)
        local output = "Account: " .. (completed and RaidSkipper.getColorText(COMPLETE, "Complete") or RaidSkipper.getColorText(INCOMPLETE, "Incomplete"))
        output = output .. " Character: " .. (wasEarnedByMe and RaidSkipper.getColorText(COMPLETE, "Complete") or RaidSkipper.getColorText(INCOMPLETE, "Incomplete"))
        RaidSkipper:print(output)
    end
end

local function showRaidSkip(raid)
    local output = "  " .. GetRealZoneText(raid.instanceId) .. ": "
    -- Battle of Dazar'alor uses an Achievement, not quests
    if raid.instanceId == BATTLE_OF_DAZAR_ALOR_INSTANCE_ID then
        local completed, wasEarnedByMe = isAchievementComplete(raid.achievementId)
        if completed then
            output = output .. RaidSkipper.getColorText(COMPLETE, COMPLETE)
        else
            output = output .. RaidSkipper.getColorText(INCOMPLETE, INCOMPLETE)
        end
    else
        -- Mythic
        output = output .. getQuestInfo(raid.mythicId, PLAYER_DIFFICULTY6, GetRealZoneText(raid.instanceId))
        -- Heroic, if Mythic is complete Heroic and Normal can be skipped
        if (not isQuestComplete(raid.mythicId) and raid.heroicId ~= nil) then
            output = output .. " " .. getQuestInfo(raid.heroicId, PLAYER_DIFFICULTY2, GetRealZoneText(raid.instanceId))
            -- Normal, if Heroic is complete Normal can be skipped
            if (not isQuestComplete(raid.heroicId) and raid.normalId ~= nil) then
                output = output .. " " .. getQuestInfo(raid.normalId, PLAYER_DIFFICULTY1, GetRealZoneText(raid.instanceId))
            end
        end
    end
    RaidSkipper:print(output)
end

local function showExpansion(data)
    RaidSkipper:print(data.name)
    for key, raid in ipairs(data.raids) do
        showRaidSkip(raid)
    end
end

local function showRaid(data)
    showRaidSkip(data)
end

local function showExpansions()
    for name, data in ipairs(RaidSkipper.raid_skip_quests) do
        showExpansion(data)
    end
end

local function printHelp()
    RaidSkipper:print("slash commands:")
    RaidSkipper:print("  /rs wod --> Warlords of Draenor")
    RaidSkipper:print("  /rs legion --> Legion")
    RaidSkipper:print("  /rs bfa --> Battle for Azeroth")
    RaidSkipper:print("  /rs sl --> Shadowlands")
    RaidSkipper:print("  /rs df --> Dragonflight")
    RaidSkipper:print("  /rs list --> List my chars status")
end

local function showRaidInstanceById(id)
    local output = ""
    local found = false
    for expansionKey, expansionData in ipairs(RaidSkipper.raid_skip_quests) do
        for raidKey, raidData in ipairs(expansionData.raids) do
            if (raidData.instanceId == id) then
                if not found then
                    RaidSkipper:print(expansionData.name)
                end
                showRaidSkip(raidData)
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
        showRaidInstanceById(instanceID)
    end
end

local function ShowCurrentRaid() 
    local instanceID = select(8, GetInstanceInfo())
    showRaidInstanceById(instanceID)
end



-- ----------------------------------------------------------------------------------------------------

local function saveAllSkips()
    print("saving all skip quests")
    for expansionIndex, expansion in ipairs(RaidSkipper.raid_skip_quests) do
        print("checking expansion: " .. expansion.name)

        for raidIndex, raid in ipairs(expansion.raids) do

            print("checking raid: " .. GetRealZoneText(raid.instanceId))
            if raid.instanceId == BATTLE_OF_DAZAR_ALOR_INSTANCE_ID then
                -- skip dazar'alor
                print("skipping: " .. GetRealZoneText(raid.instanceId))
            else
                -- add exception for Dazar'Alor/SOO
          
                local raidName = GetRealZoneText(raid.instanceId)

                local difficulties = { PLAYER_DIFFICULTY6, PLAYER_DIFFICULTY2, PLAYER_DIFFICULTY1 }
                local questIds = { raid.mythicId, raid.heroicId, raid.normalId }
                local statuses = {}
                for i, questId in ipairs(questIds) do
                    if isQuestComplete(questId) then
                        table.insert(statuses, {[difficulties[i] .. "Status"] = "Complete"})
                    elseif isQuestInQuestLog(questId) then
                        table.insert(statuses, {[difficulties[i] .. "Status"] = "(In Progress " .. getQuestProgress(questId) .. ")"})
                    end
                end

                -- local mythicStatus = ""
                -- if isQuestComplete(raid.mythicId) then
                --     mythicStatus = "(Complete)"
                -- elseif isQuestInQuestLog(raid.mythicId) then
                --     mythicStatus = "(In Progress " .. getQuestProgress(raid.mythicId) .. ")"
                -- end

                -- local heroicStatus = ""
                -- if isQuestComplete(raid.heroicId) then
                --     heroicStatus = "(Complete)"
                -- elseif isQuestInQuestLog(raid.heroicId) then
                --     heroicStatus = "(In Progress " .. getQuestProgress(raid.heroicId) .. ")"
                -- end

                -- local normalStatus = ""
                -- if isQuestComplete(raid.normalId) then
                --     normalStatus = "(Complete)"
                -- elseif isQuestInQuestLog(raid.normalId) then
                --     normalStatus = "(In Progress " .. getQuestProgress(raid.normalId) .. ")"
                -- end
                -- local mythicStatus = isQuestComplete(raid.mythicId) and "Complete" or isQuestInQuestLog(raid.mythicId) and "(In Progress " .. getQuestProgress(raid.mythicId) .. ")" or ""
                -- local heroicStatus = isQuestComplete(raid.heroicId) and "Complete" or isQuestInQuestLog(raid.heroicId) and "(In Progress " .. getQuestProgress(raid.heroicId) .. ")" or ""
                -- local normalStatus = isQuestComplete(raid.normalId) and "Complete" or isQuestInQuestLog(raid.normalId) and "(In Progress " .. getQuestProgress(raid.normalId) .. ")" or ""

                -- if (mythicStatus ~= "") then
                --     saveSkip(raidName, PLAYER_DIFFICULTY6, mythicStatus)
                -- elseif (heroicStatus ~= "") then
                --     saveSkip(raidName, PLAYER_DIFFICULTY2, heroicStatus)
                -- elseif (normalStatus ~= "") then
                --     saveSkip(raidName, PLAYER_DIFFICULTY1, normalStatus)
                -- end
            end
        end
    end
    print("saved")
end

local function SlashHandler(msg, editBox)
    -- local arg1 = RaidSkipper.AceAddon:GetArgs(args, 1)

    print("RS: SlashHandler: msg: " .. msg)

    -- local command, ext = msg:match("^(%S*)%s(.-)$")

    local command, ext = strsplit(" ", msg)

    if command then
        
        -- print("RS: command: " .. command)
        
        -- Show specific raids
        if command == "" then
            -- No arguments were passed in
            if InRaid() then
                ShowCurrentRaid()
            else
                showExpansions()
            end
        elseif command == "save" or command == "update" then
            RaidSkipper.populatePlayerDb()
        elseif command == "help" then
            printHelp()
        elseif command == "list" then
            showMySkips()
        elseif command == "all" then
            showExpansions()
        elseif command == "df" or command == "dragonflight" then
            showExpansion(RaidSkipper.raid_skip_quests[5])
        elseif command == "sl" or command == "shadowlands" then
            showExpansion(RaidSkipper.raid_skip_quests[4])
        elseif command == "bfa" or command == "battle" then
            showExpansion(RaidSkipper.raid_skip_quests[3])
        elseif command == "lg" or command == "legion" then
            showExpansion(RaidSkipper.raid_skip_quests[2])
        elseif command == "wod" or command == "warlords" then
            showExpansion(RaidSkipper.raid_skip_quests[1])
        end
    end
end

RaidSkipper.Frame = CreateFrame("Frame")

function RaidSkipper.Frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function RaidSkipper.Frame:ADDON_LOADED(event, addOnName)
    -- print(event, addOnName)
end

function RaidSkipper.Frame:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    -- print(event, isLogin, isReload)
    -- TODO: Initialize saved vars
    initDb()
end

function RaidSkipper.Frame:PLAYER_LEAVING_WORLD(event)
    -- print(event, isLogin, isReload)
    -- TODO: Initialize saved vars
end

function RaidSkipper.Frame:QUEST_WATCH_UPDATE(event)
    
end

function RaidSkipper.Frame:ZONE_CHANGED_NEW_AREA(event)
    OnChangeZone()
end

RaidSkipper.Frame:RegisterEvent("ADDON_LOADED")
RaidSkipper.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidSkipper.Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
RaidSkipper.Frame:RegisterEvent("QUEST_WATCH_UPDATE")
RaidSkipper.Frame:SetScript("OnEvent", RaidSkipper.Frame.OnEvent)

SLASH_RAIDSKIPPER1 = "/raidskipper"
SLASH_RAIDSKIPPER2 = "/rs"

SlashCmdList.RAIDSKIPPER = function(msg, editBox)
    SlashHandler(msg, editBox)
end

SLASH_ISCOMPLETE1 = "/ic"
SlashCmdList.ISCOMPLETE = function(msg, editBox)
    print("Handle IS_COMPLETE")
end
