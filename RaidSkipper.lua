------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

-- Function style
--   Use PascalCase for API functions
--   Use camelCase for local functions

local _, RaidSkipper = ...
RaidSkipper.Config = {}

if raid_skipper_db == nil then
    raid_skipper_db = {}
end

function RaidSkipper:CreateUI()
    local UIConfig = CreateFrame("Frame", "MUI_BuffFrame", UIParent, "BasicFrameTemplateWithInset")
    UIConfig:SetSize(800, 600)
    UIConfig:SetPoint("CENTER", UIParent, "CENTER", 20, 10)
    
    UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
    UIConfig.title:SetFontObject("GameFontHighlight")
    UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0)
    UIConfig.title:SetText("Raid Skipper")
    local success = UIConfig.title:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE")
    
    UIConfig:Hide()
end

function RaidSkipper:Toggle()

end

function RaidSkipper:init()
    -- Main RaidSkipper slash commands
    SLASH_RAIDSKIPPER1 = "/raidskipper"
    SLASH_RAIDSKIPPER2 = "/rs"

    SlashCmdList.RAIDSKIPPER = RaidSkipper.SlashHandler

    -- development slash commands
    
    SLASH_ISCOMPLETE1 = "/ic"
    SlashCmdList.ISCOMPLETE = function(msg, editBox)
        print("Handle IS_COMPLETE")
    end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_FRAMESTACK1 = "/fs"
    SlashCmdList.FRAMESTACK = function()
        LoadAddon('Blizzard_DebugTools')
        FrameStackTooltip_Toggle()
    end

    for i = 1, NUM_CHAT_WINDOWS do
        _G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
    end
end

local events = CreateFrame("Frame")

function events:OnEvent(event, ...)
    self[event](self, event, ...)
end

function events:ADDON_LOADED(event, addOnName)
    -- print(event, addOnName)
    RaidSkipper:init()
    -- RaidSkipper.reallySaveSkips()
end

function events:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    -- print(event, isLogin, isReload)
    -- TODO: Initialize saved vars
end

function events:PLAYER_LEAVING_WORLD(event)
    -- print(event, isLogin, isReload)
    -- TODO: Initialize saved vars
    -- savePlayerSkips()
    RaidSkipper.reallySaveSkips()
end

function events:QUEST_WATCH_UPDATE(event)
    -- if any of our questIds are in progress then
    --     update current character data
end

function events:ZONE_CHANGED_NEW_AREA(event)
    RaidSkipper.onChangeZone()
end



events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("QUEST_WATCH_UPDATE")
events:SetScript("OnEvent", RaidSkipper.OnEvent)

