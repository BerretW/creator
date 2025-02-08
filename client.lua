local sleeping = {}

Citizen.CreateThread(function()
    while not LocalPlayer.state.IsInSession do
        Citizen.Wait(1000)
    end
    -- print("Waking up")
    TriggerServerEvent('aprts_sleepRP:server:WakeUp')
    TriggerEvent("aprts_sleepRP:client:RemoveNPC", LocalPlayer.state.Character.CharId)
end)
function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function debugPrint(msg)
    if Config.Debug == true then
        print(msg)
    end
end
local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end

function spawnNPCs(model, x, y, z, h)
    if model == false then
        model = "mp_male"
    end
    if h == nil then
        h = 0.0
    end
    LoadModel(model)

    local npc_ped = CreatePed(model, x, y, z - 1.0, h, false, false, false, false)
    -- SetRemovePedNetworked(npc_ped)
    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    local animDict = "amb_rest@world_human_sleep_ground@arm@male_b@base"
    local animBody = "base"
    RequestAnimDict(animDict)
    local timeout = 20
    while (not HasAnimDictLoaded(animDict) and timeout > 0) do
        timeout = timeout - 1
        if timeout == 0 then
            print("Animation Failed to Load")
        end
        Citizen.Wait(300)
    end
    TaskPlayAnim(npc_ped, animDict, animBody, 1.0, 1.0, 5000.0, 1, 1, false, false, false, 0, true)

    -- TaskStartScenarioInPlace(npc_ped, GetHashKey("PROP_CAMP_BILL_SLEEP"), 0, true, false, false, false)

    -- SetEntityCoords(npc_ped, x, y, z-1.0)
    -- SetEntityHeading(npc_ped, h)
    SetEntityCanBeDamaged(npc_ped, false)
    SetEntityInvincible(npc_ped, true)
    FreezeEntityPosition(npc_ped, true)
    SetBlockingOfNonTemporaryEvents(npc_ped, true)
    SetModelAsNoLongerNeeded(model)
    -- SetEntityAsMissionEntity(npc_ped, false, false)
    -- print("NPC spawned")
    return npc_ped
end

RegisterNetEvent('aprts_sleepRP:client:recieve')
AddEventHandler('aprts_sleepRP:client:recieve', function(serversleepers)
    -- print("Recieved sleepers" .. table.count(serversleepers))
    debugPrint("Recieved sleepers" .. table.count(serversleepers))
    sleeping = serversleepers
end)

RegisterNetEvent('aprts_sleepRP:client:addSleeper')
AddEventHandler('aprts_sleepRP:client:addSleeper', function(charID, coords, gender, meta)
    -- print(json.encode(coords))
    debugPrint("Adding new Sleeper " .. charID)
    sleeping[charID] = {
        coords = coords,
        charid = charID,
        meta = meta,
        gender = gender
    }

end)

RegisterNetEvent('aprts_sleepRP:client:update')
AddEventHandler('aprts_sleepRP:client:update', function(charID, coords)
    -- print("Updating Sleeper " .. charID)
    debugPrint("Updating Sleeper " .. charID)
    if sleeping[charID] == nil then
        debugPrint("Sleeper " .. charID .. " not found")
        return
    end
    sleeping[charID].coords = coords
    if DoesEntityExist(sleeping[charID].NPC) then
        DeleteEntity(sleeping[charID].NPC)
        SetModelAsNoLongerNeeded(GetHashKey(sleeping[charID].model))
    end
end)

RegisterNetEvent('aprts_sleepRP:client:RemoveNPC')
AddEventHandler('aprts_sleepRP:client:RemoveNPC', function(charID)
    Citizen.Wait(1000)
    debugPrint("Removing NPC " .. charID)
    while not LocalPlayer.state.IsInSession do
        Citizen.Wait(1000)
    end

    if sleeping[charID] == nil then
        return
    end

    if DoesEntityExist(sleeping[charID].NPC) then
        -- print("Deleting NPC")
        DeleteEntity(sleeping[charID].NPC)
        SetModelAsNoLongerNeeded(GetHashKey(sleeping[charID].model))
    end
    sleeping[charID] = nil

end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        while table.count(sleeping) < 1 do
            Citizen.Wait(1000)
            -- print("No sleepers")
        end
        for k, sleeper in pairs(sleeping) do
            -- print(json.encode(sleeper.coords), "ID: " .. sleeper.charid)

            local pcoords = GetEntityCoords(PlayerPedId())
            -- print(json.encode(pcoords))
            local dist = GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, sleeper.coords.x, sleeper.coords.y,
                sleeper.coords.z, false)
            sleeper.model = Config.DefaultMale

            if sleeper.gender == "Female" then
                sleeper.model = Config.DefaultFemale
            end

            -- print("Distance: " .. dist)
            if dist < Config.RenderDistance and not DoesEntityExist(sleeper.NPC) and not NetworkIsInTutorialSession() then

                sleeper.NPC = spawnNPCs(sleeper.model, sleeper.coords.x, sleeper.coords.y, sleeper.coords.z, 0.0)
                -- print("Spawning NPC for " .. sleeper.charid .. ", " .. sleeper.NPC)
                if sleeper.meta == nil then
                    -- print("Sleeper Meta is nil")
                    sleeper.meta = {}
                end
                while not DoesEntityExist(sleeper.NPC) do
                    Wait(10)
                end
                ResetPedComponents(sleeper.NPC)
                for i, data in pairs(sleeper.meta) do
                    local category = GetPedComponentCategoryByIndex(sleeper.NPC, tonumber(i))

                    SetMetaPedTag(sleeper.NPC, data.drawable, data.albedo, data.normal, data.material, data.palette,
                        data.tint0, data.tint1, data.tint2)
                end
                UpdatePedVariation(sleeper.NPC, 0, 1, 1, 1, false)

            elseif (dist > Config.RenderDistance and DoesEntityExist(sleeper.NPC)) or NetworkIsInTutorialSession() then
                if DoesEntityExist(sleeper.NPC) then
                    -- print("Deleting NPC")
                    DeleteEntity(sleeper.NPC)
                    SetModelAsNoLongerNeeded(GetHashKey(sleeper.model))
                end
                sleeper.NPC = nil
            end
        end
    end
end)

AddEventHandler("onClientResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        while not LocalPlayer.state.IsInSession do
            Citizen.Wait(1000)
        end
        debugPrint("Requesting Sleepers")
        TriggerServerEvent('aprts_sleepRP:server:getSleepingPlayers')
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        -- print(#sleeping)
        for k, sleeper in pairs(sleeping) do
            -- print(k)
            -- print("Removing NPC " .. sleeper.NPC)
            DeleteEntity(sleeper.NPC)
            SetModelAsNoLongerNeeded(GetHashKey(sleeper.model))
            -- table.remove(sleeping, k)
        end
    end
end)

function getMetaTag(entity)
    -- print("GetMetaTag")
    local metatag = {}
    local numComponents = GetNumComponentsInPed(entity)

    -- print("Num components: ", numComponents)
    -- print("Num catagories: ", GetNumComponentCategoriesInPed(entity))
    for i = 0, numComponents - 1, 1 do
        local index, drawable, albedo, normal, material = GetMetaPedAssetGuids(entity, i)
        local iindex, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(entity, i)
        -- print(GetPedComponentCategoryByIndex(entity, i))
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
        -- dprint(drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end
    return metatag
end

RegisterCommand(Config.RemoveSleeperCommand, function(source, args, rawCommand)
    local pcoords = GetEntityCoords(PlayerPedId())
    if LocalPlayer.state.Character.Job == Config.RemoveSleeperCommandJob then
        for _, sleeper in pairs(sleeping) do
            local distance = Vdist(pcoords, sleeper.coords.x, sleeper.coords.y, sleeper.coords.z)
            -- print("Distance: " .. distance)
            if distance < 5.0 then
                -- print("Removing Sleeper " .. sleeper.charid)
                TriggerServerEvent('aprts_sleepRP:server:WakeUpSleeper', sleeper.charid)
            end
        end
    end
end)

RegisterCommand("uklidit", function(source, args, rawCommand)
    local pcoords = GetEntityCoords(PlayerPedId())

    if LocalPlayer.state.Character.Job == Config.RemoveSleeperCommandJob then
        local ped = exports["aprts_select"]:startSelecting(true)
        local sleeper = nil

        -- Filtrace spících NPC
        for _, k in pairs(sleeping) do
            if k.NPC == ped then
                sleeper = k
            end
        end

        if sleeper then
            local motels = {}

            -- Vytvoření seznamu motelů s výpočtem vzdálenosti
            for _, motel in ipairs(Config.Motels) do
                table.insert(motels, {
                    motel = motel,
                    distance = Vdist(pcoords, motel.coords.x, motel.coords.y, motel.coords.z),
                    beds = motel.beds
                })
            end

            -- Seřazení motelů podle vzdálenosti od hráče
            table.sort(motels, function(a, b)
                return a.distance < b.distance
            end)

            -- Procházení motelů podle vzdálenosti
            for _, motel in ipairs(motels) do
                debugPrint("Procházím motel " .. motel.motel.name)
                local freeBed = nil

                for _, bed in ipairs(motel.beds) do
                    -- Kontrola, zda je postel volná
                    local bedOccupied = false
                    for _, k in pairs(sleeping) do
                        if bed.coords == k.coords then
                            bedOccupied = true
                            break
                        end
                    end

                    if not bedOccupied then
                        freeBed = bed.coords
                        break
                    end
                end

                if freeBed ~= nil then
                    local name = LocalPlayer.state.Character.FirstName .. " " .. LocalPlayer.state.Character.LastName
                    TriggerServerEvent('aprts_sleepRP:server:log', name, "Uklidil spáče :" .. sleeper.charid ..
                        " do postele na " .. json.encode(freeBed), "SleepRP")

                    TriggerServerEvent('aprts_sleepRP:server:updateSleeper', sleeper, freeBed)

                    debugPrint("Spáč " .. sleeper.charid .. " obsadil postel na " .. json.encode(freeBed))
                    return
                else
                    debugPrint("Postele v " .. motel.motel.name .. " jsou obsazené, posílám do dalšího")
                end
            end

            debugPrint("Všechny postele jsou obsazené")
        else
            debugPrint("Není vybrán žádný spící NPC")
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        while not LocalPlayer.state.IsInSession do
            Citizen.Wait(1000)
        end
        debugPrint("Sending Meta")
        TriggerServerEvent('aprts_sleepRP:server:getMeta', LocalPlayer.state.Character.CharId,
            json.encode(getMetaTag(PlayerPedId())))
    end
end)
