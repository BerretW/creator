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

