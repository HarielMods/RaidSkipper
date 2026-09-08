local ADDON_NAME, L = ...

if GetLocale() == "enUS" then
    L["ADDON_NAME"] = "Raid Skip Tracker"
    L["SKIP UNLOCKED"] = "SKIP UNLOCKED"
    L["NOT COMPLETED"] = "NOT COMPLETED"
    L["UPPER"] = "UPPER"
    L["LOWER"] = "LOWER"
    L["DEBUG"] = "Debug"
    L["DIFFICULTY"] = "Difficulty"
    L["ACCOUNT QUEST API"] = "Account quest API"
    L["LOADED_MESSAGE_PART1"] = " loaded. Type "
    L["LOADED_MESSAGE_PART2"] = " to open."
    L["No tracked quest completed on account"] = "No tracked quest completed on account"
    L["Account-wide quest completion"] = "Account-wide quest completion"
    L["Account-wide"] = "Account-wide"
    L["Account achievement"] = "Account achievement"
    L["Achievement"] = "Achievement"
    L["Quest title unavailable"] = "Quest title unavailable"

    -- Use provided globals
    L["REFRESH"] = REFRESH
    L["RAID"] = RAID
    L["INSTANCE"] = INSTANCE:lower()
    L["INSTANCE TYPE"] = INSTANCE:lower() .. " type"
    L["AVAILABLE"] = AVAILABLE:lower()
    L["UNAVAILABLE"] = UNAVAILABLE:lower()
    L["MYTHIC"] = PLAYER_DIFFICULTY6
    L["HEROIC"] = PLAYER_DIFFICULTY2
    L["NORMAL"] = PLAYER_DIFFICULTY1
end