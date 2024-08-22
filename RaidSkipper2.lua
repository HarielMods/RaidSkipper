-- Raid Skipper

local RaidSkipper = {}
local RaidSkipper.data = {}

if raid_skipper_db == nil then
    raid_skipper_db = { }
end

local function DbMigrations(playerName, playerRealm)
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

    if raid_skipper_db[playerRealm]["version"] == 110 then
        
    end
end

local function SaveCharacterInfo()
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

    for name, data in ipairs(RaidSkipper.raid_skip_quests) do
        for key, raid in ipairs(data.raids) do
            -- Exception raids: Battle of Dazar'alor, Siege of Orgrimmar
            if raid.instanceId == 2070 or raid.instanceId == 0 then
                raid_skipper_db[playerRealm]["achievements"][raid.achievementId] = IsAchievementComplete(raid.achievementId)
            else
                -- Mythic
                raid_skipper_db[playerRealm]["quests"][raid.mythicId] = IsQuestComplete(raid.mythicId)
                -- Heroic
                raid_skipper_db[playerRealm]["quests"][raid.heroicId] = IsQuestComplete(raid.heroicId)
                -- Normal
                raid_skipper_db[playerRealm]["quests"][raid.normalId] = IsQuestComplete(raid.normalId)
            end
        end
    end
end

local function GetClassColor(classFilename)
    return RAID_CLASS_COLORS[classFilename].colorStr || 'ffff0000'
end

local function GetPlayerRealmName(playerName, realmName)
    return playerName .. "-" .. realmName
end


-- Register events ------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
    elseif event == "PLAYER_LOGIN" then
        SaveCharacterInfo()
    elseif event == "PLAYER_LOGOUT" then
        SaveCharacterInfo()
    end
end)
