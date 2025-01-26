-- File: config.lua

Config = {}

-- Definice attachmentů
Config.Items = {
    badge_star_1 = {
        item = 'badge_star_1',
        model = 'aprts_star_001', -- Model attachmentu
        coords = {
            x = 0.04,
            y = -0.13,
            z = 0.04,
            xr = 0.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff", -- Povolání, které může attachment používat
        grade = 1, -- Minimální hodnost pro použití
        jobLabel = "Valentine", -- Popisek práce
        category = "badge", -- Kategorie attachmentu
        obj = nil
    },
    badge_star_2 = {
        item = 'badge_star_2',
        model = 'aprts_star_002', -- Model attachmentu
        coords = {
            x = 0.04,
            y = -0.13,
            z = 0.04,
            xr = 0.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff",
        grade = 1,
        jobLabel = "Valentine",
        category = "badge", -- Kategorie attachmentu
        obj = nil
    },
    
    badge_star_3 = {
        item = 'badge_star_3',
        model = 'aprts_star_003', -- Model attachmentu
        coords = {
            x = 0.04,
            y = -0.13,
            z = 0.04,
            xr = 0.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff",
        grade = 1,
        jobLabel = "Valentine",
        category = "badge", -- Kategorie attachmentu
        obj = nil
    },
    
    badge_star_4 = {
        item = 'badge_star_4',
        model = 's_badgeusmarshal01x', -- Model attachmentu
        coords = {
            x = 0.04,
            y = -0.13,
            z = 0.04,
            xr = 90.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff",
        grade = 1,
        jobLabel = "Valentine",
        category = "badge", -- Kategorie attachmentu
        obj = nil
    },
    alcohol_otvirak = {
        item = 'alcohol_otvirak',
        model = 'mp006_p_mp006_crate02x',
        coords = {
            x = 0.0,
            y = 0.0,
            z = -0.5,
            xr = 0.0,
            yr = 0.0,
            zr = 0.0
        },
        bone = 'CP_Chest',
        job = nil,
        grade = nil,
        jobLabel = nil,
        category = "mask", -- Kategorie attachmentu
        obj = nil
    },
    -- Přidejte další attachmenty zde
}

-- Příkaz pro nasazení attachmentu
Config.AttachCommand = "attach"

-- Omezení viditelnosti
Config.VisibleDistance = 50.0 -- Maximální vzdálenost, na kterou budou attachmenty viditelné

-- Povolené pracovní pozice pro příkaz /attach
Config.AllowedJobs = {
    sheriff = true,
    marshal = true,
    -- Přidejte další povolené práce zde
}
