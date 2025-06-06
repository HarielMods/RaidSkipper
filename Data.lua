local _, RaidSkipper = ...

-- Raid IDs obtained from:
-- https://warcraft.wiki.gg/wiki/InstanceID#Raids

RaidSkipper.raid_skip_quests = {
    {
        name = EXPANSION_NAME4,
        expansionId = LE_EXPANSION_MISTS_OF_PANDARIA,
        raids = {
            -- Siege of Orgrimmar
            { instanceId = 1136, achievementId = 8482 }
        }
    },
    {
        name = EXPANSION_NAME5,
        expansionId = LE_EXPANSION_WARLORDS_OF_DRAENOR,
        raids = {
            -- Blackrock Foundary
            { instanceId = 1205,  mythicId = 37031, heroicId = 37030, normalId = 37029 },
            -- Hellfire Citadel Lower
            { instanceId = 1448, mythicId = 39501, heroicId = 39500, normalId = 39499 },
            -- Hellfire Citadel Upper
            { instanceId = 1448, mythicId = 39505, heroicId = 39504, normalId = 39502 }
        }
    },
    {
        name = EXPANSION_NAME6,
        expansionId = LE_EXPANSION_LEGION,
        raids = {
            -- The Emerald Nightmare
            { instanceId = 1520, mythicId = 44285, heroicId = 44284, normalId = 44283 },
            -- The Nighthold
            { instanceId = 1530, mythicId = 45383, heroicId = 45382, normalId = 45381 },
            -- Tomb of Sargeras
            { instanceId = 1676, mythicId = 47727, heroicId = 47726, normalId = 47725 },
            -- Burning Throne Lower
            { instanceId = 1712, mythicId = 49076, heroicId = 49075, normalId = 49032 },
            -- Burning Throne Upper
            { instanceId = 1712, mythicId = 49135, heroicId = 49134, normalId = 49133 }
        }
    },
    {
        name = EXPANSION_NAME7,
        expansionId = LE_EXPANSION_BATTLE_FOR_AZEROTH,
        raids = {
            -- Battle of Dazar'alor
            { instanceId = 2070, achievementId = 13314 },
            -- Ny'alotha, the Waking City
            { instanceId = 2217, mythicId = 58375, heroicId = 58374, normalId = 58373 }
        }
    },
    {
        name = EXPANSION_NAME8,
        expansionId = LE_EXPANSION_SHADOWLANDS,
        raids = {
            -- Castle Nathria
            { instanceId = 2296, mythicId = 62056, heroicId = 62055, normalId = 62054 },
            -- Sanctum of Domination
            { instanceId = 2450, mythicId = 64599, heroicId = 64598, normalId = 64597 },
            -- Sepulcher of the First Ones
            { instanceId = 2481, mythicId = 65762, heroicId = 65763, normalId = 65764 }
        }
    },
    {
        name = EXPANSION_NAME9,
        expansionId = LE_EXPANSION_DRAGONFLIGHT,
        raids = {
            -- Vault of the Incarnates
            { instanceId = 2522, mythicId = 71020, heroicId = 71019, normalId = 71018 },
            -- Aberrus, the Shadowed Crucible
            { instanceId = 2569, mythicId = 76086, heroicId = 76085, normalId = 76083 },
            -- Amirdrassil, the Dream's Hope
            { instanceId = 2549, mythicId = 78602, heroicId = 78601, normalId = 78600 }
        }
    },
    {
        name = EXPANSION_NAME10,
        expansionId = LE_EXPANSION_WAR_WITHIN,
        raids = {
            -- Nerub-ar Palace: For Nerubian Eyes Only
            { instanceId = 2657, mythicId = 82639, heroicId = 82638, normalId = 82629 },
            -- Liberation of Undermine: Splitting Pairs
            { instanceId = 2769, mythicId = 89353, heroicId = 89352, normalId = 89351 }
        }
    }
}
