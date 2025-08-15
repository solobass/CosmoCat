local GameConfig = {}

-- Level configuration with cat-themed names
GameConfig.Levels = {
    [1] = { name = "Cosmo Kitten", pointsRequired = 0, catModel = "CosmoKitten" },
    [2] = { name = "Stellar Whisker", pointsRequired = 1, catModel = "StellarWhisker" },
    [3] = { name = "Nebula Paws", pointsRequired = 2, catModel = "NebulaPaws" },
    [4] = { name = "Galaxy Tail", pointsRequired = 3, catModel = "GalaxyTail" },
    [5] = { name = "Cosmic Whisker", pointsRequired = 4, catModel = "CosmicWhisker" },
    [6] = { name = "Astro Claws", pointsRequired = 5, catModel = "AstroClaws" },
    [7] = { name = "Void Hunter", pointsRequired = 6, catModel = "VoidHunter" },
    [8] = { name = "Star Chaser", pointsRequired = 7, catModel = "StarChaser" },
    [9] = { name = "Lunar Shadow", pointsRequired = 8, catModel = "LunarShadow" },
    [10] = { name = "Cosmo Master", pointsRequired = 9, catModel = "CosmoMaster" }
}

-- Game settings
GameConfig.MaxCatTreats = 25
GameConfig.CatTreatRespawnTime = 3 -- seconds
GameConfig.PlayAreaSize = Vector3.new(1000, 100, 1000) -- Width, Height, Depth

return GameConfig
