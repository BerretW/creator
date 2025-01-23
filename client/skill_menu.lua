
skills = {"shooting", "fishing", "riding", "hunting", "herbalism", "cooking", "stamina", "mining", "woodcutting","crafting"}
skillValues = {}


function createSkillMenu()
    local basePoints = 1  -- Základní pool kladných bodů (za hodnotu 1 se body neplatí)

    -- Vygenerujeme seznam hodnot od -10 do +10, vynecháme 0
    local possibleValues = {}
    for i = -10, 10 do
        if i ~= 0 then
            table.insert(possibleValues, i)
        end
    end

    -- Vytvoříme pole "switchOptions" pro slider (label je jen text)
    local switchOptions = {}
    for _, value in ipairs(possibleValues) do
        table.insert(switchOptions, { label = tostring(value) })
    end

    -- Pomocná funkce: najde v possibleValues index pro danou hodnotu
    local function getIndexForValue(val)
        for idx, v in ipairs(possibleValues) do
            if v == val then
                return idx
            end
        end
        return nil
    end

    -- Funkce pro výpočet dodatečného nákladu u kladných hodnot (nad základní 1)
    local function getPositiveCost()
        local cost = 0
        for _, v in pairs(skillValues) do
            if v > 1 then
                cost = cost + (v - 1)  -- Platí se jen přebytek nad 1
            end
        end
        return cost
    end

    -- Součet všech záporných (mínusových) hodnot – ty nám „vracejí“ body
    local function getNegativeSum()
        local sum = 0
        for _, v in pairs(skillValues) do
            if v < 0 then
                sum = sum + (-v)
            end
        end
        return sum
    end

    -- Vytvoříme menu
    local menu = jo.menu.create("skillMenu", {
        title = "Dovednosti",
        subtitle = "Nastav level dovednosti od -10 do +10 (bez 0)"
    })

    -- 1) Položka zobrazující, kolik zbývá kladných bodů
    menu:addItem({
        title = "Zbývající kladné body: " .. basePoints,
        disabled = true
    })

    -- Aktualizace zobrazení zbývajících bodů
    local function updateRemainingPoints()
        local positiveCost = getPositiveCost()
        local negSum = getNegativeSum()
        local allowedPositive = basePoints + negSum
        local remaining = allowedPositive - positiveCost
        if remaining < 0 then
            remaining = 0
        end

        menu.items[1].title = "Zbývající kladné body: " .. remaining
        menu:refresh()
    end

    -- 2) Pro každou dovednost přidáme položku se sliderem
    for _, skill in ipairs(skills) do
        -- Každý skill začíná na hodnotě 1 (tato hodnota se neplatí z poolu)
        skillValues[skill] = 1
        local startIndex = getIndexForValue(1)

        menu:addItem({
            title = skill,

            -- Statistiky: bar ukazuje hodnotu pro kladnou část (1 až 10)
            statistics = {{
                label = "Level: 1",
                type = "bar",
                value = { 1, 10 }  -- Zobrazuje počet „čárek“ (minimálně 1 z 10)
            }},

            sliders = {{
                type = "switch",
                wrap = false,
                current = startIndex,     -- Index odpovídající počáteční hodnotě 1
                values = switchOptions
            }},

            onChange = function(currentData)
                local oldValue = skillValues[skill]

                -- Přečteme nový index slideru a získáme odpovídající hodnotu
                local newIndex = currentData.item.sliders[1].current
                local newValue = possibleValues[newIndex]

                -- Pomocná funkce pro výpočet nákladu pro danou hodnotu
                local function costForValue(val)
                    if val > 1 then
                        return val - 1
                    else
                        return 0
                    end
                end

                -- Výpočet nového celkového nákladu pro kladné hodnoty, pokud by se změnila tato dovednost.
                local currentPositiveCost = getPositiveCost() - costForValue(oldValue)
                local newPositiveCost = currentPositiveCost
                if newValue > 1 then
                    newPositiveCost = newPositiveCost + (newValue - 1)
                end

                local negSum = getNegativeSum()
                local allowedPositive = basePoints + negSum

                -- Zkontrolujeme, zda by tím nebyl překročen pool
                if newPositiveCost <= allowedPositive then
                    -- Změna je povolena
                    skillValues[skill] = newValue
                else
                    -- Nedostatek bodů – vrátíme slider na původní hodnotu
                    local oldIndex = getIndexForValue(oldValue)
                    currentData.item.sliders[1].current = oldIndex
                    newValue = oldValue
                end

                -- Aktualizace bar statistiky
                local statBar = currentData.item.statistics[1]
                local barValue = (newValue > 1) and newValue or 0
                statBar.value[1] = barValue
                statBar.value[2] = 10
                statBar.label = ("Level: %d"):format(newValue)

                debugPrint(skill .. " => " .. newValue)
                updateRemainingPoints()
            end
        })
    end
    menu:addItem({
        title = "Resetovat body",
        type = "button",
        onClick = function()
            -- Reset všech dovedností na výchozí hodnotu 1
            for _, skill in ipairs(skills) do
                skillValues[skill] = 1
                local resetIndex = getIndexForValue(1)
    
                -- Najdeme položku menu pro danou dovednost
                for i, item in ipairs(menu.items) do
                    if item.title == skill then
                        -- Resetujeme slider
                        item.sliders[1].current = resetIndex
    
                        -- Resetujeme statistiky
                        local statBar = item.statistics[1]
                        statBar.value[1] = 1
                        statBar.label = "Level: 1"
    
                        break
                    end
                end
            end
    
            -- Aktualizujeme zbývající body
            updateRemainingPoints()
    
            -- Obnovíme menu
            menu:refresh()
    
            debugPrint("Všechny body byly resetovány na výchozí hodnoty.")
        end
    })
    menu:send()
    updateRemainingPoints()
end
