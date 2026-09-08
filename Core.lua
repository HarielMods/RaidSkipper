--[[
    Raid Skip Tracker
      (Formerly Raid Skipper)
    Version 2.0.0

    Show which quests or achievements have been completed that allow the player to skip content in raids.
]]

local ADDON_NAME, L = ...
local VERSION = "2.0.0"

------------------------------------------------------------
-- Localize Blizzard API
------------------------------------------------------------

local GetRealZoneText = GetRealZoneText
local GetQuestLogTitle = GetQuestLogTitle

------------------------------------------------------------
-- Saved Variables
------------------------------------------------------------

RaidSkipTrackerDB = RaidSkipTrackerDB or {}

RaidSkipTrackerDB.settings = RaidSkipTrackerDB.settings or {
    showZoneMessage = true,
}

local DB = RaidSkipTrackerDB

------------------------------------------------------------
-- Colors
------------------------------------------------------------

local RED    = "|cffff4040"
local GREEN  = "|cff40ff40"
local YELLOW = "|cffffff40"
local GREY   = "|cffaaaaaa"
local WHITE  = "|cffffffff"
local CYAN   = "|cff00ccff"
local RESET  = "|r"

------------------------------------------------------------
-- Expansion Constants
------------------------------------------------------------

local EXP_MOP = LE_EXPANSION_MISTS_OF_PANDARIA or 4
local EXP_WOD = LE_EXPANSION_WARLORDS_OF_DRAENOR or 5
local EXP_LEGION = LE_EXPANSION_LEGION or 6
local EXP_BFA = LE_EXPANSION_BATTLE_FOR_AZEROTH or 7
local EXP_SL = LE_EXPANSION_SHADOWLANDS or 8
local EXP_DF = LE_EXPANSION_DRAGONFLIGHT or 9
local EXP_WW = LE_EXPANSION_WAR_WITHIN or 10
local EXP_MD = LE_EXPANSION_MIDNIGHT or 11

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function SafeExpansionName(globalName, fallback)
    return _G[globalName] or fallback
end

local function SafeInstanceName(instanceId, fallback)
    return GetRealZoneText(instanceId) or fallback
end

local QUEST_TITLES = {}


------------------------------------------------------------
-- Raid Data
------------------------------------------------------------

local RAID_DATA = {

    --------------------------------------------------------
    -- Midnight
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME11",
            "Midnight"
        ),

        expansionId = EXP_MD,

        raids = {
            {
                name = SafeInstanceName(3004, "The Venmous Abyss"),
                instanceId = 3004,

                mythicId = 98229,
                heroicId = 98228,
                normalId = 98226,
            },
            {
                name = SafeInstanceName(2912, "The Voidespire"),
                instanceId = 2912,

                mythicId = 94477,
                heroicId = 94476,
                normalId = 94475,
            },
        },
    },

    --------------------------------------------------------
    -- War Within
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME10",
            "The War Within"
        ),

        expansionId = EXP_WW,

        raids = {
            {
                name = SafeInstanceName(2810, "Manaforge Omega"),
                instanceId = 2810,

                mythicId = 91461,
                heroicId = 91460,
                normalId = 91459,
            },
            {
                name = SafeInstanceName(2769, "Liberation of Undermine"),
                instanceId = 2769,

                mythicId = 89353,
                heroicId = 89352,
                normalId = 89351,
            },
            {
                name = SafeInstanceName(2657, "Nerub-ar Palace"),
                instanceId = 2657,

                mythicId = 82639,
                heroicId = 82638,
                normalId = 82629,
            }
        },
    },

    --------------------------------------------------------
    -- Dragonflight
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME9",
            "Dragonflight"
        ),

        expansionId = EXP_DF,

        raids = {
            {
                name = SafeInstanceName(2549, "Amirdrassil, the Dream's Hope"),
                instanceId = 2549,

                mythicId = 78602,
                heroicId = 78601,
                normalId = 78600,
            },
            {
                name = SafeInstanceName(2569, "Aberrus, the Shadowed Crucible"),
                instanceId = 2569,

                mythicId = 76086,
                heroicId = 76085,
                normalId = 76083,
            },
            {
                name = SafeInstanceName(2522, "Vault of the Incarnates"),
                instanceId = 2522,

                mythicId = 71020,
                heroicId = 71019,
                normalId = 71018,
            },
        },
    },

    --------------------------------------------------------
    -- Shadowlands
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME8",
            "Shadowlands"
        ),

        expansionId = EXP_SL,

        raids = {
            {
                name = SafeInstanceName(2481, "Sepulcher of the First Ones"),
                instanceId = 2481,

                mythicId = 65762,
                heroicId = 65763,
                normalId = 65764,
            },
            {
                name = SafeInstanceName(2450, "Sanctum of Domination"),
                instanceId = 2450,

                mythicId = 64599,
                heroicId = 64598,
                normalId = 64597,
            },
            {
                name = SafeInstanceName(2296, "Castle Nathria"),
                instanceId = 2296,

                mythicId = 62056,
                heroicId = 62055,
                normalId = 62054,
            },
        },
    },

    --------------------------------------------------------
    -- Battle for Azeroth
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME7",
            "Battle for Azeroth"
        ),

        expansionId = EXP_BFA,

        raids = {
            {
                name = SafeInstanceName(2217, "Ny'alotha, the Waking City"),
                instanceId = 2217,

                mythicId = 58375,
                heroicId = 58374,
                normalId = 58373,
            },
            {
                name = SafeInstanceName(2070, "Battle of Dazar'alor"),
                instanceId = 2070,
                achievementId = 13314,
            },
        },
    },

    --------------------------------------------------------
    -- Legion
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME6",
            "Legion"
        ),

        expansionId = EXP_LEGION,

        raids = {
            {
                name = SafeInstanceName(1712, "Antorus, the Burning Throne") .. " " .. L["UPPER"],
                instanceId = 1712,

                mythicId = 49135,
                heroicId = 49134,
                normalId = 49133,
            },
            {
                name = SafeInstanceName(1712, "Antorus, the Burning Throne") .. " " .. L["LOWER"],
                instanceId = 1712,

                mythicId = 49076,
                heroicId = 49075,
                normalId = 49032,
            },
            {
                name = SafeInstanceName(1676, "Tomb of Sargeras"),
                instanceId = 1676,

                mythicId = 47727,
                heroicId = 47726,
                normalId = 47725,
            },
            {
                name = SafeInstanceName(1530, "The Nighthold"),
                instanceId = 1530,

                mythicId = 45383,
                heroicId = 45382,
                normalId = 45381,
            },
            {
                name = SafeInstanceName(1520, "The Emerald Nightmare"),
                instanceId = 1520,

                mythicId = 44285,
                heroicId = 44284,
                normalId = 44283,
            },
        },
    },

    --------------------------------------------------------
    -- Warlords of Draenor
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME5",
            "Warlords of Draenor"
        ),

        expansionId = EXP_WOD,

        raids = {
            {
                name = SafeInstanceName(1448, "Hellfire Citadel") .. " " .. L["UPPER"],
                instanceId = 1448,

                mythicId = 39505,
                heroicId = 39504,
                normalId = 39502,
            },
            {
                name = SafeInstanceName(1448, "Hellfire Citadel") .. " " .. L["LOWER"],
                instanceId = 1448,

                mythicId = 39501,
                heroicId = 39500,
                normalId = 39499,
            },
            {
                name = SafeInstanceName(1205, "Blackrock Foundry"),
                instanceId = 1205,

                mythicId = 37031,
                heroicId = 37030,
                normalId = 37029,
            },
        },
    },

    --------------------------------------------------------
    -- Mists of Pandaria
    --------------------------------------------------------

    {
        name = SafeExpansionName(
            "EXPANSION_NAME4",
            "Mists of Pandaria"
        ),

        expansionId = EXP_MOP,

        raids = {
            {
                name = SafeInstanceName(1136, "Siege of Orgrimmar"),
                instanceId = 1136,
                achievementId = 8482,
            },
        },
    },

}

------------------------------------------------------------
-- Build Instance Lookup
------------------------------------------------------------

local RAID_BY_INSTANCE = {}

for _, expansion in ipairs(RAID_DATA) do

    for _, raid in ipairs(expansion.raids) do
        
        if raid.mythicId then
            C_QuestLog.RequestLoadQuestByID(raid.mythicId)
        end
        
        RAID_BY_INSTANCE[raid.instanceId] =
            RAID_BY_INSTANCE[raid.instanceId] or {}

        table.insert(
            RAID_BY_INSTANCE[raid.instanceId],
            raid
        )

    end

end

------------------------------------------------------------
-- Account-Wide Quest Check
------------------------------------------------------------

local function IsQuestCompleteOnAccount(questID)

    if not questID then
        return false
    end

    if C_QuestLog
        and C_QuestLog.IsQuestFlaggedCompletedOnAccount then

        return C_QuestLog.IsQuestFlaggedCompletedOnAccount(
            questID
        ) == true

    end

    return false
end

------------------------------------------------------------
-- Achievement Check
------------------------------------------------------------

local function IsAchievementComplete(achievementID)

    if not achievementID then
        return false
    end

    if not GetAchievementInfo then
        return false
    end

    local _, _, _, completed =
        GetAchievementInfo(achievementID)

    return completed == true
end

------------------------------------------------------------
-- Get Quest Status
------------------------------------------------------------

local function GetQuestStatus(raid)

    local result = {

        mythic =
            raid.mythicId
            and IsQuestCompleteOnAccount(raid.mythicId)
            or false,

        heroic =
            raid.heroicId
            and IsQuestCompleteOnAccount(raid.heroicId)
            or false,

        normal =
            raid.normalId
            and IsQuestCompleteOnAccount(raid.normalId)
            or false,

    }

    result.unlocked =
        result.mythic
        or result.heroic
        or result.normal

    return result
end

------------------------------------------------------------
-- Determine Raid Requirement State
------------------------------------------------------------

local function RequirementState(raid)

    --------------------------------------------------------
    -- Achievement-based skip
    --------------------------------------------------------

    if raid.achievementId then

        local completed =
            IsAchievementComplete(raid.achievementId)

        local _, title, _, _, _, _, _, desc = GetAchievementInfo(raid.achievementId)
        local source = L["Achievement"] .. ": " .. title
        local difficulty = " "

        if completed then
            difficulty = L["MYTHIC"] .. ", " .. L["HEROIC"] .. ", " .. L["NORMAL"]
        end

        return {
            unlocked = completed,
            source = source,
            difficulty = difficulty --L["NOT COMPLETED"],
        }

    end

    --------------------------------------------------------
    -- Quest-based skip
    --------------------------------------------------------

    local status =
        GetQuestStatus(raid)

    local completed = {}

    if status.mythic then
        table.insert(
            completed,
            L["MYTHIC"]
        )
    end

    if status.heroic then
        table.insert(
            completed,
            L["HEROIC"]
        )
    end

    if status.normal then
        table.insert(
            completed,
            L["NORMAL"]
        )
    end

    local questTitle = C_QuestLog.GetTitleForQuestID(raid.mythicId) or L["Quest title unavailable"]

    if #completed > 0 then

        return {

            unlocked = true,

            -- source = L["Account-wide quest completion"],
            -- Use quest name if available
            source = questTitle,

            difficulty =
                table.concat(
                    completed,
                    ", "
                ),

            questStatus = status,

        }

    end

    return {

        unlocked = false,

        source = questTitle,

        difficulty = " ", -- L["NOT COMPLETED"],

        questStatus = status,

    }

end

------------------------------------------------------------
-- UI
------------------------------------------------------------

local MainFrame
local ContentFrame
local ScrollFrame

local Rows = {}

------------------------------------------------------------
-- Backdrop
------------------------------------------------------------

local function CreateBackdrop(frame)

    frame:SetBackdrop({

        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3,
        },
    })

    frame:SetBackdropColor(
        0.03,
        0.03,
        0.03,
        0.96
    )

    frame:SetBackdropBorderColor(
        0.5,
        0.5,
        0.5,
        1
    )

end

------------------------------------------------------------
-- Font String
------------------------------------------------------------

local function CreateText(
    parent,
    size,
    justify
)

    local fs =
        parent:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    fs:SetFont(
        fs:GetFont(),
        size or 12
    )

    fs:SetJustifyH(
        justify or "LEFT"
    )

    return fs

end

------------------------------------------------------------
-- Clear Rows
------------------------------------------------------------

local function ClearRows()

    for _, row in ipairs(Rows) do

        row:Hide()
        row:SetParent(nil)

    end

    wipe(Rows)

end

------------------------------------------------------------
-- Add Row
------------------------------------------------------------

local function AddRow(
    parent,
    y,
    height
)

    local row =
        CreateFrame(
            "Frame",
            nil,
            parent
        )

    row:SetSize(
        690,
        height
    )

    row:SetPoint(
        "TOPLEFT",
        0,
        y
    )

    table.insert(
        Rows,
        row
    )

    return row

end

------------------------------------------------------------
-- Status Text
------------------------------------------------------------

local function StatusText(state)

    if state.unlocked then

        return GREEN
            .. L["SKIP UNLOCKED"]
            .. RESET

    end

    return RED
        .. L["NOT COMPLETED"]
        .. RESET

end

------------------------------------------------------------
-- Refresh UI
------------------------------------------------------------

local function RefreshUI()

    if not MainFrame
        or not MainFrame:IsShown() then

        return
    end

    ClearRows()

    local y = -4

    --------------------------------------------------------
    -- Expansions
    --------------------------------------------------------

    for _, expansion in ipairs(RAID_DATA) do

        ----------------------------------------------------
        -- Expansion Header
        ----------------------------------------------------

        local header =
            AddRow(
                ContentFrame,
                y,
                28
            )

        local bg =
            header:CreateTexture(
                nil,
                "BACKGROUND"
            )

        bg:SetAllPoints()

        bg:SetColorTexture(
            0.12,
            0.12,
            0.12,
            1
        )

        local title =
            CreateText(
                header,
                15,
                "LEFT"
            )

        title:SetPoint(
            "LEFT",
            8,
            0
        )

        title:SetText(
            expansion.name
        )

        ----------------------------------------------------
        -- Expansion completion count
        ----------------------------------------------------

        local countDone = 0

        local countTotal =
            #expansion.raids

        for _, raid in ipairs(expansion.raids) do

            if RequirementState(raid).unlocked then

                countDone =
                    countDone + 1

            end

        end

        local count =
            CreateText(
                header,
                12,
                "RIGHT"
            )

        count:SetPoint(
            "RIGHT",
            -8,
            0
        )

        local countColor =
            countDone == countTotal
            and GREEN
            or YELLOW

        count:SetText(
            countColor
            .. countDone
            .. "/"
            .. countTotal
            .. RESET
        )

        y = y - 32

        ----------------------------------------------------
        -- Raids
        ----------------------------------------------------

        for _, raid in ipairs(expansion.raids) do

            local state =
                RequirementState(raid)

            local row =
                AddRow(
                    ContentFrame,
                    y,
                    48
                )

            ------------------------------------------------
            -- Raid name
            ------------------------------------------------

            local name =
                CreateText(
                    row,
                    13,
                    "LEFT"
                )

            name:SetPoint(
                "TOPLEFT",
                12,
                -2
            )

            name:SetText(
                raid.name
            )

            ------------------------------------------------
            -- Status
            ------------------------------------------------

            local status =
                CreateText(
                    row,
                    12,
                    "RIGHT"
                )

            status:SetPoint(
                "TOPRIGHT",
                -12,
                -2
            )

            status:SetText(
                StatusText(state)
            )

            ------------------------------------------------
            -- Detail Left
            ------------------------------------------------

            local detailLeft =
                CreateText(
                    row,
                    11,
                    "LEFT"
                )

            detailLeft:SetPoint(
                "BOTTOMLEFT",
                12,
                14
            )

            detailLeft:SetText(
                GREY
                .. state.source
                .. RESET
            )

            ------------------------------------------------
            -- Detail Right
            ------------------------------------------------

            local detailRight =
                CreateText(
                    row,
                    11,
                    "RIGHT"
                )

            detailRight:SetPoint(
                "BOTTOMRIGHT",
                -12,
                14
            )

            detailRight:SetText(
                GREY
                .. state.difficulty
                .. RESET
            )

            y = y - 52

        end

        y = y - 4

    end

    ContentFrame:SetHeight(
        math.max(
            1,
            -y + 10
        )
    )

    ScrollFrame:SetVerticalScroll(0)

end

------------------------------------------------------------
-- Create Main Window
------------------------------------------------------------

local function CreateMainFrame()

    if MainFrame then
        return
    end

    --------------------------------------------------------
    -- Main Frame
    --------------------------------------------------------

    MainFrame =
        CreateFrame(
            "Frame",
            ADDON_NAME .. "MainFrame",
            UIParent,
            "BackdropTemplate"
        )

    MainFrame:SetSize(
        730,
        600
    )

    MainFrame:SetPoint(
        "CENTER"
    )

    MainFrame:SetFrameStrata(
        "DIALOG"
    )

    MainFrame:SetClampedToScreen(
        true
    )

    MainFrame:EnableMouse(
        true
    )

    MainFrame:SetMovable(
        true
    )

    MainFrame:RegisterForDrag(
        "LeftButton"
    )

    MainFrame:SetScript(
        "OnDragStart",
        MainFrame.StartMoving
    )

    MainFrame:SetScript(
        "OnDragStop",
        MainFrame.StopMovingOrSizing
    )

    CreateBackdrop(
        MainFrame
    )

    --------------------------------------------------------
    -- Title
    --------------------------------------------------------

    local title =
        CreateText(
            MainFrame,
            18,
            "LEFT"
        )

    title:SetPoint(
        "TOPLEFT",
        16,
        -12
    )

    title:SetText(
        "Raid Skip Tracker"
    )

    --------------------------------------------------------
    -- Subtitle
    --------------------------------------------------------

    local subtitle =
        CreateText(
            MainFrame,
            11,
            "LEFT"
        )

    subtitle:SetPoint(
        "TOPLEFT",
        16,
        -36
    )

    subtitle:SetText(
        GREY
          .. " "
        .. RESET
    )

    --------------------------------------------------------
    -- Close
    --------------------------------------------------------

    local close =
        CreateFrame(
            "Button",
            nil,
            MainFrame,
            "UIPanelCloseButton"
        )

    close:SetPoint(
        "TOPRIGHT",
        2,
        2
    )

    --------------------------------------------------------
    -- Refresh
    --------------------------------------------------------

    local refresh =
        CreateFrame(
            "Button",
            nil,
            MainFrame,
            "UIPanelButtonTemplate"
        )

    refresh:SetSize(
        80,
        24
    )

    refresh:SetPoint(
        "TOPRIGHT",
        -34,
        -42
    )

    refresh:SetText(
        L["REFRESH"]
    )

    refresh:SetScript(
        "OnClick",
        RefreshUI
    )

    --------------------------------------------------------
    -- Scroll Frame
    --------------------------------------------------------

    ScrollFrame =
        CreateFrame(
            "ScrollFrame",
            ADDON_NAME .. "ScrollFrame",
            MainFrame,
            "UIPanelScrollFrameTemplate"
        )

    ScrollFrame:SetPoint(
        "TOPLEFT",
        12,
        -68
    )

    ScrollFrame:SetPoint(
        "BOTTOMRIGHT",
        -32,
        12
    )

    --------------------------------------------------------
    -- Scroll Child
    --------------------------------------------------------

    ContentFrame =
        CreateFrame(
            "Frame",
            nil,
            ScrollFrame
        )

    ContentFrame:SetSize(
        690,
        1
    )

    ScrollFrame:SetScrollChild(
        ContentFrame
    )

    --------------------------------------------------------
    -- Refresh whenever shown
    --------------------------------------------------------

    MainFrame:SetScript(
        "OnShow",
        RefreshUI
    )

    -- Hide the main frame by default; it will be shown when the user types the slash command.
    MainFrame:Hide()

end

------------------------------------------------------------
-- Toggle Window
------------------------------------------------------------

local function ToggleUI()

    CreateMainFrame()

    if MainFrame:IsShown() then
        MainFrame:Hide()
    else
        MainFrame:Show()
    end

end

------------------------------------------------------------
-- Find Raid
------------------------------------------------------------

local function FindTrackedRaid(instanceID)

    return RAID_BY_INSTANCE[instanceID]

end

------------------------------------------------------------
-- Print Raid Status
------------------------------------------------------------

local function PrintRaidStatus(
    instanceID,
    instanceName
)

    local raids =
        FindTrackedRaid(
            instanceID
        )

    if not raids then
        return false
    end

    print(
        CYAN
        .. L["ADDON_NAME"]
        .. RESET
        .. ": "
        .. WHITE
        .. (instanceName or L["Raid"])
        .. RESET
    )

    for _, raid in ipairs(raids) do

        local state =
            RequirementState(raid)

        print(
            "  "
            .. raid.name
            .. ": "
            .. StatusText(state)
        )

        print(
            "    "
            .. GREY
            .. state.source
            .. " • "
            .. state.difficulty
            .. RESET
        )

    end

    return true

end

------------------------------------------------------------
-- Report Current Raid
------------------------------------------------------------

local function ReportCurrentRaid()

    local inInstance,
          instanceType =
        IsInInstance()

    if not inInstance
        or instanceType ~= "raid" then

        return
    end

    local name,
          _,
          difficultyID,
          _,
          _,
          _,
          _,
          instanceID =
        GetInstanceInfo()

    if not instanceID then
        return
    end

    if not FindTrackedRaid(instanceID) then
        return
    end

    if DB.settings.showZoneMessage then

        PrintRaidStatus(
            instanceID,
            name
        )

    end

end

------------------------------------------------------------
-- Events
------------------------------------------------------------

local EventFrame =
    CreateFrame("Frame")

EventFrame:RegisterEvent(
    "PLAYER_LOGIN"
)

EventFrame:RegisterEvent(
    "PLAYER_ENTERING_WORLD"
)

EventFrame:RegisterEvent(
    "ZONE_CHANGED_NEW_AREA"
)

EventFrame:RegisterEvent(
    "ZONE_CHANGED"
)

EventFrame:RegisterEvent(
    "ZONE_CHANGED_INDOORS"
)

EventFrame:RegisterEvent(
    "ACHIEVEMENT_EARNED"
)

EventFrame:RegisterEvent(
    "QUEST_TURNED_IN"
)

EventFrame:RegisterEvent(
    "QUEST_DATA_LOAD_RESULT"
)

------------------------------------------------------------
-- Event Handler
------------------------------------------------------------

EventFrame:SetScript(
    "OnEvent",
    function(_, event, ...)

        ----------------------------------------------------
        -- Login
        ----------------------------------------------------

        if event == "PLAYER_LOGIN" then

            SLASH_RAIDSKIPTRACKER1 = "/raidskip"
            SLASH_RAIDSKIPTRACKER2 = "/raidskipper"
            SLASH_RAIDSKIPTRACKER3 = "/raidskiptracker"
            SLASH_RAIDSKIPTRACKER4 = "/rst"

            SlashCmdList.RAIDSKIPTRACKER =
                function(msg)

                    msg =
                        (msg or "")
                        :lower()
                        :trim()

                    ------------------------------------------------
                    -- Debug
                    ------------------------------------------------

                    if msg == "debug" then

                        local inInstance,
                              instanceType =
                                IsInInstance()

                        local name, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()

                        print(
                            CYAN
                            .. L["ADDON_NAME"] .. " " .. L["DEBUG"]
                            .. RESET
                            .. ":"
                        )

                        print(
                            " " .. L["INSTANCE"] .. ":",
                            instanceID or "nil",
                            name or "nil"
                        )

                        print(
                            " " .. L["INSTANCE TYPE"] .. ":",
                            instanceType or "nil"
                        )

                        print(
                            " " .. L["DIFFICULTY"] .. ":",
                            difficultyID or "nil"
                        )

                        print(
                            " " .. L["ACCOUNT QUEST API"] .. ":",
                            C_QuestLog
                            and C_QuestLog.IsQuestFlaggedCompletedOnAccount
                            and L["AVAILABLE"]
                            or L["UNAVAILABLE"]
                        )

                        print(
                            " Locale: " .. GetLocale()
                        )

                        return
                    end

                    ------------------------------------------------
                    -- Toggle UI
                    ------------------------------------------------

                    ToggleUI()

                end

            C_Timer.After(
                1,
                ReportCurrentRaid
            )

            return

        end

        --------------------------------------------------------
        -- Quest / Achievement changed
        --------------------------------------------------------

        if event == "ACHIEVEMENT_EARNED" or event == "QUEST_TURNED_IN" then

            if MainFrame and MainFrame:IsShown() then
                RefreshUI()
            end

            C_Timer.After(
                0.25,
                ReportCurrentRaid
            )

            return
        end

        --------------------------------------------------------
        -- Zone change
        --------------------------------------------------------

        if event == "PLAYER_ENTERING_WORLD"
            or event == "ZONE_CHANGED_NEW_AREA"
            or event == "ZONE_CHANGED"
            or event == "ZONE_CHANGED_INDOORS" then

            C_Timer.After(
                0.25,
                ReportCurrentRaid
            )

        end

        if event == "QUEST_DATA_LOAD_RESULT" then
        end
    end
)

------------------------------------------------------------
-- Public API
------------------------------------------------------------

RaidSkipTracker = {
    Version = VERSION,
    Data = RAID_DATA,

    --------------------------------------------------------
    -- Open UI
    --------------------------------------------------------

    Open = function()
        CreateMainFrame()
        MainFrame:Show()
    end,

    --------------------------------------------------------
    -- Refresh UI
    --------------------------------------------------------

    Refresh = function()
        if MainFrame then
            RefreshUI()
        end
    end,

    --------------------------------------------------------
    -- Account Quest Check
    --------------------------------------------------------

    IsQuestCompleteOnAccount = IsQuestCompleteOnAccount,

    --------------------------------------------------------
    -- Get Raid State
    --------------------------------------------------------

    GetRaidState = function(instanceID)

        local raids = FindTrackedRaid(instanceID)

        if not raids then
            return nil
        end

        local result = {}

        for _, raid in ipairs(raids) do
            result[#result + 1] = {
                raid = raid,
                state = RequirementState(raid),
            }
        end

        return result
    end,
}

------------------------------------------------------------
-- Loaded Message
------------------------------------------------------------

print(
    CYAN
    .. "Raid Skip Tracker"
    .. RESET
    .. " v"
    .. VERSION
    .. L["LOADED_MESSAGE_PART1"]
    .. YELLOW
    .. "/raidskip"
    .. RESET
    .. L["LOADED_MESSAGE_PART2"]
)