wagons = {}
cargos = {}
ShippingPosts = {}

mywagon = nil
mycargo = nil
holding = false
crate = {}
crate.obj = nil
crate.butcherID = nil
blip = nil
blips = {}

function notify(text)
    TriggerEvent('notifications:notify', "Brigáda pro řezníka", text, 3000)
end


function drawMarker(x, y, z)
    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, x, y, z - 1.0, 0, 0, 0, 0, 0, 0, Config.interactDistance + 1,
        Config.interactDistance + 1, 1.4, 100, 250, 150, 200, 0, 0, 2, 0, 0, 0, 0)
end

function CreateBlip(coords, sprite, scale, name)
    print("Creating Blip: ")
    local blip = BlipAddForCoords(1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite, 1)
    SetBlipScale(blip, scale)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, name)
    return blip
end

function DrawText3D(x, y, z, text, color)
    if not color then
        color = {250, 250, 250, 250}
    end
    -- color = {100, 100, 250, 250}
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (2 / dist) * 1.1

    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local fov = (2 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.13 * scale, 0.13 * scale)
        SetTextFontForCurrentCommand(1)
        SetTextColor(color[1], color[2], color[3], color[4])
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 355
        -- DrawSprite("generic_textures", "hud_menu_4a", _x, _y + 0.0125, 0.015 + factor, 0.1, 0.1, 35, 35, 35, 220, 0)
        -- DrawSprite("feeds", "toast_bg", _x + 0.01 * (scale / 2), _y + 0.0115 * (scale / 2), (0.0155 + factor) * scale,
        --     0.02 * scale, 0.1, 1, 1, 1, 10, 0)
    end
end

function createRoute(coords)
    -- StartGpsMultiRoute(6, true, true)
    -- AddPointToGpsMultiRoute(coords.x, coords.y, coords.z, true)
    -- SetGpsCustomRouteRender(true)

    SetWaypointOff()
    Wait(100)
    ClearGpsMultiRoute()
    StartGpsMultiRoute(GetHashKey("COLOR_RED"), true, true)
    AddPointToGpsMultiRoute(coords.x, coords.y, coords.z)
    SetGpsMultiRouteRender(true)
end

function spawnWagon(coords)
    local ped = PlayerPedId()
    local car_start = GetEntityCoords(ped)
    local car_name = "wagon04x"
    local carHash = GetHashKey(car_name)
    RequestModel(carHash)

    while not HasModelLoaded(carHash) do
        Citizen.Wait(10)
    end

    local car = CreateVehicle(carHash, coords.x, coords.y, coords.z, 176.3, true, false)
    SetVehicleOnGroundProperly(car)
    Wait(200)
    -- SetPedIntoVehicle(ped, car, -1)
    AddPropSetForVehicle(car, GetHashKey(Config.PropSet))
    SetModelAsNoLongerNeeded(carHash)
    modeltodelete = car
    return car
end

function spawnCargo(coords, model)
    print("Spawning " .. model .. " Cargo at " .. coords.x .. " " .. coords.y .. " " .. coords.z)
    local hash = GetHashKey(model)
    RequestModel(hash)

    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
    end

    local cargo = CreateObject(hash, coords.x, coords.y, coords.z, true, false, false)
    local groundZ = 0.0
    for height = 1, 1000 do
        foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, height + 0.0)
        if foundGround then
            print('FOUND GROUND!: ' .. groundZ)
            break
        end
    end
    SetEntityCoords(cargo, coords.x, coords.y, groundZ, 0.0, 0.0, 0.0, false)
    SetModelAsNoLongerNeeded(hash)
    return cargo
end
-- GetEntityCoords

local function allGood(ped)
    if IsPedAPlayer(ped) and not IsPedOnMount(ped) and not IsPedOnVehicle(ped) and IsPedOnFoot(ped) then
        return true
    else
        return false
    end
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for _, wagon in pairs(wagons) do
            local coords = wagon.coords
            local distance = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, false)

            if distance < Config.interactDistance and allGood(ped) then
                if holding then
                    pause = 0
                    DrawText3D(coords.x, coords.y, coords.z,
                        "Zmáčkni ~g~" .. Config.KeyLabel .. "~w~ pro naložení bedny " .. wagon.count,
                        {255, 255, 255, 255})
                    if IsControlJustPressed(0, Config.Key) then
                        holding = false
                        UnEquipTool()
                        EndAnimation(Config.Animation)
                        TriggerServerEvent('aprts_hunting_job:Server:putBox', wagon.obj)
                    end
                else
                    if wagon.count > 0 then
                        pause = 0
                        DrawText3D(coords.x, coords.y, coords.z,
                            "Zmáčkni ~g~" .. Config.KeyLabel .. "~w~ pro vyložení bedny " .. wagon.count,
                            {255, 255, 255, 255})
                        if IsControlJustPressed(0, Config.Key) then
                            holding = true
                            crate.butcherID = wagon.butcherID

                            EquipTool(Config.Animation.prop)
                            StartAnimation(Config.Animation)

                            TriggerServerEvent('aprts_hunting_job:Server:takeBoxFromWagon', wagon.obj)
                        end
                    else
                        pause = 0
                        DrawText3D(coords.x, coords.y, coords.z,
                            "Zmáčkni ~g~" .. Config.KeyLabel .. "~w~ pro uklizení vozu ", {255, 255, 255, 255})
                        if IsControlJustPressed(0, Config.Key) then
                            holding = false
                            UnEquipTool()
                            EndAnimation(Config.Animation)
                            TriggerServerEvent('aprts_hunting_job:Server:deleteWagon', mywagon)
                            TriggerServerEvent("aprts_hunting_job:Server:deleteCargo", mycargo)
                            if mywagon then
                                DeleteEntity(mywagon)
                                ClearGpsMultiRoute()
                                SetGpsMultiRouteRender(false)
                                mywagon = nil
                            end
                            if mycargo then
                                DeleteEntity(mycargo)
                                mycargo = nil
                            end

                        end
                    end
                end
            else
                -- print(distance)
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for _, cargo in pairs(cargos) do
            local coords = cargo.coords
            local distance = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, false)

            if distance < Config.interactDistance and not holding and allGood(ped) then
                pause = fpsTimer()

                drawMarker(coords.x, coords.y, coords.z)
                DrawText3D(coords.x, coords.y, coords.z,
                    "Zmáčkni ~g~" .. Config.KeyLabel .. "~w~ a vem krabici " .. cargo.count, {255, 255, 255, 255})
                if IsControlJustPressed(0, Config.Key) then
                    crate.butcherID = nil
                    -- crate.obj = 
                    holding = true
                    EquipTool(Config.Animation.prop)
                    StartAnimation(Config.Animation)
                    TriggerServerEvent('aprts_hunting_job:Server:takeBox', cargo.obj)
                end
            else
                -- print(distance)
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        if mywagon then

            local coords = GetEntityCoords(mywagon)
            -- print("Updating Wagon " .. mywagon .. " Position: " .. json.encode(coords))
            TriggerServerEvent('aprts_hunting_job:Server:updateWagonCoords', mywagon, coords)
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    for _, jobmaster in pairs(Config.JobPost) do
        if jobmaster.showblip then
            local blip = CreateBlip(jobmaster.coords, jobmaster.blipsprite, jobmaster.blipscale, jobmaster.name)
            table.insert(blips, blip)
        end
    end
end)
