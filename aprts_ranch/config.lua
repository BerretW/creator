Config = {}
Config.Ver = "1.0.1"
Config.Debug = false
Config.Blip = 423351566
Config.WebHook =
    "https://discord.com/api/webhooks/1290779405555077211/SF4nN-jWRTi72LFpKvjcWLKIIFmlMttrwzS1R2Ny4EnegqxUIS0pctnp1JNwOyT6JPvH"
Config.ServerName = 'WestHaven Ranch Loger'
Config.DiscordColor = 16753920
Config.Locale = 'cs'
Config.Framework = "VORP"
Config.Job = 'rancher'
Config.fullWaterItem = "tool_water_bucket"
Config.emptyWaterItem = "tool_empty_bucket"
Config.WateringCount = 5
Config.fullFoodItem = "animal_food"
Config.emptyFoodItem = "tool_empty_bag"
Config.BrushItem = "animal_brush"
Config.leashItem = "animal_leash"
Config.ShovelItem = "tool_rake"
Config.NameTagItem = "animal_name_tag"
Config.railing1Item = "tool_feeding_trough_1"
Config.productPickupTool = "tool_basket"
Config.PoopItem = "animal_dung"
Config.ShaveTool = "tool_scissors"
Config.GatherTool = "tool_basket"
Config.MaxPoop = 10
Config.MaxProduct = 2
Config.medicineItemTool = "medic_syringe"
Config.ranchBasePrice = 10
Config.UpdateRate = 3600 -- 1 hodina
Config.PoopTime = 1800000 -- 30 minut
Config.RenderDistance = 30.0
Config.ranchLimit = 1
Config.clearance = 100.0
Config.homeSafeDistance = 100.0
Config.animalsWalkOnly = false
Config.animalFollowSettings = {}
Config.animalFollowSettings.offsetX = 10.0
Config.animalFollowSettings.offsetY = 0.0
Config.animalFollowSettings.offsetZ = 0.0
Config.SicknessChanceMultiplier = 0.05 -- Množitel pro šanci na onemocnění
Config.RecoveryChance = 0.05 -- Šance na uzdravení
Config.CleaverItem = "tool_cleaver"
Config.deadReward = "spoiled_meat"
Config.ReviveChance = 30
Config.Skill = "vet"
Config.ReviveItem = "animal_medicine_mild"

Config.Key = 0x760A9C6F
Config.KeyLabel = 'G' -- Label klávesy
Config.FeedKey = 0x760A9C6F
Config.FeedKeyLabel = 'G' -- Label klávesy
Config.WaterKey = 0x8AAA0AD4
Config.WaterKeyLabel = 'LALT' -- Label klávesy
Config.Key2 = 0xF3830D8E
Config.KeyLabel2 = 'J' -- Label klávesy

Config.maxWalkedAnimals = 10
Config.DoctorJob = "vet"
Config.InfectionChance = 0.02
Config.Level1 = 90 -- *1,5   4h30min
Config.Level2 = 180 -- *2   6h45min
Config.Level3 = 320 -- *2,5   9h
Config.Level4 = 540 -- *3   13h30min
Config.Level5 = 780 -- *4  18h

Config.XPPrice = 0.3
Config.SickPrice = 0.1

Config.Shelters = {{
    name = "Útulek u kulhavý Betty",
    model = "a_m_m_rancher_01",
    npcCoords = vector3(-320.364960, -134.434753, 51.670578),
    coords = vector3(-320.249146, -138.596100, 50.645897),
    heading = 74.0,
    blip = true,
    blipName = "Útulek u kulhavý Betty",
    blipSprite = 423351566

}}

Config.SlaughterHouses = {{
    name = "Jatka Wallace",
    model = "a_m_m_rancher_01",
    npcCoords = vector3(-1311.268555, 389.221588, 95.380150),
    heading = 262.0,
    blip = true,
    blipName = "Jatka Wallace",
    blipSprite = 423351566
},{
    name = "Jatka Valentine",
    model = "a_m_m_rancher_01",
    npcCoords = vector3(-159.584167, 641.725098, 113.482033),
    heading = 262.0,
    blip = true,
    blipName = "Jatka Valentine",
    blipSprite = 423351566
},{
    name = "Jatka Armadillo",
    model = "a_m_m_rancher_01",
    npcCoords = vector3(-3744.024170, -2621.700439, -13.253958),
    heading = 262.0,
    blip = true,
    blipName = "Jatka Armadillo",
    blipSprite = 423351566
}}


Config.WeaponHash = {
    Unarmed = -1569615261,
    Animal = -100946242,
    Alligator = -1245325071,
    Badger = 0xD872AB0A,
    Bear = 0x1EC181D9,
    Beaver = 0x30E5211A,
    Horse = 0x8BD282A4,
    Cougar = 0x8D4BE52,
    Coyote = 0x453467D1,
    Deer = 0xF4C67A9E,
    Fox = 0x33B2D208,
    Muskrat = 0x2D880572,
    Raccoon = 0x356951B,
    Snake = 0xD8EFBC17,
    Wolf = 0x238A339,
    WolfMedium = 0x88394C06,
    WolfSmall = 0xC80FDF53,
    RevolverCattleman = 379542007,
    MeleeKnife = -618550132,
    ShotgunDoublebarrel = 1845102363,
    MeleeLantern = -164645981,
    RepeaterCarbine = -183018591,
    RevolverSchofieldBill = 1845380267,
    RifleBoltactionBill = 1845380267,
    MeleeKnifeBill = -834915932,
    ShotgunSawedoffCharles = -1098045850,
    BowCharles = 2031861036,
    MeleeKnifeCharles = -1267249859,
    ThrownTomahawk = -1511427369,
    RevolverSchofieldDutch = -95736505,
    RevolverSchofieldDutchDualwield = -733324796,
    MeleeKnifeDutch = 747485975,
    RevolverCattlemanHosea = -1493265355,
    RevolverCattlemanHoseaDualwield = 0x1EAA7376,
    ShotgunSemiautoHosea = 0xFD9B510B,
    MeleeKnifeHosea = 0xCACE760E,
    RevolverDoubleactionJavier = 0x514B39A1,
    ThrownThrowingKnivesJavier = 0x39B815A2,
    MeleeKnifeJavier = 0xFA66468E,
    RevolverCattlemanJohn = 0xC9622757,
    RepeaterWinchesterJohn = 0xBE76397C,
    MeleeKnifeJohn = 0x1D7D0737,
    RevolverCattlemanKieran = 0x8FAE73BB,
    MeleeKnifeKieran = 0x2F3ECD37,
    RevolverCattlemanLenny = 0xC9095426,
    SniperrifleRollingblockLenny = 0x21556EC2,
    MeleeKnifeLenny = 0x9DD839AE,
    RevolverDoubleactionMicah = 0x2300C65,
    RevolverDoubleactionMicahDualwield = 0xD427AD,
    MeleeKnifeMicah = 0xE9245D38,
    RevolverCattlemanSadie = 0x49F6BE32,
    RevolverCattlemanSadieDualwield = 0x8384D5FE,
    RepeaterCarbineSadie = 0x7BD9C820,
    ThrownThrowingKnives = 0xD2718D48,
    MeleeKnifeSadie = 0xAF5EEF08,
    RevolverCattlemanSean = 0x3EECE288,
    MeleeKnifeSean = 0x64514239,
    RevolverSchofieldUncle = 0x99496406,
    ShotgunDoublebarrelUncle = 0x8BA6AF0A,
    MeleeKnifeUncle = 0x46E97B10,
    RevolverDoubleaction = 127400949,
    RifleBoltaction = 1999408598,
    RevolverSchofield = 2075992054,
    RifleSpringfield = 1676963302,
    RepeaterWinchester = -1471716628,
    RifleVarmint = -570967010,
    PistolVolcanic = 34411519,
    ShotgunSawedoff = 392538360,
    PistolSemiauto = 1701864918,
    PistolMauser = -2055158210,
    RepeaterHenry = -1783478894,
    ShotgunPump = 834124286,
    Bow = -2002235300,
    ThrownMolotov = 1885857703,
    MeleeHatchetHewing = 469927692,
    MeleeMachete = 680856689,
    RevolverDoubleactionExotic = 600245965,
    RevolverSchofieldGolden = -510274983,
    ThrownDynamite = -1504859554,
    MeleeDavyLantern = 1247405313,
    Lasso = 2055893578,
    KitBinoculars = -160924582,
    KitCamera = 0xC3662B7D,
    Fishingrod = 0xABA87754,
    SniperrifleRollingblock = 0xE1D2B317,
    ShotgunSemiauto = 0x6D9BB970,
    ShotgunRepeating = 0x63CA782A,
    SniperrifleCarcano = 0x53944780,
    MeleeBrokenSword = 0xF79190B4,
    MeleeKnifeBear = 0x2BC12CDA,
    MeleeKnifeCivilWar = 0xDA54DD53,
    MeleeKnifeJawbone = 0x1086D041,
    MeleeKnifeMiner = 0xC45B2DE,
    MeleeKnifeVampire = 0x14D3F94D,
    MeleeTorch = 0x67DC3FDE,
    MeleeLanternElectric = 0x3155643F,
    MeleeHatchet = 0x9E12A01,
    MeleeAncientHatchet = 0x21CCCA44,
    MeleeCleaver = -281894307,
    MeleeHatchetDoubleBit = -1127860381,
    MeleeHatchetDoubleBitRusted = -1894785522,
    MeleeHatchetHunter = 710736342,
    MeleeHatchetHunterRusted = -462374995,
    MeleeHatchetViking = 1960591597,
    RevolverCattlemanMexican = 383145463,
    RevolverCattlemanPig = -169598849,
    RevolverSchofieldCalloway = 38266755,
    PistolMauserDrunk = 1252941818,
    ShotgunDoublebarrelExotic = 575725904,
    SniperrifleRollingblockExotic = 1311933014,
    ThrownTomahawkAncient = 2133046983,
    Tomahawk = -1511427369,
    Sip = -2002235300,
    Nuz = -618550132,
    Mauser = -2055158210,
    RevolverNavy = 132728264,
    Sekyrka = 165751297,
    Bota = -1569615261,
    MeleeTorchCrowd = -867858243,
    Kladivo = -295349450,
    LanceKnife = -1448818329,
    MeleeHatchetMeleeonly = 124604331
}

Config.Animation = {
    feed = {
        dict = "mech_inventory@chores@feed_chickens",
        name = "looped_action",
        time = 3000,
        flag = 17,
        type = 'standard',
        prop = {
            model = 'p_handfulofhay',
            coords = {
                x = 0.0,
                y = -0.09,
                z = -0.09,
                xr = 250.2899,
                yr = 579.19,
                zr = 373.3
            },
            bone = 'SKEL_R_Hand'
        }
    },
    shovel = {
        dict = "amb_work@world_human_farmer_rake@male_a@idle_a",
        name = "idle_a",
        time = 15000,
        flag = 17,
        type = 'standard',
        prop = nil
    },
    water = {
        dict = "amb_work@world_human_gravedig@working@male_b@base",
        name = "base",
        time = 5000,
        flag = 17,
        type = 'standard',
        prop = {
            model = 'p_buckethang01x',
            coords = {
                x = 0.0,
                y = -0.09,
                z = -0.09,
                xr = 250.2899,
                yr = 579.19,
                zr = 373.3
            },
            bone = 'SKEL_R_Hand'
        }
    },
    cure = {
        dict = "mech_animal_interaction@horse@right@injection",
        name = "injection_player",
        time = 3000,
        flag = 17,
        type = 'standard',
        prop = nil
    },
    clean = {
        dict = "mech_animal_interaction@horse@left@brushing",
        name = "idle_a",
        time = 10000,
        flag = 17,
        type = 'standard',
        prop = nil
    },
    shave = {
        dict = "mech_animal_interaction@horse@left@brushing",
        name = "idle_a",
        time = 10000,
        flag = 17,
        type = 'standard',
        prop = nil
    }
}

Config.medicineItems = {
    animal_herbal_brew = {
        item = "animal_herbal_brew",
        chance = 30,
        cure = 4,
        job = "",
        grade = 1
    },
    animal_medicine_antibiotic = {
        item = "animal_medicine_antibiotic",
        chance = 90,
        cure = 50,
        job = Config.DoctorJob,
        grade = 1
    },
    animal_medicine_1 = {
        item = "animal_medicine_1",
        chance = 90,
        cure = 50,
        job = Config.DoctorJob,
        grade = 1
    },
    animal_medicine_2 = {
        item = "animal_medicine_2",
        chance = 90,
        cure = 50,
        job = Config.DoctorJob,
        grade = 1
    },
    animal_medicine_3 = {
        item = "animal_medicine_3",
        chance = 90,
        cure = 50,
        job = Config.DoctorJob,
        grade = 1
    }
}

Config.CureItems = {
    animal_medicine_small = {
        item = "animal_medicine_small",
        chance = 90,
        cure = 25,
        job = Config.DoctorJob,
        grade = 1
    },
    animal_medicine_mild = {
        item = "animal_medicine_mild",
        chance = 90,
        cure = 50,
        job = Config.DoctorJob,
        grade = 1
    },
    animal_medicine_big = {
        item = "animal_medicine_big",
        chance = 50,
        cure = 75,
        job = Config.DoctorJob,
        grade = 1
    }
}
Config.DefaultRanch = {
    storage_limit = 200
}
Config.DefaultRailing = {
    price = 1000,
    food = 0,
    water = 0,
    shit = 0

}
Config.feeding = {
    p_mp_feedbaghang01x = {
        name = "Pytel s krmením",
        prop = "p_mp_feedbaghang01x",
        item = "tool_feeding_trough_1",
        upgradeItem = nil,
        food = 500,
        water = 500,
        price = 100,
        size = 5,
        zmod = -0.7
    },
    p_feedtrough01x = {
        name = "Malé krmítko",
        prop = "p_feedtrough01x",
        item = "tool_feeding_trough_2",
        upgradeItem = "tool_feeding_trough_upgrade1",
        food = 1000,
        water = 1000,
        price = 1000,
        size = 10,
        zmod = 0.0

    },
    p_feedtroughsml01x = {
        name = "Velké krmítko",
        prop = "p_feedtroughsml01x",
        item = "tool_feeding_trough_3",
        upgradeItem = "tool_feeding_trough_upgrade2",
        food = 1500,
        water = 1500,
        price = 10000,
        size = 15,
        zmod = 0.0
    }
}

Config.Animals = {
   
}

