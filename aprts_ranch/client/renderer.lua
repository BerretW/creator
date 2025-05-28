-- Funkce pro získání FPS
local function getFPS()
    return 1.0 / GetFrameTime() -- Vrací počet FPS jako inverzní hodnotu času jednoho snímku
end

-- Funkce pro výpočet pauzy na základě FPS
function fpsTimer()
    local minFPS, maxFPS = 15, 165
    local minPause, maxPause = 0, 15
    local fps = getFPS()
    local coefficient = 1 - (fps - minFPS) / (maxFPS - minFPS)
    return minPause + coefficient * (maxPause - minPause)
end

-- Nastavení maximálního zdraví pro entitu
function SetEntityHealthToMax(entity, health)
    local maxHealthValue = math.floor(tonumber(health))
    if DoesEntityExist(entity) and not IsPedAPlayer(entity) then
        SetEntityHealth(entity, maxHealthValue)
    end
end

-- Funkce pro škálování zvířete podle věku
function scaleByAge(breed, age)
    local adultAge = Config.Animals[breed].adultAge
    if age > 0 then
        if age < adultAge then
            local ageRatio = age / adultAge
            return 0.3 + (ageRatio * (1.0 - 0.3)) -- Škálování z 0.3 na 1.0
        else
            return 1.0 -- Plná velikost pro dospělé zvíře
        end
    else
        return 0.3
    end
end

-- Zpracování zvířat v každém cyklu
Citizen.CreateThread(function()
    while dataLoaded == false do
        Citizen.Wait(100)
    end
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        while not LocalPlayer.state.IsInSession do
            Citizen.Wait(1000)
        end
        for _, railing in pairs(railings) do
            local railingPos = railing.coords
            local distance = GetDistanceBetweenCoords(playerPos, railingPos.x, railingPos.y, railingPos.z, true)
            local railingId = railing.id

            if distance <= Config.RenderDistance then
                -- debugPrint("distance" .. distance)
                -- Pro každé zvíře připojené k hrazení
                for i, animal in pairs(animals) do

                    if animal.railing_id == railingId then
                        if not DoesEntityExist(animal.obj) and animal.home == 1 then
                            -- debugPrint("animal home")
                            -- Vytvoření modelu zvířete na základě pohlaví
                            -- debugPrint("Vytvářím zvíře " .. animal.breed .. " na railingu " .. railingId)
                            local anima = {}
                            debugPrint("Animal: ", json.encode(Config.Animals[animal.breed]))
                            anima.model = (animal.gender == "female") and Config.Animals[animal.breed].model or
                                              Config.Animals[animal.breed].m_model
                            anima.health = animal.health

                            -- Náhodné umístění zvířete do hrazení
                            local pos = getRandomPosInRailing(railing)
                            pos = railingPos
                            TriggerEvent("aprts_ranch:Client:spawnAnimal", anima, pos, true, animal.id, railingPos)
                            Citizen.Wait(300)
                        else
                            -- Pokud zvíře zemřelo, ohlásí to serveru
                            local health = GetEntityHealth(animal.obj)
                            if health <= 0 and animal.health > 0 then

                                local CauseOdDeath = GetPedCauseOfDeath(animal.obj)
                                -- debugPrint("Zvíře bylo zabitou zbraní: " .. CauseOdDeath)
                                for _, cause in pairs(Config.WeaponHash) do
                                    if CauseOdDeath == cause then
                                        -- debugPrint("Zvíře bylo zabitou zbraní: " .. _)
                                        CauseOdDeath = _
                                        break
                                    end

                                end
                                TriggerServerEvent("aprts_clue:Server:addClue",
                                    "Zvíře bylo zraněno zbraní: " .. CauseOdDeath, GetEntityCoords(animal.obj),
                                    "p_cougarbloodpools01x", 5.0,1)
                                TriggerServerEvent("aprts_ranch:Server:logKillAnimal", animal.id, CauseOdDeath,
                                    GetEntityCoords(animal.obj))

                                TriggerServerEvent("aprts_ranch:Server:killAnimal", animal.id)
                            elseif animal.health == 0 then
                                SetEntityHealth(animal.obj, 0)
                            end
                            -- Aktualizace velikosti zvířete
                            SetPedScale(animal.obj, scaleByAge(animal.breed, animal.age))
                        end
                    end
                end
                if railing.products == nil then
                    railing.products = {}
                end

                for i, product in pairs(railing.products) do
                    -- debugPrint("produkt = " .. product.prop .. " v počtu " .. product.amount .. " na railingu " .. railingId)
                    if tonumber(product.amount) > 0 then
                        if not DoesEntityExist(product.obj) then
                            product.obj = spawnEntity(product.coords, product.prop)
                            -- debugPrint("Spawnuji produkt = " .. product.prop .. " na railingu " .. railingId)
                        end
                    else
                        if DoesEntityExist(product.obj) then
                            -- debugPrint("Produkt " .. product.prop .. " je prázdný, mažu")
                            DeleteEntity(product.obj)
                        end
                    end
                end
            else
                for i, product in pairs(railing.products) do
                    if DoesEntityExist(product.obj) then
                        DeleteEntity(product.obj)
                    end
                end
                -- Pokud je zvíře příliš daleko, smaže se jeho entita
                for i, animal in pairs(animals) do
                    if animal.railing_id == railingId and DoesEntityExist(animal.obj) then
                        DeleteEntity(animal.obj)
                    end
                end
            end
        end

        Citizen.Wait(pause)

    end
end)

-- Funkce pro vykreslování hoven a propů
Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        -- Správa hoven
        for _, poop in pairs(poops) do
            local poopPos = poop.coords
            local distance = GetDistanceBetweenCoords(playerPos, poopPos.x, poopPos.y, poopPos.z, true)

            if distance <= Config.RenderDistance then
                -- Pokud hovno není vykresleno, vytvoř jej
                if not DoesEntityExist(poop.obj) then
                    poop.obj = spawnEntity(poop.coords, poop.prop) -- Použijeme funkci spawnEntity
                end
            else
                -- Pokud je hovno příliš daleko, smaž jeho entitu
                if DoesEntityExist(poop.obj) then
                    DeleteEntity(poop.obj)
                end
            end
        end

        -- Správa propů (např. hrazení)
        for _, prop in pairs(railings) do
            local propPos = prop.coords
            local distance = GetDistanceBetweenCoords(playerPos, propPos.x, propPos.y, propPos.z, true)

            if distance <= Config.RenderDistance then
                -- Pokud prop není vykreslen, vytvoř jej
                if not DoesEntityExist(prop.obj) and LocalPlayer.state.IsInSession then
                    prop.obj = spawnEntity(prop.coords, prop.prop) -- Použijeme funkci spawnEntity

                    -- Upraví se výška objektu na základě zmod hodnoty, pokud je třeba
                    local coords = GetEntityCoords(prop.obj)
                    SetEntityCoords(prop.obj, coords.x, coords.y, coords.z + Config.feeding[prop.prop].zmod)
                end
            else
                -- Pokud je prop mimo renderovací vzdálenost, smaž jeho entitu
                if DoesEntityExist(prop.obj) then
                    DeleteEntity(prop.obj)
                end
            end
        end

        Citizen.Wait(pause)
    end
end)
