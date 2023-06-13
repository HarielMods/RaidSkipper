local _, RaidSkipper = ...

RaidSkipper.raid_skip_quests = {
    {
        name = "Warlords of Draenor",
        raids = {
            { name = "Blackrock Foundary",     instanceId = 1205, mythicId = 37031, heroicId = 37030, normalId = 37029 },
            { name = "Hellfire Citadel Lower", instanceId = 1448, mythicId = 39501, heroicId = 39500, normalId = 39499 },
            { name = "Hellfire Citadel Upper", instanceId = 1448, mythicId = 39505, heroicId = 39504, normalId = 39502 }
        }
    },
    {
        name = "Legion",
        raids = {
            { name = "The Emerald Nightmare", instanceId = 1520, mythicId = 44285, heroicId = 44284, normalId = 44283 },
            { name = "The Nighthold",         instanceId = 1530, mythicId = 45383, heroicId = 45382, normalId = 45381 },
            { name = "Tomb of Sargeras",      instanceId = 1676, mythicId = 47727, heroicId = 47726, normalId = 47725 },
            { name = "Burning Throne Lower",  instanceId = 1712, mythicId = 49076, heroicId = 49075, normalId = 49032 },
            { name = "Burning Throne Upper",  instanceId = 1712, mythicId = 49135, heroicId = 49134, normalId = 49133 }
        }
    },
    {
        name = "Battle for Azeroth",
        raids = {
            { name = "Battle of Dazar'alor", instanceId = 2070, achievementId = 13314, mythicId = 316476 },
            { name = "Ny'alotha, the Waking City", instanceId = 2217, mythicId = 58375, heroicId = 58374, normalId = 58373 }
        }
    },
    {
        name = "Shadowlands",
        raids = {
            { name = "Castle Nathria", instanceId = 2296, mythicId = 62056, heroicId = 62055, normalId = 62054 },
            { name = "Sanctum of Domination", instanceId = 2450, mythicId = 64599, heroicId = 64598, normalId = 64597 },
            { name = "Sepulcher of the First Ones", instanceId = 2481, mythicId = 65762, heroicId = 65763, normalId = 65764 }
        }
    },
    {
        name = "Dragonflight",
        raids = {
            { name = "Vault of the Incarnates", instanceId = 14030, mythicId = 71020, heroicId = 71019, normalId = 71018 },
            -- Aberrus seems to only have a heroic and mythic quest, no normal quest https://www.wowhead.com/zone=14663/aberrus-the-shadowed-crucible#quests
            { name = "Aberrus, the Shadowed Crucible", instanceId = 14663, mythicId = 76086, heroicId = 76085, normalId = 76083 },
        }
    },
    {
        name = "Dragonflight",
        raids = {
            { name = "Vault of the Incarnates", instanceId = 14030, mythicId = 71020, heroicId = 71019, normalId = 71018 },
            { name = "Aberrus, the Shadowed Crucible", instanceId = 14663, mythicId = 76086, heroicId = 76085, normalId = 76083 }
        }
    }
}

