Config = {}
Config.Debug = false
Config.GainUp = 0.01
Config.boxPrice = 1.5
Config.Drawdistance = 25.0
Config.interactDistance = 2.0
Config.Key = 0x760A9C6F
Config.KeyLabel = 'G'
Config.cargoCount = 10
Config.Blip = "blip_ambient_loan_shark"
Config.PropSet = "pg_vehload_crates01"

Config.Animation = {
    dict = "mech_carry_box",
    name = "idle",
    time = 3000,
    flag = 31,
    type = 'standard',
    prop = {
        model = 'p_chair_crate02x',
        coords = {
            x = 0.1,
            y = -0.1399,
            z = 0.21,
            xr = 263.2899,
            yr = 619.19,
            zr = 334.3
        },
        bone = 'SKEL_L_Hand'
    }
}

Config.JobPost = {{
    id = 1,
    name = "Vyvoz BW",
    location = 'BW',
    butcherID = 1,
    shipmendID = 1,
    item = "export_bw",
    coords = vector3(-742.8026, -1295.5459, 43.2594), -- -742.8026, -1295.5459, 43.2594, 93.8623
    npcH = 93.8623,
    vagonCoords = vector3(-743.362610, -1300.373047, 43.179440),
    vagonH = 176.3,
    cargoCoords = vector3(-752.884949, -1292.110352, 43.429790),
    cargoModel = "p_bat_cratestack01x",
    targetCoords = vector3(-329.508698, -368.719666, 87.446007),
    blipsprite = 'blip_ambient_loan_shark',
    blipscale = 0.2,
    showblip = true,
    model = "u_m_m_rhdgenstoreowner_02"
}, {
    id = 2,
    name = "Vyvoz VAL",
    location = 'VL',
    butcherID = 3,
    shipmendID = 1,
    coords = vector3(-334.984833, 762.674683, 116.567749), -- -742.8026, -1295.5459, 43.2594, 93.8623
    npcH = 93.8623,
    vagonCoords = vector3(-348.084015, 753.281738, 116.497459),
    vagonH = 176.3,
    cargoCoords = vector3(-336.364227, 757.394287, 116.865471),
    cargoModel = "p_bat_cratestack01x",
    targetCoords = vector3(-329.508698, -368.719666, 87.446007),
    blipsprite = 'blip_ambient_loan_shark',
    blipscale = 0.2,
    showblip = true,
    model = "u_m_m_rhdgenstoreowner_02"
}, {
    id = 3,
    name = "Vyvoz RH",
    location = 'RH',
    butcherID = 4,
    shipmendID = 1,
    coords = vector3(1305.270996, -1275.895020, 76.066071), -- -742.8026, -1295.5459, 43.2594, 93.8623
    npcH = 93.8623,
    vagonCoords = vector3(1313.297485, -1280.453125, 76.183327),
    vagonH = 176.3,
    cargoCoords = vector3(1287.200073, -1273.490234, 75.429680),
    cargoModel = "p_bat_cratestack01x",
    targetCoords = vector3(-329.508698, -368.719666, 87.446007),
    blipsprite = 'blip_ambient_loan_shark',
    blipscale = 0.2,
    showblip = true,
    model = "u_m_m_rhdgenstoreowner_02"
}, {
    id = 4,
    name = "Vyvoz SB",
    location = 'SB',
    butcherID = 8,
    shipmendID = 1,
    coords = vector3(-1744.864258, -391.792847, 156.671204), -- -742.8026, -1295.5459, 43.2594, 93.8623
    npcH = 93.8623,
    vagonCoords = vector3(-1751.313354, -406.458466, 155.420624),
    vagonH = 249.3,
    cargoCoords = vector3(-1749.279297, -389.286499, 156.366409),
    cargoModel = "p_bat_cratestack01x",
    targetCoords = vector3(-329.508698, -368.719666, 87.446007),
    blipsprite = 'blip_ambient_loan_shark',
    blipscale = 0.2,
    showblip = true,
    model = "u_m_m_rhdgenstoreowner_02"
}}

Config.CrateReward = {{
    id = 1,
    name = "export_bw",
    price = 2.3
}, {
    id = 3,
    name = "export_val",
    price = 1.9
}, {
    id = 4,
    name = "export_rh",
    price = 2.5
}}
Config.ShipmmentPosts = {{
    id = 1,
    name = "Sklady FlatNeck",
    location = 'FN',
    coords = vector3(-329.508698, -368.719666, 87.446007)
}}
