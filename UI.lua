-- local BSRS, L = unpack((select(2, ...)))
local addonName, BSRS = ...

local window = nil
local state = "BSRaidSkipperTabThisHero"
local stateHeroName = nil

local tabs = nil

local scroll = nil
local scrollHeight = 10000
local countLabel, tabLabel, textArea, heroesContent, heroesContentDataString = nil, nil, nil, nil, nil
local heroNames = {}
local heroRealmNames = {}
local tabStyle = 2 -- [0,1,2]

local function getHeroNames()
    for heroRealmName, _ in pairs(BSRaidSkipperData["heroes"]) do
        table.insert(heroRealmNames, heroRealmName)
        table.insert(heroNames, BSRaidSkipperData["heroes"][heroRealmName]["name"] or "Unknonwn Hero")
    end
    table.sort(heroRealmNames)
    table.sort(heroNames)
end

local lastState = nil
local function updateHeroesDisplay(forceRefresh)
    if state ~= lastState then forceRefresh = true end
	lastState = state

    if forceRefresh then
    else
    end

    heroesContentDataString:SetText("")
    
    local paneContent = ""
    if state == "BSRaidSkipperTabAllHeroes" then
        currentTab = "AllHeroes"
		tabLabel:SetText("All Heroes")        
        
        BSRS:Debug(#BSRaidSkipperData["heroes"])

        for heroName, _ in pairs(BSRaidSkipperData["heroes"]) do
            BSRS:Debug("heroName: " .. heroName)
            paneContent = paneContent .. heroName .. "\n\n"
            local statuses = BSRS:GetHeroStatuses(heroName)
            for _, questStatus in ipairs(statuses) do
                -- BSRS:Debug("questStatus: " .. questStatus)
                paneContent = paneContent .. questStatus .. "\n"
            end
            paneContent = paneContent .. "\n"
        end

	elseif state == "BSRaidSkipperTabThisHero" then
        currentTab = "ThisHero"
        tabLabel:SetText(BSRS.playerRealm)        

        local statuses = BSRS:GetHeroStatuses(BSRS.playerRealm)
        for _, v in ipairs(statuses) do
            paneContent = paneContent .. v .. "\n"
        end
    else
        currentTab = state
        tabLabel:SetText(stateHeroName)        

        local statuses = BSRS:GetHeroStatuses(stateHeroName)
        for _, v in ipairs(statuses) do
            paneContent = paneContent .. v .. "\n"
        end
	end
    heroesContentDataString:SetText(paneContent)


    for i, t in next, tabs do
		if state == t:GetName() then
			PanelTemplates_SelectTab(t)
		else
			PanelTemplates_DeselectTab(t)
		end
	end
end

local function setActiveTab(tab)
    BSRS:Debug("setActiveTab() ")
	tabLabel:Show()

	state = type(tab) == "table" and tab:GetName() or tab
    stateHeroName = type(tab) == "table" and tab.hero or nil
    BSRS:Debug("setActiveTab() " .. state)
	updateHeroesDisplay(true)
end

local function createHeroesWindow()
    -- window = CreateFrame("Frame", "BSRaidSkipperFrame", UIParent, "BasicFrameTemplateWithInset")
    window = CreateFrame("Frame", "BSRaidSkipperFrame", UIParent)
    window:Hide()

    window:SetFrameStrata("DIALOG")
    -- window:SetSize(800, 500)
    window:SetWidth(800)
    window:SetHeight(500)
    window:SetPoint("CENTER")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetClampedToScreen(true)
    window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:SetScript("OnShow", function()
		PlaySound(844) -- SOUNDKIT.IG_QUEST_LOG_OPEN
	end)
    window:SetScript("OnHide", function()
		PlaySound(845) -- SOUNDKIT.IG_QUEST_LOG_CLOSE
	end)

    local titlebg = window:CreateTexture(nil, "BORDER")
	titlebg:SetTexture(251966) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background"
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

    local dialogbg = window:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetTexture(136548) --"Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1"
	dialogbg:SetPoint("TOPLEFT", 8, -12)
	dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
	dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

	local topleft = window:CreateTexture(nil, "BORDER")
	topleft:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	topleft:SetWidth(64)
	topleft:SetHeight(64)
	topleft:SetPoint("TOPLEFT")
	topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

	local topright = window:CreateTexture(nil, "BORDER")
	topright:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	topright:SetWidth(64)
	topright:SetHeight(64)
	topright:SetPoint("TOPRIGHT")
	topright:SetTexCoord(0.625, 0.75, 0, 1)

	local top = window:CreateTexture(nil, "BORDER")
	top:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	top:SetHeight(64)
	top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
	top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
	top:SetTexCoord(0.25, 0.369140625, 0, 1)

	local bottomleft = window:CreateTexture(nil, "BORDER")
	bottomleft:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottomleft:SetWidth(64)
	bottomleft:SetHeight(64)
	bottomleft:SetPoint("BOTTOMLEFT")
	bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

	local bottomright = window:CreateTexture(nil, "BORDER")
	bottomright:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottomright:SetWidth(64)
	bottomright:SetHeight(64)
	bottomright:SetPoint("BOTTOMRIGHT")
	bottomright:SetTexCoord(0.875, 1, 0, 1)

	local bottom = window:CreateTexture(nil, "BORDER")
	bottom:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottom:SetHeight(64)
	bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
	bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

	local left = window:CreateTexture(nil, "BORDER")
	left:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	left:SetWidth(64)
	left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
	left:SetTexCoord(0.001953125, 0.125, 0, 1)

	local right = window:CreateTexture(nil, "BORDER")
	right:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	right:SetWidth(64)
	right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
	right:SetTexCoord(0.1171875, 0.2421875, 0, 1)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", C_EditMode and -3 or 2, C_EditMode and -3 or 1)
	close:SetScript("OnClick", BSRS.CloseHeroes)

	-- countLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	-- countLabel:SetPoint("TOPRIGHT", titlebg, -6, -3)
	-- countLabel:SetJustifyH("RIGHT")
	-- countLabel:SetTextColor(1, 1, 1, 1)

    tabLabel = CreateFrame("Button", nil, window)
	tabLabel:SetNormalFontObject("GameFontNormalLeft")
	tabLabel:SetHighlightFontObject("GameFontHighlightLeft")
	tabLabel:SetPoint("TOPLEFT", titlebg, 6, -1)
	tabLabel:SetPoint("BOTTOMRIGHT", titlebg, "BOTTOMRIGHT", -26, 1)
    -- tabLabel:SetText("Heroes")
    tabLabel:SetText(BSRS.playerRealm)

    -- Content Areas

    local Panel = CreateFrame("Frame", nil, window)
    Panel:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)

    scroll = CreateFrame("ScrollFrame", "BSRaidSkipperScroll", window, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -34, 16)

    local heroesContent = CreateFrame("Frame", "BSRaidSkipperScrollContent", scroll)
    heroesContent:SetPoint("TOPLEFT", scroll, "BOTTOMLEFT", 0, 0)
    heroesContent:SetSize(750, scrollHeight)
    scroll:SetScrollChild(heroesContent)

    heroesContentDataString = heroesContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    heroesContentDataString:SetAllPoints(heroesContent)
    heroesContentDataString:SetJustifyH("LEFT")
    heroesContentDataString:SetJustifyV("TOP")
    heroesContentDataString:SetWordWrap(true)

    local EndOfScrollFrame = heroesContent:CreateFontString()
    EndOfScrollFrame:SetFont("Fonts\\FRIZQT__.TTF", 20, "GameFontHighlightSmall")
    EndOfScrollFrame:SetPoint("TOP", 0, -1 * scrollHeight)
    EndOfScrollFrame:SetTextColor(1, 0, 0, 1)
    EndOfScrollFrame:SetText("End of ScrollFrame")

    getHeroNames()

    
    if tabStyle == 2 then
        -- Bottom Tab for each hero
        local heroTabs = {}
        
        local heroTab1 = CreateFrame("Button", "BSRaidSkipperTabHero1", window, C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
        heroTab1:SetFrameStrata("FULLSCREEN")
        heroTab1:SetPoint("TOPLEFT", window, "BOTTOMLEFT", C_EditMode and 10 or 0, C_EditMode and 6 or 8)
        heroTab1:SetText(BSRS.playerName)
        heroTab1:SetScript("OnLoad", nil)
        heroTab1:SetScript("OnShow", nil)
        heroTab1:SetScript("OnClick", setActiveTab)
        heroTab1.hero = BSRS.playerRealm

        heroTabs[1] = heroTab1

        local m = 1
        for n = 1, #heroNames do
            local heroRealmName = heroRealmNames[n]
            if heroRealmName ~= BSRS.playerRealm then -- we already put this hero first
                local heroName = heroNames[n]
                m = m + 1
                
                local newTab = CreateFrame("Button", "BSRaidSkipperTabHero" .. tostring(m), window, C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
                newTab:SetFrameStrata("FULLSCREEN")
                newTab:SetPoint("LEFT", heroTabs[m-1], "RIGHT")
                newTab:SetText(heroName)
                newTab:SetScript("OnLoad", nil)
                newTab:SetScript("OnShow", nil)
                newTab:SetScript("OnClick", setActiveTab)
                newTab.hero = heroRealmName
                        
                heroTabs[m] = newTab
            end
        end

        tabs = heroTabs

    elseif tabStyle == 1 then
        -- Next and Prev through Heroes

    else
        -- Bottom Tab Buttons (This Hero, All Heroes)

        local thisHero = CreateFrame("Button", "BSRaidSkipperTabThisHero", window, C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
        thisHero:SetFrameStrata("FULLSCREEN")
        thisHero:SetPoint("TOPLEFT", window, "BOTTOMLEFT", C_EditMode and 10 or 0, C_EditMode and 6 or 8)
        thisHero:SetText("This Hero") -- L["This Hero"]
        thisHero:SetScript("OnLoad", nil)
        thisHero:SetScript("OnShow", nil)
        thisHero:SetScript("OnClick", setActiveTab)
        thisHero.heroes = "thisHero"
        
        local allHeroes = CreateFrame("Button", "BSRaidSkipperTabAllHeroes", window, C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
        allHeroes:SetFrameStrata("FULLSCREEN")
        allHeroes:SetPoint("LEFT", thisHero, "RIGHT")
        allHeroes:SetText("All Heroes") -- L["All Heroes"]
        allHeroes:SetScript("OnLoad", nil)
        allHeroes:SetScript("OnShow", nil)
        allHeroes:SetScript("OnClick", setActiveTab)
        allHeroes.heroes = "allHeroes"
        
        tabs = {thisHero, allHeroes}
    end

    -- BSRS:Debug("createHeroesWindow() tabs count: " .. #tabs)
    local size = (C_EditMode and 780 or 800) / #heroNames --#tabs
    for i, t in next, tabs do
        PanelTemplates_TabResize(t, nil, size, size)
        if i == 1 then
            PanelTemplates_SelectTab(t)
        else
            PanelTemplates_DeselectTab(t)
        end
    end
end

local function show()
	if createHeroesWindow then
		createHeroesWindow()
		createHeroesWindow = nil
	end
	updateHeroesDisplay(true)
	window:Show()
end

function BSRS:CloseHeroes()
	window:Hide()
end

function BSRS:OpenHeroes()
	if window and window:IsShown() then
		-- Window is already open, we just need to update various texts.
		return
	end
    
	show()
end
