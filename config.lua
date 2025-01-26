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
            xr = 90.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff", -- Povolání, které může attachment používat
        grade = 1, -- Minimální hodnost pro použití
        jobLabel = "Valentine", -- Popisek práce
        obj = nil
    },
    badge_star_2 = {
        item = 'badge_star_2',
        model = 'aprts_star_002', -- Model attachmentu
        coords = {
            x = 0.04,
            y = -0.13,
            z = 0.04,
            xr = 90.0,
            yr = 25.0,
            zr = 990.0
        },
        bone = 'CP_Chest', -- Kost, na kterou se attachment připevní
        job = "sheriff", -- Povolání, které může attachment používat
        grade = 1, -- Minimální hodnost pro použití
        jobLabel = "Valentine", -- Popisek práce
        obj = nil
    },
    -- Přidejte další attachmenty zde
}

-- Příkaz pro nasazení attachmentu
Config.AttachCommand = "attach"

-- Omezení viditelnosti
Config.VisibleDistance = 50.0 -- Maximální vzdálenost, na kterou budou attachmenty viditelné

