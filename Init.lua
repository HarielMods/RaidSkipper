------------------------------------------------------------
--  Raid Skipper: Show what raid content can be skipped   --
------------------------------------------------------------

local addonName, BSRaidSkipper = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
BSRaidSkipper.AceAddon = addon


BSRaidSkipper.playerName = UnitName("player")
BSRaidSkipper.realmName = GetRealmName()
BSRaidSkipper.playerRealm = BSRaidSkipper.playerName .. ' - ' .. BSRaidSkipper.realmName
BSRaidSkipper.playerFaction = ({UnitFactionGroup("player")})[2]
BSRaidSkipper.playerClass = UnitClassBase("player")
BSRaidSkipper.playerColor = RAID_CLASS_COLORS[BSRaidSkipper.playerClass]["colorStr"]

BSRaidSkipper.locale = GetLocale()

BSRaidSkipper.debug = true


--[[
TODO
- Add support for other languages
- Create config screen for options
  - Add ability to ignore hero
  - Close window with escape key
  - Use pop up window or chat window
  - Order expansions by by newest first or oldest first
  - Designate a "main" character
  - Allow font sizing

]]