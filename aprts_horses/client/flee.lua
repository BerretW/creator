function fleeHorse(horse)
    if horse ~= 0 then
        -- DeletePed(horse)
        TriggerServerEvent("aprts_horses:stableHorse", myHorse.id)
        myHorse = {}
        TaskFleePed(horse, PlayerPedId(), 3, 0, -1.0, -1, 0)
        Citizen.Wait(2000)

        DeletePed(horse)
    end

end

Citizen.CreateThread(function()
    while true do
        local pause = 3000
        local horse = nil
        -- chceck distance between myHorse and player
        if myHorse.ped ~= 0 then
            horse = myHorse.ped
            RemoveBlip(myHorse.Blip)
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local horsePos = GetEntityCoords(horse)
            local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, horsePos.x, horsePos.y, horsePos.z)
            if distance < 4.0 then
                pause = 0
                if IsDisabledControlJustPressed(0, 0x4216AF06) then -- Control = Horse Flee
                    
                    TriggerServerEvent("aprts_horses:stableHorse", myHorse.id)

                    TaskFleePed(horse, playerPed, 3, 0, -1.0, -1, 0)
                    myHorse = {}
                    Citizen.Wait(2000)
                    
                    DeletePed(horse)

                end
            end
        end
        Citizen.Wait(pause)
    end
end)
Citizen.CreateThread(function()
    while true do
        local pause = 30000
        local horse = nil
        -- chceck distance between myHorse and player
        local coords = GetEntityCoords(PlayerPedId())
        local horseCoords = GetEntityCoords(myHorse.ped)
        local distance = Vdist(coords.x, coords.y, coords.z, horseCoords.x, horseCoords.y, horseCoords.z)
        if distance < 150.0 then
            myHorse = {}
            
        end
        if DoesEntityExist(myHorse.ped) == true then

            TriggerEvent("aprts_horses:updateAttributes", myHorse.id, myHorse.ped, myHorse.shoed)
        else
            myHorse = {}
        end
        Citizen.Wait(pause)
    end
end)
