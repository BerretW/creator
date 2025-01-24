Config = {}
Config.Debug = true
Config.WebHook =
    "https://discord.com/api/webhooks/1293864809497886770/PFsQjS38FaN5FiFh6YPPWuQtWp3H-lKbxQ88pnlwgVpzsuuIN-kVNJEqZLuTN8pbrUTD"
Config.ServerName = 'WestHaven Doktor Loger'

MAX_INNER_HEALTH = 100
MAX_ENTITY_HEALTH = 600

Config.DiscordColor = 16753920
Config.illnessHealth = 100
Config.ColdTemp = 0.0
Config.StaminaBorder = 30
Config.Job = "doctor"
Config.Tool1 = "medic_stethoscope"
Config.Anim = {
    dict = "script_mp@emotes@take_notes@male@unarmed@upper",
    name = "loop",
    time = 15000 -- Doba trvání animace v milisekundách
}

Config.Key = 0x760A9C6F
Config.KeyLabel = 'G' -- Label klávesy
Config.Key2 = 0x8CC9CD42
Config.KeyLabel2 = 'X' -- Label klávesy ["X"] = 0x8CC9CD42,

Config.Receipt_Item = "receipt_minus"

Config.NPC = {{
    name = "Lékař GoldenCock",
    coords = vector3(-849.589661, -1235.681396, 44.097691),
    heading = 10.0,
    model = "cs_sddoctor_01",
    price = 10
}}

Config.TooHot = 37
Config.TooCold = -10

Config.Items = {
    rag = {
        item = "medic_rag",
        label = "Hadřík",
        effect = 15,
        myself = true,
        others = false,
        job = nil
    },
    bandage = {
        item = "medic_bandage",
        label = "Bandáž",
        effect = 45,
        myself = true,
        others = true,
        job = nil
    },
    sterileBandage = {
        item = "medic_sterile_bandage",
        label = "Sterilní bandáž",
        effect = 100,
        myself = false,
        others = true,
        job = Config.Job
    }
}
Config.AlternateMedicine = {{
    item = "medic_alt_flu_cure",
    cure = "medic_flu_cure",
    label = "Alternativní lék na chřipku",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_cold_cure",
    cure = "medic_cold_cure",
    label = "Alternativní lék na nachlazení",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_bronchitis_cure",
    cure = "medic_bronchitis_cure",
    label = "Alternativní lék na bronchitidu",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_gastro_cure",
    cure = "medic_gastro_cure",
    label = "Alternativní lék na gastroenteritidu",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_malaria_cure",
    cure = "medic_malaria_cure",
    label = "Alternativní lék na malárii",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_itch_cure",
    cure = "medic_itch_cure",
    label = "Alternativní lék na svrab",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "medic_alt_badblood_cure",
    cure = "medic_badblood_cure",
    label = "Alternativní lék na otravu krve",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "product_tea_diarrhea",
    cure = "medic_gastro_cure",
    label = "Alternativní lék na gastroenteritidu",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "product_tea_bronchitidis",
    cure = "medic_bronchitis_cure",
    label = "Alternativní lék na bronchitidu",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "product_tea_cold",
    cure = "medic_cold_cure",
    label = "Alternativní lék na nachlazení",
    returnItem = "tool_clay_bottle_empty"
}, {
    item = "product_tea_flu",
    cure = "medic_flu_cure",
    label = "Alternativní lék na chřipku",
    returnItem = "tool_clay_bottle_empty"
}}
Config.ReviveItems = {
    medic_smellingsalt = {
        item = "medic_smellingsalt",
        label = "Jód",
        time = 30000,
        animDict = "amb@world_human_clipboard@male@base",
        animBody = "base",
        job = "doctor",
        health = 0.0,
        stamina = 0.0,
        water = 0.0,
        food = 0.0
    }
}

Config.States = {
    BayouNwa = 2025841068,
    bigvalley = 822658194,
    BluewaterMarsh = 1308232528,
    ChollaSprings = -108848014,
    Cumberland = 1835499550,
    DiezCoronas = 426773653,
    GaptoothRidge = -2066240242,
    greatPlains = 476637847,
    GrizzliesEast = -120156735,
    GrizzliesWest = 1645618177,
    GuarmaD = -512529193,
    Heartlands = 131399519,
    HennigansStead = 892930832,
    Perdido = -1319956120,
    PuntaOrgullo = 1453836102,
    RioBravo = -2145992129,
    roanoke = 178647645,
    scarlettMeadows = -864275692,
    TallTrees = 1684533001

}

Config.Components = {
    Spats = 1,
    Vest = 2,
    Pant = 3,
    Shirt = 2,
    NeckTies = 1,
    Mask = 0,
    Poncho = 3,
    Glove = 2,
    Skirt = 1,
    Boots = 3,
    Gauntlets = 1,
    Coat = 1, -- otevřený kabát jen mírně hřeje
    Hat = 2,
    Chap = 1,
    Cloak = 4, -- plášť už hodně hřeje
    CoatClosed = 5, -- zavřený kabát hřeje nejvíc
    Dress = 0, -- šaty spíš neutrální, než ochlazující
    Armor = -1 -- kov/pancéř omezuje tělesné teplo
}

Config.stateIllnesses = {
    BayouNwa = {
        flu = 10, -- Chřipka
        cold = 10, -- Nachlazení
        bronchitis = 10, -- Bronchitida
        malaria = 30 -- Malárie
    },
    bigvalley = {
        flu = 8,
        cold = 12,
        bronchitis = 10,
        measles = 8,
        gastroenteritis = 12,
        malaria = 4
    },
    BluewaterMarsh = {
        flu = 9,
        cold = 11,
        bronchitis = 9,
        measles = 11,
        gastroenteritis = 10,
        malaria = 6
    },
    ChollaSprings = {
        flu = 7,
        cold = 13,
        bronchitis = 11,
        measles = 7,
        gastroenteritis = 13,
        malaria = 5
    },
    Cumberland = {
        flu = 10,
        cold = 10,
        bronchitis = 10,
        measles = 10,
        gastroenteritis = 10,
        malaria = 5
    },
    DiezCoronas = {
        flu = 6,
        cold = 14,
        bronchitis = 12,
        measles = 6,
        gastroenteritis = 14,
        malaria = 5
    },
    GaptoothRidge = {
        flu = 8,
        cold = 12,
        bronchitis = 10,
        measles = 8,
        gastroenteritis = 12,
        malaria = 5
    },
    greatPlains = {
        flu = 9,
        cold = 11,
        bronchitis = 9,
        measles = 11,
        gastroenteritis = 10,
        malaria = 6
    },
    GrizzliesEast = {
        flu = 7,
        cold = 13,
        bronchitis = 11,
        measles = 7,
        gastroenteritis = 13,
        malaria = 5
    },
    GrizzliesWest = {
        flu = 10,
        cold = 10,
        bronchitis = 10,
        measles = 10,
        gastroenteritis = 10,
        malaria = 5
    },
    GuarmaD = {
        flu = 5,
        cold = 15,
        bronchitis = 13,
        measles = 5,
        gastroenteritis = 15,
        malaria = 7
    },
    Heartlands = {
        flu = 9,
        cold = 11,
        bronchitis = 9,
        measles = 11,
        gastroenteritis = 10,
        malaria = 6
    },
    HennigansStead = {
        flu = 8,
        cold = 12,
        bronchitis = 10,
        measles = 8,
        gastroenteritis = 12,
        malaria = 5
    },
    Perdido = {
        flu = 7,
        cold = 13,
        bronchitis = 11,
        measles = 7,
        gastroenteritis = 13,
        malaria = 5
    },
    PuntaOrgullo = {
        flu = 6,
        cold = 14,
        bronchitis = 12,
        measles = 6,
        gastroenteritis = 14,
        malaria = 5
    },
    RioBravo = {
        flu = 10,
        cold = 10,
        bronchitis = 10,
        measles = 10,
        gastroenteritis = 10,
        malaria = 5
    },
    roanoke = {
        flu = 8,
        cold = 12,
        bronchitis = 10,
        measles = 8,
        gastroenteritis = 12,
        malaria = 5
    },
    scarlettMeadows = {
        flu = 7,
        cold = 13,
        bronchitis = 11,
        measles = 7,
        gastroenteritis = 13,
        malaria = 5
    },
    TallTrees = {
        flu = 9,
        cold = 11,
        bronchitis = 9,
        measles = 11,
        gastroenteritis = 10,
        malaria = 6
    }
}
-- mech_loco_m@generic@special@unarmed@itchy@idle idle

Config.Illnesses = {
    flu = { -- chřipka
        name = "flu",
        chance = 10, -- 10% šance
        priority = 1,
        duration = 5 * 60 * 60, -- 5 hodin
        cure = "medic_flu_cure",
        startTime = 10,
        infective = true,
        symptoms = {
            teplota = math.random(385, 400) / 10, -- Tělesná teplota (38.5°C až 40.0°C), měřeno teploměrem
            jazyk = "bílý povlak", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "zčervenalé", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "zvětšené", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "bolestivý", -- Stav krku, zkoumáno vizuálně a palpací
            plice = "šelest", -- Stav plic, posloucháno stetoskopem pro detekci šelestů
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "hustý", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "normální", -- Stav kůže, kontrolováno vizuálně
            vyrazka = "ne", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "ne", -- Pocení, hodnoceno vizuálně
            bricho = "ne", -- Stav žaludku, zkoumáno vizuálně
            animDict = "mech_loco_m@character@arthur@fidgets@weather@rainy_wet@unarmed", -- Animace kašle
            animBody = "cough_a", -- Tělo animace kašle
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = 0, -- Dopad na hydrataci hráče
            food = 0, -- Dopad na výživu hráče
            stamina = -100, -- Dopad na výdrž hráče
            innerHealth = 0, -- Dopad na zdraví hráče
            outerHealth = -10 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    cold = { -- nachlazení
        name = "cold",
        chance = 10, -- 10% šance
        priority = 1,
        duration = 4 * 60 * 60, -- 4 hodiny
        cure = "medic_cold_cure",
        startTime = 0,
        infective = true,
        symptoms = {
            teplota = math.random(360, 375) / 10, -- Tělesná teplota (37.0°C až 37.5°C), měřeno teploměrem
            jazyk = "normální", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "normální", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "bolestivý", -- Stav krku, zkoumáno vizuálně a palpací
            plice = "normální", -- Stav plic, posloucháno stetoskopem
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "hustý", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "normální", -- Stav kůže, kontrolováno vizuálně
            vyrazka = "ne", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "ne", -- Pocení, hodnoceno vizuálně
            bricho = "ne", -- Stav žaludku, zkoumáno vizuálně
            animDict = "mech_loco_m@character@arthur@fidgets@weather@rainy_wet@unarmed", -- Animace kýchání veh_horseback@seat_saddle@generic@terrain@unarmed@cold@idle@fidget: sneeze_01
            animBody = "sneeze_a", -- Tělo animace kýchání
            horseDict = "vveh_horseback@seat_saddle@generic@terrain@unarmed@cold@idle@fidget", -- Animace zvracení
            horseBody = "sneeze_01", -- Tělo animace zvracení
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = 0, -- Dopad na hydrataci hráče
            food = 0, -- Dopad na výživu hráče
            stamina = 0, -- Dopad na výdrž hráče
            innerHealth = 0, -- Dopad na zdraví hráče
            outerHealth = -10 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    bronchitis = { -- bronchitida
        name = "bronchitis",
        chance = 10, -- 10% šance
        priority = 1,
        duration = 10 * 60 * 60, -- 10 hodin
        cure = "medic_bronchitis_cure",
        startTime = 0,
        infective = false,
        symptoms = {
            teplota = math.random(370, 390) / 10, -- Tělesná teplota (37.0°C až 38.0°C), měřeno teploměrem
            jazyk = "normální", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "zvětšené", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "bolestivý", -- Stav krku, zkoumáno vizuálně a palpací
            plice = "šelest", -- Stav plic, posloucháno stetoskopem pro detekci šelestů
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "hustý", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "normální", -- Stav kůže, kontrolováno vizuálně
            vyrazka = "ne", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "ne", -- Pocení, hodnoceno vizuálně
            bricho = "ne", -- Stav žaludku, zkoumáno vizuálně
            animDict = "mech_loco_m@character@arthur@fidgets@weather@rainy_wet@unarmed", -- Animace kašle
            animBody = "cough_a", -- Tělo animace kašle
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = -50, -- Dopad na hydrataci hráče
            food = -50, -- Dopad na výživu hráče
            stamina = -50, -- Dopad na výdrž hráče
            innerHealth = 0, -- Dopad na zdraví hráče
            outerHealth = -20 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    gastroenteritis = { -- gastroenteritida
        name = "gastroenteritis",
        chance = 0, -- 10% šance
        priority = 1,
        duration = 8 * 60 * 60, -- 8 hodin
        cure = "medic_gastro_cure",
        startTime = 0,
        infective = false,
        symptoms = {
            teplota = math.random(370, 380) / 10, -- Tělesná teplota (37.0°C až 38.0°C), měřeno teploměrem
            jazyk = "normální", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "normální", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "normální", -- Stav krku, kontrolováno vizuálně a palpací
            plice = "normální", -- Stav plic, posloucháno stetoskopem
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "normální", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "bledá", -- Stav kůže, kontrolováno vizuálně pro bledost
            vyrazka = "ne", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "ne", -- Pocení, hodnoceno vizuálně
            bricho = "bolest", -- Bolest žaludku, zkoumáno vizuálně
            animDict = "amb_misc@world_human_vomit@male_a@idle_b", -- Animace zvracení
            animBody = "idle_f", -- Tělo animace zvracení
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = -75, -- Dopad na hydrataci hráče
            food = -75, -- Dopad na výživu hráče
            stamina = -200, -- Dopad na výdrž hráče
            innerHealth = 0, -- Dopad na zdraví hráče
            outerHealth = 0 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    malaria = { -- malárie
        name = "malaria",
        chance = 5, -- 5% šance
        priority = 1,
        duration = 10 * 60 * 60, -- 10 hodin
        cure = "medic_malaria_cure",
        startTime = 0,
        infective = false,
        symptoms = {
            teplota = math.random(385, 400) / 10, -- Tělesná teplota (38.5°C až 40.0°C), měřeno teploměrem
            jazyk = "normální", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "zvětšené", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "normální", -- Stav krku, kontrolováno vizuálně a palpací
            plice = "normální", -- Stav plic, posloucháno stetoskopem
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "normální", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "vyrážka", -- Stav kůže, kontrolováno vizuálně pro vyrážku
            vyrazka = "ano", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "intenzivní", -- Pocení, hodnoceno vizuálně
            bricho = "bolest", -- Bolest žaludku, zkoumáno vizuálně
            animDict = "amb_misc@world_human_vomit@male_a@idle_b", -- Animace zvracení
            animBody = "idle_f", -- Tělo animace zvracení
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = -75, -- Dopad na hydrataci hráče
            food = -75, -- Dopad na výživu hráče
            stamina = -200, -- Dopad na výdrž hráče
            innerHealth = -2, -- Dopad na zdraví hráče
            outerHealth = -30 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    itch = { -- svrab
        name = "itch",
        chance = 5, -- 5% šance
        priority = 1,
        duration = 2 * 60 * 60, -- 2 hodin
        cure = "medic_itch_cure",
        startTime = 0,
        infective = true,
        symptoms = {
            teplota = math.random(365, 375) / 10, -- Tělesná teplota (38.5°C až 40.0°C), měřeno teploměrem
            jazyk = "normální", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "normální", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "normální", -- Stav krku, kontrolováno vizuálně a palpací
            plice = "normální", -- Stav plic, posloucháno stetoskopem
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "normální", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "drobné červené pupínky", -- Stav kůže, kontrolováno vizuálně pro vyrážku
            vyrazka = "ano", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "intenzivní", -- Pocení, hodnoceno vizuálně
            bricho = "nic", -- Bolest žaludku, zkoumáno vizuálně
            animDict = "mech_loco_m@generic@special@unarmed@itchy@idle", -- Animace zvracení
            animBody = "idle", -- Tělo animace zvracení
            horseDict = "veh_horseback@seat_saddle@generic@terrain@unarmed@hot@idle@fidget", -- Animace zvracení
            horseBody = "arm_scratch_01", -- Tělo animace zvracení
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = -75, -- Dopad na hydrataci hráče
            food = -75, -- Dopad na výživu hráče
            stamina = -50, -- Dopad na výdrž hráče
            innerHealth = 0, -- Dopad na zdraví hráče
            outerHealth = 0 -- Dopad na zdraví hráče -- Dopad na výdrž hráče
        }
    },
    badblood = { -- Otrava krve
        name = "Otrava Krve",
        chance = 0, -- 5% šance

        priority = 10,
        duration = 2 * 60 * 60, -- 10 hodin
        cure = "medic_badblood_cure",
        startTime = 0,
        infective = false,
        symptoms = {
            teplota = math.random(365, 375) / 10, -- Tělesná teplota (36.5°C až 37.5°C), měřeno teploměrem
            jazyk = "Bílý povlak", -- Stav jazyka, kontrolováno vizuálně pomocí špachtle
            mandle = "normální", -- Stav mandlí, zkoumáno vizuálně a palpací
            uzliny = "zvětšené", -- Stav lymfatických uzlin, kontrolováno palpací
            krk = "bolestivý", -- Stav krku, kontrolováno vizuálně a palpací
            plice = "šelest", -- Stav plic, posloucháno stetoskopem
            tep = "rychlý", -- Stav srdce, poslech stetoskopem
            hlen = "normální", -- Stav hlenu, hodnoceno vizuálně a odkašováním
            oci = "normální", -- Stav očí, kontrolováno vizuálně
            nos = "normální", -- Stav nosu, kontrolováno vizuálně
            kuze = "bledá s vyrážkou", -- Stav kůže, kontrolováno vizuálně
            vyrazka = "ano", -- Přítomnost vyrážky, vizuálně kontrolováno
            nekroza = "ne", -- Přítomnost nekrózy, vizuálně kontrolováno
            poceni = "intenzivní", -- Pocení, hodnoceno vizuálně
            bricho = "bolest", -- Stav žaludku, zkoumáno vizuálně
            animDict = "script_re@snake_bite@ig_bitten", -- Animace svědění
            animBody = "pain_idle_enter_victim", -- Tělo animace svědění
            animTime = 5000, -- Doba trvání animace v milisekundách
            animTimer = math.random(1, 10) * 60000, -- Náhodný čas mezi 1 až 10 minutami pro spuštění animace
            water = -100, -- Dopad na hydrataci hráče
            food = -50, -- Dopad na výživu hráče
            stamina = -150, -- Dopad na výdrž hráče
            innerHealth = -50, -- Dopad na vnitřní zdraví hráče
            outerHealth = -75 -- Dopad na vnější zdraví hráče
        }
    }

    -- Další nemoci mohou být přidány zde s konzistentními příznaky
}
