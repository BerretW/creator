AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    while LocalPlayer == nil do
        Wait(100)
    end
    while LocalPlayer.state == nil do
        Wait(100)
    end
    while LocalPlayer.state.Character == nil do
        Wait(100)
    end
    TriggerServerEvent("aprts_medicalAtention:Server:getIllness")
    TriggerServerEvent("aprts_medicalAtention:Server:getClothes")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    FreezeEntityPosition(PlayerPedId(), false)
    for _, doctor in pairs(Config.NPC) do
        if DoesEntityExist(doctor.obj) then
            DeleteEntity(doctor.obj)
        end
    end
    -- for k, v in pairs(Clues) do
    --     if DoesEntityExist(v.obj) then
    --         print("Ukončuji resource, mažu stopu: " .. v.id)
    --         DeleteEntity(v.obj)
    --     end
    -- end
end)

RegisterNetEvent("aprts_medicalAtention:Client:GetIllness")
AddEventHandler("aprts_medicalAtention:Client:GetIllness", function(illness)

    local bandada = LocalPlayer.state.IsBandanaOn
    print(bandada)
    if bandada then
        debugPrint("Nemůžeš se nakazit když máš bandanou")
    else
        playerIllness = illness
        TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick", playerIllness)
    end
end)

RegisterNetEvent("aprts_medicalAtention:Client:GetPlayerIllness")
AddEventHandler("aprts_medicalAtention:Client:GetPlayerIllness", function(illness)
    debugPrint("Hráč má nemoc : " .. illness.name)
    otherPlayerIllness = illness
end)

RegisterNetEvent("aprts_medicalAtention:Client:GetCured")
AddEventHandler("aprts_medicalAtention:Client:GetCured", function()
    playerIllness = nil
end)

RegisterNetEvent("aprts_medicalAtention:Client:updateTime")
AddEventHandler("aprts_medicalAtention:Client:updateTime", function(time)
    if playerIllness == nil then
    else
        playerIllness.duration = time
        if playerIllness.duration <= 0 then
            TriggerServerEvent("aprts_medicalAtention:Server:playerGetCured")
        end
    end
end)

RegisterNetEvent('aprts_medicalAtention:Client:diagnose')
AddEventHandler('aprts_medicalAtention:Client:diagnose', function()
    if LocalPlayer.state.Character.Job == Config.Job then
        local ped = exports["aprts_select"]:startSelecting(true)
        if IsPedAPlayer(ped) then
            local playerPed = ped
            otherPlayer = playerPed
            local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(playerPed))
            notify("Diagnóza začala")
            TriggerServerEvent("aprts_medicalAtention:Server:getPlayerIllness", playerID)
        else
            notify("Tohle není hráč")
        end
    end
end)

RegisterNetEvent('aprts_medicalAtention:Client:tryCure')
AddEventHandler('aprts_medicalAtention:Client:tryCure', function(cure)
    if LocalPlayer.state.Character.Job == Config.Job then
        local ped = exports["aprts_select"]:startSelecting(true)
        if IsPedAPlayer(ped) then
            PlayAnimation(Config.Anim)
            TriggerServerEvent("aprts_medicalAtention:Server:Cure",
                GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)), cure)
        else
            notify("Tohle není hráč")
        end
    else
        TriggerServerEvent("aprts_medicalAtention:Server:Cure",
            GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId())), cure)
    end

end)

RegisterNetEvent("aprts_medicalAtention:Client:Cure")
AddEventHandler("aprts_medicalAtention:Client:Cure", function(cure)
    if playerIllness == nil then
        notify("Nejsi nemocný, ale stejně si to zkusil")
        return
    end
    if playerIllness.cure == cure then
        if playerIllness.duration <= 60 * 30 then
            playerIllness.duration = math.floor(playerIllness.duration / 2)
        else
            playerIllness.duration = 60 * 30
        end

        TriggerServerEvent("aprts_medicalAtention:Server:updateTime", playerIllness.duration)
        notify("Cítíš se trochu lépe")
    else
        notify("Nemáš pocit že by tohle pomáhalo")
    end

end)

RegisterNetEvent('aprts_medicalAtention:Client:useItem')
AddEventHandler('aprts_medicalAtention:Client:useItem', function(item)
    
    ChangeEntityHealth(GetPlayerPed(), item.effect)
end)

RegisterNetEvent("aprts_medicalAtention:Client:healSelf")
AddEventHandler("aprts_medicalAtention:Client:healSelf", function(percent)
    
    healSelf(tonumber(percent))
end)

RegisterNetEvent("aprts_medicalAtention:Client:healPatient")
AddEventHandler("aprts_medicalAtention:Client:healPatient", function(percent)
    healPatient(tonumber(percent))
end)

RegisterNetEvent("aprts_medicalAtention:Client:PatientHealing")
AddEventHandler("aprts_medicalAtention:Client:PatientHealing", function(value)
    PatientHealing(value)
end)

RegisterNetEvent("aprts_medicalAtention:Client:useItem")
AddEventHandler("aprts_medicalAtention:Client:useItem", function(item)
    local ped = 0
    if item.others == true then
        ped = exports["aprts_select"]:startPlayerSelecting(true)
    end
    
    if ped == 0 and item.myself == true then
        ped = 999
    end
    print("heal " .. ped)

    if ped > 0 then
        TriggerServerEvent("aprts_medicalAtention:Server:heal", ped, item)
    else
        notify("Takhle to nemůžeš použít")
    end

end)

RegisterNetEvent("aprts_medicalAtention:Client:revive")
AddEventHandler("aprts_medicalAtention:Client:revive", function(item)
    local ped = exports["aprts_select"]:startPlayerSelecting(true)
    print("revive " .. ped)
    -- TriggerEvent('vorp:resurrectPlayer', ped)
    TriggerServerEvent("aprts_medicalAtention:Server:revive", ped, item)

end)
local function EndDeathCam()
    NetworkSetInSpectatorMode(false, PlayerPedId())
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false, 0)
    DestroyCam(cam, false)
    cam = nil
    DestroyAllCams(true)
end

RegisterNetEvent("aprts_medicalAtention:Client:reviveME")
AddEventHandler("aprts_medicalAtention:Client:reviveME", function(item)
    -- print("reviveME")
    Wait(1000)
    local player = PlayerPedId()

    Citizen.InvokeNative(0xCE7A90B160F75046, false) -- SET_CINEMATIC_MODE_ACTIVE
    TriggerEvent("vorp:showUi", not false)
    ResurrectPed(player)
    Wait(200)
    EndDeathCam()
    TriggerServerEvent("vorp:ImDead", false)

    TriggerServerEvent("vorp_core:Server:OnPlayerRevive")
    TriggerEvent("vorp_core:Client:OnPlayerRevive")

    Citizen.InvokeNative(0xC6258F41D86676E0, player, 0, 250) -- _SET_ATTRIBUTE_CORE_VALUE HEALTH
    SetEntityHealth(player, 1, 250)
    Citizen.InvokeNative(0xC6258F41D86676E0, player, 1, 250) -- _SET_ATTRIBUTE_CORE_VALUE STAMINA
    Citizen.InvokeNative(0x675680D089BFA21F, player, 1065330373)
    SetEntityHealth(PlayerPedId(), 10)
    TriggerEvent("vorpcharacter:reloadafterdeath")
end)

RegisterNetEvent("aprts_medicalAtention:Client:getClothes")
AddEventHandler("aprts_medicalAtention:Client:getClothes", function(serverClothes)
    debugPrint("Dostal jsem oblečení" .. table.count(serverClothes))
    clothes = serverClothes
end)

RegisterNetEvent("aprts_medicalAtention:Server:setClothesTemp")
AddEventHandler("aprts_medicalAtention:Server:setClothesTemp", function(id, temp)
    clothes[id].temp = temp
end)
