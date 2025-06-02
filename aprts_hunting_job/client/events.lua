AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("Stopping Butcher Job")
        if mywagon then
            TriggerServerEvent('aprts_hunting_job:Server:deleteWagon', mywagon)
        end
        if mycargo then
            TriggerServerEvent("aprts_hunting_job:Server:deleteCargo", mycargo)
        end 
        for k, v in pairs(Config.JobPost) do
            if DoesEntityExist(v.npc) then
                print("Deleting Job Master")
                DeleteEntity(v.npc)
            end

        end
        for _, wagon in pairs(wagons) do
            if DoesEntityExist(wagon.obj) then
                print("Deleting Wagon")
                RemoveVehiclePropSets(wagon.obj)
                DeletePropSet(GetVehiclePropSet(wagon.obj))
                DeleteEntity(wagon.obj)
            end
        end
        for _, cargo in pairs(cargos) do
            if DoesEntityExist(cargo.obj) then
                print("Deleting Cargo")
                DeleteEntity(cargo.obj)
            end
        end
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end
        RemoveBlip(blip)
        ClearGpsMultiRoute()
        SetGpsMultiRouteRender(false)
        SetGpsCustomRouteRender(false)

    end
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("Starting Butcher Job")
        TriggerServerEvent('aprts_hunting_job:Server:loadWagons')
        TriggerServerEvent('aprts_hunting_job:Server:loadCargos')
        TriggerServerEvent('aprts_hunting_job:Server:LoadShipments')
    end
end)

RegisterNetEvent('aprts_hunting_job:Client:newWagon')
AddEventHandler('aprts_hunting_job:Client:newWagon', function(wagon)
    wagons[wagon.obj] = {}
    wagons[wagon.obj] = wagon
    print(json.encode(wagons[wagon.obj]))
end)

RegisterNetEvent('aprts_hunting_job:Client:newCargo')
AddEventHandler('aprts_hunting_job:Client:newCargo', function(cargo)
    cargos[cargo.obj] = {}
    cargos[cargo.obj] = cargo
    print(json.encode(cargos[cargo.obj]))
end)

RegisterNetEvent('aprts_hunting_job:Client:putBox')
AddEventHandler('aprts_hunting_job:Client:putBox', function(wagon)
    wagons[wagon.obj] = wagon
end)

RegisterNetEvent('aprts_hunting_job:Client:takeBoxFromWagon')
AddEventHandler('aprts_hunting_job:Client:takeBoxFromWagon', function(wagon)
    wagons[wagon.obj] = wagon
end)

RegisterNetEvent('aprts_hunting_job:Client:takeBox')
AddEventHandler('aprts_hunting_job:Client:takeBox', function(cargo)
    cargos[cargo.obj] = cargo
    if cargos[cargo.obj].count <= 0 then
        DeleteEntity(cargos[cargo.obj].obj)
        cargos[cargo.obj] = nil
    end
end)

RegisterNetEvent('aprts_hunting_job:Client:deleteCargo')
AddEventHandler('aprts_hunting_job:Client:deleteCargo', function(cargo)
    if DoesEntityExist(cargo) then
        DeleteEntity(cargo)
    end
    if cargo == mycargo then
        mycargo = nil
    end
    cargos[cargo] = nil
end)

RegisterNetEvent('aprts_hunting_job:Client:loadWagons')
AddEventHandler('aprts_hunting_job:Client:loadWagons', function(serverWagons)
    wagons = serverWagons
    -- print(json.encode(wagons))
end)

RegisterNetEvent('aprts_hunting_job:Client:loadCargos')
AddEventHandler('aprts_hunting_job:Client:loadCargos', function(serverCargos)
    cargos = serverCargos
    -- print(json.encode(cargos))
end)

RegisterNetEvent('aprts_hunting_job:Client:LoadShipments')
AddEventHandler('aprts_hunting_job:Client:LoadShipments', function(shipments)
    ShippingPosts = shipments
    -- print(json.encode(shipments))
end)

RegisterNetEvent('aprts_hunting_job:Client:updateWagonCoords')
AddEventHandler('aprts_hunting_job:Client:updateWagonCoords', function(wagon, coords)
    wagons[wagon].coords = coords
end)

RegisterNetEvent('aprts_hunting_job:Client:deleteWagon')
AddEventHandler('aprts_hunting_job:Client:deleteWagon', function(wagon)
    wagons[wagon] = nil
    if wagon == mywagon then
        if DoesEntityExist(wagon) then
            DeleteEntity(wagon)
        end
    end

end)

RegisterNetEvent('aprts_hunting_job:Client:updateShipment')
AddEventHandler('aprts_hunting_job:Client:updateShipment', function(shipment)
    ShippingPosts[shipment.id] = shipment
end)
