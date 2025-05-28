function notify(text)
    -- TriggerEvent('notifications:notify', "RANČ", text, 3000)
    TriggerEvent("westhaven_notify:send", {
        title = "Ranč",
        description = text,
        placement = "top-right",
        duration = 5000
    }, "SUCCESS")

end

land = nil

ranches = {}
animals = {}
railings = {}
herdAnimals = {}
walkingAnimals = {}
poops = {}
lastRailingID = 0
medicine = nil

closestAnimal = nil
closestRailing = nil

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function debugPrint(text)
    if Config.Debug == true then
        print(text)
    end
end

function sendHome(animal, railingID)
    local railing = railings[railingID]
    local distance = GetDistanceBetweenCoords(GetEntityCoords(animal.obj), railing.coords.x, railing.coords.y,
        railing.coords.z, 1)
    if distance <= Config.homeSafeDistance then
        TaskGoToCoordAnyMeans(animal.obj, railing.coords.x, railing.coords.y, railing.coords.z, 1.0, 0, 0, 786603,
            0xbf800000)
        Wait(10000)
        DeleteEntity(animal.obj)
        TriggerServerEvent("aprts_ranch:Server:putAnimal", railing.id, animal)
        notify("Zvíře " .. animal.id .. " dorazilo zpět na svou ohradu")
    else -- pokud je zvíře moc daleko, smaž ho
        notify("Zvíře " .. animal.id .. " je moc daleko a nedorazilo zpět na ohradu")
        DeleteEntity(animal.obj)
        walkingAnimals[animal.id] = nil
    end
end

function placeRailing(coords, prop)
    local feeding = Config.feeding[prop].item
    if land then
        for _, railing in pairs(railings) do
            local railingPos = railing.coords
            local distance = GetDistanceBetweenCoords(coords, railingPos.x, railingPos.y, railingPos.z, true)
            if distance <= 15.0 then
                notify("Nemůžete postavit krmítko tak blízko k sobě")
                return
            end
        end
        local ranch = getRanchFromLand(land.id)
        local ranchID = 0
        -- debugPrint("Ranch ID: " .. ranch)
        if ranch ~= 0 then
            ranchID = ranch.id
        end

        if land.access >= 1 then
            -- debugPrint("Placing railing" .. ranchID)
            if ranchID == 0 then
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("aprts_ranch:Server:createRanch", "Ranch", land.id, coords)
                notify("Tento pozemek nebyl Ranč, Vytvořil jsi nový ranč. Polož krmítko znovu")
                TriggerServerEvent("aprts_ranch:Server:returnItem", feeding)
            else
                TriggerServerEvent("aprts_ranch:Server:placeRailing", ranchID, GetEntityCoords(PlayerPedId()), prop)
            end
        else
            notify("Nemáte přístup na tento pozemek")
            TriggerServerEvent("aprts_ranch:Server:returnItem", feeding)
        end
    else
        notify("Nemáte pozemek")
        TriggerServerEvent("aprts_ranch:Server:returnItem", feeding)
    end
end

function newAnimal(animalName)
    -- debugPrint("Creating animal: " .. animalName)
    if not Config.Animals[animalName] then
        -- debugPrint("Zvíře neexistuje")
        return
    end
    local animal = deepCopy(Config.Animals[animalName]) -- Vytvoříme hlubokou kopii zvířete
    animal.gender = math.random() < 0.5 and 'male' or 'female'
    local anima = {}
    anima.model = nil
    if animal.gender == "female" then
        anima.model = Config.Animals[animal.name].model
    else
        anima.model = Config.Animals[animal.name].m_model
    end
    anima.health = animal.health
    animal.obj = spawnAnimal(anima)
    SetPedScale(animal.obj, 0.3)
    table.insert(herdAnimals, animal)
    SetRelAndFollowPlayer(herdAnimals)
    return animal.obj
end

exports("newAnimal", newAnimal)

function removeHerdAnimal(animal)
    for k, v in pairs(herdAnimals) do
        if v.obj == animal then
            table.remove(herdAnimals, k)
            return
        end
    end
end

exports("removeHerdAnimal", removeHerdAnimal)

-- Function to get user input
function GetUserInput(text, length)
    AddTextEntry('FMMC_KEY_TIP1', text)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", length)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        return GetOnscreenKeyboardResult()
    end
    return nil
end

function removeWalkingAnimal(animalID)
    local animal = walkingAnimals[animalID]

    TriggerServerEvent("aprts_ranch:Server:deleteAnimal", animal.id)

    DeleteEntity(animal.obj)
    walkingAnimals[animalID] = nil
end

Citizen.CreateThread(function()
    while true do
        local pause = 60000
        local playerCoods = GetEntityCoords(PlayerPedId())
        for _, animal in pairs(walkingAnimals) do
            -- print(json.encode(animal))
            if animal.obj then
                local animalPos = GetEntityCoords(animal.obj)
                local distance = GetDistanceBetweenCoords(playerCoods, animalPos.x, animalPos.y, animalPos.z, 1)
                if distance >= Config.homeSafeDistance then
                    sendHome(animal, animal.oldRailing)
                    notify("Zvíře " .. animal.id .. " je od tebe moc daleko a uteklo ti")
                end
                local tempTool = exports.aprts_tools:GetEquipedTool()

                if tempTool ~= Config.leashItem then
                    animal.xp = animal.xp + 1
                    animal.energy = math.max(0, animal.energy - 1)
                    animal.food = math.max(0, animal.food - 1)
                    animal.water = math.max(0, animal.water - 1)
                    animal.happynes = math.min(100, animal.happynes + 2)
                end

                if animal.food <= 0 or animal.water <= 0 then
                    animal.health = animal.health - 1
                end
                -- animal.health = GetEntityHealth(animal.obj)

                if animal.health <= 0 then

                    notify(animal.breed .. " zemřelo hlady nebo žízní na procházce!")
                    print("food:" .. animal.food, "watter:" .. animal.water)
                    animal.health = 10
                    sendHome(animal, animal.oldRailing)
                elseif IsPedDeadOrDying(animal.obj) then
                    print(GetPedSourceOfDeath(animal.obj))
                    notify(animal.breed .. " něco zabilo na procházce!")
                    print("food:" .. animal.food, "watter:" .. animal.water)
                    animal.health = 10
                    sendHome(animal, animal.oldRailing)

                end

                if animal.energy <= 0 then
                    notify("Zvíře " .. animal.id .. " je unavené posílám ho domů")

                end
            end
        end
        Wait(pause)
    end
end)

function getRandomPosInRailing(railing)
    local nx = railing.coords.x + math.random(math.floor(-railing.size / 2), math.floor(railing.size / 2))
    local ny = railing.coords.y + math.random(math.floor(-railing.size / 2), math.floor(railing.size / 2))
    local nz = railing.coords.z

    return {
        x = nx,
        y = ny,
        z = nz
    }
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        land = exports["aprts_landmark"]:getLand()
        Wait(pause)
    end
end)
function deleteAnimals(table)
    for k, v in pairs(table) do
        DeleteEntity(v.obj)
        v = nil
    end
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

function getMetaTag(entity)
    -- debugPrint("GetMetaTag")
    local metatag = {}
    local numComponents = GetNumComponentsInPed(entity)

    -- debugPrint("Num components: ", numComponents)
    -- debugPrint("Num catagories: ", GetNumComponentCategoriesInPed(entity))
    for i = 0, numComponents - 1, 1 do
        local index, drawable, albedo, normal, material = GetMetaPedAssetGuids(entity, i)
        local iindex, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(entity, i)
        -- debugPrint(GetPedComponentCategoryByIndex(entity, i))
        metatag[tostring(i)] = {
            drawable = tonumber(drawable),
            albedo = tonumber(albedo),
            normal = tonumber(normal),
            material = tonumber(material),
            palette = tonumber(palette),
            tint0 = tonumber(tint0),
            tint1 = tonumber(tint1),
            tint2 = tonumber(tint2)
        }
        -- ddebugPrint(drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end
    return metatag
end

function CreateBlip(coords, sprite, name)
    -- debugPrint("Creating Blip: ")
    local blip = BlipAddForCoords(1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite, 1)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, name)
    return blip
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for _, animal in pairs(walkingAnimals) do
            if DoesEntityExist(animal.obj) then
                local animPos = GetEntityCoords(animal.obj)
                local distance = GetDistanceBetweenCoords(playerPos, animPos.x, animPos.y, animPos.z, 1)
                if distance <= 1.5 then
                    local data = {}
                    -- zobraz druh, energii, štěstí, zdraví, hlad, žízeň zvířete
                    data[1] = {
                        text = "Druh: " .. animal.breed .. ". XP:" .. animal.xp,
                        color = "#ffffff"
                    }
                    data[2] = {
                        text = "Energie: " .. animal.energy .. "%",
                        color = "#ffffff"
                    }
                    data[3] = {
                        text = "Štěstí: " .. animal.happynes .. "%",
                        color = "#ffffff"
                    }
                    data[4] = {
                        text = "Zdraví: " .. animal.health .. "%",
                        color = "#fc0a03"
                    }
                    data[5] = {
                        text = "Hlad: " .. animal.food .. "/" .. Config.Animals[animal.breed].foodMax .. " Žízeň: " ..
                            animal.water .. "/" .. Config.Animals[animal.breed].waterMax,
                        color = "#00aaff"
                    }
                    displayData3D(animPos.x, animPos.y, animPos.z, data)
                    pause = fpsTimer()
                end
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)

        if land and table.count(herdAnimals) > 0 then
            if land.access > 0 then
                for _, prop in pairs(railings) do
                    local propPos = prop.coords
                    local distance = GetDistanceBetweenCoords(playerPos, propPos.x, propPos.y, propPos.z, 1)
                    if distance <= 1.0 then
                        DrawText3D(propPos.x, propPos.y, propPos.z, "[" .. Config.KeyLabel .. "] Uvázat zvířata")
                        if IsControlJustPressed(0, Config.Key) then
                            for k, animal in pairs(herdAnimals) do
                                if IsPedDeadOrDying(animal.obj) then
                                    DeleteEntity(animal.obj)
                                    table.remove(herdAnimals, k)
                                    animal = nil
                                end
                            end
                            -- debugPrint("Uvazani zvirat" .. table.count(herdAnimals))
                            if table.count(herdAnimals) <= (prop.size - getCountAnimlsonRailing(prop)) then
                                for _, animal in pairs(herdAnimals) do
                                    if not IsPedDeadOrDying(animal.obj) then
                                        TaskGoToEntity(animal.obj, prop.obj, -1, 1.0, 2.0, 0, 0)
                                        Wait(10000)

                                        TriggerServerEvent("aprts_ranch:Server:addAnimal", prop.id, animal.name,
                                            animal.gender, getMetaTag(animal.obj))

                                        DeleteEntity(animal.obj)
                                    end
                                end

                                deleteAnimals(herdAnimals)
                                herdAnimals = {}
                            else
                                notify("Sem se tvá zvířata nevejdou.")
                            end
                        end
                        pause = fpsTimer()
                    end
                end
            end
        end
        Wait(pause)
    end
end)

function relationshipsetup(ped, relInt) -- ped and player relationship setter, rail int is 1-5 1 being friend 5 being hate
    SetRelationshipBetweenGroups(relInt, GetPedRelationshipGroupHash(ped), joaat('PLAYER'))
end

function SetRelAndFollowPlayer(table) -- will set the peds relation with player and then have ped follow player
    for k, v in pairs(table) do
        relationshipsetup(v.obj, 1)
        TaskFollowToOffsetOfEntity(v.obj, PlayerPedId(), v.offsetX, v.offsetY, v.offsetZ, 1, -1, 5, true, true,
            v.WalkOnly, true, true, true)
    end
end

function spawnAnimal(animal, coords, single)
    -- debugPrint("Spawning animal: " .. animal.model)
    local model = GetHashKey(animal.model)
    local newanimal = nil
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    local pos = GetEntityCoords(PlayerPedId())
    if coords then
        pos = coords
    end
    if not single then
        -- debugPrint("Spawning animal for group")
        newanimal = CreatePed(model, pos.x + math.random(0.0, 2.0), pos.y + math.random(0.0, 2.0), pos.z - 1.0, 0.0,
            true, true, true, true)
        SetEntityAsMissionEntity(newanimal, true, true)
    else
        newanimal = CreatePed(model, pos.x + math.random(0.0, 2.0), pos.y + math.random(0.0, 2.0), pos.z - 1.0, 0.0,
            false, false, false, false)
    end
    Citizen.InvokeNative(0xADB3F206518799E8, newanimal, GetHashKey("PLAYER"))
    Citizen.InvokeNative(0xDF93973251FB2CA5, newanimal, false)
    SetRandomOutfitVariation(newanimal, true)
    SetBlockingOfNonTemporaryEvents(newanimal, true)

    local animalFlags = {
        [6] = true,
        [113] = true,
        [136] = true,
        [208] = true,
        [209] = true,
        [211] = true,
        [277] = true,
        [297] = false,
        [300] = false,
        [301] = false,
        [312] = false,
        [319] = true,
        [400] = true,
        [412] = false,
        [419] = false,
        [438] = false,
        [439] = false,
        [440] = false,
        [561] = true
    }
    for flag, val in pairs(animalFlags) do
        SetPedConfigFlag(newanimal, flag, val); -- SetPedConfigFlag (kind of sets defaultbehavior)
    end

    Wait(100)
    SetModelAsNoLongerNeeded(model)
    SetEntityHealth(newanimal, animal.health, 0)
    -- PlaceOnGroundProperly(newanimal)
    return newanimal
end

function spawnEntity(coords, model)
    -- debugPrint("Spawning " .. model .. " at " .. coords.x .. " " .. coords.y .. " " .. coords.z)
    local hash = GetHashKey(model)
    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
    end

    local entity = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    Wait(100)
    PlaceEntityOnGroundProperly(entity)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(entity, true)
    return entity
end

function getRanchFromLand(landID)
    -- debugPrint("Searching for ranch with landID: " .. landID)
    for k, v in pairs(ranches) do
        if v.land_id == landID then
            -- debugPrint("Found ranch with ID: " .. v.id)
            return v
        end
    end
    return 0
end

-- Funkce pro hlubokou kopii tabulky
function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v) -- Rekurzivní kopie pro tabulky
        else
            copy[k] = v
        end
    end
    return copy
end

-- Client Vorp Core
-- LocalPlayer.state.IsInSession -- returns true if player have choosen a character
-- LocalPlayer.state.Character.FirstName 
-- LocalPlayer.state.Character.LastName
-- LocalPlayer.state.Character.Job 
-- LocalPlayer.state.Character.JobLabel 
-- LocalPlayer.state.Character.Grade  
-- LocalPlayer.state.Character.Group 
-- LocalPlayer.state.Character.Age 
-- LocalPlayer.state.Character.Gender
-- LocalPlayer.state.Character.NickName
-- LocalPlayer.state.Character.CharDescription
-- LocalPlayer.state.Character.Money
-- LocalPlayer.state.Character.Gold
-- LocalPlayer.state.Character.Rol
-- LocalPlayer.state.Character.CharId
