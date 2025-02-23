-- local api = nil
-- TriggerEvent('getApi', function(gumApi)
--     api = gumApi
-- end)
ePedAttribute = {"PA_HEALTH", -- 0 
"PA_STAMINA", -- 1 
"PA_SPECIALABILITY", -- 2
"PA_COURAGE", -- 3
"PA_AGILITY", -- 4
"PA_SPEED", -- 5
"PA_ACCELERATION", -- 6
"PA_BONDING", -- 7
"SA_HUNGER", -- 8
"SA_FATIGUED", -- 9
"SA_INEBRIATED", -- 10
"SA_POISONED", -- 11
"SA_BODYHEAT", -- 12
"SA_BODYWEIGHT", -- 13
"SA_OVERFED", -- 14
"SA_SICKNESS", -- 15
"SA_DIRTINESS", -- 16
"SA_DIRTINESSHAT", -- 17
"MTR_STRENGTH", -- 18
"MTR_GRIT", -- 19
"MTR_INSTINCT", -- 20
"PA_UNRULINESS", -- 21
"SA_DIRTINESSSKIN"}; -- 22

-- Funkce pro vykreslení textu, čáry a dalších prvků na základě vstupní tabulky `data`
function displayData3D(x, y, z, data, showImage, imagePath)
    -- Získání koordinátů na obrazovce a vzdálenosti od kamery
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    -- Pevná škála, která bere v potaz vzdálenost a fov kamery
    local scale = (1 / dist) * 2.0
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        -- Upravíme základní posun na ose Y, aby se prvky pohybovaly správně vzhledem k pozici
        local baseYOffset = -0.03 -- Posun, aby první řádek začal o trochu výše

        -- Projdi jednotlivé položky v `data` tabulce
        for i, row in pairs(data) do
            local yOffset = baseYOffset + (0.03 * (i - 1)) * scale -- Dynamický posun na základě škálování

            -- Zpracuj a vykresli text pro aktuální řádek
            if row.text then
                SetTextScale(0.35 * scale, 0.35 * scale) -- Zvětšíme text dle vzdálenosti
                SetTextFontForCurrentCommand(1)
                local r, g, b = hexToRGB(row.color) -- Konverze hex na RGB
                SetTextColor(r, g, b, 255)
                SetTextCentre(1)
                DisplayText(CreateVarString(10, "LITERAL_STRING", row.text, Citizen.ResultAsLong()), _x, _y + yOffset)
            end

            -- Pokud je definovaná čára (line = true), vykresli ji s procentuální hodnotou (value)
            if row.line and row.value then
                local lineLength = 0.06 * scale -- Délka čáry (přizpůsobená dle měřítka)
                local lineStartX = _x - (lineLength / 2) -- Začátek čáry
                local lineEndX = lineStartX + (lineLength * (row.value / 100)) -- Konec čáry dle procent

                local lineColorR, lineColorG, lineColorB = hexToRGB(row.lineColor or "#ffffff") -- Barva čáry
                local lineWidth = row.lineWidth or 0.005 -- Tloušťka čáry

                -- Vykreslení čáry blíže pod text
                DrawRect(lineStartX + ((lineEndX - lineStartX) / 2), _y + yOffset + (0.015 * scale),
                    (lineEndX - lineStartX), lineWidth * scale, lineColorR, lineColorG, lineColorB, 255)
            end
        end

        -- Vykreslení PNG obrázku, pokud je zapnuto
        if showImage and imagePath then
            DrawSprite(imagePath, "default", _x + 0.05 * scale, _y + 0.02 * scale, 0.05 * scale, 0.05 * scale, 0.0, 255,
                255, 255, 255)
        end
    end
end

-- Funkce pro konverzi hex kódu na RGB (např. "#fc0a03" => 252, 10, 3)
function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

-- Funkce pro zobrazení informací o atributu koně
function displayHorseAttributes(horse, showImage, imagePath)
    local attributes, coreAttributes = getHorseAttibutes(horse)
    local health = Citizen.InvokeNative(0x36731AC041289BB1, horse, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local stamina = Citizen.InvokeNative(0x36731AC041289BB1, horse, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue

    local data = {{
        text = "Zdraví: " .. coreAttributes.CoreHealth .. "/" .. attributes.PA_HEALTH.Points .. "/" .. health,
        line = false,
        value = coreAttributes.Health,
        color = "#ff0000",
        lineColor = "#ff0000"
    }, {
        text = "Stamina: " .. coreAttributes.CoreStamina .. "/" .. attributes.PA_STAMINA.Points .. "/" .. stamina,
        line = false,
        value = coreAttributes.Stamina,
        color = "#00ff00",
        lineColor = "#00ff00"
    }, {
        text = "Síla: " .. attributes.MTR_STRENGTH.Points,
        line = false,
        value = attributes.PA_STAMINA.Points,
        color = "#ff0000",
        lineColor = "#ff0000"
    }, {
        text = "Obratnost: " .. attributes.PA_AGILITY.Points,
        line = false,
        value = attributes.PA_AGILITY.Points,
        color = "#00ff00",
        lineColor = "#00ff00"
    }, {
        text = "Rychlost: " .. attributes.PA_SPEED.Points,
        line = false,
        value = attributes.PA_SPEED.Points,
        color = "#ffffff",
        lineColor = "#0000ff"
    }, {
        text = "Akcelerace: " .. attributes.PA_ACCELERATION.Points,
        line = false,
        value = attributes.PA_ACCELERATION.Points,
        color = "#ff00ff",
        lineColor = "#ff00ff"
    }, {
        text = "Výcvik : " .. attributes.PA_BONDING.Points,
        line = false,
        value = attributes.PA_BONDING.Points,
        color = "#ffff00",
        lineColor = "#ffff00"
    }}
    local pos = GetEntityCoords(horse)
    displayData3D(pos.x, pos.y, pos.z, data, showImage, imagePath)
end

-- Citizen.CreateThread(function()
--     while true do
--         local pause = 1000

--         local isMounted = IsPedOnMount(PlayerPedId())
--         if isMounted then
--             pause = 0
--             local currentHorse = GetMount(PlayerPedId())
--             local model = GetEntityModel(currentHorse)
--             if not IsThisModelAHorse(model) then
--                 return
--             end
--             displayHorseAttributes(currentHorse, false, "horse.png")
--             SetEntityHealth(currentHorse, 1000, 0)
--         end
--         Wait(pause)
--     end
-- end)

function getHorseAttibutes(horse)
    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    local Attributes = {}
    for index, atr in pairs(ePedAttribute) do
        Attributes[atr] = {}
        -- print(index - 1, "-", atr)
        Attributes[atr].index = index - 1
        Attributes[atr].Name = atr
        -- Atribute.BaseRank = GetAttributeBaseRank(horse, index)
        Attributes[atr].Rank = GetAttributeRank(horse, index - 1)
        Attributes[atr].BonusRank = GetAttributeBonusRank(horse, index)
        -- Atribute.maxRank = GetMaxAttributeRank(horse, index)
        Attributes[atr].Points = GetAttributePoints(horse, index - 1)
        -- Atribute.maxPoints = GetMaxAttributePoints(horse, index)
        -- print(json.encode(Atributes[atr]))
    end
    local coreAttributes = {}
    coreAttributes.CoreHealth = GetAttributeCoreValue(horse, 0)
    coreAttributes.Health = GetEntityHealth(horse)
    coreAttributes.CoreStamina = GetAttributeCoreValue(horse, 1)
    coreAttributes.Stamina = GetPedStamina(horse)
    print("Core Health: ", coreAttributes.CoreHealth, " Health: ", coreAttributes.Health, " Core Stamina: ",
        coreAttributes.CoreStamina, " Stamina: ", coreAttributes.Stamina)
    return Attributes, coreAttributes
end

exports('getHorseAttibutes', function(horse)
    return getHorseAttibutes(horse)
end)


function setHorseAttributes(horse, attributes)
    for index, atr in pairs(attributes) do
        SetAttributeBonusRank(horse, atr.index, atr.BonusRank)
        SetAttributePoints(horse, atr.index, atr.Points)
    end
end

function setHorseCoreAttributes(horse, CoreHealth, CoreStamina, health, stamina)
    SetAttributeCoreValue(horse, 0, CoreHealth)
    SetAttributeCoreValue(horse, 1, CoreStamina)
    RestorePedStamina(horse, stamina)
    SetEntityHealth(horse, health, 0)
    local Attributes = {}
    Attributes.CoreHealth = GetAttributeCoreValue(horse, 0)
    Attributes.CoreStamina = GetAttributeCoreValue(horse, 1)

    return Attributes
end

function getHorseBondingLevel(horse)
    return GetAttributePoints(horse, 7)
end

RegisterNetEvent("aprts_horses:useItem")
AddEventHandler("aprts_horses:useItem", function(item)
    print("Using item: ", json.encode(item))
    local isMounted = IsPedOnMount(PlayerPedId()) and not IsPedOnFoot(PlayerPedId())
    local myhorse = false
    if isMounted == true then
        local currentHorse = GetMount(PlayerPedId())

        if currentHorse == myHorse.ped then
            myhorse = true
        end

        local model = GetEntityModel(currentHorse)
        if not IsThisModelAHorse(model) then
            return
        end
        if item.onMountAnimation and item.onMountAnimationParameter then
            local onMountAnimation = item.onMountAnimation
            local onMountAnimationParameter = item.onMountAnimationParameter
            RequestAnimDict(onMountAnimation)
            while not HasAnimDictLoaded(onMountAnimation) do
                Citizen.Wait(0)
            end
            TaskPlayAnim(PlayerPedId(), onMountAnimation, onMountAnimationParameter, 1.0, 1.0, item.timer, 1, 1.0,
                false, false, false)
            -- api.playAnim(PlayerPedId(), onMountAnimation, onMountAnimationParameter, 1, item.timer)
        end
        Wait(item.timer)
        ClearPedTasksImmediately(PlayerPedId())
        local attributes, coreAttributes = getHorseAttibutes(currentHorse)
        for index, atr in pairs(attributes) do

            if item.modifiers[tostring(atr.index)] then
                local points = item.modifiers[tostring(atr.index)]
                print("Attribute: ", atr.Name, " - ", atr.index, " - ", points)
                if atr.index == 1 then
                    RestorePedStamina(currentHorse, points)
                else
                    AddAttributePoints(currentHorse, atr.index, points)
                end
                if atr.index == 0 then
                    SetEntityHealth(currentHorse, points, 0)
                else
                    AddAttributePoints(currentHorse, atr.index, points)
                end
            end
        end

        if item.core_modifiers then
            print("Core Modifiers: ", json.encode(item.core_modifiers))
            local currenthealth = tonumber(coreAttributes.CoreHealth)
            local healthbonus = tonumber(item.core_modifiers.CoreHealth)
            print("Current Health: ", currenthealth, " Health Bonus: ", healthbonus)
            setHorseCoreAttributes(currentHorse, currenthealth + healthbonus,
                coreAttributes.CoreStamina + item.core_modifiers.CoreStamina, 100, 100)
        end
    else
        print("You are not mounted")
        notify("Nejsi na koni");
        if item.oneTime == 1 then
            TriggerServerEvent("aprts_horses:Server:giveItem", item)
        end
    end

end)

RegisterNetEvent("aprts_horses:upgradeAttribute")
AddEventHandler("aprts_horses:upgradeAttribute", function(horse, index, points)

    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    if index then
        AddAttributePoints(horse, index, points)
    else
        print("Attribute index is missing")
    end

end)

RegisterNetEvent("aprts_horses:updateAttributes")
AddEventHandler("aprts_horses:updateAttributes", function(horseID, horse, shoed)
    if not horseID or horseID == 0 then
        dprint("Horse ID is missing")
        return
    end
    local Attributes, CoreAttributes = getHorseAttibutes(horse)
    if shoed == 1 then
        Attributes.PA_AGILITY.Points = Attributes.PA_AGILITY.Points - Config.shoeBonus
    end
    local alive = IsPedDeadOrDying(horse)

    TriggerServerEvent("aprts_horses:Server:updateAttributes", horseID, Attributes, CoreAttributes, alive)
end)

RegisterNetEvent("aprts_horses:restoreStamina") -- Core
AddEventHandler("aprts_horses:restoreStamina", function(horse, points, horseID)
    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    local oldValue = GetAttributeCoreValue(horse, 1)
    local newValue = oldValue + points
    SetAttributeCoreValue(horse, 1, newValue)



end)

RegisterNetEvent("aprts_horses:rechargeStamina")
AddEventHandler("aprts_horses:rechargeStamina", function(horse, points, horseID)
    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    local oldValue = GetAttributePoints(horse, 1)
    local newValue = oldValue + points
    AddAttributePoints(horse, 1, newValue)
    -- RestorePedStamina(horse, 100.0)


end)

RegisterNetEvent("aprts_horses:restoreHealth") -- Core
AddEventHandler("aprts_horses:restoreHealth", function(horse, points, horseID)
    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    local oldValue = GetAttributeCoreValue(horse, 0)
    local newValue = oldValue + points
    SetAttributeCoreValue(horse, 0, newValue)

end)

RegisterNetEvent("aprts_horses:rechargeHealth")
AddEventHandler("aprts_horses:rechargeHealth", function(horse, points, horseID)
    local model = GetEntityModel(horse)

    if not IsThisModelAHorse(model) then
        return
    end
    local oldValue = GetAttributePoints(horse, 0)
    local newValue = oldValue + points
    AddAttributePoints(horse, 0, newValue)


end)

