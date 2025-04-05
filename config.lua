Config = {}
Config.Debug = false
Config.WebHook = ""
Config.ServerName = 'WestHaven ** Loger'
Config.DiscordColor = 16753920
Config.Jobs = {"printer", "major"}
Config.RenderDistance = 100.0
Config.Items = {
    -- ["library_newspaper"] = {
    --     label = "Noviny",
    --     weight = 1,
    --     stack = 100
    -- },
    ["library_book"] = {
        type = "book",
        
    },
    -- ["library_poster"] = {
    --     label = "Plakát",
    --     weight = 1,
    --     stack = 100
    -- }
}
Config.Key = {
    print = {
        key = 0xF3830D8E,
        label = "J"
    },
    open = {
        key = 0x760A9C6F,
        label = "G"
    }
}
Config.Printables = {{
    name = "Noviny",
    item = "library_newspaper",
    price = 1,
    materials = {{
        name = "Papír",
        amount = 1
    }, {
        name = "Barva",
        amount = 1
    }}
}, {
    name = "Kniha",
    item = "library_book",
    price = 2,
    materials = {{
        name = "Papír",
        amount = 20
    }, {
        name = "Barva",
        amount = 1
    }}
}, {
    name = "Plakát",
    item = "library_poster",
    price = 3,
    materials = {{
        name = "Papír",
        amount = 10
    }, {
        name = "Barva",
        amount = 5
    }}
}}

Config.Printers = {{

    name = "Tiskárna SD",
    active = true,
    openTime = 7,
    closeTime = 19,
    closeMessage = "Tiskárna je zavřena, přijďte později.",
    coords = vector3(108.0, -1284.0, 29.0),
    heading = 0.0,
    model = "prop_printer_01",
    grade = 5,
    Jobs = Config.Jobs,
    props = {
        ["printer"] = {
            model = "prop_paper_bag_small",
            coords = vector3(0.0, 0.0, 0.0),
            heading = 0.0
        },
        ["chair"] = {
            model = "prop_paper_bag_small",
            coords = vector3(0.0, 0.0, 0.0),
            heading = 0.0
        }
    }
}}
