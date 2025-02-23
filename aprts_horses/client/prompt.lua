local promptGroup = GetRandomIntInRange(0, 0xffffff)
local stablePrompt, sellPrompt, stablesPrompt = nil, nil, nil

-- Funkce pro vytvoření promptu
local function createPrompt(controlKey, text)
    local prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(prompt, controlKey)
    local varStr = CreateVarString(10, 'LITERAL_STRING', text)
    PromptSetText(prompt, varStr)
    PromptSetEnabled(prompt, true)
    PromptSetVisible(prompt, true)
    PromptSetHoldMode(prompt, true)
    PromptSetGroup(prompt, promptGroup)
    PromptRegisterEnd(prompt)
    return prompt
end

-- Inicializace promptů pro ustájení a prodej
local function initPrompts()
    Citizen.CreateThread(function()
        stablePrompt = createPrompt(Config.StableKey.key, "Ustájit")
    end)
    Citizen.CreateThread(function()
        sellPrompt = createPrompt(Config.SellKey.key, "Prodat")
    end)
    Citizen.CreateThread(function()
        stablesPrompt = createPrompt(Config.StablesKey.key, "Otevřít Stáje")
    end)
end

RegisterNetEvent("aprts_horses:delMount")
AddEventHandler("aprts_horses:delMount", function()
    print("delMount" .. breakedHorse.horse)
    DeleteEntity(breakedHorse.horse)
    breakedHorse.horse = nil
end)

-- Kontrola, jestli je hráč poblíž NPC a jestli je kůň "rozbitý"
local function checkNearNPCAndBrokenHorse(npc, breakedHorse)

    return IsPedOnMount(PlayerPedId()) and breakedHorse.horse and GetMount(PlayerPedId()) == breakedHorse.horse
end

-- Funkce, která vrátí true, když je kůň v evidenci Horses
local function isInHorses(modelHash)
    for _, horse in pairs(Horses) do
        if GetHashKey(horse.horse_id) == modelHash then
            return true
        end
    end
    return false
end

local function canStableHorse(horse)
    for _, h in pairs(Horses) do
        print(horse, h.horse_id)
        if GetHashKey(h.horse_id) == horse then
            -- print ("canStable", h.canStable)
            return h.canStable == 1 and true or false
        end
    end
    return false
end

-- Hlavní vlákno pro obsluhu promptů u NPC
Citizen.CreateThread(function()
    initPrompts()
    while true do
        local waitTime = 1000
        for _, npc in pairs(NPCs) do
            local pCoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pCoords, npc.coords.x, npc.coords.y, npc.coords.z, false)
            -- print(dist)
            if dist < npc.distance then
                local displayName = CreateVarString(10, 'LITERAL_STRING', "Stáje")
                PromptSetActiveGroupThisFrame(promptGroup, displayName)
                waitTime = 0
                if checkNearNPCAndBrokenHorse(npc, breakedHorse) then
                    PromptSetVisible(stablesPrompt, false)
                    -- aktivujeme kontrolu častěji, pokud jsme poblíž NPC s koněm

                    if canStableHorse(GetEntityModel(breakedHorse.horse)) then
                        PromptSetVisible(stablePrompt, true)
                    else
                        PromptSetVisible(stablePrompt, false)
                    end

                    PromptSetVisible(sellPrompt, true)

                    -- Nastavení aktivní skupiny promptů

                    -- Zpracování prodeje koně
                    if PromptHasHoldModeCompleted(sellPrompt) then
                        breakedHorse.hash = GetEntityModel(breakedHorse.horse)
                        print("sellHorse", breakedHorse.hash)
                        TriggerServerEvent("aprts_horses:sellHorse", breakedHorse.hash, true)
                        -- fleeHorse(breakedHorse.horse)
                        -- breakedHorse.horse = nil
                        Citizen.Wait(1000)
                    end

                    -- Zpracování ustájení koně
                    if PromptHasHoldModeCompleted(stablePrompt) then
                        -- notify("Kůň byl ustájen")
                        ResetPedComponents(breakedHorse.horse)
                        SetRandomOutfitVariation(breakedHorse.horse, true)
                        UpdatePedVariation(breakedHorse.horse, 0, 1, 1, 1, false)
                        Citizen.Wait(100)
                        createVehicle('horse', breakedHorse.horse)
                        -- while (breakedHorse.name == nil) do
                        --     Citizen.Wait(100)
                        -- end
                        -- fleeHorse(breakedHorse.horse)
                        -- breakedHorse.horse = nil
                        Citizen.Wait(1000)

                    end
                    
                else
                    PromptSetVisible(stablesPrompt, true)
                    PromptSetVisible(stablePrompt, false)
                    PromptSetVisible(sellPrompt, false)

                    if PromptHasHoldModeCompleted(stablesPrompt) then
                        PromptSetVisible(stablesPrompt, false)
                        TriggerEvent("aprts_horses:openMenu")
                    end
                end
                break
            else
                PromptSetVisible(stablesPrompt, true)
            end
        end
        Citizen.Wait(waitTime)
    end
end)

