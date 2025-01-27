local PromptsStarted = false
local HorseDrink, HorseRest, HorseSleep, HorseWallow, HorseTrade = nil, nil, nil, nil,nil
local Drinking, InWrithe = false, false

function HorseTargetPrompts(menuGroup)
    -- local currentLevel = Citizen.InvokeNative(0x147149F2E909323C, myHorse.ped, 7, Citizen.ResultAsInteger()) -- GetAttributeBaseRank
    local currentLevel = 4
    if not PromptsStarted then
        HorseDrink = PromptRegisterBegin()
        PromptSetControlAction(HorseDrink, Config.keys.drink)
        PromptSetText(HorseDrink, CreateVarString(10, 'LITERAL_STRING', "Napojit"))
        PromptSetVisible(HorseDrink, true)
        PromptSetStandardMode(HorseDrink, true)
        PromptSetGroup(HorseDrink, menuGroup, 0)
        PromptRegisterEnd(HorseDrink)

        HorseRest = PromptRegisterBegin()
        PromptSetControlAction(HorseRest, Config.keys.rest)
        PromptSetText(HorseRest, CreateVarString(10, 'LITERAL_STRING', "Odpočinout koně"))
        PromptSetVisible(HorseRest, true)
        PromptSetStandardMode(HorseRest, true)
        PromptSetGroup(HorseRest, menuGroup, 1)
        PromptRegisterEnd(HorseRest)

        HorseSleep = PromptRegisterBegin()
        PromptSetControlAction(HorseSleep, Config.keys.sleep)
        PromptSetText(HorseSleep, CreateVarString(10, 'LITERAL_STRING', "Uspat koně"))
        PromptSetVisible(HorseSleep, true)
        PromptSetStandardMode(HorseSleep, true)
        PromptSetGroup(HorseSleep, menuGroup, 0)
        PromptRegisterEnd(HorseSleep)

        HorseWallow = PromptRegisterBegin()
        PromptSetControlAction(HorseWallow, Config.keys.wallow)
        PromptSetText(HorseWallow, CreateVarString(10, 'LITERAL_STRING', "Koupel"))
        PromptSetVisible(HorseWallow, true)
        PromptSetStandardMode(HorseWallow, true)
        PromptSetGroup(HorseWallow, menuGroup, 1)
        PromptRegisterEnd(HorseWallow)

        HorseTrade = PromptRegisterBegin()
        PromptSetControlAction(HorseTrade, Config.keys.trade)
        PromptSetText(HorseTrade, CreateVarString(10, 'LITERAL_STRING', "Darovat"))
        PromptSetVisible(HorseTrade, true)
        PromptSetEnabled(HorseTrade, true)
        PromptSetStandardMode(HorseTrade, true)
        PromptSetGroup(HorseTrade, menuGroup, 0)
        PromptRegisterEnd(HorseTrade)


        PromptsStarted = true
    end

    if currentLevel >= 1 then
        PromptSetEnabled(HorseDrink, true)
    else
        PromptSetEnabled(HorseDrink, false)
    end
    if currentLevel >= 2 then
        PromptSetEnabled(HorseRest, true)
    else
        PromptSetEnabled(HorseRest, false)
    end
    if currentLevel >= 3 then
        PromptSetEnabled(HorseSleep, true)
    else
        PromptSetEnabled(HorseSleep, false)
    end
    if currentLevel >= 4 then
        PromptSetEnabled(HorseWallow, true)
    else
        PromptSetEnabled(HorseWallow, false)
    end
end

CreateThread(function()
    while true do

        Citizen.Wait(1000)
        local player = PlayerId()
        local fleeEnabled = true
        local distanceCheckEnabled = true
        local horseRadius = 300.0
        -- print("Tik")
        if myHorse.ped then
            while myHorse.ped  do
                local playerPed = PlayerPedId()
                local sleep = 1000
                local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(myHorse.ped))

                if distanceCheckEnabled then
                    if distance > horseRadius then
                        DeleteEntity(myHorse.ped)
                        myHorse = {}
                        goto END
                    end
                end

                if (IsPlayerFreeAiming(player)) or (distance > 2.8) or (IsEntityDead(playerPed)) then
                    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, myHorse.ped, 35, 1, true) -- Hide TARGET_INFO
                    Citizen.InvokeNative(0xA3DB37EDF9A74635, player, myHorse.ped, 33, 1, true) -- Hide HORSE_FLEE
                    PromptDelete(HorseDrink)
                    PromptDelete(HorseRest)
                    PromptDelete(HorseSleep)
                    PromptDelete(HorseWallow)
                    -- PromptDelete(HorseTrade)
                    PromptsStarted = false
                    goto END
                end

                sleep = 0

                Citizen.InvokeNative(0xA3DB37EDF9A74635, player, myHorse.ped, 35, 1, false) -- Show TARGET_INFO
                Citizen.InvokeNative(0xA3DB37EDF9A74635, player, myHorse.ped, 33, 1, false) -- Show HORSE_FLEE
                if Citizen.InvokeNative(0x27F89FDC16688A7A, player, myHorse.ped, false) then -- IsPlayerTargettingEntity
                    sleep = 0
                    local menuGroup = Citizen.InvokeNative(0xB796970BD125FCE8, myHorse.ped) -- PromptGetGroupIdForTargetEntity
                    -- UiPromptRemoveGroup(menuGroup)
                    HorseTargetPrompts(menuGroup)
                    -- PromptDelete(HorseSleep)
                    if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.drink) then -- [U] IsControlJustPressed
                        if Drinking then
                            goto END
                        end
                        HorseDrinking()
                    end

                    if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.rest) then -- [V] IsControlJustPressed
                        if Drinking then
                            goto END
                        end
                        HorseResting()
                    end

                    if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.sleep) then -- [Z] IsControlJustPressed
                        if Drinking then
                            goto END
                        end
                        HorseSleeping()
                    end

                    if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.wallow) then -- [C] IsControlJustPressed
                        if Drinking then
                            goto END
                        end
                        HorseWallowing()
                    end
                    if Citizen.InvokeNative(0x580417101DDB492F, 0, Config.keys.trade) then -- [C] IsControlJustPressed
                        if Drinking then
                            goto END
                        end
                        HorseTrading()
                    end

                    -- if fleeEnabled then
                    --     if Citizen.InvokeNative(0x580417101DDB492F, 0, GetHashKey("INPUT_HORSE_COMMAND_FLEE")) then -- IsControlJustPressed
                    --         -- FleeHorse()
                    --     end
                    -- end
                end
                ::END::
                Wait(sleep)
            end
        end
    end
end)

function HorseDrinking()
    if not IsEntityInWater(myHorse.ped) then
        notify("Kůň musí být ve vodě, aby mohl pít.")
        return
    end
    Drinking = true
    local drinkTime = 20 * 1000
    local dict = 'amb_creature_mammal@world_horse_drink_ground@idle'
    LoadAnim(dict)
    TaskPlayAnim(myHorse.ped, dict, 'idle_a', 1.0, 1.0, drinkTime, 3, 1.0, false, false, false)
    Wait(drinkTime)
    local health = Citizen.InvokeNative(0x36731AC041289BB1, myHorse.ped, 0, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    local stamina = Citizen.InvokeNative(0x36731AC041289BB1, myHorse.ped, 1, Citizen.ResultAsInteger()) -- GetAttributeCoreValue
    if health < 100 or stamina < 100 then
        local healthBoost = 100
        local staminaBoost = 100
        if healthBoost > 0 then
            local newHealth = health + healthBoost
            if newHealth > 100 then
                newHealth = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, myHorse.ped, 0, newHealth) -- SetAttributeCoreValue
        end
        if staminaBoost > 0 then
            local newStamina = stamina + staminaBoost
            if newStamina > 100 then
                newStamina = 100
            end
            Citizen.InvokeNative(0xC6258F41D86676E0, myHorse.ped, 1, newStamina) -- SetAttributeCoreValue
        end
        -- if Config.horseXpPerDrink > 0 and not MaxBonding then
        --     if Config.trainerOnly then
        --         if IsTrainer then
        --             SaveXp('drink')
        --         end
        --     else
        --         SaveXp('drink')
        --     end
        -- end
        Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Core_Fill_Up', 'Consumption_Sounds', true, 0) -- PlaySoundFrontend
    end
    Drinking = false
end

function HorseResting()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, myHorse.ped, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_resting@idle'
    LoadAnim(dict)
    TaskPlayAnim(myHorse.ped, dict, 'idle_a', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function HorseSleeping()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, myHorse.ped, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_sleeping@base'
    LoadAnim(dict)
    TaskPlayAnim(myHorse.ped, dict, 'base', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function HorseWallowing()
    if not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, myHorse.ped, -1) then -- IsMountSeatFree
        return
    end
    local dict = 'amb_creature_mammal@world_horse_wallow_shake@idle'
    LoadAnim(dict)
    TaskPlayAnim(myHorse.ped, dict, 'idle_a', 1.0, 1.0, -1, 3, 1.0, false, false, false)
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end


function HorseTrading()
    if myHorse.ped then
        local targetPlayer = exports.aprts_select:startPlayerSelecting(true, 5.0)
        if targetPlayer > 0 then
            TriggerServerEvent("aprts_horses:transferHorse", myHorse.id, targetPlayer)
            DeletePed(myHorse.ped)
            myHorse = {}
            
        else
            notify("Nikdo nebyl vybrán.")
        end
    end
end