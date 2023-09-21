-- local BSRS, L = unpack((select(2, ...)))
local addonName, BSRS = ...


function BSRS.AceAddon:OnInitialize()
    BSRS:Debug("BSRS:OnInitialize()")
    
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", BSRS.OnChangeZone)
    -- self:RegisterEvent("QUEST_DATA_LOAD_RESULT", BSRS.OnQuestDataLoadResult)
    
    -- self:RegisterChatCommand("bsraidskipper", BSRS.SlashHandler)
    -- self:RegisterChatCommand("bsrs", BSRS.SlashHandler)

end

function BSRS.AceAddon:OnEnable()
    BSRS:Debug("BSRS:OnEnable()")

    BSRS.PreLoadQuestTitles()
    BSRS.InitPlayerData()

    -- self:RegisterEvent("ZONE_CHANGED_NEW_AREA", BSRS.OnChangeZone)
    -- self:RegisterEvent("QUEST_DATA_LOAD_RESULT", BSRS.OnQuestDataLoadResult)
    -- self:RegisterChatCommand("bsraidskipper", BSRS.SlashHandler)
    -- self:RegisterChatCommand("bsrs", BSRS.SlashHandler)

    -- self:RegisterChatCommand("iac", IsAchievementCompleteHandler)
    -- self:RegisterChatCommand("iqc", IsQuestCompleteHandler)
end

SLASH_BSRAIDSKIPPER1 = "/bsraidskipper"
SLASH_BSRAIDSKIPPER2 = "/bsrs"
SlashCmdList["BSRAIDSKIPPER"] = BSRS.SlashHandler
