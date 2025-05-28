MySQL = exports.oxmysql

ranches = {}
railings = {}
animals = {}
lostAnimals = {}
poops = {}
local Loaded = false
AddEventHandler("onResourceStart", function(resource)

    if resource == GetCurrentResourceName() then
        local dataReady = false
        print("[aprts_ranch] Starting ranch. Version:" .. Config.Ver)
        local time = getTimeStamp()

        -- load data from aprts_ranch_config_animals 
        MySQL:execute("SELECT * FROM aprts_ranch_config_animals", {}, function(result)
            for k, v in pairs(result) do
                Config.Animals[v.name] = v
                Config.Animals[v.name].product = {}
                -- load products for this animal
                local loaded = false
                MySQL:execute("SELECT * FROM aprts_ranch_config_animal_products WHERE animal_id = ?", {v.animal_id},
                    function(result2)
                        -- print("Loading products for " .. v.name)

                        for k2, v2 in pairs(result2) do
                            v2.anim = json.decode(v2.anim)
                            table.insert(Config.Animals[v.name].product, v2)
                            -- print(json.encode(v2))
                            -- Config.Animals[v.name].products[v2.name] = v2
                        end
                        loaded = true
                    end)
                while loaded == false do
                    Wait(100)
                end
                debugPrint(json.encode(Config.Animals[v.name]))

            end
            dataReady = true
        end)
        while dataReady == false do
            Wait(100)
        end
        dataReady = false
        MySQL:execute("SELECT * FROM aprts_ranch", {}, function(result)
            for k, v in pairs(result) do
                v.coords = json.decode(v.coords)
                ranches[v.id] = v
            end
            dataReady = true
        end)

        while dataReady == false do
            Wait(100)
        end
        dataReady = false
        MySQL:execute("SELECT * FROM aprts_ranch_railing", {}, function(result)
            for k, v in pairs(result) do
                v.coords = json.decode(v.coords)
                v.products = json.decode(v.products)
                debugPrint(json.encode(v.products))
                railings[v.id] = v
            end
            dataReady = true
        end)

        while dataReady == false do
            Wait(100)
        end
        dataReady = false

        MySQL:execute(
            "SELECT *, UNIX_TIMESTAMP(updated) AS updated, UNIX_TIMESTAMP(born) AS born, UNIX_TIMESTAMP(pregnantStart) AS pregnantStart, TIMESTAMPDIFF(DAY, born, NOW()) AS ageNow,TIMESTAMPDIFF(DAY, pregnantStart, NOW()) AS lastPregDiff FROM aprts_ranch_animals",
            {}, function(result)
                for k, v in pairs(result) do

                    v.coords = json.decode(v.coords)
                    v.meta = json.decode(v.meta)
                    v.updated = v.updated
                    v.age = v.ageNow
                    v.injections = 0
                    debugPrint("Zvířeti " .. v.id .. " je " .. v.ageNow .. " dní")
                    debugPrint("Zvíře rodilo naposledy před : " .. v.lastPregDiff .. " dny")
                    -- debugPrint("Animal: " .. v.id .. " " .. v.updated)
                    animals[v.id] = v
                    if v.home == 0 then
                        lostAnimals[v.id] = v
                    end
                end
                dataReady = true
            end)
        while dataReady == false do
            Wait(100)
        end
        dataReady = false

        -- load shits
        MySQL:execute("SELECT * FROM aprts_ranch_poop", {}, function(result)
            for k, v in pairs(result) do
                v.coords = json.decode(v.coords)
                poops[v.id] = v
            end
            dataReady = true
        end)
        while dataReady == false do
            Wait(100)
        end
        dataReady = false
        while table.count(ranches) < 1 do
            Wait(100)
        end
        debugPrint("Ranch started")
        debugPrint("Ranches: " .. table.count(ranches))
        debugPrint("Railings: " .. table.count(railings))
        debugPrint("Animals: " .. table.count(animals))
        debugPrint("Poops: " .. table.count(poops))
        Loaded = true
    end
end)

function unixToDateTime(unixTime)
    return os.date('%Y-%m-%d %H:%M:%S', unixTime)
end



RegisterServerEvent("aprts_ranch:Server:putAnimal")
AddEventHandler("aprts_ranch:Server:putAnimal", function(railingID, newanimal)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local animal = newanimal
    animals[animal.id] = animal
    local railing = railings[railingID]
    if animal then
        if railing then
            if railing.size <= getCountAnimlsonRailing(railing) then
                notify(_source, "Railing is full.")
                return
            end
            animal.railing_id = railingID
            animal.home = 1
            animal.food = math.max(0, animal.food)
            animal.water = math.max(0, animal.water)

            -- Helper function to ensure timestamp is in seconds
            local function normalize_timestamp_to_seconds(value)
                if value == nil or value == 0 then
                    return getTimeStamp() -- Returns seconds
                end

                local num_value
                if type(value) == "string" then
                    num_value = tonumber(value)
                    if not num_value then
                        -- Invalid string, default to current time in seconds
                        return getTimeStamp()
                    end
                elseif type(value) == "number" then
                    num_value = value
                else
                    -- Unknown type, default to current time in seconds
                    return getTimeStamp()
                end

                -- If the numeric value is very large (e.g., typical millisecond range like 12-13 digits or more)
                -- Unix timestamps in seconds are usually 10 digits.
                -- 100,000,000,000 (10^11) is a threshold; values larger are likely milliseconds.
                if num_value >= 100000000000 then -- If it has at least 12 digits, it's likely ms
                    return math.floor(num_value / 1000)
                else
                    -- Assume it's already in seconds
                    return math.floor(num_value)
                end
            end

            animal.born = normalize_timestamp_to_seconds(animal.born)
            animal.pregnantStart = normalize_timestamp_to_seconds(animal.pregnantStart)
            local current_time_seconds_for_updated = getTimeStamp() -- for 'updated' field

            MySQL:execute(
                "UPDATE aprts_ranch_animals SET railing_id = ?, home = ?, coords = ?, health = ?, food = ?, water = ?, clean = ?, sick = ?, happynes = ?, energy = ?, age = ?, quality = ?, count = ?, born = FROM_UNIXTIME(?), pregnantStart =FROM_UNIXTIME(?), updated = FROM_UNIXTIME(?),xp= ?, meta = ? WHERE id = ?",
                {railingID, 1, json.encode(railing.coords), animal.health, animal.food, animal.water, animal.clean,
                 animal.sick, animal.happynes, animal.energy, animal.age, animal.quality, animal.count,
                 animal.born,             -- Should now be in seconds
                 animal.pregnantStart,    -- Should now be in seconds
                 current_time_seconds_for_updated, -- Already in seconds
                 animal.xp, json.encode(animal.meta), animal.id}, function(result)
                    if result == 0 then
                        print("[ERROR] aprts_ranch:Server:putAnimal - Failed to update animal ID: " .. animal.id)
                    end
                end)

            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            TriggerClientEvent('aprts_ranch:Client:putAnimal', _source, animal.id)
            notify(_source, "Animal added to the railing!")
            lib.logger(_source, 'RanchPutAnimal',
                "Hráč " .. playerName .. " umístil zvíře " .. animal.breed .. " na railing " .. railingID,
                "AnimalID:" .. animal.id, "Zvíře:" .. animal.breed, "RailingID:" .. railingID)
        else
            notify(_source, "Railing not found.")
        end
    else
        notify(_source, "Animal not found.")
    end
end)


RegisterServerEvent("aprts_ranch:Server:addAnimal")
AddEventHandler("aprts_ranch:Server:addAnimal", function(railingID, animalBreed, gender, meta)
    debugPrint("Adding animal to railing: " .. railingID, animalBreed, gender, json.encode(meta))
    local _source = source
    local time = getTimeStamp()

    local newMeta = json.encode(meta)

    local railing = railings[railingID]
    local animalConfig = Config.Animals[animalBreed]

    if railing then
        if railing.size <= getCountAnimlsonRailing(railing) then
            notify(_source, "Railing is full.")
            return
        end
        if animalConfig then
            local coords = railing.coords -- Assuming you want the animal to be placed at the railing's coords
            MySQL:execute(
                "INSERT INTO aprts_ranch_animals (home,railing_id, breed, gender, coords, health, food, water, clean, sick, happynes, energy, age, quality, count,born,pregnantStart,updated,meta) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,FROM_UNIXTIME(?),FROM_UNIXTIME(?),FROM_UNIXTIME(?),?) RETURNING id",
                {1, railingID, animalBreed, gender, json.encode(coords), 100, animalConfig.foodMax,
                 animalConfig.waterMax, 100, 0, 100, 100, 0, 0, 0, time, time, time, newMeta}, function(result)
                    local id = result[1].id
                    MySQL:execute("SELECT * FROM aprts_ranch_animals WHERE id = ?", {id}, function(result2)
                        local animal = result2[1]
                        animal.coords = json.decode(animal.coords)
                        animals[id] = animal
                        animals[id].meta = json.decode(animal.meta)
                        TriggerClientEvent("aprts_ranch:Client:getAnimal", -1, animals[id])
                        notify(_source, "Animal added to the railing!")
                    end)
                end)
        else
            notify(_source, "Animal not found.")
        end
    else
        notify(_source, "Railing not found.")
    end
end)
RegisterServerEvent("aprts_ranch:Server:deleteAnimal")
AddEventHandler("aprts_ranch:Server:deleteAnimal", function(animalID)
    local _source = source
    local animal = animals[animalID]
    if animal then
        MySQL:execute("DELETE FROM aprts_ranch_animals WHERE id = ?", {animalID})
        animals[animalID] = nil
        TriggerClientEvent('aprts_ranch:Client:removeAnimal', -1, animalID)
        -- notify(_source, "Animal deleted.")
        DiscordWeb("Ranch", "Zvíře " .. animal.breed .. " bylo odstraněno")
    else
        -- notify(_source, "Animal not found.")
    end
end)
RegisterServerEvent("aprts_ranch:Server:logKillAnimal")
AddEventHandler("aprts_ranch:Server:logKillAnimal", function(animalID, weapon, coords)
    local _source = source
    print("Killing animal with ID " .. animalID)
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local animal = animals[animalID]

    DiscordWeb("Ranch",
        "Zvíře " .. animalID .. " druhu:" .. animal.breed .. " bylo zabitou zbraní: " .. weapon ..
            " na souřadnicích " .. coords)
    lib.logger(_source, 'MurderANimal',
        "Hráč " .. playerName .. " zabil zvíře " .. animal.breed .. " zbraní: " .. weapon .. " na souřadnicích " ..
            coords, "AnimalID:" .. animalID, "Zvíře:" .. animal.breed, "Zbraň:" .. weapon, "Coords:" .. coords,
        "railing_id:" .. animal.railing_id)

end)

RegisterServerEvent("aprts_ranch:Server:getData")
AddEventHandler("aprts_ranch:Server:getData", function()
    local _source = source
    while Loaded == false do
        Wait(100)
    end

    print("Push Data to client " .. _source)

    TriggerClientEvent("aprts_ranch:Client:getData", _source, ranches, railings, animals, poops, Config.Animals,lostAnimals)
end)

RegisterServerEvent("aprts_ranch:Server:createRanch")
AddEventHandler("aprts_ranch:Server:createRanch", function(name, landID, coords)
    local _source = source
    local User = Core.getUser(_source)
    local Character = User.getUsedCharacter
    local charid = Character.charIdentifier

    MySQL:execute("INSERT INTO aprts_ranch (name, owner, money, land_id, coords) VALUES (?, ?, ?, ?, ?) RETURNING id",
        {name, charid, 0, landID, json.encode(coords)}, function(result)
            local id = result[1].id
            ranches[id] = {
                id = id,
                land_id = landID,
                name = name,
                owner = charid,
                money = 0,
                storage_id = id,
                storage_limit = 200,
                coords = coords
            }
            -- update storage_id to ranch_id
            MySQL:execute("UPDATE aprts_ranch SET storage_id = ? WHERE id = ?", {id, id})
            debugPrint("Ranch " .. name .. " created with " .. id .. ", at land " .. landID)

            TriggerClientEvent("aprts_ranch:Client:getRanch", -1, ranches[id])

            notify(_source, "Ranč " .. name .. " vytvořen")
        end)
end)

RegisterServerEvent("aprts_ranch:Server:addMoney")
AddEventHandler("aprts_ranch:Server:addMoney", function(ranchID, amount)

    local ranch = ranches[tonumber(ranchID)]
    if ranch then
        ranch.money = ranch.money + amount
        MySQL:execute("UPDATE aprts_ranch SET money = ? WHERE id = ?", {ranch.money, ranchID})
    end

end)

RegisterServerEvent("aprts_ranch:Server:takeAnimal")
AddEventHandler("aprts_ranch:Server:takeAnimal", function(animalID, happy, coords)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local animal = animals[animalID]
    local lostAnimal = lostAnimals[animalID]
    if lostAnimal then
        lostAnimals[animalID] = nil
        TriggerClientEvent('aprts_ranch:Client:removeLostAnimal', -1, animalID)
    end
    if animal then
        animal.oldRailing = animal.railing_id
        animal.railing_id = 0
        if happy then
            animal.happynes = 100
            animal.energy = 100
            animal.food = 200
            animal.water = 200
            animal.clean = 100
            animal.sick = 0
        end
        lib.logger(_source, 'RanchTakeAnimal',
            "Hráč " .. playerName .. " vzal zvíře " .. animal.breed .. " z railingu " .. animal.oldRailing,
            "AnimalID:" .. animalID, "Zvíře:" .. animal.breed, "RailingID:" .. animal.oldRailing)

        debugPrint("Taking animal " .. animalID .. " from railing " .. animal.oldRailing)
        animal.home = 0
        MySQL:execute("UPDATE aprts_ranch_animals SET railing_id = ?, home = ? WHERE id = ?", {0, 0, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        TriggerClientEvent('aprts_ranch:Client:walkAnimal', _source, animal, coords)
        notify(_source, "Vzal jsi zvíře na procházku.")
        debugPrint(json.encode(animal))
    else
        notify(_source, "Chyba, zváře nenalezeno")
    end
end)

RegisterServerEvent("aprts_ranch:Server:takeAnimals")
AddEventHandler("aprts_ranch:Server:takeAnimals", function(railingID)
    --- vzít zvířata na procházku, nebo je odvést, u zvířat které jsou na procházce se zvýší štěstí a XP. zvíře na procházce má nastavený home na 0
    local _source = source
    local railing = railings[tonumber(railingID)]
    if railing then
        for k, v in pairs(animals) do
            local count = getCountAnimlsonRailing(railing)
            if count > 0 then
                if v.railing_id == railingID then
                    v.oldRailing = railingID
                    v.railing_id = 0
                    -- nstavení home na 0
                    v.home = 0
                    MySQL:execute("UPDATE aprts_ranch_animals SET railing_id = ?, home = ? WHERE id = ?", {0, 0, v.id})
                    TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, v)
                    TriggerClientEvent('aprts_ranch:Client:walkAnimal', _source, v)
                    notify(_source, "Vzal jsi zvíře na procházku")
                    debugPrint(json.encode(v))
                    break
                end
            else
                notify(_source, "U krmítka není žádné zvíře")
            end

        end

    else
        notify(_source, "Railing not found")
    end
end)

RegisterServerEvent("aprts_ranch:Server:pickupProduct")
AddEventHandler("aprts_ranch:Server:pickupProduct", function(railingID, product_name)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local railing = railings[tonumber(railingID)]
    if railing then
        for _, product in pairs(railing.products) do
            if product.name == product_name then
                if product.amount > 0 then
                    product.amount = product.amount - 1
                    exports.vorp_inventory:addItem(_source, product.item, 1)

                    MySQL:execute("UPDATE aprts_ranch_railing SET products = ? WHERE id = ?",
                        {json.encode(railing.products), railingID})
                    TriggerClientEvent('aprts_ranch:Client:updateRailing', -1, railing)

                    notify(_source, "Sebral jsi " .. product_name)
                    lib.logger(_source, 'RanchPickupProduct', "Hráč " .. playerName .. " sebral produkt " ..
                        product_name .. " z krmítka " .. railingID, "Product:" .. product_name,
                        "RailingID:" .. railingID)
                else

                    notify(_source, "Produkt nenalezen")
                end
            end
        end
    else
        notify(_source, "Railing not found")
    end
end)

RegisterServerEvent("aprts_ranch:Server:gatherAnimalProduct")
AddEventHandler("aprts_ranch:Server:gatherAnimalProduct", function(animalID, product)
    local _source = source
    local animal = animals[tonumber(animalID)]
    local animalConfig = Config.Animals[animal.breed]
    if animal then
        -- odečíst 1 ks produktu ze zvířete 
        if animal.count > 0 then
            local level = 0
            local count = product.amount
            -- uprav počet získaných prduktů ze zvířete podle xp zvířete v porovnání s Config.Level1 - 5, při dosažení úrovně 1 je produkt zdvojnásobený atd..
            if animal.xp >= Config.Level1 then
                count = product.amount * 1.5
                count = math.floor(count)
                level = 1
            end
            if animal.xp >= Config.Level2 then
                count = product.amount * 2
                level = 2
            end
            if animal.xp >= Config.Level3 then
                count = product.amount * 2.5
                count = math.floor(count)
                level = 3
            end
            if animal.xp >= Config.Level4 then
                count = product.amount * 3
                level = 4
            end
            if animal.xp >= Config.Level5 then
                count = product.amount * 4
                level = 5
            end
            local reward = animal.count + count
            animal.count = 0
            MySQL:execute("UPDATE aprts_ranch_animals SET count = ? WHERE id = ?", {animal.count, animalID})
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            TriggerClientEvent("aprts_ranch:Client:playAnim", _source, product.anim)
            Wait(product.anim.time)

            exports.vorp_inventory:addItem(_source, product.item, reward)
            notify(_source, "Sebral jsi produkt " .. reward .. "x " .. product.item)
            lib.logger(_source, "RanchGatherAnimal",
                "Hráč " .. Player(_source).state.Character.FirstName .. " " .. Player(_source).state.Character.LastName ..
                    " sebral produkt " .. product.item .. " ze zvířete " .. animal.breed, "AnimalID:" .. animalID,"AnimalXP:" .. animal.xp,"AnimalLevel:" .. level,
                "Product:" .. product.item, "Count:" .. reward,"RailingID:" .. animal.railing_id)
        else
            notify(_source, "Produkt nenalezen")
        end
    else
        notify(_source, "Zvíře nenalezeno")
    end
end)

RegisterServerEvent("aprts_ranch:Server:placeRailing")
AddEventHandler("aprts_ranch:Server:placeRailing", function(ranchID, coords, prop)
    debugPrint("Placing Railing on ranch" .. ranchID)
    local _source = source
    local ranch = ranches[tonumber(ranchID)]

    local feeding = Config.feeding[prop]
    if ranch then
        if feeding then
            MySQL:execute("INSERT INTO aprts_ranch_railing (ranch_id, coords,prop,size) VALUES (?, ?,?,?) RETURNING id",
                {ranchID, json.encode(coords), feeding.prop, feeding.size}, function(result)
                    MySQL:execute("SELECT * FROM aprts_ranch_railing WHERE id = ?", {result[1].id}, function(result2)
                        railings[result[1].id] = result2[1]
                        railings[result[1].id].coords = json.decode(result2[1].coords)
                        railings[result[1].id].products = json.decode(result2[1].products)
                        notify(_source, "Railing placed")
                        TriggerClientEvent("aprts_ranch:Client:getRailing", -1, railings[result[1].id])
                    end)
                end)
        else
            notify(_source, "Railing not found")
        end
    else
        notify(_source, "Ranch not found")
    end
end)

RegisterServerEvent("aprts_ranch:Server:pickupPoop")
AddEventHandler("aprts_ranch:Server:pickupPoop", function(poopID)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname
    local poop = poops[poopID]
    if poop then

        lib.logger(_source, 'RanchPoop',
            "Hráč " .. playerName .. " sebral hovínko " .. poopID .. " u krmítka " .. poop.railing_id,
            "poopID:" .. poopID, "coords:" .. json.encode(poop.coords), "railing_id:" .. poop.railing_id)

        MySQL:execute("DELETE FROM aprts_ranch_poop WHERE id = ?", {poopID})
        poops[poopID] = nil
        TriggerClientEvent('aprts_ranch:Client:removePoop', -1, poopID)

        TriggerClientEvent("aprts_ranch:Client:playAnim", _source, Config.Animation.shovel)
        Wait(Config.Animation.shovel.time)

        exports.vorp_inventory:addItem(_source, Config.PoopItem, 1)
        notify(_source, "Poop picked up")
    else
        notify(_source, "Poop not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:healAnimal")
AddEventHandler("aprts_ranch:Server:healAnimal", function(animalID, medicine)
    local chance = medicine.chance
    local item = medicine.item
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname
    local animal = animals[animalID]
    -- kontrola jestli je zvíře nemocné
    if animal.sick < 1 then
        notify(_source, "Zvíře není nemocné")
        return
    end

    --- kontrola jestli hráč má u sebe item Config.medicineItem
    local hasItem = exports.vorp_inventory:getItemCount(_source, nil, item)

    if hasItem < 1 then
        notify(_source, "Nemáš lék")
        return
    end
    -- odeber z hráčova inventáře item Config.medicineItem
    exports.vorp_inventory:subItem(_source, item, 1)
    print("JOB:" .. Player(_source).state.Character.Job)
    if medicine.job ~= "" then
        if Player(_source).state.Character.Job ~= medicine.job then
            notify(_source, "Nemáš potřebnou kvalifikaci pro aplikaci tohoto léčiva")
            return
        end
    end

    if animal then

        animal.injections = tonumber(animal.injections) + 1
        if animal.injections > 5 then
            notify(_source, "Předávkoval jsi zvíře!")
            animal.health = 0
            MySQL:execute("UPDATE aprts_ranch_animals SET health = ? WHERE id = ?", {0, animalID})
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            lib.logger(_source, 'RanchOverdose',
                "Hráč " .. playerName .. " předávkoval zvíře " .. animalID .. " druhu " .. animal.breed ..
                    "na krmítku: " .. animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed,
                "railing_id:" .. animal.railing_id)
            return
        end
        TriggerClientEvent("aprts_ranch:Client:playAnim", _source, Config.Animation.cure)
        Wait(Config.Animation.cure.time)
        if math.random(1, 100) <= chance then
            animal.sick = math.max(0, animal.sick - medicine.cure)
            MySQL:execute("UPDATE aprts_ranch_animals SET sick = ? WHERE id = ?", {0, animalID})
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            if animal.sick == 0 then
                notify(_source, "Zvíře bylo vyléčeno")
                lib.logger(_source, 'RanchHealAnimal',
                    "Hráč " .. playerName .. " vyléčil zvíře " .. animalID .. " druhu " .. animal.breed ..
                        "na krmítku: " .. animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed,
                    "railing_id:" .. animal.railing_id)
            else
                notify(_source, "Zvíře bylo částečně vyléčeno")
                lib.logger(_source, 'RanchPartialHealAnimal',
                    "Hráč " .. playerName .. " částečně vyléčil zvíře " .. animalID .. " druhu " ..
                        animal.breed .. "na krmítku: " .. animal.railing_id, "animalID:" .. animalID,
                    "breed:" .. animal.breed, "railing_id:" .. animal.railing_id)
            end
        else
            notify(_source, "Léčba se nezdařila")
        end

    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:feedAnimal")
AddEventHandler("aprts_ranch:Server:feedAnimal", function(animalID)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname
    local animal = animals[animalID]
    if animal then
        local kibble = Config.Animals[animal.breed].kibble
        local kibbleFood = Config.Animals[animal.breed].kibbleFood
        local hasItem = exports.vorp_inventory:getItemCount(_source, nil, kibble)
        if hasItem > 0 then
            TriggerClientEvent("aprts_ranch:Client:playAnim", _source, Config.Animation.feed)
            exports.vorp_inventory:subItem(_source, kibble, 1)
            Wait(Config.Animation.feed.time)

            animal.food = math.min(Config.Animals[animal.breed].foodMax, animal.food + kibbleFood)
            MySQL:execute("UPDATE aprts_ranch_animals SET food = ? WHERE id = ?", {animal.food, animalID})
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            notify(_source, "Nakrmil jsi zvíře")
            lib.logger(_source, 'RanchFeedAnimal',
                "Hráč " .. playerName .. " nakrmil zvíře " .. animalID .. " druhu " .. animal.breed ..
                    "na krmítku: " .. animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed,
                "railing_id:" .. animal.railing_id)
        else
            notify(_source, "Nemáš správné krmení!")
        end
    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:waterAnimal")
AddEventHandler("aprts_ranch:Server:waterAnimal", function(animalID, waterAmount)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname
    local animal = animals[animalID]
    if animal then
        local hasItem = exports.vorp_inventory:getItemCount(_source, nil, Config.fullWaterItem)
        if hasItem < 1 then
            notify(_source, "Nemáš vodu kterou bys zvíže napojil")
            return
        end
        local item = exports.vorp_inventory:getItem(_source, Config.fullWaterItem)
        local meta = item["metadata"]

        if next(meta) == nil then
            local metadata = {
                description = "Zbývá " .. Config.WateringCount - 1,
                capacity = Config.WateringCount - 1
            }
            if metadata.capacity <= 0 then
                exports.vorp_inventory:subItem(_source, Config.fullWaterItem, 1, meta)
                exports.vorp_inventory:addItem(_source, Config.emptyWaterItem, 1)
                notify(_source, "Jsi vyprázdnil dosucha")
            else
                exports.vorp_inventory:setItemMetadata(_source, item.id, metadata)
            end

        else
            if meta.capacity then
                meta.capacity = meta.capacity - 1

                if meta.description then
                    meta.description = "Zbývá " .. meta.capacity
                end

                if meta.capacity <= 0 then
                    exports.vorp_inventory:subItem(_source, Config.fullWaterItem, 1, meta)
                    exports.vorp_inventory:addItem(_source, Config.emptyWaterItem, 1)
                    notify(_source, "Jsi vyprázdnil dosucha")
                else
                    exports.vorp_inventory:setItemMetadata(_source, item.id, meta)
                end
            else
                local metadata = {
                    description = "Zbývá " .. Config.WateringCount - 1,
                    capacity = Config.WateringCount - 1
                }
                if metadata.capacity <= 0 then
                    exports.vorp_inventory:subItem(_source, Config.fullWaterItem, 1, meta)
                    exports.vorp_inventory:addItem(_source, Config.emptyWaterItem, 1)
                    notify(_source, "Jsi vyprázdnil dosucha")
                else
                    exports.vorp_inventory:setItemMetadata(_source, item.id, metadata)
                end
            end
            if meta.capacity > 0 then
                notify(_source, "Zbývá " .. meta.capacity .. " vody na zalévání v kýbli")
            end
        end

        animal.water = math.min(Config.Animals[animal.breed].waterMax, animal.water + 500)
        MySQL:execute("UPDATE aprts_ranch_animals SET water = ? WHERE id = ?", {animal.water, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        notify(_source, "Napojil jsi zvíře.")
        lib.logger(_source, 'RanchWaterAnimal',
            "Hráč " .. playerName .. " napojil zvíře " .. animalID .. " druhu " .. animal.breed .. "na krmítku: " ..
                animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed, "railing_id:" .. animal.railing_id)
    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:cleanAnimal")
AddEventHandler("aprts_ranch:Server:cleanAnimal", function(animalID)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local animal = animals[animalID]
    if animal then
        animal.clean = 100
        MySQL:execute("UPDATE aprts_ranch_animals SET clean = ? WHERE id = ?", {animal.clean, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        -- play animation
        TriggerClientEvent("aprts_ranch:Client:playAnim", _source, Config.Animation.clean)
        notify(_source, "Vyčistil jsi zvíře.")
        lib.logger(_source, 'RanchCleanAnimal',
            "Hráč " .. playerName .. " vyčistil zvíře " .. animalID .. " druhu " .. animal.breed .. "na krmítku: " ..
                animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed, "railing_id:" .. animal.railing_id)
    else
        notify(_source, "Animal not found.")
    end
end)

function getRanchIdbyRailingId(railingId)
    for k, v in pairs(ranches) do
        if v.id == railingId then
            return v.id
        end
    end
    return 0
end

RegisterServerEvent("aprts_ranch:Server:killAnimal")
AddEventHandler("aprts_ranch:Server:killAnimal", function(animalID)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local animal = animals[animalID]
    if animal then
        -- print("Killing animal " .. animalID)
        local ranchid = getRanchIdbyRailingId(animal.railing_id)
        DiscordWeb("Zvíře bylo zabito", "Zvíře " .. animal.breed .. " bylo zabito")
        -- MySQL:execute("DELETE FROM aprts_ranch_animals WHERE id = ?", {animalID})
        -- animals[animalID] = nil
        -- TriggerClientEvent('aprts_ranch:Client:removeAnimal', -1, animalID)
        animals[animalID].health = 0
        MySQL:execute("UPDATE aprts_ranch_animals SET health = ? WHERE id = ?", {0, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        -- notify(_source, "You have killed the animal.")

    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:slaughterAnimal")
AddEventHandler("aprts_ranch:Server:slaughterAnimal", function(animalID)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local Tool = exports.vorp_inventory:getItem(_source, Config.CleaverItem)
    local ToolMeta = Tool["metadata"]
    if next(ToolMeta) == nil then
        exports.vorp_inventory:subItem(_source, Config.CleaverItem, 1, {})
        exports.vorp_inventory:addItem(_source, Config.CleaverItem, 1, {
            description = "Durability: " .. 100 - 4,
            durability = 100 - 4
        })
        notify(_source, "Tvuj " .. exports.vorp_inventory:getItemDB(Config.CleaverItem).label ..
            " se poškodil o 4% na " .. 100 - 4 .. "%")
    else
        local Durability = ToolMeta.durability - 4
        local description = "Durability: " .. Durability
        if Durability > 1 then
            exports.vorp_inventory:subItem(_source, Config.CleaverItem, 1, ToolMeta)
            exports.vorp_inventory:addItem(_source, Config.CleaverItem, 1, {
                description = description,
                durability = Durability
            })
            notify(_source, "Tvuj " .. exports.vorp_inventory:getItemDB(Config.CleaverItem).label ..
                " se poškodil o 4% na " .. Durability .. "%")
        else
            exports.vorp_inventory:subItem(_source, Config.CleaverItem, 1, ToolMeta)
            notify(_source, "Rozbil se ti " .. exports.vorp_inventory:getItemDB(Config.CleaverItem).label)
            TriggerClientEvent("aprts_tools:Client:unequip", _source)
            return
        end
    end

    local animal = animals[animalID]
    local configAnimal = Config.Animals[animal.breed]
    if animal then
        DiscordWeb("Ranch", "Mrtvola zvířete " .. animal.breed .. " byla naporcována")
        MySQL:execute("DELETE FROM aprts_ranch_animals WHERE id = ?", {animalID})
        animals[animalID] = nil
        TriggerClientEvent('aprts_ranch:Client:removeAnimal', -1, animalID)
        -- exports.vorp_inventory:addItem(_source, Config.deadReward, math.random(1, 10))

        local reward = nil
        for _, product in pairs(configAnimal.product) do
            if product.gather == 1 then
                local count = 1
                -- calculate reward for dead animal from animal XP Level (Level1 = 1x, Level2 = 2x, Level3 = 3x, Level4 = 4x, Level5 = 5x)
                if animal.xp >= Config.Level1 then
                    count = 1
                end
                if animal.xp >= Config.Level2 then
                    count = 2
                end
                if animal.xp >= Config.Level3 then
                    count = 3
                end
                if animal.xp >= Config.Level4 then
                    count = 4
                end
                if animal.xp >= Config.Level5 then
                    count = 5
                end
                reward = product.item
                count = count * product.amount
                -- exports.vorp_inventory:addItem(_source, product.item, count)
                if reward then
                    exports.vorp_inventory:addItem(_source, reward, count)
                    notify(_source, "Rozbil jsi mrtvé zvíře a získal " .. count .. "x" ..
                        exports.vorp_inventory:getItemDB(reward).label)
                else
                    exports.vorp_inventory:addItem(_source, configAnimal.deadReward, count)
                end
            end
        end

        notify(_source, "Rozbil jsi mrtvé zvíře")
        lib.logger(_source, 'RanchSlaughterAnimal',
            "Hráč " .. playerName .. " rozbil zvíře " .. animalID .. " druhu " .. animal.breed .. "na krmítku: " ..
                animal.railing_id, "animalID:" .. animalID, "breed:" .. animal.breed, "railing_id:" .. animal.railing_id)
    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:addWater")
AddEventHandler("aprts_ranch:Server:addWater", function(railingID, amount)
    local _source = source
    local railing = railings[railingID]
    if railing then
        local maxWater = Config.feeding[railing.prop].water
        railing.water = math.min(maxWater, railing.water + amount)
        MySQL:execute("UPDATE aprts_ranch_railing SET water = ? WHERE id = ?", {railing.water, railingID})
        TriggerClientEvent('aprts_ranch:Client:updateRailing', -1, railing)
        notify(_source, "Naplnil jsi krmítko vodou")
        exports.vorp_inventory:subItem(_source, Config.fullWaterItem, 1)
        exports.vorp_inventory:addItem(_source, Config.emptyWaterItem, 1)
    else
        notify(_source, "Railing not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:addFood")
AddEventHandler("aprts_ranch:Server:addFood", function(railingID, amount)
    local _source = source
    local railing = railings[railingID]
    if railing then
        local maxFood = Config.feeding[railing.prop].food
        railing.food = math.min(maxFood, railing.food + amount)
        MySQL:execute("UPDATE aprts_ranch_railing SET food = ? WHERE id = ?", {railing.food, railingID})
        TriggerClientEvent('aprts_ranch:Client:updateRailing', -1, railing)
        notify(_source, "Naplnil jsi krmítko krmivem")
        exports.vorp_inventory:subItem(_source, Config.fullFoodItem, 1)
        exports.vorp_inventory:addItem(_source, Config.emptyFoodItem, 1)
    else
        notify(_source, "Railing not found.")
    end
end)
RegisterServerEvent("aprts_ranch:Server:updateAnimalSickness")
AddEventHandler("aprts_ranch:Server:updateAnimalSickness", function(animalID, sickness)
    local _source = source
    local animal = animals[animalID]
    if animal then
        animal.sick = sickness

        -- notify(_source, "Zvíře bylo označeno jako nemocné")
    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:updateAnimalName")
AddEventHandler("aprts_ranch:Server:updateAnimalName", function(animalID, name)
    local _source = source
    local animal = animals[animalID]
    if animal then
        animal.name = name
        exports.vorp_inventory:subItem(_source, Config.NameTagItem, 1)
        MySQL:execute("UPDATE aprts_ranch_animals SET name = ? WHERE id = ?", {name, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        notify(_source, "Jméno zvířete bylo změněno")
    else
        notify(_source, "Animal not found.")
    end
end)

RegisterServerEvent("aprts_ranch:Server:upgradeRailing")
AddEventHandler("aprts_ranch:Server:upgradeRailing", function(railingID, prop)
    local _source = source
    local railing = railings[railingID]
    if railing then
        local feeding = Config.feeding[prop]
        if feeding then
            railing.prop = prop
            railing.size = feeding.size
            railing.food = feeding.food
            railing.water = feeding.water
            MySQL:execute("UPDATE aprts_ranch_railing SET prop = ?, size = ?, food = ?, water = ? WHERE id = ?",
                {prop, feeding.size, feeding.food, feeding.water, railingID})
            TriggerClientEvent('aprts_ranch:Client:upgradeRailing', -1, railing)
            notify(_source, "Railing upgraded")
        else
            notify(_source, "Railing not found")
        end
    else
        notify(_source, "Railing not found")
    end
end)

RegisterServerEvent("aprts_ranch:Server:cureAnimal")
AddEventHandler("aprts_ranch:Server:cureAnimal", function(animalID, cure)
    local _source = source
    exports.vorp_inventory:addItem(_source, Config.medicineItemTool, 1)
    local animal = animals[animalID]
    if animal then
        animal.health = math.min(100, animal.health + cure)
        MySQL:execute("UPDATE aprts_ranch_animals SET health = ? WHERE id = ?", {animal.health, animalID})
        TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
        notify(_source, "Zvířeti bylo vyléčeno " .. cure .. " HP")
    else
        notify(_source, "Animal not found.")

    end
end)

RegisterServerEvent("aprts_ranch:Server:returnItem")
AddEventHandler("aprts_ranch:Server:returnItem", function(item)
    local _source = source
    exports.vorp_inventory:addItem(_source, item, 1)
end)

RegisterServerEvent("aprts_ranch:Server:reviveAnimal")
AddEventHandler("aprts_ranch:Server:reviveAnimal", function(animalID)
    local _source = source

    local hasItem = exports.vorp_inventory:getItemCount(_source, nil, Config.ReviveItem)

    if hasItem < 1 then
        local label = exports.vorp_inventory:getItemDB(Config.ReviveItem).label
        notify(_source, "Nemáš " .. label)
        return
    end

    local skillLevel, skillXP = exports.westhaven_skill:get(_source, Config.Skill)
    if not skillLevel then
        skillLevel = 0
    end

    local chance = math.random(1, 100)

    local animal = animals[animalID]
    if animal then
        if chance < Config.ReviveChance + skillLevel then
            local anim = Config.Animation.cure
            anim.time = 60000
            TriggerClientEvent("aprts_ranch:Client:playAnim", _source, anim)
            Wait(anim.time)
            notify(_source, "Zvíře se neprobudilo")
            exports.westhaven_skill:increaseSkill(_source, Config.Skill, 1)
        else
            exports.vorp_inventory:subItem(_source, Config.ReviveItem, 1)
            local anim = Config.Animation.cure
            anim.time = 60000
            TriggerClientEvent("aprts_ranch:Client:playAnim", _source, anim)
            Wait(anim.time)

            exports.westhaven_skill:increaseSkill(_source, Config.Skill, math.random(1, 15))
            DiscordWeb("Ranch", "Zvíře " .. animal.breed .. "/" .. animal.id .. " bylo oživeno")
            animal.health = 100
            MySQL:execute("UPDATE aprts_ranch_animals SET health = ? WHERE id = ?", {animal.health, animalID})
            TriggerClientEvent('aprts_ranch:Client:updateAnimal', -1, animal)
            notify(_source, "Zvíře bylo oživeno")
        end
    else
        notify(_source, "Nějaká chyba, zvíře nenalezeno.")
    end
end)



RegisterServerEvent("aprts_ranch:Server:removeMoney")
AddEventHandler("aprts_ranch:Server:removeMoney", function(amount)
    local _source = source
    local user = Core.getUser(_source) --[[@as User]]  
    if not user then return end -- is player in session?
    local character = user.getUsedCharacter --[[@as Character]]
    character.removeCurrency(0, amount)
end)


RegisterServerEvent("aprts_ranch:server:sellAnimal")
AddEventHandler("aprts_ranch:server:sellAnimal", function(animal)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname
    local price = Config.Animals[animal.breed].price
    price = price + (animal.xp * Config.XPPrice)
    price = price - (animal.sick * Config.SickPrice)
    if animal then

        notify(_source, "Zvíře bylo prodáno za " .. price .. "$")
        local Character = Core.getUser(_source).getUsedCharacter
        Character.addCurrency(0, price)
        lib.logger(_source, 'RanchSellAnimal',
            "Hráč " .. playerName .. " prodal zvíře druhu " .. animal.breed ..
                "na krmítku: " .. animal.railing_id, "breed:" .. animal.breed,
            "railing_id:" .. animal.railing_id)
    else
        notify(_source, "Animal not found.")
    end
end)