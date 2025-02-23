--[[
    npc.lua
    Description: This script handles NPC spawning and interaction prompts in the game.
    
    Functions:
        LoadModel(model) - Loads the specified model.
        spawnNPCs(model, x, y, z, h, scenario) - Spawns an NPC at the given coordinates with the specified scenario.
        CreateBlip(npc) - Creates a blip on the map for the specified NPC.
        checkHorse() - Checks if the player is on a tamed horse.
    
    Events:
        onResourceStop - Cleans up NPCs and blips when the resource is stopped.
    
    Prompts:
        "STABLES" - Opens the stables menu (always visible near NPC).
        "Sell Horse" - Sells the current horse (visible only when on a tamed horse).
        "Stable Horse" - Stables the current horse (visible only when on a tamed horse).
]]
closestNPC = nil

function getFPS()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime
    return frame
end

function fpsTimer()
    local minFPS = 15
    local maxFPS = 165
    local minSpeed = 0
    local maxSpeed = 15
    local coefficient = 1 - (getFPS() - minFPS) / (maxFPS - minFPS)
    return minSpeed + coefficient * (maxSpeed - minSpeed)
end

local function LoadModel(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        RequestModel(modelHash)
        Citizen.Wait(10)
    end
    return modelHash
end

local function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    Citizen.InvokeNative(0xADA9255D, 22)
    DisplayText(str, x, y)
end

local function spawnNPCs(model, x, y, z, h, scenario)
    local modelHash = LoadModel(model)
    local npc_ped = CreatePed(modelHash, x, y, z, false, false, false, false)

    if scenario then
        TaskStartScenarioInPlace(npc_ped, GetHashKey(scenario), 0, true, false, false, false)
    else
        TaskStartScenarioInPlace(npc_ped, GetHashKey("WORLD_HUMAN_HORSE_TEND_BRUSH_LINK"), 0, true, false, false, false)
    end

    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)

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

function CreateBlip(npc)
    local blip = N_0x554d9d53f696d002(1664425300, npc.coords.x, npc.coords.y, npc.coords.z)
    SetBlipSprite(blip, -73168905, 1)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, npc.name)
    return blip
end

local function checkHorse()
    local isMounted = IsPedOnMount(PlayerPedId())
    local currentHorse = GetMount(PlayerPedId())
    return breakedHorse.horse == currentHorse and isMounted
end

Citizen.CreateThread(function()
    for _, npc in pairs(NPCs) do
        npc.blip = CreateBlip(npc)
    end
end)

-- Sell or tame breaked horse and manage NPC rendering
Citizen.CreateThread(function()
    while true do
        for _, npc in pairs(NPCs) do
            local pcoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pcoords, npc.coords.x, npc.coords.y, npc.coords.z, 1)

            if dist < Config.drawDistance and not DoesEntityExist(npc.NPC) then
                npc.NPC = spawnNPCs(npc.model, npc.coords.x, npc.coords.y, npc.coords.z, npc.h,
                    "WORLD_HUMAN_HORSE_TEND_BRUSH_LINK")
            elseif dist > Config.drawDistance and DoesEntityExist(npc.NPC) then
                DeleteEntity(npc.NPC)
                SetModelAsNoLongerNeeded(GetHashKey(npc.model))
            end
           
            if dist < npc.distance then
                stablesVisible = true
                closestNPC = npc
                break
            else
                closestNPC = nil
            end
        end
        Citizen.Wait(10)
    end
end)

function ControlChecker()
    -- Dev function to print key names on press
    for k, v in pairs(Keys) do
        if IsControlJustPressed(0, v) then
            dprint("Control 0 pressed : " .. k)
        elseif IsDisabledControlJustPressed(0, v) then
            dprint("Disabled Control pressed : " .. k)
        end
    end
end


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    for _, npc in pairs(NPCs) do
        if npc.NPC then
            DeleteEntity(npc.NPC)
            RemoveBlip(npc.blip)
        end
    end
end)
