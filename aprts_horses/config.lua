Config = {}
Config.Debug = false
Config.StableSlots = 5
Config.ShowTagsOnHorses = false
Config.drawDistance = 60
Config.shoeTime = 15 -- počet dní, po které zůstane kůň podkován
Config.shoeBonus = 500
Config.InventoryPrefix = "horse_"
Config.SellTimeout = 3*60*60
Config.Sell = 20
Config.WebHook =
    "https://discord.com/api/webhooks/1315374247022956685/gb9OR4Fml_DbrnqOx4iAlUCYRbBMIFkCX7JsiBuXu3z96HThyP1H1Dzd97lIey8aIxco"
Config.ServerName = 'WestHaven Horses Loger'
Config.DiscordColor = 16753920

Config.KVP = "aprts_horses"
Config.StableKey = {
    ["key"] = 0xA1ABB953,
    ["label"] = "G"
}
Config.SellKey = {
    ["key"] = 0xCBDB82A8,
    ["label"] = "E"
}

Config.StablesKey = {
    ["key"] = 0xD9D0E1C0,
    ["label"] = "SPACE"
}
Config.BagsKey = {}
Config.BagsKey.label = "R"
Config.BagsKey.key = 0xE30CD707

Config.keys = {

    drink = 0xD8F73058, -- [U] Horse Drink when in Water
    rest = 0x620A6C5E, -- [V] Horse Rest
    sleep = 0x43CDA5B0, -- [Z] Horse Sleep
    wallow = 0x9959A6F0, -- [C] Horse Wallow
    loot = 0x27D1C284, -- [R] Loot Horse
    trade = 0x430593AA -- [LEFTBRACKET] Trade Horse
}

Config.Animation = {
    dict = "mech_pickup@saddle@fallback",
    name = "stow_lt_fallback",
    flag = 17,
    type = 'standard',
    prop = "p_cs_saddle01x",
    time = 2000
}
Config.Animation2 = {
    dict = "mech_pickup@saddle@gear_transfer@secure_gear@lf",
    name = "secure_gear_lf",
    flag = 17,
    type = 'standard',
    prop = "p_cs_saddle01x",
    time = 10000
}
Config.multiStable = false
Config.HorseShopNPC = {
    --     {
    --     id = 1,
    --     obj = nil,
    --     name = "BlackWater Horses",
    --     model = "RE_HORSERACE_FEMALES_01",
    --     coords = vector3(-880.8336, -1364.1746, 43.5259),
    --     horseCoords = vector3(-888.0406, -1362.8115, 43.5021),
    --     cameraCoords = vector3(-892.1740, -1360.7700, 43.4898),
    --     horseHeading = 12.4563,
    --     heading = 127.4563,
    --     shopDistance = 2.0
    -- }
}

Config.horseLoot = {{
    name = "Kartáč na koně",
    item = "tool_horse_brush",
    count = 1,
    chance = 0.5
}, {
    name = "Jablko",
    item = "product_apple",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek na sušák masa",
    item = "recipe_dryingframe",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek na kemp",
    item = "recipe_campstick",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek na ohniště",
    item = "recipe_campfire",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek na napínák kůží",
    item = "recipe_hideframe",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek na kempové ohniště",
    item = "recipe_stonecampfire",
    count = 1,
    chance = 0.5
}, {
    name = "Plánek Sušák na tabák",
    item = "recipe_tobacodryingframe",
    count = 1,
    chance = 0.5
}}

NPCs = {{
    id = 1,
    NPC = nil,
    blip = nil,
    name = "Stablehand BlackWater",
    coords = vector3(-873.8472, -1367.6451, 43.5295),
    spawnCoords = vector3(-873.8472, -1367.6451, 43.5295),
    displayCoords = vector3(-866.7798, -1361.5259, 43.6588),
    displayCoords2 = vector3(-863.3885, -1361.4568, 43.6402),
    displayCoords3 = vector3(-859.7682, -1361.3085, 43.6374),
    displayCoords4 = vector3(-863.8909, -1370.7595, 43.7198),
    displayCoords5 = vector3(-867.5687, -1371.0087, 43.6704),
    displayH = 83.0,
    camCoords = vector3(-868.2819, -1364.1720, 43.6451),
    camCoords2 = vector3(-864.9584, -1364.0707, 43.6247),
    camCoords3 = vector3(-861.4351, -1364.4197, 43.5483),
    camCoords4 = vector3(-864.4877, -1367.7509, 43.5466),
    camCoords5 = vector3(-864.6032, -1367.9844, 43.5462),
    h = 12.0,
    distance = 2,
    model = "U_M_M_BwmStablehand_01"
}, {
    id = 2,
    NPC = nil,
    blip = nil,
    name = "Stablehand Valentine",
    coords = vector3(-370.902191, 784.370605, 116.165375),
    spawnCoords = vector3(-353.9294, 792.3561, 116.2198),
    displayCoords = vector3(-363.1650, 781.6769, 116.1622),
    displayCoords2 = vector3(-366.1208, 781.6475, 116.1436),
    displayCoords3 = vector3(-368.9468, 781.3415, 116.1488),
    displayCoords4 = vector3(-371.6231, 781.3674, 116.1681),
    displayCoords5 = vector3(-374.7301, 781.0951, 116.1925),
    displayH = 340.16,
    camCoords = vector3(-364.3521, 785.2975, 116.1711),
    camCoords2 = vector3(-367.3132, 785.5756, 116.1620),
    camCoords3 = vector3(-370.1371, 785.0444, 116.1627),
    camCoords4 = vector3(-372.8354, 785.1599, 116.1724),
    camCoords5 = vector3(-375.3301, 784.6939, 116.1895),
    h = 340.16,
    distance = 2,
    model = "U_M_M_BwmStablehand_01"
}, {
    id = 3,
    NPC = nil,
    blip = nil,
    name = "Stablehand SaintDenis",
    coords = vector3(2505.247803, -1461.973511, 46.314400),
    spawnCoords = vector3(2502.402832, -1458.138794, 46.312782),
    displayCoords = vector3(2508.809082, -1453.287720, 46.426392),
    displayCoords2 = vector3(2508.668701, -1450.187500, 46.403481),
    displayCoords3 = vector3(2509.120850, -1446.911377, 46.362873),
    displayCoords4 = vector3(2509.154541, -1443.509766, 46.414951),
    displayCoords5 = vector3(2509.375000, -1440.747314, 46.394600),
    displayH = 81.02,
    camCoords = vector3(2503.979492, -1454.780762, 46.313931),
    camCoords2 = vector3(2502.833740, -1450.975220, 46.312683),
    camCoords3 = vector3(2502.841797, -1447.782593, 46.312473),
    camCoords4 = vector3(2503.565674, -1444.289307, 46.312355),
    camCoords5 = vector3(2503.437012, -1441.235596, 46.313183),
    h = 81.02,
    distance = 2,
    model = "U_M_M_BwmStablehand_01"
}, {
    id = 4,
    NPC = nil,
    blip = nil,
    name = "Stáje Wapiti",
    coords = vector3(412.509216, 2227.365234, 253.992569),
    spawnCoords = vector3(443.725677, 2234.328613, 247.941238),
    displayCoords = vector3(443.725677, 2234.328613, 247.941238),
    displayCoords2 = vector3(2508.668701, -1450.187500, 46.403481),
    displayCoords3 = vector3(2509.120850, -1446.911377, 46.362873),
    displayCoords4 = vector3(2509.154541, -1443.509766, 46.414951),
    displayCoords5 = vector3(2509.375000, -1440.747314, 46.394600),
    displayH = 172.3,
    camCoords = vector3(444.064819, 2237.572266, 249.242599),
    camCoords2 = vector3(2502.833740, -1450.975220, 46.312683),
    camCoords3 = vector3(2502.841797, -1447.782593, 46.312473),
    camCoords4 = vector3(2503.565674, -1444.289307, 46.312355),
    camCoords5 = vector3(2503.437012, -1441.235596, 46.313183),
    h = 172.3,
    distance = 2,
    model = "msp_native1_males_01"
}, {
    id = 5,
    NPC = nil,
    blip = nil,
    name = "Stáje Nawayo",
    coords = vector3(-2933.685791, -2079.429443, 77.641418),
    spawnCoords = vector3(-2931.535400, -2082.580811, 76.615898),
    displayCoords = vector3(-2931.535400, -2082.580811, 76.615898),
    displayCoords2 = vector3(2508.668701, -1450.187500, 46.403481),
    displayCoords3 = vector3(2509.120850, -1446.911377, 46.362873),
    displayCoords4 = vector3(2509.154541, -1443.509766, 46.414951),
    displayCoords5 = vector3(2509.375000, -1440.747314, 46.394600),
    displayH = 357.3,
    camCoords = vector3(-2933.976807, -2082.465332, 77.585045),
    camCoords2 = vector3(2502.833740, -1450.975220, 46.312683),
    camCoords3 = vector3(2502.841797, -1447.782593, 46.312473),
    camCoords4 = vector3(2503.565674, -1444.289307, 46.312355),
    camCoords5 = vector3(2503.437012, -1441.235596, 46.313183),
    h = 357.3,
    distance = 2,
    model = "msp_native1_males_01"
}, {
    id = 5,
    NPC = nil,
    blip = nil,
    name = "Stáje TW",
    coords = vector3(-5514.695312, -3040.989258, -2.387692),
    spawnCoords = vector3(-5490.796875, -2877.321533, -4.943555),
    displayCoords = vector3(-5490.796875, -2877.321533, -4.943555),
    displayCoords2 = vector3(2508.668701, -1450.187500, 46.403481),
    displayCoords3 = vector3(2509.120850, -1446.911377, 46.362873),
    displayCoords4 = vector3(2509.154541, -1443.509766, 46.414951),
    displayCoords5 = vector3(2509.375000, -1440.747314, 46.394600),
    displayH = 141.15,
    camCoords = vector3(-5487.331543, -2879.687988, -4.800018),
    camCoords2 = vector3(-5487.331543, -2879.687988, -4.800018),
    camCoords3 = vector3(2502.841797, -1447.782593, 46.312473),
    camCoords4 = vector3(2503.565674, -1444.289307, 46.312355),
    camCoords5 = vector3(2503.437012, -1441.235596, 46.313183),
    h = 141.15,
    distance = 2,
    model = "U_M_M_BwmStablehand_01"
}, {
    id = 6,
    NPC = nil,
    blip = nil,
    name = "Stáje Annesburg",
    coords = vector3(2967.345459, 1430.956299, 44.744728),
    spawnCoords = vector3(2970.245117, 1429.478760, 44.763470),
    displayCoords = vector3(2970.245117, 1429.478760, 44.763470),
    displayCoords2 = vector3(2508.668701, -1450.187500, 46.403481),
    displayCoords3 = vector3(2509.120850, -1446.911377, 46.362873),
    displayCoords4 = vector3(2509.154541, -1443.509766, 46.414951),
    displayCoords5 = vector3(2509.375000, -1440.747314, 46.394600),
    displayH = 285.9,
    camCoords = vector3(2973.386719, 1425.468994, 44.705944),
    camCoords2 = vector3(2973.386719, 1425.468994, 44.705944),
    camCoords3 = vector3(2502.841797, -1447.782593, 46.312473),
    camCoords4 = vector3(2503.565674, -1444.289307, 46.312355),
    camCoords5 = vector3(2503.437012, -1441.235596, 46.313183),
    h = 285.9,
    distance = 2,
    model = "U_M_M_BwmStablehand_01"
}}

HorseDifficulty = {
    ["Tennessee Walker"] = {
        time = 3000,
        skill = 15
    },
    ["American Paint"] = {
        time = 3000,
        skill = 15
    },
    ["American Standardbred"] = {
        time = 3000,
        skill = 15
    },
    ["Andalusian"] = {
        time = 3000,
        skill = 15
    },
    ["Appaloosa"] = {
        time = 3000,
        skill = 15
    },
    ["Arabian"] = {
        time = 3000,
        skill = 15
    },
    ["Ardennes"] = {
        time = 3000,
        skill = 15
    },
    ["Belgian Draft"] = {
        time = 3000,
        skill = 15
    },
    ["Breton"] = {
        time = 3000,
        skill = 15
    },
    ["Criollo"] = {
        time = 3000,
        skill = 15
    },
    ["Dutch Warmblood"] = {
        time = 3000,
        skill = 15
    },
    ["Gypsy Cob"] = {
        time = 3000,
        skill = 15
    },
    ["Hungarian Halfbred"] = {
        time = 3000,
        skill = 15
    },
    ["Kentucky Saddler"] = {
        time = 3000,
        skill = 15
    },
    ["Kladruber"] = {
        time = 3000,
        skill = 15
    },
    ["Missouri Fox Trotter"] = {
        time = 3000,
        skill = 15
    },
    ["Morgan"] = {
        time = 3000,
        skill = 15
    },
    ["Mustang"] = {
        time = 10000,
        skill = 15
    },
    ["Turkoman"] = {
        time = 10000,
        skill = 15
    },
    ["Nokota"] = {
        time = 3000,
        skill = 15
    },
    ["Norfolk Roadster"] = {
        time = 3000,
        skill = 15
    },
    ["Shire"] = {
        time = 3000,
        skill = 15
    },
    ["Suffolk Punch"] = {
        time = 3000,
        skill = 15
    }

}
