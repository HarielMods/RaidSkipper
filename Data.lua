local _, RaidSkipper = ...

-- Raid IDs obtained from:
-- https://wowpedia.fandom.com/wiki/InstanceID#Raids
--
-- Most content is skipped by completing quests in raids and are character
-- specific. Battle of Dazar'Alor is the only current exception that is
-- completed by an Achievement and is account wide.

RaidSkipper.data2 = {
    [EXPANSION_NAME5] = {                 -- Warlords of Draenor
        [1205] = { ["full"] = {37031, 37030, 37029} }, -- Blackrock Foundary
        [1448] = {                        -- Hellfire Citadel
            ["Lower"] = { 39501, 39500, 39499 },
            ["Upper"] = { 39505, 39504, 39502 },
        },
    },
    [EXPANSION_NAME6] = {                 -- Legion
        [1520] = { ["full"] = {44285, 44284, 44283} }, -- The Emerald Nightmare
        [1530] = { ["full"] = {45383, 45382, 45381} }, -- The Nighthold
        [1676] = { ["full"] = {47727, 47726, 47725} }, -- Tomb of Sargeras
        [1712] = {
            ["Lower"] = { 49076, 49075, 49032 },      -- Antorus, The Burning Throne Lower
            ["Upper"] = { 49135, 49134, 49133 },      -- Antorus, The Burning Throne Upper
        },
    },
    [EXPANSION_NAME7] = {                 -- Battle for Azeroth
        [2070] = { ["full"] = {13314} }, -- Battle of Dazar'alor
        [2217] = { ["full"] = {58375, 58374, 58373} }, -- Ny'alotha, the Waking City
    },
    [EXPANSION_NAME8] = {                 -- Shadowlands

        [2296] = { ["full"] = {62056, 62055, 62054} }, --Castle Nathria
        [2450] = { ["full"] = {64599, 64598, 64597} }, --Sanctum of Domination
        [2481] = { ["full"] = {65762, 65763, 65764} }, --Sepulcher of the First Ones
    },
    [EXPANSION_NAME9] = {                 -- Dragonflight
        [2522] = { ["full"] = {71020, 71019, 71018} }, -- Vault of the Incarnates
        [2569] = { ["full"] = {76086, 76085, 76083} }, -- Aberrus, the Shadowed Crucible
    },
};

RaidSkipper.data = {
    [EXPANSION_NAME5] = {
        quests = { 37031, 37030, 37029, 39501, 39500, 39499, 39505, 39504, 39502 }
    },
    [EXPANSION_NAME6] = {
        quests = { 44285, 44284, 44283, 45383, 45382, 45381, 47727, 47726, 47725, 49076, 49075, 49032, 49135, 49134,
            49133 }
    },
    [EXPANSION_NAME7] = {
        quests = { 58375, 58374, 58373 },
        achievements = { 13314 },

    },
    [EXPANSION_NAME8] = {
        quests = { 62056, 62055, 62054, 64599, 64598, 64597, 65762, 65763, 65764 }
    },
    [EXPANSION_NAME9] = {
        quests = { 71020, 71019, 71018, 76086, 76085, 76083 }
    },
};

RaidSkipper.raid_skip_quests = {
    [EXPANSION_NAME5] = {
        name = EXPANSION_NAME5, -- "Warlords of Draenor"
        raids = {
            --Blackrock Foundary
            { instanceId = 1205, mythicId = 37031, heroicId = 37030, normalId = 37029 },
            --Hellfire Citadel Lower
            { instanceId = 1448, mythicId = 39501, heroicId = 39500, normalId = 39499 },
            --Hellfire Citadel Upper
            { instanceId = 1448, mythicId = 39505, heroicId = 39504, normalId = 39502 },

            [1205] = { -- Blackrock Foundary
                instanceId = 1205,
                quests = { 37031, 37030, 37029 }
            },

            [1448] = { -- Hellfire Citadel Upper
                instanceId = 1448,
                quests = { 39501, 39500, 39499, 39505, 39504, 39502 }
            },
        }
    },
    [EXPANSION_NAME6] = {
        name = EXPANSION_NAME6, -- "Legion"
        raids = {
            --The Emerald Nightmare
            { instanceId = 1520, mythicId = 44285, heroicId = 44284, normalId = 44283 },
            --The Nighthold
            { instanceId = 1530, mythicId = 45383, heroicId = 45382, normalId = 45381 },
            --Tomb of Sargeras
            { instanceId = 1676, mythicId = 47727, heroicId = 47726, normalId = 47725 },
            --Burning Throne Lower
            { instanceId = 1712, mythicId = 49076, heroicId = 49075, normalId = 49032 },
            --Burning Throne Upper
            { instanceId = 1712, mythicId = 49135, heroicId = 49134, normalId = 49133 }
        }
    },
    [EXPANSION_NAME7] = {
        name = EXPANSION_NAME7, -- "Battle for Azeroth"
        raids = {
            --Battle of Dazar'alor
            { instanceId = 2070, achievementId = 13314, mythicId = 316476 },
            --Ny'alotha, the Waking City
            { instanceId = 2217, mythicId = 58375,      heroicId = 58374, normalId = 58373 }
        }
    },
    [EXPANSION_NAME8] = {
        name = EXPANSION_NAME8, -- "Shadowlands"
        raids = {
            --Castle Nathria
            { instanceId = 2296, mythicId = 62056, heroicId = 62055, normalId = 62054 },
            --Sanctum of Domination
            { instanceId = 2450, mythicId = 64599, heroicId = 64598, normalId = 64597 },
            --Sepulcher of the First Ones
            { instanceId = 2481, mythicId = 65762, heroicId = 65763, normalId = 65764 }
        }
    },
    [EXPANSION_NAME9] = {
        name = EXPANSION_NAME9, -- "Dragonflight"
        raids = {
            --Vault of the Incarnates
            { instanceId = 2522, mythicId = 71020, heroicId = 71019, normalId = 71018 },
            --"Aberrus, the Shadowed Crucible"
            { instanceId = 2569, mythicId = 76086, heroicId = 76085, normalId = 76083 }
        }
    }
}
