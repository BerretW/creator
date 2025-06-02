local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
    return model
end

function spawnNPCs(model,x, y, z, h, scenario, outfit, weapon)


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
    --SetEntityAsMissionEntity(npc_ped, true, true)
    return npc_ped
end
