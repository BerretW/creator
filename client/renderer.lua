local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end

local function spawnProp(prop, coords, h)
    local hash = GetHashKey(prop)
    LoadModel(prop)
    local object = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(object, h)
    SetModelAsNoLongerNeeded(hash)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)
    return object
end

local function spawnNPC(model, x, y, z)
    local modelHash = LoadModel(model)
    local npc_ped = CreatePed(model, x, y, z, false, false, false, false)
    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    -- print('npc_ped: ' .. npc_ped)
    SetEntityHeading(npc_ped, 0.0)
    SetEntityCanBeDamaged(npc_ped, false)
    SetEntityInvincible(npc_ped, true)
    FreezeEntityPosition(npc_ped, true)
    SetBlockingOfNonTemporaryEvents(npc_ped, true)
    SetEntityCompletelyDisableCollision(npc_ped, false, false)

    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 6)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 0)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 1)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 2)

    SetModelAsNoLongerNeeded(modelHash)
    return npc_ped
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        for _, doctor in pairs(Config.NPC) do
            local distance =
                GetDistanceBetweenCoords(playerPos, doctor.coords.x, doctor.coords.y, doctor.coords.z, true)
            if distance < 100 then

                if not DoesEntityExist(doctor.obj) then
                    doctor.obj = spawnNPC(doctor.model, doctor.coords.x, doctor.coords.y, doctor.coords.z)
                    SetEntityHeading(doctor.obj, doctor.heading)
                end
            else
                if DoesEntityExist(doctor.obj) then
                    DeleteEntity(doctor.obj)
                    doctor.obj = nil
                end
            end
        end

        Citizen.Wait(pause)
    end
end)
