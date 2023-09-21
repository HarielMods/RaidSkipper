-- local BSRS, L = unpack((select(2, ...)))
local addonName, BSRS = ...


-- Raid IDs obtained from:
-- https://wowpedia.fandom.com/wiki/InstanceID#Raids

BSRS.quests = {
    -- Warlords of Draenor
    37031, -- Blackrock Foundary Mythic
    37030, -- Blackrock Foundary Heroic
    37029, -- Blackrock Foundary Normal
    39501, -- Hellfire Citadel Mythic Lower
    39500, -- Hellfire Citadel Heroic Lower
    39499, -- Hellfire Citadel Normal Lower
    39505, -- Hellfire Citadel Mythic Upper
    39504, -- Hellfire Citadel Heroic Upper
    39502, -- Hellfire Citadel Normal Upper
    -- Legion
    44285, -- The Emerald Nightmare Mythic
    44284, -- The Emerald Nightmare Heroic
    44283, -- The Emerald Nightmare Normal
    45383, -- The Nighthold Mythic
    45382, -- The Nighthold Heroic
    45381, -- The Nighthold Normal
    47727, -- Tomb of Sargeras Mythic
    47726, -- Tomb of Sargeras Heroic
    47725, -- Tomb of Sargeras Normal
    49076, -- Antorus, the Burning Throne Mythic Lower
    49075, -- Antorus, the Burning Throne Heroic Lower
    49032, -- Antorus, the Burning Throne Normal Lower
    49135, -- Antorus, the Burning Throne Mythic Upper
    49134, -- Antorus, the Burning Throne Heroic Upper
    49133, -- Antorus, the Burning Throne Normal Upper
    -- Battle for Azeroth
    -- 13314, -- Battle of Dazar'alor
    58375, -- Ny'alotha, the Waking City Mythic
    58374, -- Ny'alotha, the Waking City Heroic
    58373, -- Ny'alotha, the Waking City Normal
    -- Shadowlands
    62056, -- Castle Nathria Mythic
    62055, -- Castle Nathria Heroic
    62054, -- Castle Nathria Normal
    64599, -- Sanctum of Domination Mythic
    64598, -- Sanctum of Domination Heroic
    64597, -- Sanctum of Domination Normal
    65762, -- Sepulcher of the First Ones Mythic
    65763, -- Sepulcher of the First Ones Heroic
    65764, -- Sepulcher of the First Ones Normal
    -- Dragonflight
    71020, -- Vault of the Incarnates Mythic
    71019, -- Vault of the Incarnates Heroic
    71018, -- Vault of the Incarnates Normal
    76086, -- Aberrus, the Shadowed Crucible Mythic
    76085, -- Aberrus, the Shadowed Crucible Heroic
    76083 -- Aberrus, the Shadowed Crucible Normal
}

BSRS.raid_skip_quests = {
    {
        name = EXPANSION_NAME4,
        expid = LE_EXPANSION_MISTS_OF_PANDARIA,
        raids = {
            -- Siege of Orgrimar
            [1136] = {
                instanceId = 1136,
                achievementId = 8482
            }
        }
    },
    {
        name = EXPANSION_NAME5,
        expid = LE_EXPANSION_WARLORDS_OF_DRAENOR,
        raids = {
            -- Blackrock Foundary
            [1205] = {
                instanceId = 1205, 
                questGroups = {{bossId = nil, mythicId = 37031, heroicId = 37030, normalId = 37029}}
            },
            -- Hellfire Citadel
            [1448] = {
                instanceId = 1448,
                questGroups = {
                    {bossId = 1372, mythicId = 39501, heroicId = 39500, normalId = 39499},
                    {bossId = 1395, mythicId = 39505, heroicId = 39504, normalId = 39502}
                }
            }
        }
    },
    {
        name = EXPANSION_NAME6,
        expid = LE_EXPANSION_LEGION,
        raids = {
            -- The Emerald Nightmare
            [1520] = {
                instanceId = 1520, 
                questGroups = {{bossId = nil, mythicId = 44285, heroicId = 44284, normalId = 44283}} 
            },
            -- The Nighthold
            [1530] = {
                instanceId = 1530, 
                questGroups = {{bossId = nil, mythicId = 45383, heroicId = 45382, normalId = 45381}} 
            },
            -- Tomb of Sargeras
            [1676] = {
                instanceId = 1676, 
                questGroups = {{bossId = nil, mythicId = 47727, heroicId = 47726, normalId = 47725}} 
            },
            -- Burning Throne
            [1712] = {
                instanceId = 1712, 
                questGroups = {
                    {bossId = 2009, mythicId = 49076, heroicId = 49075, normalId = 49032},
                    {bossId = 1984, mythicId = 49135, heroicId = 49134, normalId = 49133}
                } 
            }
        }
    },
    {
        name = EXPANSION_NAME7,
        expid = LE_EXPANSION_BATTLE_FOR_AZEROTH,
        raids = {
            -- Battle of Dazar'alor
            [2070] = {
                instanceId = 2070, 
                achievementId = 13314
            },
            -- Ny'alotha, the Waking City
            [2217] = {
                instanceId = 2217, 
                questGroups = {{bossId = nil, mythicId = 58375, heroicId = 58374, normalId = 58373}} 
            }
        }
    },
    {
        name = EXPANSION_NAME8,
        expid = LE_EXPANSION_SHADOWLANDS,
        raids = {
            -- Castle Nathria
            [2296] = {
                instanceId = 2296, 
                questGroups = {
                    {bossId = nil, mythicId = 62056, heroicId = 62055, normalId = 62054}
                }
            },
            -- Sanctum of Domination
            [2450] = {
                instanceId = 2450, 
                questGroups = {
                    {bossId = nil, mythicId = 64599, heroicId = 64598, normalId = 64597}
                }
            },
            -- Sepulcher of the First Ones
            [2481] = {
                instanceId = 2481, 
                questGroups = {
                    {bossId = nil, mythicId = 65762, heroicId = 65763, normalId = 65764}
                } 
            }
        }
    },
    {
        name = EXPANSION_NAME9,
        expid = LE_EXPANSION_DRAGONFLIGHT,
        raids = {
            -- Vault of the Incarnates
            [2522] = {
                instanceId = 2522, 
                questGroups = {
                    {bossId = nil, mythicId = 71020, heroicId = 71019, normalId = 71018}
                }
            },
            -- Aberrus, the Shadowed Crucible
            [2569] = {
                instanceId = 2569, 
                questGroups = {
                    {bossId = nil, mythicId = 76086, heroicId = 76085, normalId = 76083}
                } 
            }
        }
    }
}
