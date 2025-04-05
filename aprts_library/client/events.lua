AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    -- TriggerServerEvent("aprts_clue:Server:LoadClues")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    -- FreezeEntityPosition(PlayerPedId(), false)
    -- for k, v in pairs(Clues) do
    --     if DoesEntityExist(v.obj) then
    --         print("Ukončuji resource, mažu stopu: " .. v.id)
    --         DeleteEntity(v.obj)
    --     end
    -- end
end)


-- RegisterNetEvent('aprts_farming:Client:playAnim')
-- AddEventHandler('aprts_farming:Client:playAnim', function(anim)
--     local playerPed = PlayerPedId()
--     local prop = equipProp(anim.prop.model, anim.prop.bone, anim.prop.coords)
--     playAnim(playerPed,anim.dict, anim.name, anim.flag, anim.time)
--     if DoesEntityExist(prop) then
--         DeleteEntity(prop)
--     end
-- end)