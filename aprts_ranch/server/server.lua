-- server.lua
Core = exports.vorp_core:GetCore()

ranches = {}
animals = {}
railings = {}
freeAnimals = {}

function notify(source, text)
    debugPrint("RANČ", text)
    TriggerClientEvent('notifications:notify', source, "RANČ", text, 3000)
end

function debugPrint(text)
    if Config.Debug == true then
        print(text)
    end
end

function getTimeStamp()
    local time = 0
    MySQL:execute("SELECT UNIX_TIMESTAMP() as time", {}, function(result)
        if result then
            time = result[1].time
        end
    end)
    while time == 0 do
        Wait(100)
    end
    return time
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function getCountAnimlsonRailing(railing)
    local count = 0
    for _, animal in pairs(animals) do
        if animal.railing_id == railing.id then
            count = count + 1
        end
    end
    return count
end

function getCountPoopInRailing(railing)
    -- debugPrint("Získávání počtu hoven v ohradě " .. railing.id)
    local count = 0
    for _, poop in pairs(poops) do
        if poop.railing_id == railing.id then
            count = count + 1
        end
    end
    return count
end

function getRandomPosInRailing(railing)
    -- získá náhodnou pozici vypočítanou z pozice ralingu v coords a velikosti railingu v size. Nová pozice je jen na x a y z je stejná jako railingu
    -- debugPrint("Získávání náhodné pozice v ohradě " .. railing.id .. " s velikostí " .. railing.size)
    local nx = railing.coords.x + math.random(math.floor(-railing.size / 2), math.floor(railing.size / 2))
    local ny = railing.coords.y + math.random(math.floor(-railing.size / 2), math.floor(railing.size / 2))
    local nz = railing.coords.z

    return {
        x = nx,
        y = ny,
        z = nz
    }
end

function getAnimalsInRailing(railing_id)
    -- debugPrint("Získávání zvířat v ohradě " .. railing_id)
    local result = {}
    for _, animal in pairs(animals) do
        if animal.railing_id == railing_id then
            table.insert(result, animal)
        end
    end
    return result
end
-- Aktualizace hoven
Citizen.CreateThread(function()
    while true do
        local pause = Config.PoopTime -- Pauza mezi sraním
        for _, railing in pairs(railings) do
            local poopCount = getCountPoopInRailing(railing)
            if poopCount < Config.MaxPoop then
                local ourAnimals = getAnimalsInRailing(railing.id)
                for _, animal in pairs(ourAnimals) do
                    local animalConfig = Config.Animals[animal.breed]
                    -- pokud zvíře není nemocné ,má dostatek energie >50 a má více než 10% jídla ze svého maximálního množství a vody udělá hovno 
                    if animal.sick == 0 and animal.food > animalConfig.foodMax * 0.1 and animal.water >
                        animalConfig.waterMax * 0.1 then
                        -- pokud se povedlo udělat hovno (poopChance = 0.8, 80% šance) zadej ho do datzabaze
                        if math.random() < animalConfig.poopChance then
                            local poop = {
                                railing_id = railing.id,
                                coords = getRandomPosInRailing(railing),
                                prop = animalConfig.poop
                            }
                            MySQL:execute(
                                "INSERT INTO aprts_ranch_poop (railing_id, prop, coords) VALUES (?, ?, ?) RETURNING id",
                                {poop.railing_id, poop.prop, json.encode(poop.coords)}, function(result)
                                    poop.id = result[1].id
                                    poops[poop.id] = poop
                                    TriggerClientEvent('aprts_ranch:Client:getPoop', -1, poop)
                                    -- debugPrint("Nové hovno s ID " .. poop.id)
                                end)
                            -- debugPrint("Ranch", "Sraní se nepovedlo")
                        end
                    else
                        -- debugPrint("Ranch", "Zvířata ještě srát nechtěhjí")
                    end
                end
            else
                -- debugPrint("Ranch", "Ohrada " .. railing.id .. " je plná hoven.")
            end
        end
        Citizen.Wait(pause)
    end
end)

-- Aktualizace statistik zvířat
Citizen.CreateThread(function()
    while true do
        local pause = 60000 -- Pauza mezi aktualizacemi (1 minuta)
        local time = getTimeStamp() -- Aktuální timestamp (ms)
        -- zvířata mají sloupec updated ve kterém je kdy byla naposledy updatována, pokud je rozdíl těch dvou času větší než Config.UpdateRate, updatuj zvíře a jeho updateTime
        for railing_id, railing in pairs(railings) do
            -- Získej zvířata v ohradě
            local animalsInRailing = getAnimalsInRailing(railing_id)

            for _, animal in pairs(animalsInRailing) do
                -- debugPrint("Aktualizace statistik zvířete " .. animal.id .. " naposledy updatováno v " .. animal.updated)
                local diference = time - animal.updated
                -- debugPrint("Do update zvířete " .. animal.id .. " zbývá " .. Config.UpdateRate - diference .. "s")
                if diference >= Config.UpdateRate then
                    debugPrint("Aktualizace statistik zvířete " .. animal.id)
                    updateAnimalStats(animal)
                    checkForBreeding(railing_id, animalsInRailing)
                end
            end

        end

        Citizen.Wait(pause) -- Čekej před dalším cyklem
    end
end)

function getAnimalsInRailing(railing_id)
    local result = {}
    for _, animal in pairs(animals) do
        if animal.railing_id == railing_id then
            table.insert(result, animal)
        end
    end
    return result
end

function makeProduct(animal, time)

    local animalConfig = Config.Animals[animal.breed]
    if animal.age < animalConfig.adultAge then
        debugPrint("Zvíře " .. animal.id .. " je příliš mladé na produkci.")
        return
    end
    local railing = railings[animal.railing_id]
    for _, product in pairs(animalConfig.product) do
        local chance = math.random(0, 100)
        if not product.chance then
            product.chance = 50
        end
        local bonus = 0
        if animal.xp > Config.Level5 then
            bonus = 30
        elseif animal.xp > Config.Level4 then
            bonus = 20
        elseif animal.xp > Config.Level3 then
            bonus = 10
        elseif animal.xp > Config.Level2 then
            bonus = 5
        elseif animal.xp > Config.Level1 then
            bonus = 3
        end

        product.chance = product.chance + bonus
        if product.gather == 3 and chance < product.chance then
            if product.gender == animal.gender or product.gender == nil then
                -- debugPrint("Zvíře " .. animal.id .. " produkuje " .. product.name)

                if railing.products[product.item] then
                    railing.products[product.item].amount = railing.products[product.item].amount + product.amount
                    railing.products[product.item].amount = math.min(railing.products[product.item].amount, Config.MaxProduct * getCountAnimlsonRailing(railing))
                    railing.products[product.item].time = time
                else
                    railing.products[product.item] = {
                        name = product.name,
                        amount = product.amount,
                        time = time,
                        coords = getRandomPosInRailing(railing),
                        item = product.item,
                        prop = product.prop

                    }
                end
                saveRailingData(railing)
                TriggerClientEvent('aprts_ranch:Client:updateRailing', -1, railing)
            end
        elseif product.gather == 2 then
            if product.gender == animal.gender or product.gender == nil then

                animal.count = animal.count + product.amount
                if product.maxAmount then
                    animal.count = math.min(animal.count, product.maxAmount)
                end
            end
        end
    end
end

function updateAnimalStats(animal)
    if animal.health <= 0 then
        handleAnimalDeath(animal)
        return
    end
    if animal.home == 0 then
        -- debugPrint("zvíře " .. animal.id .. " není na farmě")
        return
    end

    -- debugPrint("Aktualizace statistik zvířete " .. animal.id)
    local animalConfig = Config.Animals[animal.breed]
    local time = getTimeStamp()
    if animalConfig then
        animal.age = math.floor((time - animal.born) / (60 * 60 * 24))
        debugPrint("Nový věk zvířete " .. animal.id .. " je " .. animal.age)
        animal.lastPregDiff = (time - animal.pregnantStart) / (60 * 60 * 24)
        debugPrint("Zvíře " .. animal.id .. " bylo těhotné před " .. animal.lastPregDiff .. "dny")
        -- smrt zvířete kvůli stáří¨
        -- debugPrint("Zvířeti je " .. animal.age .. " a maximální věk je " .. animalConfig.dieAge)
        if animal.age >= animalConfig.dieAge then
            DiscordWeb("Ranch", "Zvíře " .. animal.id .. " zemřelo věkem v " .. animal.age, "Ranch")
            handleAnimalDeath(animal)

            animal.health = 0
            -- Ulož zvíře do databáze
            saveAnimalData(animal)

            -- Aktualizuj zvíře na klientovi
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            return
        end

        makeProduct(animal, time)
        -- Získej ohradu, ve které je zvíře
        local railing = railings[animal.railing_id]

        if railing then
            -- Kontrola jídla
            if railing.food >= animalConfig.food then -- Pokud je v railingu víc jídla než zvíře sežere během krmení
                railing.food = railing.food - animalConfig.food -- Odeber jídlo z ohrady
                -- animal.food = math.min(animalConfig.foodMax, animal.food + animalConfig.food) -- Přidej jídlo zvířeti ale zastropuj na maximální hodnotu, takže to vypadá jako by se zvíře najedlo
            else -- Pokud je v railingu méně jídla než zvíře sežere během krmení
                animal.food = animal.food - animalConfig.food -- Odeber jídlo zvířeti
            end
            -- Shrnutí - pokud je v railingu dostatek jídla, zvíře se nají a ohrada ztratí jídlo, pokud není dostatek jídla, zvíře ztratí jídlo a ohrada zůstane stejná
            -- Kontrola vody
            if railing.water >= animalConfig.water then
                railing.water = railing.water - animalConfig.water
                -- animal.water = math.min(animalConfig.waterMax, animal.water + animalConfig.water)
            else
                animal.water = animal.water - animalConfig.water
            end

            -- Ulož ohradu
            saveRailingData(railing)
            TriggerClientEvent('aprts_ranch:Client:updateRailing', -1, railing)
        else
            -- Pokud není ohrada nalezena, sniž jídlo a vodu zvířete
            animal.food = animal.food - animalConfig.food
            animal.water = animal.water - animalConfig.water
        end

        -- Zajisti, že statistiky jsou v rozmezí 0-100
        animal.food = math.max(0, math.min(animalConfig.foodMax, animal.food))
        animal.water = math.max(0, math.min(animalConfig.waterMax, animal.water))

        -- Sniž zdraví, pokud je zvíře hladové nebo dehydrované
        if animal.food <= 0 or animal.water <= 0 then
            animal.health = animal.health - 5
        else
            if animal.health < 100 and animal.sick == 0 and animal.health >= 1 then
                animal.health = animal.health + 1
            end
        end

        -- Aktualizuj čistotu
        animal.clean = animal.clean - 1
        animal.clean = math.max(0, math.min(100, animal.clean))
        -- Pokud čistota je nízká, zvyšuje se pravděpodobnost onemocnění
        if animal.clean < 20  and animal.sick == 0 then
            local sicknessChance = (20 - animal.clean) * Config.SicknessChanceMultiplier -- Čím nižší čistota, tím větší šance
            if math.random() < sicknessChance then
                animal.sick = 1
                -- debugPrint("Zvíře " .. animal.id .. " onemocnělo kvůli nízké čistotě.")
                DiscordWeb("Ranch", "Zvíře " .. animal.id .. " onemocnělo kvůli nízké čistotě.", "Ranch")
            end
        end

        if animal.sick > 0 then
            animal.sick = animal.sick + 1
        end

        -- Pokud je zvíře nemocné, snižuje se zdraví
        if animal.sick > 0 and animal.sick < 10 + (animal.happynes/10) then
            animal.health = animal.health - 2
            -- Šance na uzdravení
            local recoveryChance = Config.RecoveryChance -- 1% šance na uzdravení
            if math.random() < recoveryChance then
                animal.sick = 0
                -- debugPrint("Zvíře " .. animal.id .. " se uzdravilo.")
                DiscordWeb("Ranch", "Zvíře " .. animal.id .. " se samo uzdravilo.", "Ranch")
            end
        end

        if animal.sick >= 40 then
            animal.health = animal.health - 5
            -- Šance na uzdravení
            local animalsInsRailing =  getAnimalsInRailing(animal.railing_id)
            -- nakazí zvířata ve své ohrádce
            for _, animalInRailing in pairs(animalsInsRailing) do
                if animalInRailing.sick == 0 then
                    local infectionChance = Config.InfectionChance
                    if math.random() < infectionChance then
                        animalInRailing.sick =  1
                        -- debugPrint("Zvíře " .. animalInRailing.id .. " onemocnělo kvůli nízké čistotě.")
                        DiscordWeb("Ranch", "Zvíře " .. animalInRailing.id .. " se nakazilo od jiného zvířete!", "Ranch")
                        MySQL:execute("UPDATE aprts_ranch_animals SET sick = ? WHERE id = ?", {1, animalInRailing.id})
                        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animalInRailing.id)
                    end
                end
            end
        end


        -- Aktualizuj štěstí zvířete na základě různých faktorů
        local happinessFactors = 0
        if animal.food > animalConfig.foodMax/2 then
            happinessFactors = happinessFactors + 1
        end
        if animal.water > animalConfig.waterMax/2 then
            happinessFactors = happinessFactors + 1
        end
        if animal.clean > 50 then
            happinessFactors = happinessFactors + 1
        end
        if animal.sick == 0 then
            happinessFactors = happinessFactors + 1
        end

        animal.happynes = math.max(0, math.min(100, (happinessFactors / 4) * 100))

        -- Aktualizuj energii zvířete
        animal.energy = animal.energy + 20
        if animal.energy < 20 then
            -- Zvíře je unavené, může produkovat méně produktů
            -- Zde můžete přidat logiku pro snížení produkce
        end
        animal.energy = math.max(0, math.min(100, animal.energy))

        -- Zajisti, že zdraví je v rozmezí 0-100
        animal.health = math.max(0, math.min(100, animal.health))

        if animal.health <= 0 then
            DiscordWeb("Ranch", "Zvíře " .. animal.id .. " zemřelo kvůli špatnému zdraví.", "Ranch")
            handleAnimalDeath(animal)
            saveAnimalData(animal)
            return
        else
            -- Kontrola těhotenství a porodu
            if animal.pregnant > 0 then
                -- debugPrint("Zvíře " .. animal.id .. " je těhotné.")
                local pregnancyDuration = Config.Animals[animal.breed].pregnancyTime * 86400 -- dny na s
                debugPrint(time)
                debugPrint(animal.pregnantStart)
                debugPrint(pregnancyDuration)
                local differece = time - animal.pregnantStart
                -- debugPrint('Pregnancy duration: ' .. differece)
                if differece >= pregnancyDuration then
                    -- debugPrint("Zvíře " .. animal.id .. " porodilo.")
                    handleAnimalBirth(animal)
                    animal.pregnant = 0
                end
            end

            -- Ulož zvíře do databáze
            saveAnimalData(animal)

            -- Aktualizuj zvíře na klientovi
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        end
    else
        -- debugPrint("Neznámé plemeno zvířete: " .. animal.breed)
    end
end

-- female.pregnantStart = exports["aprts_hunting"]:getTimeStamp() / 1000
-- -- Ulož těhotenství zvířete do databáze
-- female.pregnant = 1
-- MySQL:execute("UPDATE aprts_ranch_animals SET  pregnant = ?, pregnantStart = FROM_UNIXTIME(?) WHERE id = ?",
--     {female.pregnant, female.pregnantStart, female.id})

function saveAnimalData(animal)
    animal.updated = getTimeStamp()
    -- debugPrint("Ukládání dat zvířete " .. animal.id .. " v " .. animal.updated)
    MySQL:execute(
        "UPDATE aprts_ranch_animals SET food = ?, water = ?, health = ?, clean = ?, age = ?, sick = ?, happynes = ?, energy = ?,pregnant = ?,count= ?, updated = FROM_UNIXTIME(?) WHERE id = ?",
        {animal.food, animal.water, animal.health, animal.clean, animal.age, animal.sick, animal.happynes,
         animal.energy, animal.pregnant, animal.count, animal.updated, animal.id})
end

function saveRailingData(railing)
    -- debugPrint("Ukládání dat ohrady " .. railing.id)
    MySQL:execute("UPDATE aprts_ranch_railing SET food = ?, water = ?, shit = ? , products = ? WHERE id = ?",
        {railing.food, railing.water, railing.shit, json.encode(railing.products), railing.id})
end

function handleAnimalDeath(animal)

    -- animals[animal.id] = nil
    -- MySQL:execute("DELETE FROM aprts_ranch_animals WHERE id = ?", {animal.id})
    -- TriggerClientEvent('aprts_ranch:Client:removeAnimal', -1, animal.id)
    TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
    -- debugPrint("Zvíře " .. animal.id .. " zemřelo.")

end

function checkForBreeding(railing_id, animalsInRailing)
    local breeds = {}

    for _, animal in pairs(animalsInRailing) do

        if animal.age >= Config.Animals[animal.breed].adultAge then
            -- Vytvoří tabulku druhů u krmítka
            if not breeds[animal.breed] then
                breeds[animal.breed] = {
                    male = false,
                    female = false
                }
            end

            if animal.gender == 'male' then
                breeds[animal.breed].male = true
            elseif animal.gender == 'female' and animal.pregnant == 0 then
                breeds[animal.breed].female = true
            end
        end
    end
    debugPrint(json.encode(breeds))

    for breed, genderPresent in pairs(breeds) do
        if genderPresent.male and genderPresent.female then
            debugPrint("Zvířata vhodná pro množení  " .. breed .. " nalezena v ohradě " .. railing_id)
            attemptBreeding(breed, railing_id, animalsInRailing)
        end
    end
end

function attemptBreeding(breed, railing_id, animalsInRailing)
    local females = {}
    for _, animal in pairs(animalsInRailing) do
        if animal.breed == breed then
            if animal.gender == 'female' then
                if animal.pregnant == 0 then
                    if animal.age >= Config.Animals[breed].adultAge then
                        if animal.lastPregDiff > Config.Animals[breed].noFuckTime then
                            table.insert(females, animal)
                            debugPrint("Samoce zvířete " .. animal.id .. " přidána do seznamu zvířat v říji.")
                        else
                            debugPrint("Samice rodila před nedávnou dobou")
                        end
                        debugPrint("Samice je moc mladá")
                    end
                else
                    debugPrint("Samice už je těhotná")
                end
            else
                debugPrint("Zvíře je samec")
            end
        else
            debugPrint("Zvíře je špatného druhu")
        end
    end

    for _, female in pairs(females) do
        local chance = Config.Animals[breed].pregnancyChance -- 10% šance na těhotenství
        local random = math.random(0, 100)
        debugPrint("Šance byla" .. chance .. " a náhodné číslo bylo " .. random)
        if random < chance then

            -- AddEventHandler("westhaven_log:Server:Log", function(type, message)
            -- TriggerEvent("westhaven_log:Server:ServerLog", "Ranch", "Zvíře " .. female.id .." je nyní těhotné.")
            DiscordWeb("Ranch", "Zvíře " .. female.id .. " je nyní těhotné.", "Ranch")
            female.pregnantStart = getTimeStamp()
            -- Ulož těhotenství zvířete do databáze
            female.pregnant = 1
            MySQL:execute("UPDATE aprts_ranch_animals SET  pregnant = ?, pregnantStart = FROM_UNIXTIME(?) WHERE id = ?",
                {female.pregnant, female.pregnantStart, female.id})

            -- saveAnimalData(female)
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, female)
            notify("Zvíře " .. female.id .. " je nyní těhotné.")
        end
    end
end

function handleAnimalBirth(mother)
    -- debugPrint("Zvíře " .. mother.id .. " porodilo nové zvíře.")
    local newAnimal = {}
    local animalConfig = Config.Animals[mother.breed]
    newAnimal.updated = getTimeStamp()
    TriggerEvent("aprts_ranch:Server:addAnimal", mother.railing_id, mother.breed,
        math.random() < 0.5 and 'male' or 'female', mother.meta)
    DiscordWeb("Ranch", "Zvíře " .. mother.id .. " porodilo nové zvíře u krmítka " .. mother.railing_id, "Ranch")
    mother.pregnant = 0
    saveAnimalData(mother)
    TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, mother)
end

-- Event pro sběr produktů ze zvířat
RegisterServerEvent("aprts_ranch:Server:collectProduct")
AddEventHandler("aprts_ranch:Server:collectProduct", function(animalID, productIndex)
    local _source = source
    local animal = animals[animalID]
    if animal then
        local breedConfig = Config.Animals[animal.breed]
        if breedConfig then
            local product = breedConfig.product[productIndex]
            if product then
                local User = Core.getUser(_source)
                local Character = User.getUsedCharacter
                if product.tool ~= "" then
                    exports.vorp_inventory:getItemCount(_source, function(count)
                        if count > 0 then
                            proceedWithProductCollection(_source, animal, product)
                        else
                            notify(_source, "Potřebuješ " .. product.tool .. " k získání " .. product.name)
                        end
                    end, product.tool)
                else
                    proceedWithProductCollection(_source, animal, product)
                end
            else
                notify(_source, "Produkt nenalezen")
            end
        else
            notify(_source, "Neznámé zvíře")
        end
    else
        notify(_source, "Zvíře nenalezeno")
    end
end)

function proceedWithProductCollection(_source, animal, product)
    if product.gather == 1 then
        -- Zabij zvíře a dej produkt
        local amount = product.amount
        exports.vorp_inventory:addItem(_source, product.item, amount)
        DiscordWeb("Ranch", "Zvíře " .. animal.id .. " bylo zabito a získáno " .. amount .. "x " .. product.name,
            "Ranch")
        handleAnimalDeath(animal)
        notify(_source, "Získal jsi " .. amount .. "x " .. product.name)
    elseif product.gather == 2 then
        -- Sběr produktu bez zabití
        local amount = product.add
        exports.vorp_inventory:addItem(_source, product.item, amount)
        notify(_source, "Získal jsi " .. amount .. "x " .. product.name)
    end
end

function DiscordWeb(name, message, footer)
    local embed = {{
        ["color"] = Config.DiscordColor,
        ["title"] = "",
        ["description"] = "**" .. name .. "** \n" .. message .. "\n\n",
        ["footer"] = {
            ["text"] = footer
        }
    }}
    PerformHttpRequest(Config.WebHook, function(err, text, headers)
    end, 'POST', json.encode({
        username = Config.ServerName,
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end
