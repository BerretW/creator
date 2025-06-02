RegisterCommand("hunt", function(source, args, rawCommand)
    if LocalPlayer.state.Character.Group == "admin" then
        print('args', args)
        local animal = args[1]
        local freeze = args[2]
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)

        if animal == nil then
            animal = 'a_c_deer_01'
        end



        if freeze == nil then
            freeze = true
        else
            freeze = false
        end



        RequestModel(animal)
        while not HasModelLoaded(animal) do
            Wait(10)
        end

        animal = CreatePed(animal, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, animal, 1, 0)
        Wait(1000)
        FreezeEntityPosition(animal, freeze)
    else
        print('You are not allowed to use this command')
        
    end
end, false)

if Config.Debug == true then

    -- function SetEntityHealthToMax(entity, health)
    --     local maxHealthValue = tonumber(health)
    --     if DoesEntityExist(entity) and not IsPedAPlayer(entity) then
    --         -- Získej aktuální zdraví entity
    --         print('Entity health', GetEntityHealth(entity))
    --         local currentHealth = GetEntityHealth(entity)

    --         -- Pokud je zdraví nižší než požadované, nastav ho

    --         SetEntityHealth(entity, maxHealthValue)
    --         print('Entity health', GetEntityHealth(entity))

    --     end
    -- end

    -- RegisterCommand("huntHP", function(source, args, rawCommand)
    --     local animal = nil
    --     local player = PlayerPedId()
    --     local playerCoords = GetEntityCoords(player)

    --     animal = 'a_c_deer_01'

    --     RequestModel(animal)
    --     while not HasModelLoaded(animal) do
    --         Wait(10)
    --     end

    --     animal = CreatePed(animal, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    --     Citizen.InvokeNative(0x77FF8D35EEC6BBC4, animal, 1, 0)

    --     Citizen.Wait(1000)
    --     FreezeEntityPosition(animal, true)
    --     SetEntityHealthToMax(animal, args[1])

    -- end, false)

    RegisterCommand("hunth", function(source, args, rawCommand)
        local animal = tonumber(args[1])
        local freeze = args[2]
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        print('animal', animal)
        if animal == nil then
            animal = 'a_c_deer_01'
        end

        if freeze == nil then
            freeze = '1000'
        end

        freeze = tonumber(freeze)

        RequestModel(animal)
        while not HasModelLoaded(animal) do
            Wait(10)
        end

        animal = CreatePed(animal, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, animal, 1, 0)
        Wait(freeze)
        FreezeEntityPosition(animal, true)
    end, true)

    RegisterCommand('animal', function(source, args, rawCommand)
        local ped = PlayerPedId()
        local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
        local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
        local model = GetEntityModel(holding)
        local type = GetPedType(holding)
        local hash = GetHashKey(holding)

        print('holding', holding)
        print('quality', quality)
        print('model', model)
        print('type', type)
        print('hash', hash)

    end, true)
    RegisterCommand('animaloutfit', function(source, args, rawCommand)
        local ped = PlayerPedId()
        local holding
        if args[2] == nil then
            holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
        else
            holding = tonumber(args[2])
        end

        local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
        local model = GetEntityModel(holding)
        local type = GetPedType(holding)
        local hash = GetHashKey(holding)
        print('Original outfit ', GetPedMetaOutfitHash(holding))
        print('holding', holding)
        print('quality', quality)
        print('model', model)
        print('type', type)
        print('hash', hash)
        EquipMetaPedOutfit(holding, tonumber(args[1]))
        UpdatePedVariation(holding, 0, 0, 0, 2)
        print('outfit ', GetPedMetaOutfitHash(holding))

    end, true)
end
