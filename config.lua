Config = {}
Config.Debug = false
Config.WebHook =
    ""
Config.ServerName = 'WestHaven ** Loger'
Config.DiscordColor = 16753920


Config.KeyM = 0xB2F377E8
Config.KeyMLabel = "F"
Config.KeyF = 0x760A9C6F
Config.KeyFLabel = "G"
Config.KeyOK = 0xC7B5340A
Config.KeyOKLabel = "ENTER"
Config.KeyUP = 0x8FD015D8
Config.KeyUPLabel = "UP"
Config.KeyDOWN = 0xD27782E3
Config.KeyDOWNLabel = "DOWN"
Config.Camera = {
    coords = vector3(4573.200195, -3456.991211, 50.674847),
    lookAt = vector3(4575.341309, -3456.147461, 49.674866),
    heading = 93.2,
    fov = 50.0,
    obj = 0
}


Config.NPC = {
    coords = vector3(4562.535156, -3467.938477, 50.577354),
    heading = 0.0,
    model = "mp_u_m_o_blwpolicechief_01",
    sceneario = "WORLD_HUMAN_CLIPBOARD",
    targetCoords = vector3(2851.634033, -1360.315063, 44.557415)
}

Config.DefaultMoney = 150 
Config.DefaultGold = 0
Config.DefaultWeapons = {"WEAPON_REVOLVER_CATTLEMAN", "WEAPON_MELEE_KNIFE"}
Config.DefaultItems = {
    ["canteen"] = 1,
    ["medic_bandage"] = 5,
    ["ammorevolvernormal"] = 3,
    ["food_greaves"] = 5
}



Config.BannedNames = {
    "Arthur",
    "Marshton",
    "Shit",
    "Dick",
    "Péro",
    "Penis",
    "Vagína",
    "Píča",
    "Kurva",
    "Hovno",
    "Sráč",
    "Cikán",
    "Feták",
    "Feťák",
    "Buzna",
    "Kunda",
    "Píčus",
    "Zmrde",
    "Kretén",
    "Debil",
    "Vůl",
    "Čurák",
    "Hovado"
} 
Config.DefaultChar = {
    Male = {
        {
            label = "Běloch", -- change label only
            imgColor = "white",    -- change img only
            Heads = { "A0BE4A7B", "1E78F6D", "27A4DC22", "5E9A394D", "7BE9E352", "7D7AA347", "839997EF", 
                      "876B1FAE", "8BC1469D", "9324DB9E", "970F3409", "A11747C5", "CA6DABEE",
                      "DC8DA4BA", "DFBFB8F4", "ED8EDA8E", "E79A7372", "E78826B1", "F0FB1DF0", },
            Body = { "206061DB", "16E292A1", "206061DB", "4AEEDD87", "4BD8F4A1", "BA59624D", "F6496128" },
            Legs = { "84BAA309", "8AD16414", "A615E02", "E4B584D5", "F11CF1FA", "F2EA7BDE" },
            HeadTexture = { "mp_head_mr1_sc08_c0_000_ab" },
        },
        {
            label = "Mexičan",
            imgColor = "white2",
            Heads = { "3625908B", "40365810", "613CF195", "66B5DE24", "7AFEF216", "8574F682", 
                      "93C69313", "9D604053", "A23ED555", "AC2963F2", "C1130197", "C55F46B9", "CF482B6A", "D89ED98E",
                      "D879AA64", "E4FF6111",
                      "F4696EBC", "D3D6DD59", "F3CE707E", },
            Body = { "3825D527", "5A929214", "82F14D87", "99E82863", "DF522C3A" },
            Legs = { "15ACBB1D", "97596A2A", "EA27EDE2", "F91940A6", "9EE7070B", "D7F34979" },
            HeadTexture = { "mp_head_mr1_sc02_c0_000_ab" },
        },
        {
            label = "Asiat",
            imgColor = "white3",
            Heads = { "158CB7F2", "36739C03", "48133466", "4E11220E", "68C7CDA8", "6DF5043C", "6EF1C97C",
                      "771A7EE9", "7B035098", "89556A4D", "9DD7C74F", "A156BC1F", "AFCDE52E", "C6077794",
                      "DD95F0D7", "4BCC286D", "D7506A9B", "D1B722DF",
                      "D7CDC6AE", "E718D713", },
            Body = { "465F719A", "6D582255", "8CC97681", "B0D24F3F" },
            Legs = { "47FE9FC0", "64F9856B", "B0F62B29", "ACAE409" },
            HeadTexture = { "mp_head_mr1_sc03_c0_000_ab" },
        },
        {
            label = "Indián tmavší",
            imgColor = "brown",
            Heads = { "4C5C14D1", "2BADE2F9", "32E0BD65", "51EE52F8", "53361205", "7150F35A", "7320223C",
                       "8239BA1C", "4DAD06D9", "93C8CFE3", "B0B07238", "BC310F75", "B9C497C7",
                      "C00E8CF7", "C2978B19", "FEC87D01", "89601857", "FEB1F6D4", "936FAFDE", },
            Body = { "34C3B131", "5C1686B", "8C9686C8", "BF787383" },
            Legs = { "F5E0272A", "B897BFA0", "C17616E", "73710076", "B897BFA0" },
            HeadTexture = { "MP_head_fr1_sc01_c0_000_ab" },
        },
        {
            label = "Indián",
            imgColor = "brown2",
            Heads = { "1EF1D4F5", "20BEAD17", "1D1391CB", "3E1D8D10", "41FB09E2", "421209B8",
                      "44C938AE", "465D3511", "48531C43", "5A5A4569", "69A6DC4D", "87198A9F", "8C099185",
                      "9AD0D9E0",
                      "9B593624", "A9918F1E", "AF4B1442", "E2BED257", "F769DA58", },
            Body = { "4824ED39", "3B6F503", "5EA984F8", "B4485D23", "6BB6BC48" },
            Legs = { "D3A7708B", "5B835093", "DDF48A5D", "35D1FB67" },
            HeadTexture = { "mp_head_mr1_sc04_c0_000_ab" },
        },
        {
            label = "Černoch",
            imgColor = "black",
            Heads = { "101E374E", "48A3A1FC", "4C55A1AB", "5248AA25", "52CC549C", "54CED1F4",
                      "6817A7D2", "6B50E776", "729570C7", "8B921D0F", "9BE9739A", "9CCAB601", "A0D12D3E", "A9A2BECB",
                      "AC877D4D", "BB432C32",
                      "B6316BD4", "BF97F8A1", "FAEAC26", },
            Body = { "69B6305B", "BA09D8ED", "C8EA5978", "CD7F8895" },
            Legs = { "52CC3F25", "6577142C", "6CBCE93C", "887C4C70", "EF9D2DAE" },
            HeadTexture = { "mp_head_fr1_sc05_c0_000_ab" },
        },
        
    },
    Female = {
        {
            label = "Běloška",
            imgColor = "", --todo
            Heads = { "76ACA91E", "30378AB3", "478C7817", "6D06466A", "772F8047", "7C1A194E", "87311A4B",
                      "18665C91", "1B15AE7A", "20F6540D", "F8332625", "ED123FBD", "C28AB791", "BBD7BFC",
                      "B3BA8C05", "A661B163", "AAC2D8A9", "9D251F06", "945686CF" },
            Body = { "489AFE52", "64181923", "8DCF7A49", "928DAD43", "B1D3B3A", "D878696D" },
            Legs = { "11A244CC", "3B653032", "41021120", "A0736DA7", "C3BFA017", "F0CD92EC" },
            HeadTexture = { "mp_head_fr1_sc08_c0_000_ab" },
        },
        {
            label = "Mexičanka",
            imgColor = "",
            Heads = { "1C851DA8", "2E1791E1", "477D749A", "6D8686E8", "87371192", "886DB564",
                      "8A1E0CED", "FEA98F74", "E64076CE", "E6377EEA", "E4EE32DC", "CDDA79D6", "C9677F2B", "BBF9DC7A",
                      "C2E3978", "BB8088E4", "B00FC4DB", "A2B1D14C", "B240A051" },
            Body = { "8002D0F8", "6C25B6F6", "8223BCC5", "2BE27CC4", "C1CF0BC1" },
            Legs = { "18916A9B", "4D38CBC5", "98975DF3", "DC1AD9D2", "E74007F9" },
            HeadTexture = { "mp_head_fr1_sc02_c0_000_ab" },
        },
        {
            label = "Asiatka",
            imgColor = "",
            Heads = { "1E6FDDFB", "30B5C9FA", "43857351", "50A1A9F2", "5A274672", "6369FC85", "65A5CE70",
                      "6DCBE781", "E23268F4", "D406DA89", "D47BD345", "DEE3A266", "D3949F79",
                      "C93AA458", "C9D5F867", "C6B7F1F6", "AAB53384", "A4372E08", "98B8DD4C", "47BC4C6", },
            Body = { "2C4FE0C5", "3708268F", "7145337D", "79D35251", "B2850A03" },
            Legs = { "3E152D7E", "C9903FE8", "CC543A45", "24CF58B7", "1684BC22" },
            HeadTexture = { "mp_head_fr1_sc03_c0_000_ab" },
        },
        {
            label = "Černoška",
            imgColor = "",
            Heads = { "11567C3", "1D896D8D", "24452D0B", "34FC0B13", "43F08B06", "53B5B98F", "5DC6A042",
                      "5F192A74", "7F2AAA30", "89B0F7FE", "E72483EC", "CC66815D", "C65BEAD1", "B3F26095",
                       "9D3F64C1",
                      "9B4BDB4C", "9409E68", "93DA499", "E8E50D99" },
            Body = { "5B4E1547", "58D8EA30", "87363366", "D0C5A9AE", "DC86C81" },
            Legs = { "CEAB4EC0", "DBE4E491", "5B4E1547", "F9609455", "3DBEB4BD" },
            HeadTexture = { "mp_head_fr1_sc05_c0_000_ab" },
        },
        {
            label = "Indiánka tmavší",
            imgColor = "",
            Heads = { "2AE6E5C", "4A52F943", "50882CFA", "", "65F9F637", "6A0AB89D", "8E53BDC1",
                      "F7AC67A8", "E6648288",  "CDC2BD9", "C71039E6", "BFAFA3EF", "B8F8F515",
                      "B2155087", "ADD7ED93", "B059132E", "A6F0329C", "11F10982", "DB4094A2", "C770CAA5", },
            Body = { "80DB09DE", "93925FA2", "94778799", "56617DB6", "E36416C" },
            Legs = { "31BE7295", "71821457", "9D6CD26", "A29CE6D7", "A65CF97E" },
            HeadTexture = { "mp_head_fr1_sc01_c0_000_ab" },
        },
        {
            label = "Indiánka",
            imgColor = "",
            Heads = {
                "11F69034", "169B95C6", "1C32EE08", "22B4E685", "3129C6F1", "3C7D04E4",
                "40E72684", "75AF6E83", "8A7F3F41", "8CD1ABC6", "544D8D50", "F70CFFFC", "E6F8006B", "E1D23BF4",
                "D150CE67",
                "986F1565", "9C879729", "16C5E95A", "93F68D87", },
            Body = { "35A7C9FB", "1B088705", "A1AEFBDB", "E28C4D3B", "C05A25AD" },
            Legs = { "27B700C2", "4BA188D", "AAD70276", "EDE17D5F", "F4F5A364" },
            HeadTexture = { "mp_head_fr1_sc04_c0_000_ab" },
        }
    }
}

PlayerSkin = {
    ShouldersS                           = 0.0,
    ShouldersT                           = 0.0,
    ShouldersM                           = 0.0,
    ArmsS                                = 0.0,
    LegsS                                = 0.0,
    CalvesS                              = 0.0,
    ChestS                               = 0.0,
    WaistW                               = 0.0,
    HipsS                                = 0.0,
    FaceW                                = 0.0,
    FaceD                                = 0.0,
    FaceS                                = 0.0,
    NeckW                                = 0.0,
    NeckD                                = 0.0,
    MouthCLW                             = 0.0,
    MouthCRW                             = 0.0,
    MouthCLD                             = 0.0,
    MouthCRD                             = 0.0,
    MouthCLH                             = 0.0,
    MouthCRH                             = 0.0,
    MouthCLLD                            = 0.0,
    MouthCRLD                            = 0.0,
    EyeLidL                              = 0.0,
    EyeLidR                              = 0.0,
    sex                                  = "mp_male",
    albedo                               = 0,
    HeadType                             = 0,
    BodyType                             = 0,
    LegsType                             = 0,
    Torso                                = 0,
    HeadSize                             = 0.0,
    EyeBrowH                             = 0.0,
    EyeBrowW                             = 0.0,
    EyeBrowD                             = 0.0,
    EarsH                                = 0.0,
    EarsW                                = 0.0,
    EarsD                                = 0.0,
    EarsA                                = 0.0,
    EyeLidH                              = 0.0,
    EyeLidW                              = 0.0,
    EyeD                                 = 0.0,
    EyeAng                               = 0.0,
    EyeDis                               = 0.0,
    EyeH                                 = 0.0,
    NoseW                                = 0.0,
    NoseS                                = 0.0,
    NoseH                                = 0.0,
    NoseAng                              = 0.0,
    NoseC                                = 0.0,
    NoseDis                              = 0.0,
    CheekBonesH                          = 0.0,
    CheekBonesW                          = 0.0,
    CheekBonesD                          = 0.0,
    MouthW                               = 0.0,
    MouthD                               = 0.0,
    MouthX                               = 0.0,
    MouthY                               = 0.0,
    ULiphH                               = 0.0,
    ULiphW                               = 0.0,
    ULiphD                               = 0.0,
    LLiphH                               = 0.0,
    LLiphW                               = 0.0,
    LLiphD                               = 0.0,
    JawH                                 = 0.0,
    JawW                                 = 0.0,
    JawD                                 = 0.0,
    ChinH                                = 0.0,
    ChinW                                = 0.0,
    ChinD                                = 0.0,
    Beard                                = 0,
    Hair                                 = 0,
    Body                                 = 0,
    Waist                                = 0,
    Eyes                                 = 0,
    Scale                                = 0.0,
    eyebrows_visibility                  = 0,
    eyebrows_tx_id                       = 0,
    eyebrows_opacity                     = 0.0,
    eyebrows_color                       = 0,
    scars_visibility                     = 0,
    scars_tx_id                          = 0,
    scars_opacity                        = 0,
    spots_visibility                     = 0,
    spots_tx_id                          = 0,
    spots_opacity                        = 0,
    disc_visibility                      = 0,
    disc_tx_id                           = 0,
    disc_opacity                         = 0,
    complex_visibility                   = 0,
    complex_tx_id                        = 0,
    complex_opacity                      = 0,
    acne_visibility                      = 0,
    acne_tx_id                           = 0,
    acne_opacity                         = 0,
    ageing_visibility                    = 0,
    ageing_tx_id                         = 0,
    ageing_opacity                       = 0,
    freckles_visibility                  = 0,
    freckles_tx_id                       = 0,
    freckles_opacity                     = 0,
    moles_visibility                     = 0,
    moles_tx_id                          = 0,
    moles_opacity                        = 0,
    grime_visibility                     = 0,
    grime_tx_id                          = 0,
    grime_opacity                        = 0,
    lipsticks_visibility                 = 0,
    lipsticks_tx_id                      = 0,
    lipsticks_palette_id                 = 0,
    lipsticks_palette_color_primary      = 0,
    lipsticks_palette_color_secondary    = 0,
    lipsticks_palette_color_tertiary     = 0,
    lipsticks_opacity                    = 0,
    shadows_visibility                   = 0,
    shadows_tx_id                        = 0,
    shadows_palette_id                   = 0,
    shadows_palette_color_primary        = 0,
    shadows_palette_color_secondary      = 0,
    shadows_palette_color_tertiary       = 0,
    shadows_opacity                      = 0,
    beardstabble_tx_id                   = 0,
    beardstabble_visibility              = 0,
    beardstabble_color_primary           = 0,
    beardstabble_opacity                 = 0,
    eyeliner_tx_id                       = 0,
    eyeliner_visibility                  = 0,
    eyeliner_color_primary               = 0,
    eyeliner_opacity                     = 0,
    eyeliner_palette_id                  = 0,
    blush_visibility                     = 0,
    blush_tx_id                          = 0,
    blush_palette_id                     = 0,
    blush_palette_color_primary          = 0,
    blush_opacity                        = 0,
    hair_tx_id                           = 0,
    hair_visibility                      = 0,
    hair_color_primary                   = 0,
    hair_opacity                         = 0,
    foundation_tx_id                     = 0,
    foundation_visibility                = 0,
    foundation_palette_id                = 0,
    foundation_palette_color_primary     = 0,
    foundation_palette_color_secondary   = 0,
    foundation_palette_color_tertiary    = 0,
    foundation_opacity                   = 0,
    paintedmasks_tx_id                   = 0,
    paintedmasks_visibility              = 0,
    paintedmasks_palette_id              = 0,
    paintedmasks_palette_color_primary   = 0,
    paintedmasks_palette_color_secondary = 0,
    paintedmasks_palette_color_tertiary  = 0,
    paintedmasks_opacity                 = 0,
    overlays                            = {},

}

PlayerClothing = {
    Poncho      = { comp = -1 },
    Glove       = { comp = -1 },
    RingRh      = { comp = -1 },
    Gauntlets   = { comp = -1 },
    Spats       = { comp = -1 },
    GunbeltAccs = { comp = -1 },
    NeckTies    = { comp = -1 },
    bow         = { comp = -1 },
    RingLh      = { comp = -1 },
    Loadouts    = { comp = -1 },
    Boots       = { comp = -1 },
    Suspender   = { comp = -1 },
    NeckWear    = { comp = -1 },
    Holster     = { comp = -1 },
    CoatClosed  = { comp = -1 },
    EyeWear     = { comp = -1 },
    Shirt       = { comp = -1 },
    Gunbelt     = { comp = -1 },
    Hat         = { comp = -1 },
    Spurs       = { comp = -1 },
    Cloak       = { comp = -1 },
    Vest        = { comp = -1 },
    Belt        = { comp = -1 },
    Pant        = { comp = -1 },
    Skirt       = { comp = -1 },
    Coat        = { comp = -1 },
    Mask        = { comp = -1 },
    Accessories = { comp = -1 },
    Buckle      = { comp = -1 },
    Bracelet    = { comp = -1 },
    Satchels    = { comp = -1 },
    Dress       = { comp = -1 },
    Badge       = { comp = -1 },
    Armor       = { comp = -1 },
    Teeth       = { comp = -1 },
    Chap        = { comp = -1 },
}

Config.texture_types = {
    Male = {
        albedo = joaat("head_fr1_sc08_soft_c0_001_ab"),
        normal = joaat("mp_head_mr1_000_nm"),
        material = 0x50A4BBA9,
        color_type = 1,
        texture_opacity = 1.0,
        unk_arg = 0,
    },
    Female = {
        albedo = joaat("mp_head_fr1_sc08_c0_000_ab"),
        normal = joaat("head_fr1_mp_002_nm"),
        material = 0x7FC5B1E1,
        color_type = 1,
        texture_opacity = 1.0,
        unk_arg = 0,
    }
}

Config.EyeImgColor = {
    "Brown 1",
    "Brown 2",
    "Blue 1",
    "Blue 2",
    "Blue 3",
    "Blue 4",
    "Blue 5",
    "Green 1",
    "Green 2",
    "Green 3",
    "Green 4",
    "Green 5",
    "Green 6",
    "Green 7",
}

---------------------------* EYES *--------------------------
Config.Eyes = {
    Male = {
        612262189,
        3065185688,
        1864171073,
        1552505114,
        46507404,
        4030267507,
        642477207,
        329402181,
        2501331517,
        2195072443,
        3096645940,
        3983864603,
        2739887825,
        2432743988,
    },
    Female = {
        928002221,
        3117725108,
        2273169671,
        2489772761,
        1647937151,
        3773694950,
        3450854762,
        3703470983,
        2836599857,
        625380794,
        869083847,
        3045109292,
        2210319017,
        2451302243,
    }
}

-------------------------- * BODY TYPE * --------------------------------------
Config.BodyType = {
    Body = {
        61606861,
        -1241887289,
        -369348190,
        32611963,
        -20262001,
        -369348190
    },
    Waist = {
        -2045421226,
        -1745814259,
        -325933489,
        -1065791927,
        -844699484,
        -1273449080,
        927185840,
        149872391,
        399015098,
        -644349862,
        1745919061,
        1004225511,
        1278600348,
        502499352,
        -2093198664,
        -1837436619,
        1736416063,
        2040610690,
        -1173634986,
        -867801909,
        1960266524,
    }
}

Config.Teeth = {
    Female = {
        {
            hash = 0x39340BFF,
            hash_dec_signed = 959712255,
        },
        {
            hash = 0x4AD5AF42,
            hash_dec_signed = 1255518018,
        },
        {
            hash = 0x54A6C2E4,
            hash_dec_signed = 1420215012,
        },
        {
            hash = 0x66716679,
            hash_dec_signed = 1718707833,
        },
        {
            hash = 0xF57D0492,
            hash_dec_signed = -176356206,
        },
        {
            hash = 0x20CC5B30,
            hash_dec_signed = 550263600,
        },
        {
            hash = 0x322BFDEF,
            hash_dec_signed = 841743855,
        },
    },
    Male = {
        {
            hash = 0x2A7712A2,
            hash_dec_signed = 712446626,
        },
        {
            hash = 0x61227FF8,
            hash_dec_signed = 1629650936,
        },
        {
            hash = 0x060949C7,
            hash_dec_signed = 101272007,
        },
        {
            hash = 0x3C87B6C3,
            hash_dec_signed = 1015527107,
        },
        {
            hash = 0xE1A380FC,
            hash_dec_signed = -509378308,
        },
        {
            hash = 0x17FCEDAE,
            hash_dec_signed = 402451886,
        },
        {
            hash = 0xE11FFFF5,
            hash_dec_signed = -517996555,
        },
    }
}


Config.BodyFeatures = {
    upperbody = {
        ["Velikost paží"] = { hash = 46032, comp = "ArmsS" },
        ["Velikost horní části ramen"] = { hash = 50039, comp = "ShouldersS" },
        ["Tloušťka zadních ramen"] = { hash = 7010, comp = "ShouldersT" },
        ["Zádové svaly"] = { hash = 18046, comp = "ShouldersM" }, -- shoulder blades / back muscles
        ["Velikost hrudníku"] = { hash = 27779, comp = "ChestS" },
        ["Šířka pasu"] = { hash = 50460, comp = "WaistW" },
        ["Šířka boků a velikost břicha"] = { hash = 49787, comp = "HipsS" }, -- hip width / stomach size
    },
    
    lowerbody = {
        ["Velikost stehen"] = { hash = 64834, comp = "LegsS" },
        ["Velikost lýtek"] = { hash = 42067, comp = "CalvesS" },
    },
}
-- *TRANSLATE ["inside here"] below to your language*
Config.FaceFeaturesLabels = {
    head = "hlava",
    eyesandbrows = "oči a obočí",
    ears = "uši",
    cheek = "lícní kosti",
    jaw = "čelist",
    chin = "brada",
    nose = "nos",
    mouthandlips = "ústa a rty",
    
}
Config.FaceFeatures = {
    head = {
        ["Šířka hlavy"] = { hash = 0x84D6, comp = "HeadSize" },
        ["Šířka obličeje"] = { hash = 41396, comp = "FaceW" },
        ["Hloubka obličeje"] = { hash = 12281, comp = "FaceD" },
        ["Velikost čela"] = { hash = 13059, comp = "FaceS" },
        ["Šířka krku"] = { hash = 36277, comp = "NeckW" },
        ["Hloubka krku"] = { hash = 60890, comp = "NeckD" },
    },
    
    eyesandbrows = {
        ["Výška obočí"] = { hash = 0x3303, comp = "EyeBrowH" },
        ["Šířka obočí"] = { hash = 0x2FF9, comp = "EyeBrowW" },
        ["Hloubka obočí"] = { hash = 0x4AD1, comp = "EyeBrowD" },
        ["Hloubka očí"] = { hash = 0xEE44, comp = "EyeD" },
        ["Úhel očí"] = { hash = 0xD266, comp = "EyeAng" },
        ["Vzdálenost očí"] = { hash = 0xA54E, comp = "EyeDis" },
        ["Výška očí"] = { hash = 0xDDFB, comp = "EyeH" },
        ["Výška očních víček"] = { hash = 0x8B2B, comp = "EyeLidH" },
        ["Šířka očních víček"] = { hash = 0x1B6B, comp = "EyeLidW" },
        ["Levé oční víčko"] = { hash = 52902, comp = "EyeLidL" },
        ["Pravé oční víčko"] = { hash = 22421, comp = "EyeLidR" },
    },
    
    ears = {
        ["Šířka uší"] = { hash = 0xC04F, comp = "EarsW" },
        ["Úhel uší"] = { hash = 0xB6CE, comp = "EarsA" },
        ["Výška uší"] = { hash = 0x2844, comp = "EarsH" },
        ["Hloubka uší"] = { hash = 0xED30, comp = "EarsD" },
    },
    cheek = {
        ["Výška lícní kosti"] = { hash = 0x6A0B, comp = "CheekBonesH" },
        ["Šířka lícní kosti"] = { hash = 0xABCF, comp = "CheekBonesW" },
        ["Hloubka lícní kosti"] = { hash = 0x358D, comp = "CheekBonesD" },
    },
    jaw = {
        ["Výška čelisti"] = { hash = 0x8D0A, comp = "JawH" },
        ["Šířka čelisti"] = { hash = 0xEBAE, comp = "JawW" },
        ["Hloubka čelisti"] = { hash = 0x1DF6, comp = "JawD" },
    },
    chin = {
        ["Výška brady"] = { hash = 0x3C0F, comp = "ChinH" },
        ["Šířka brady"] = { hash = 0xC3B2, comp = "ChinW" },
        ["Hloubka brady"] = { hash = 0xE323, comp = "ChinD" },
    },
    nose = {
        ["Šířka nosu"] = { hash = 0x6E7F, comp = "NoseW" },
        ["Velikost nosu"] = { hash = 0x3471, comp = "NoseS" },
        ["Výška nosu"] = { hash = 0x03F5, comp = "NoseH" },
        ["Úhel nosu"] = { hash = 0x34B1, comp = "NoseAng" },
        ["Zakřivení nosu"] = { hash = 0xF156, comp = "NoseC" },
        ["Vzdálenost nosních direk"] = { hash = 0x561E, comp = "NoseDis" },
    },
    mouthandlips = {
        ["Šířka úst"] = { hash = 0xF065, comp = "MouthW" },
        ["Hloubka úst"] = { hash = 0xAA69, comp = "MouthD" },
        ["Vzdálenost úst X"] = { hash = 0x7AC3, comp = "MouthX" },
        ["Vzdálenost úst Y"] = { hash = 0x410D, comp = "MouthY" },
        ["Výška horního rtu"] = { hash = 0x1A00, comp = "ULiphH" },
        ["ŠÍrka horního rtu"] = { hash = 0x91C1, comp = "ULiphW" },
        ["Hloubka horního rtu"] = { hash = 0xC375, comp = "ULiphD" },
        ["Výška dolního rtu"] = { hash = 0xBB4D, comp = "LLiphH" },
        ["Šířka dolního rtu"] = { hash = 0xB0B0, comp = "LLiphW" },
        ["Hloubka dolního rtu"] = { hash = 0x5D16, comp = "LLiphD" },
        ["Šířka levého koutku"] = { hash = 57350, comp = "MouthCLW" },
        ["Šířka pravého koutku"] = { hash = 60292, comp = "MouthCRW" },
        ["Hloubka levého koutku"] = { hash = 40950, comp = "MouthCLD" },
        ["Hloubka pravého koutku"] = { hash = 49299, comp = "MouthCRD" },
        ["Výška levého koutku"] = { hash = 46661, comp = "MouthCLH" },
        ["Výška pravého koutku"] = { hash = 55718, comp = "MouthCRH" },
        ["Vzdálenost rtů nalevo"] = { hash = 22344, comp = "MouthCLLD" },
        ["Vzdálenost rtů napravo"] = { hash = 9423, comp = "MouthCRLD" },
    },
   
    
}



Config.HashList = {
    Gunbelt     = 0x9B2C8B89,
    Mask        = 0x7505EF42,
    Holster     = 0xB6B6122D,
    Loadouts    = 0x83887E88,
    Coat        = 0xE06D30CE,
    Cloak       = 0x3C1A74CD,
    EyeWear     = 0x5E47CA6,
    Bracelet    = 0x7BC10759,
    Skirt       = 0xA0E3AB7F,
    Poncho      = 0xAF14310B,
    Spats       = 0x514ADCEA,
    NeckTies    = 0x7A96FACA,
    Spurs       = 0x18729F39,
    Pant        = 0x1D4C528A,
    Suspender   = 0x877A2CF7,
    Glove       = 0xEABE0032,
    Satchels    = 0x94504D26,
    GunbeltAccs = 0xF1542D11,
    CoatClosed  = 0x662AC34,
    Buckle      = 0xFAE9107F,
    RingRh      = 0x7A6BBD0B,
    Belt        = 0xA6D134C6,
    Accessories = 0x79D7DF96,
    Shirt       = 0x2026C46D,
    Gauntlets   = 0x91CE9B20,
    Chap        = 0x3107499B,
    NeckWear    = 0x5FC29285,
    Boots       = 0x777EC6EF,
    Vest        = 0x485EE834,
    RingLh      = 0xF16A1D23,
    Hat         = 0x9925C067,
    Dress       = 0xA2926F9B,
    Badge       = 0x3F7F3587,
    armor       = 0x72E6EF74,
    Hair        = 0x864B03AE,
    Beard       = 0xF8016BCA,
    bow         = 0x8E84A2AA,
}

Config.Overlays = {
    ["eyebrow"] = {
        id = 0,
        opacity = 0.0,
        palette = 'metaped_tint_hair',
        tint0 = 135
    },
    ["hair"] = 
    {
        id = 0,
        opacity = 0.0,
        palette = 'metaped_tint_hair',
        tint0 = 135
    },
    ["beardstabble"] = 
    {
        id = 0,
        opacity = 0.0,
        palette = 'metaped_tint_hair',
        tint0 = 135
    }
}
