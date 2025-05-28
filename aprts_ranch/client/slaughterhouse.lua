local Prompt = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)

local function prompt()
    Citizen.CreateThread(function()
        local str = "Prodat zvíře"
        local wait = 0
        Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        PromptSetHoldMode(Prompt, true)
        PromptSetGroup(Prompt, promptGroup)
        PromptRegisterEnd(Prompt)
    end)
end

local function SellWalkingAnimals()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    for _, animal in pairs(walkingAnimals) do
        if DoesEntityExist(animal.obj) then
            TriggerServerEvent('aprts_ranch:server:sellAnimal', animal)
            removeWalkingAnimal(animal.id)

        end
    end
end

local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end

local function spawnNPC(model, x, y, z, h)
    local modelHash = LoadModel(model)
    local npc_ped = CreatePed(model, x, y, z, false, false, false, false)
    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    -- print('npc_ped: ' .. npc_ped)
    SetEntityHeading(npc_ped, h or 0.0)
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
    prompt()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local tempTool = exports.aprts_tools:GetEquipedTool()
        for v, npc in pairs(Config.SlaughterHouses) do
            local dist = #(playerPos - vector3(npc.npcCoords.x, npc.npcCoords.y, npc.npcCoords.z))
            if dist < Config.RenderDistance then
                pause = 0
                if not DoesEntityExist(npc.npc) then
                    print(json.encode(npc))
                    npc.npc = spawnNPC(npc.model, npc.npcCoords.x, npc.npcCoords.y, npc.npcCoords.z, npc.heading)
                end
            else
                if DoesEntityExist(npc.npc) then
                    DeleteEntity(npc.npc)
                    npc.npc = nil
                end
            end

            if table.count(walkingAnimals) > 0 then

                if dist < 1.0 then
                    pause = 0
                    if dist < 1.5 then
                        if Prompt == nil then
                            prompt()
                        end
                        if tempTool == Config.leashItem then
                            PromptSetActiveGroupThisFrame(promptGroup,
                                CreateVarString(10, 'LITERAL_STRING', "Prodat zvíře"))
                            if PromptHasHoldModeCompleted(Prompt) then
                                SellWalkingAnimals()
                                Citizen.Wait(1000)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(pause)
    end
end)
-- 
