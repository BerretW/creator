local function getFPS()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime
    return frame
end

function fpsTimer()
    local minFPS = 15
    local maxFPS = 165
    local minSpeed = 0
    local maxSpeed = 15
    local coefficient = 1 - (getFPS() - minFPS) / (maxFPS - minFPS)
    return minSpeed + coefficient * (maxSpeed - minSpeed)
end

local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end

local function spawnNPCs(model, x, y, z, h, scenario, outfit, weapon)

    LoadModel(model)

    local npc_ped = CreatePed(model, x, y, z, h, false, true, true, true)

    if outfit then
        SetPedOutfitPreset(npc_ped, outfit)
    else
        Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    end

    if weapon then
        GiveWeaponToPed_2(npc_ped, GetHashKey(weapon), 10, true, true, 1, false, 0.5, 1.0, 1.0, true, 0, 0)
        SetCurrentPedWeapon(npc_ped, GetHashKey(weapon), true, 0, false, false)
    end

    if scenario then
        TaskStartScenarioInPlace(npc_ped, GetHashKey(scenario), 0, true, false, false, false)
    else
        TaskStartScenarioInPlace(npc_ped, GetHashKey("GENERIC_STANDING_SCENARIO"), 0, true, false, false, false)
    end

    PlaceEntityOnGroundProperly(npc_ped)

    if h == nil then
        h = 0.0
    end

    SetEntityHeading(npc_ped, h)
    SetEntityCanBeDamaged(npc_ped, false)
    SetEntityInvincible(npc_ped, true)
    FreezeEntityPosition(npc_ped, true)
    SetBlockingOfNonTemporaryEvents(npc_ped, true)
    SetModelAsNoLongerNeeded(model)
    -- SetEntityAsMissionEntity(npc_ped, true, true)
    return npc_ped
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for _, v in pairs(Config.JobPost) do
            local distance = GetDistanceBetweenCoords(pedCoords, v.coords.x, v.coords.y, v.coords.z, false)
            if distance < Config.Drawdistance then
                if not DoesEntityExist(v.npc) then
                    v.npc = spawnNPCs(v.model, v.coords.x, v.coords.y, v.coords.z, v.npcH, nil, nil, nil)
                end
            else
                if DoesEntityExist(v.npc) then
                    DeleteEntity(v.npc)
                    v.npc = nil
                end
            end
            distance = GetDistanceBetweenCoords(pedCoords, v.coords.x, v.coords.y, v.coords.z, false)
            if distance < Config.interactDistance and mywagon == nil then
                pause = fpsTimer()
                DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[" .. Config.KeyLabel .. "]Začít vývoz",
                    {255, 255, 255, 255})
                if IsControlJustPressed(0, Config.Key) then
                    notify("Začínáš vývoz zvěřiny od řezníka")
                    notify("Nalož tyhle bedny a odvez je na místo, který sem ti namaloval do mapy!")
                    createRoute(v.targetCoords)
                    blip = CreateBlip(v.targetCoords, v.blipsprite, v.blipscale, v.name)
                    mywagon = spawnWagon(v.vagonCoords)
                    mycargo = spawnCargo(v.cargoCoords, v.cargoModel)
                    TriggerServerEvent('aprts_hunting_job:Server:newWagon', mywagon, v.vagonCoords, v.butcherID)
                    TriggerServerEvent('aprts_hunting_job:Server:newCargo', mycargo, v.cargoCoords)

                end
            end

        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        while #ShippingPosts < 1 do
            Citizen.Wait(1000)
        end
        local pause = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for _, v in pairs(ShippingPosts) do
            local distance = GetDistanceBetweenCoords(pedCoords, v.coords.x, v.coords.y, v.coords.z, false)
            if distance < Config.Drawdistance and mywagon ~= nil then
                pause = fpsTimer()
                drawMarker(v.coords.x, v.coords.y, v.coords.z)
            end
            if distance < Config.interactDistance and holding then
                if crate.butcherID then
                    pause = fpsTimer()
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[" .. Config.KeyLabel .. "]Prodat bednu",
                        {255, 255, 255, 255})
                    if IsControlJustPressed(0, Config.Key) then
                        UnEquipTool()
                        EndAnimation(Config.Animation)
                        TriggerServerEvent('aprts_hunting_job:Server:sellBox', crate.butcherID)
                        TriggerServerEvent('aprts_hunting_job:Server:putToShipment', v.id)
                        holding = false
                        crate.butcherID = nil
                    end
                else
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "Nemáš bednu kterou bys prodal",
                        {255, 255, 255, 255})
                end
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        while #ShippingPosts < 1 do
            Citizen.Wait(1000)
        end
        local pause = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for _, post in pairs(ShippingPosts) do
            local distance = GetDistanceBetweenCoords(pedCoords, post.coords.x, post.coords.y, post.coords.z, false)
            distance = GetDistanceBetweenCoords(pedCoords, post.coords.x, post.coords.y, post.coords.z, false)
            if distance < Config.interactDistance and not holding then
                pause = fpsTimer()
                DrawText3D(post.coords.x, post.coords.y, post.coords.z,
                    "Je tu uloženo: " .. post.count .. " beden zboží", {255, 255, 255, 255})
            end
        end
        Citizen.Wait(pause)
    end
end)
