--[[
    cl_main.lua
    Description: This script handles client-side operations for horse management, including creating, deleting, and setting horses as default.
    
    Functions:
        notify(message) - Sends a notification to the client.
        deleteHorse() - Deletes the current horse and stables it on the server.
        setDefaultHorse(name) - Sets the specified horse as the default horse for the player.
        createVehicle(vehType, horse) - Prompts the player to name a new horse and registers it on the server.
        
    Events:
        aprts_horses:deleteMount - Deletes the current horse mount if it exists.
]] myHorse = {
    ped = nil,
    name = "",
    id = 0,
    model = 0,
    meta = {},
    shoed = false
}
function notify(text, color)
    TriggerEvent('notifications:notify', "Koně", text, 3000)
end
HorseComp = {}

-- Exportuj funkci
exports('getHorse', function()
    return myHorse, HorseComp
end)

exports('pushHorse', function(horse)
    if myHorse.ped == horse.ped then
        myHorse = horse
    end

end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if myHorse.ped then
        if DoesEntityExist(myHorse.ped) then
            DeletePed(myHorse.ped)
        end
    end
end)

local function getItemCategory(item)
    for _, category in pairs(HorseComp) do
        for i, comp in pairs(category) do
            if comp.item == item then
                return category
            end
        end
    end
    return nil
end

AddEventHandler("onClientResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print("Zkouším získat komponenty Koní")
    TriggerServerEvent("aprts_horses:Server:getAllComponents")
    TriggerServerEvent("aprts_roadpoints:Server:getPoints")

end)

local function equipComponent(horsePed, componentHash)
    ApplyShopItemToPed(horsePed, componentHash, true, true, true)
    TriggerServerEvent("aprts_horses:Server:equipHorseComponent", horsePed, componentHash)
end

function TurnPlayerToEntity(playerPed, targetEntity)
    local playerCoords = GetEntityCoords(playerPed, true) -- Získej pozici hráče
    local targetCoords = GetEntityCoords(targetEntity, true) -- Získej pozici cílové entity

    -- Vypočítej rozdíl v souřadnicích mezi hráčem a entitou
    local dx = targetCoords.x - playerCoords.x
    local dy = targetCoords.y - playerCoords.y

    -- Vypočítej směr, kterým by se měl hráč otočit (heading)
    local heading = GetHeadingFromVector_2d(dx, dy)

    -- Nastav hráčovu orientaci (heading) směrem k entitě
    SetEntityHeading(playerPed, heading)
end

RegisterNetEvent("aprts_horses:Client:equipHorseComponent")
AddEventHandler("aprts_horses:Client:equipHorseComponent", function(horsePed, componentHash, sender)
    print("Nasazuji komponentu: ", componentHash .. " na koně: ", horsePed)
    print("muj kun: ", myHorse.ped)
    if myHorse.ped == horsePed then
        for _, comp in pairs(HorseComp) do
            for _, item in pairs(comp) do
                if item.hash == componentHash then
                    -- print(json.encode(item))
                    -- print(json.encode(myHorseComp))
                    if myHorseComp[item.category] then
                        if myHorseComp[item.category] > 0 then
                            TriggerServerEvent("aprts_horses:Server:returnComp", myHorseComp[item.category], sender)
                        end
                    else
                        myHorseComp[item.category] = 0
                        TriggerServerEvent("aprts_horses:Server:returnComp", myHorseComp[item.category], sender)
                    end
                    myHorseComp[item.category] = item.hash
                end
            end
        end
        -- print(json.encode(myHorseComp))
        TriggerServerEvent("aprts_horses:equipHorseComponent", myHorse.id, myHorseComp)
    end
end)
Horses = {}
RegisterNetEvent("aprts_horses:Client:sendAllHorses")
AddEventHandler("aprts_horses:Client:sendAllHorses", function(horses)
    Horses = horses
end)

RegisterNetEvent("aprts_horses:Client:sendAllComponents")
AddEventHandler("aprts_horses:Client:sendAllComponents", function(components)
    print("Dostal jsem komponenty!")
    HorseComp = components
    for _, category in pairs(HorseComp) do
        for i, comp in pairs(category) do
            -- print("Registrace eventu: ", "aprts_horses:Client:use_" .. comp.item)
            RegisterNetEvent("aprts_horses:Client:use_" .. comp.item)
            AddEventHandler("aprts_horses:Client:use_" .. comp.item, function(itemCategory)
                -- print("Používám item: ", comp.item)
                local playerPed = PlayerPedId()
                local currentHorse = GetMount(playerPed)
                local playerPos = GetEntityCoords(playerPed)
                -- print("Current Horse: ", currentHorse)
                if currentHorse == 0 then

                    local selectedEntity = exports["aprts_select"]:startSelecting(true)
                    local isHorse = IsThisModelAHorse(GetEntityModel(selectedEntity))
                    if selectedEntity ~= myHorse.ped then
                        notify("Nemůžeš použít komponentu na cizím koni", "COLOR_RED")
                        return
                    end
                    if isHorse > 0 then
                        local horsePos = GetEntityCoords(selectedEntity)
                        if Vdist(playerPos, horsePos) > 1.0 then
                            TaskGoToEntity(playerPed, selectedEntity, -1, 0.0, 1.0, 1073741824, 0)
                            Wait(1000)
                        end
                        ClearPedTasksImmediately(playerPed)
                        -- otoč hráče smerem na koně
                        TurnPlayerToEntity(playerPed, selectedEntity)

                        local Progressbar = exports["feather-progressbar"]:initiate()
                        Progressbar.start("Přidávám komponentu", Config.Animation.time + Config.Animation2.time,
                            function()
                            end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)',
                            'rgba(211, 11, 21, 0.5)')

                        RequestAnimDict(Config.Animation.dict)
                        while not HasAnimDictLoaded(Config.Animation.dict) do
                            Citizen.Wait(0)
                        end

                        TaskPlayAnim(PlayerPedId(), Config.Animation.dict, Config.Animation.name, 1.0, 1.0,
                            Config.Animation.time, Config.Animation.flag, 1.0, false, false, false)

                        Citizen.Wait(Config.Animation.time)
                        RemoveAnimDict(Config.Animation.dict)
                        StopAnimTask(PlayerPedId(), Config.Animation.dict, Config.Animation.name, 1.0)
                        ClearPedTasksImmediately(playerPed)

                        Citizen.Wait(100)

                        RequestAnimDict(Config.Animation2.dict)
                        while not HasAnimDictLoaded(Config.Animation2.dict) do
                            Citizen.Wait(0)
                        end
                        TaskPlayAnim(PlayerPedId(), Config.Animation2.dict, Config.Animation2.name, 1.0, 1.0,
                            Config.Animation2.time, Config.Animation2.flag, 1.0, false, false, false)

                        Citizen.Wait(Config.Animation2.time)
                        RemoveAnimDict(Config.Animation2.dict)
                        StopAnimTask(PlayerPedId(), Config.Animation2.dict, Config.Animation2.name, 1.0)

                        TriggerServerEvent("aprts_horses:Server:takeItem", comp.item)
                        equipComponent(selectedEntity, comp.hash)
                    else
                        notify("Tohle není kůň", "COLOR_RED")
                    end
                    return
                end
            end)
        end
    end
end)

breakedHorse = {
    horse = nil, -- PedOfHorse
    name = nil, -- NameOfHorse
    breed = nil, -- BreedOfHorse
    hash = nil -- HashOfHorse
}

local playerPed = PlayerPedId()

RegisterNetEvent('aprts_horses:deleteMount')
AddEventHandler('aprts_horses:deleteMount', function()
    local currentHorse = IsEntityAMissionEntity(GetMount(playerPed))
    if not currentHorse then
        local horsePed = GetEntityModel(GetMount(playerPed))
        DeletePed(horsePed)
    end
end)

function createVehicle(vehType, horse)
    dprint(vehType)
    local playerPed = PlayerPedId()
    local currentHorseModel = GetEntityModel(horse)
    local inPut1 = nil
    local breed = getHorseBreed(horse)
    local meta = getMetaTag(horse)
    dprint("Breed: ", breed)
    Citizen.CreateThread(function()
        AddTextEntry("FMMC_MPM_TYP8", "Name your horse:")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_TYP8", "", "Name", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0)
            Citizen.Wait(0)
        end
        if (GetOnscreenKeyboardResult()) then
            inPut1 = GetOnscreenKeyboardResult()
            print('Horse Hash?', currentHorseModel, inPut1)

            print("Horse with meta: ", meta)

            TriggerServerEvent('aprts_horses:newVehicle', currentHorseModel, vehType, inPut1, meta, breed)
            breakedHorse.name = inPut1
        end
    end)
end
local breaking = false
-- Event Listener
CreateThread(function()
    while true do
        Wait(0)
        local size = GetNumberOfEvents(0)
        if size > 0 then
            for i = 0, size - 1 do
                local event = Citizen.InvokeNative(0xA85E614430EFF816, 0, i) -- GetEventAtIndex
                if event == 218595333 then -- EVENT_HORSE_BROKEN
                    local eventDataSize = 3
                    local eventDataStruct = DataView.ArrayBuffer(128)
                    eventDataStruct:SetInt32(0, 0) -- Rider Ped Id                    
                    eventDataStruct:SetInt32(8, 0) -- Horse Ped Id
                    eventDataStruct:SetInt32(16, 0) -- Broken Type Id

                    local data = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize) -- GetEventData
                    if data then
                        if eventDataStruct:GetInt32(16) == 2 then -- Horse Taming Successful
                            if eventDataStruct:GetInt32(0) == PlayerPedId() then
                                breaking = false
                                breakedHorse.horse = eventDataStruct:GetInt32(8)
                                breakedHorse.breed = getHorseBreed(breakedHorse.horse)
                                breakedHorse.hash = GetEntityModel(breakedHorse.horse)
                                notify("Zkrotil jsi " .. breakedHorse.breed, "COLOR_GREEN")
                                TriggerServerEvent("aprts_horses:Server:tameHorseLog", breakedHorse.hash)
                            end
                        elseif eventDataStruct:GetInt32(16) == 1 then -- Horse Taming Failed
                            if eventDataStruct:GetInt32(0) == PlayerPedId() then
                                breaking = false
                                breakedHorse.horse = eventDataStruct:GetInt32(8)
                                breakedHorse.breed = getHorseBreed(breakedHorse.horse)
                                notify("Nepovedlo se ti zkrotit " .. breakedHorse.breed, "COLOR_RED")
                                breakedHorse.horse = nil
                            end
                        elseif eventDataStruct:GetInt32(16) == 0 then -- Horse Breaking Started
                            if eventDataStruct:GetInt32(0) == PlayerPedId() then
                                breaking = true
                                breakedHorse.horse = eventDataStruct:GetInt32(8)
                                if breakedHorse.horse then
                                    breakedHorse.breed = getHorseBreed(breakedHorse.horse)
                                    notify("Krotíš " .. breakedHorse.breed, "COLOR_GREEN")
                                end

                            end
                        else
                            -- print("Unknown Event", eventDataStruct:GetInt32(16))
                        end
                    end
                end
                if event == -503202760 then -- EVENT_HORSE_STARTED_BREAKING
                    debugPrint("Horse Breaking Started")
                    notify("Rodeo začalo! Mačkej E", "COLOR_GREEN")
                    breakedHorse = {
                        horse = nil, -- PedOfHorse
                        name = nil, -- NameOfHorse
                        breed = nil, -- BreedOfHorse
                        hash = nil -- HashOfHorse
                    }
                    breaking = true
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(300)
        while breaking do
            local isMounted = IsPedOnMount(PlayerPedId())
            local currentHorse = GetMount(PlayerPedId())

            local time = 4000
            local skillGapSent = 10
            -- Get time and skillgapset from HorseDifficulty by horse breed
            -- print("Finding Horse Difficulty for breed " .. breakedHorse.breed)
            for _, difficulty in pairs(HorseDifficulty) do
                -- print("Checking " .. _)
                if _ == breakedHorse.breed then
                    -- print("Found Horse Difficulty")
                    -- print("Setting to " .. difficulty.time .. " and " .. difficulty.skill)

                    time = difficulty.time
                    skillGapSent = difficulty.skill
                end
            end

            local test = exports["syn_minigame"]:taskBar(time, skillGapSent) -- speed,skillGapSent

            if test == 0 or not isMounted or not currentHorse then
                breaking = false
                HorseAgitate(currentHorse, true)
                notify("Nepodařilo se ti zlomit " .. breakedHorse.breed, "COLOR_RED")
            end

            if currentHorse == 0 then
                breaking = false
                notify("Nepodařilo se ti zlomit " .. breakedHorse.breed, "COLOR_RED")
                break
            end
            Wait(100)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local currentHorse = GetMount(PlayerPedId())

    end
end)
