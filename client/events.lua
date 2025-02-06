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
    FreezeEntityPosition(PlayerPedId(), false)
    DoScreenFadeIn(1000)
    if Camera then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(Camera, false)
        Camera = nil
    end
    -- local retval , hour, minute, second =NetworkGetGlobalClock()
    -- NetworkClockTimeOverride(hour, minute, second, 0, false)
    -- NetworkEndTutorialSession()
    TriggerServerEvent("murphy_clothing:instanceplayers", 0)
    if DoesEntityExist(NPC) then
        DeleteEntity(NPC)
        NPC = nil
    end
    
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