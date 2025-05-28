dataLoaded = false
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    TriggerServerEvent("aprts_ranch:Server:getData")

end)
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    for k, v in pairs(railings) do
        for i, product in pairs(v.products) do
            if DoesEntityExist(product.obj) then
                -- debugPrint("Ukončuji resource, mažu produkt: " .. product.name)
                DeleteEntity(product.obj)
            end
        end
        if DoesEntityExist(v.obj) then
            -- debugPrint("Ukončuji resource, mažu ohradu: " .. v.id)
            DeleteEntity(v.obj)
        end
    end
    railings = {}
    for k, v in pairs(animals) do
        if DoesEntityExist(v.obj) then
            -- debugPrint("Ukončuji resource, mažu zvíře: " .. v.id)
            DeleteEntity(v.obj)
        end
    end
    animals = {}
    for k, v in pairs(herdAnimals) do
        if DoesEntityExist(v.obj) then
            -- debugPrint("Ukončuji resource, mažu vedená zvířata: " .. v.obj)
            DeleteEntity(v.obj)
        end
    end
    herdAnimals = {}
    for k, v in pairs(walkingAnimals) do
        if DoesEntityExist(v.obj) then
            -- debugPrint("Ukončuji resource, mažu chodící zvíře: " .. v.id)
            DeleteEntity(v.obj)
        end
    end
    walkingAnimals = {}
    for k, v in pairs(poops) do
        if DoesEntityExist(v.obj) then
            -- debugPrint("Ukončuji resource, mažu hovínko: " .. v.id)
            DeleteEntity(v.obj)
        end
    end
    poops = {}

    for _, v in pairs(Config.Shelters) do
        if DoesEntityExist(v.npc) then
            DeleteEntity(v.npc)
        end
    end

    for _, v in pairs(Config.SlaughterHouses) do
        if DoesEntityExist(v.npc) then
            DeleteEntity(v.npc)
        end
    end
end)

RegisterNetEvent("aprts_ranch:Client:getData")
AddEventHandler("aprts_ranch:Client:getData",
    function(serverRanches, serverRailings, serverAnimals, serverPoops, config,lostanimals)
        
        for _, v in pairs(lostanimals) do
            lostAnimals[v.id] = v
        end
        Config.Animals = config
        while table.count(serverRanches) < 1 do
            Wait(100)
        end

        for k, v in pairs(serverRanches) do
            ranches[v.id] = v
            ranches[v.id].Blip = CreateBlip(v.coords, 156, "Ranch")
            local coords = v.coords
            -- exports.westhaven_cores:addClearZone(coords, 55.0) -- clearzona na emeraldu
        end

        for k, v in pairs(serverRailings) do
            local railing = railings[v.id]
            if railing then
                serverRailings.obj = railing.obj

            end
            railings[v.id] = v
            railings[v.id].obj = obj
            exports.westhaven_cores:addClearZone(v.coords, 20.0) -- clearzona na emeraldu
        end
        for k, v in pairs(serverAnimals) do
            animals[v.id] = v
        end
        for k, v in pairs(serverPoops) do
            poops[v.id] = v
        end
        debugPrint("Ranch started")
        debugPrint("Ranches: " .. table.count(ranches))
        debugPrint("Railings: " .. table.count(railings))
        debugPrint("Animals: " .. table.count(animals))
        debugPrint("Poops: " .. table.count(poops))
        dataLoaded = true
    end)

RegisterNetEvent("aprts_ranch:Client:getRailing")
AddEventHandler("aprts_ranch:Client:getRailing", function(railing)

    railings[railing.id] = railing
    -- debugPrint("New Railing: " .. railings[railing.id].id)
end)

RegisterNetEvent("aprts_ranch:Client:getPoop")
AddEventHandler("aprts_ranch:Client:getPoop", function(poop)
    if poop then
        poops[poop.id] = poop
        -- debugPrint("New Poop: " .. poops[poop.id].id)
    end
end)
RegisterNetEvent("aprts_ranch:Client:getAnimal")
AddEventHandler("aprts_ranch:Client:getAnimal", function(animal)
    if animal then
        animals[animal.id] = animal
        -- debugPrint("New Animal: " .. animals[animal.id].id)
    end
end)
RegisterNetEvent("aprts_ranch:Client:updateAnimal")
AddEventHandler("aprts_ranch:Client:updateAnimal", function(animal)
    -- copy new animal parameters to existing animal, animals[animal.id].obj must be the same
    -- debugPrint(json.encode(animal))
    if animal then
        if animal.home then
            if animal.home == 0 then

                if DoesEntityExist(animals[animal.id].obj) then
                    -- debugPrint("Deleting animal: " .. animal.id .. " protože jsi vzal zvíře z ohrady")
                    DeleteEntity(animals[animal.id].obj)
                end
                animals[animal.id] = nil
                return
            end
        end
        local temp = nil

        if animals[animal.id] then

            temp = animals[animal.id].obj

            if animals[animal.id].health ~= animal.health then
                DeleteEntity(animals[animal.id].obj)
                animals[animal.id] = nil
            end
        end
        animals[animal.id] = animal

        animals[animal.id].obj = temp
    end
end)

RegisterNetEvent('aprts_ranch:Client:removePoop')
AddEventHandler('aprts_ranch:Client:removePoop', function(poopID)
    if poops[poopID] then
        if DoesEntityExist(poops[poopID].obj) then
            -- debugPrint("Deleting poop: " .. poops[poopID].obj)
            DeleteEntity(poops[poopID].obj)
        end
        poops[poopID] = nil
    end
end)

RegisterNetEvent('aprts_ranch:Client:useMedicine')
AddEventHandler('aprts_ranch:Client:useMedicine', function(usedMedicine)

    if medicine then
        medicine = nil
        exports["aprts_tools"]:UnequipTool()
    end
    exports["aprts_tools"]:EquipTool(Config.medicineItemTool)
    medicine = usedMedicine
end)

RegisterNetEvent('aprts_ranch:Client:useBrush')
AddEventHandler('aprts_ranch:Client:useBrush', function()
    exports["aprts_tools"]:EquipTool(Config.BrushItem)
end)
RegisterNetEvent("aprts_ranch:Client:getRanch")
AddEventHandler("aprts_ranch:Client:getRanch", function(ranch)

    ranches[ranch.id] = ranch
    -- debugPrint("New Ranch: " .. ranches[ranch.id].id .. " on land " .. ranches[ranch.id].land_id)
end)

RegisterNetEvent("aprts_ranch:Client:removeAnimal")
AddEventHandler("aprts_ranch:Client:removeAnimal", function(animalID)
    if animals[animalID] then
        if DoesEntityExist(animals[animalID].obj) then
            -- debugPrint("Deleting animal: " .. animals[animalID].obj)
            DeleteEntity(animals[animalID].obj)
        end
        animals[animalID] = nil
    end
end)

RegisterNetEvent("aprts_ranch:Client:updateRailing")
AddEventHandler("aprts_ranch:Client:updateRailing", function(railing)
    local temp = railings[railing.id].obj

    -- přepiš produkty uložené v railings, ale zachovej objekty prouktů pokud existují
    for i, product in pairs(railing.products) do
        if railings[railing.id].products[i] then
            product.obj = railings[railing.id].products[i].obj
        end
    end

    if railings[railing.id] then
        railings[railing.id] = railing
        railings[railing.id].obj = temp
    end
end)

RegisterNetEvent("aprts_ranch:Client:playAnim")
AddEventHandler("aprts_ranch:Client:playAnim", function(anim)
    if anim then
        PlayAnimation(anim)
    end
end)

RegisterNetEvent("aprts_ranch:Client:putAnimal")
AddEventHandler("aprts_ranch:Client:putAnimal", function(animalID)
    debugPrint("Vracím zvíře z venčení")
    if walkingAnimals[animalID] then
        if DoesEntityExist(walkingAnimals[animalID].obj) then
            DeleteEntity(walkingAnimals[animalID].obj)
        end
        walkingAnimals[animalID] = nil
    end
end)

RegisterNetEvent("aprts_ranch:Client:walkAnimal")
AddEventHandler("aprts_ranch:Client:walkAnimal", function(newanimal,coords)
    debugPrint("Walking animal: " .. newanimal.id)
    walkingAnimals[newanimal.id] = newanimal
    local animal = walkingAnimals[newanimal.id]

    if animal.gender == "female" then
        animal.model = Config.Animals[animal.breed].model
    else
        animal.model = Config.Animals[animal.breed].m_model
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    if coords then
        playerCoords = coords
    end 
    animal.obj = spawnAnimal(animal, playerCoords, false)
    Wait(300)
    SetEntityCoords(animal.obj, playerCoords.x, playerCoords.y, playerCoords.z)
    SetRelationshipBetweenGroups(1, GetPedRelationshipGroupHash(animal.obj), joaat('PLAYER'))
    TaskFollowToOffsetOfEntity(animal.obj, PlayerPedId(), 0.0, 5.0, 0.0, 1, -1, 5, true, true, false, true, true, true)

    -- Věk zvířete a přepočet měřítka
    local adultAge = Config.Animals[animal.breed].adultAge
    if animal.age < adultAge then

        -- Procento růstu na základě věku (age) a adultAge
        local ageRatio = animal.age / adultAge

        -- Výpočet velikosti od 0.3 do 1.0 na základě věku
        local scale = 0.3 + (ageRatio * (1.0 - 0.3))

        -- Nastavení měřítka pro zvíře
        SetPedScale(animal.obj, scale)
    else
        -- Nastav plnou velikost, pokud je zvíře dospělé
        SetPedScale(animal.obj, 1.0)
    end
    -- SetEntityHealthToMax(animal.obj, animal.health)
    -- Nastavení meta dat zvířete
    for i, data in pairs(animal.meta) do
        SetMetaPedTag(animal.obj, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0,
            data.tint1, data.tint2)
    end
    -- debugPrint("Walking animal: " .. walkingAnimals[newanimal.id].obj)
end)

RegisterNetEvent('aprts_ranch:Client:useNameTag')
AddEventHandler('aprts_ranch:Client:useNameTag', function()
    if land then
        if land.access >= 1 then
            local ped = exports["aprts_select"]:startSelecting(true)
            -- find animal by ped
            local animal = nil
            for k, v in pairs(animals) do
                if v.obj == ped then
                    animal = v
                    break
                end
            end
            if animal then
                notify("Použil jsi nálepku na zvíře" .. animal.breed)
                animal.name = GetUserInput("Zadej jméno ", 30)
                if animal.name == nil then
                    notify("Zrušeno")
                else
                    TriggerServerEvent("aprts_ranch:Server:updateAnimalName", animal.id, animal.name)
                end
            else
                notify("Nevybral jsi zvíře z ranče!")
            end
        end
    end
end)
RegisterNetEvent('aprts_ranch:Client:spawnAnimal')
AddEventHandler('aprts_ranch:Client:spawnAnimal', function(anima, pos, single, animalID, railingPos)
    local animal = animals[animalID]
    debugPrint("Spawning animal: " .. animalID)
    if animal then
        animal.obj = spawnAnimal(anima, pos, single)

        SetEntityHealthToMax(animal.obj, animal.health) -- Nastavení zdraví

        -- Nastavení zvířete jako entita mise
        SetEntityAsMissionEntity(animal.obj, false, false)
        SetPedRelationshipGroupDefaultHash(animal.obj, GetHashKey("PLAYER"))
        -- Nastavení velikosti zvířete podle věku
        SetPedScale(animal.obj, scaleByAge(animal.breed, animal.age))
        -- Nastavení meta dat
        if animal.meta then

            for i, data in pairs(animal.meta) do

                SetMetaPedTag(animal.obj, data.drawable, data.albedo, data.normal, data.material, data.palette,
                    data.tint0, data.tint1, data.tint2)
            end
        end
        -- Zadání úkolu pro zvíře, aby následovalo hráče nebo bloudilo v oblasti
        TaskWanderInArea(animal.obj, railingPos.x, railingPos.y, railingPos.z, 5.0, 5.0, 5.0)
    end
end)

RegisterNetEvent('aprts_ranch:Client:placeRailing')
AddEventHandler('aprts_ranch:Client:placeRailing', function(prop)
    placeRailing(GetEntityCoords(PlayerPedId()), prop)
end)

RegisterNetEvent('aprts_ranch:Client:tryUpgrade')
AddEventHandler('aprts_ranch:Client:tryUpgrade', function(prop)
    local playerCoords = GetEntityCoords(PlayerPedId())
    if closestRailing then
        if closestRailing.prop == prop then
            notify("Ohrada již tento upgrade má")
            return
        end
        if GetDistanceBetweenCoords(playerCoords, closestRailing.coords.x, closestRailing.coords.y,
            closestRailing.coords.z, false) < 5.0 then
            TriggerServerEvent('aprts_ranch:Server:upgradeRailing', closestRailing.id, prop)
        end
    else
        notify("Není v dosahu žádná ohrada")
    end
end)

RegisterNetEvent('aprts_ranch:Client:upgradeRailing')
AddEventHandler('aprts_ranch:Client:upgradeRailing', function(railing)
    if railings[railing.id] then
        if DoesEntityExist(railings[railing.id].obj) then
            DeleteEntity(railings[railing.id].obj)
        end
        railings[railing.id] = railing
    end
end)

RegisterNetEvent('aprts_ranch:Client:useCure')
AddEventHandler('aprts_ranch:Client:useCure', function(cure)

    local animal = exports["aprts_select"]:startSelecting(true)

    if LocalPlayer.state.Character.Job ~= Config.DoctorJob then
        notify("Musíš být veterinář! Injekci jsi pouze vypráznil.")
        TriggerServerEvent("aprts_ranch:Server:returnItem", Config.medicineItemTool)
        return
    end
    if animal then
        if DoesEntityExist(animal) then
            local animalID = nil
            for k, v in pairs(animals) do
                if v.obj == animal then
                    animalID = v.id
                    break
                end
            end
            if animalID then

                exports["aprts_tools"]:EquipTool(Config.medicineItemTool)
                FreezeEntityPosition(animal, true)
                PlayAnimation(Config.Animation.cure)
                exports["aprts_tools"]:UnequipTool()
                FreezeEntityPosition(animal, false)
                TriggerServerEvent("aprts_ranch:Server:cureAnimal", animalID, cure)
            else
                notify("Nevybral jsi zvíře z ranče!")
            end
        end
    end
end)
