function fleeHorse(horse)
    if horse ~= 0 then
        DeletePed(horse)
        TriggerServerEvent("aprts_horses:stableHorse", myHorse.id)
        TriggerEvent("aprts_horses:updateAttributes", myHorse.id, myHorse.ped, myHorse.shoed)
        myHorse = {}
    end

end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
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

                if IsDisabledControlJustPressed(0, 0x4216AF06) then -- Control = Horse Flee
                    -- TriggerServerEvent("aprts_horses:Server:fleeHorse", myHorse.id)
                    TriggerServerEvent("aprts_horses:stableHorse", myHorse.id)
                    TriggerEvent("aprts_horses:updateAttributes", myHorse.id, myHorse.ped,myHorse.shoed)
                    TaskFleePed(horse, playerPed, 3, 0, -1.0, -1, 0)
                    Citizen.Wait(2000)
                    DeletePed(horse)
                    myHorse = {}
                end
            end
        end
    end
end)

RegisterNetEvent("aprts_horses:Client:fleeHorse")
AddEventHandler("aprts_horses:Client:fleeHorse", function(horseID)
    if myHorse.id == horseID then
        fleeHorse(myHorse.ped)
        TriggerServerEvent("aprts_horses:stableHorse", myHorse.id)
        TriggerEvent("aprts_horses:updateAttributes", myHorse.id, myHorse.ped, myHorse.shoed)
        TaskFleePed(horse, playerPed, 3, 0, -1.0, -1, 0)
        Citizen.Wait(2000)
        DeletePed(horse)
        myHorse = {}
    end
end)
