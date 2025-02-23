-- if data.HorseGender == 'female' then
--     Citizen.InvokeNative(0x5653AB26C82938CF, MyEntity, 41611, 1.0) -- SetCharExpression
--     Citizen.InvokeNative(0xCC8CA3E88256E58F, MyEntity) -- UpdatePedVariation
-- end
function finishHorseSpawn(ride)
    local player = PlayerPedId()
    local ped = PlayerId()

    Citizen.InvokeNative(0xADB3F206518799E8, ride.pedId, GetHashKey("PLAYER")) -- SetPedRelationship
    Citizen.InvokeNative(0xCC97B29285B1DC3B, ride.pedId, 1) -- SetAnimalMood (Natives DB says not implemented so idk)

    if Config.ShowTagsOnHorses then
        local tagHorse = Citizen.InvokeNative(0xE961BF23EAB76B12, ride.pedId, ride.name) -- CreateMpGamerTagOnEntity
        -- Citizen.InvokeNative(0x53CB4B502E1C57EA, ride.pedId, ride.name, false, false, "", 0) --CreateFakeMpGamerTag
        Citizen.InvokeNative(0x5F57522BC1EB9D9D, tagHorse, GetHashKey("PLAYER_HORSE")) -- SetMpGamerTagTopIcon
        Citizen.InvokeNative(0xA0D7CE5F83259663, MPTagHorse, " ") -- SetMpGamerTagBigText
    end

    Citizen.InvokeNative(0xFE26E4609B1C3772, ride.pedId, "HorseCompanion", true) -- DecorSetBool (wtf)
    Citizen.InvokeNative(0xA691C10054275290, player, ride.pedId, 0) -- No name (mount, player, dismountedTimeStamp)
    Citizen.InvokeNative(0x931B241409216C1F, player, ride.pedId, 0) -- setPedOwnsAnimal if true, the horse will follow the player no matter what, and wint be driveable b/c it will still try to go to player
    Citizen.InvokeNative(0xED1C764997A86D5A, player, ride.pedId) -- No name (comment on Vespura : Only used in R* Script nb_stalking_hunter)

    Citizen.InvokeNative(0xB8B6430EAD2D2437, ride.pedId, GetHashKey("PLAYER_HORSE")) -- SetPedPersonality

    Citizen.InvokeNative(0xDF93973251FB2CA5, GetEntityModel(ride.pedId), 1) -- SetPlayerMountStateActive
    Citizen.InvokeNative(0xe6d4e435b56d5bd0, ped, ride.pedId,0) -- SetPlayerOwnsMount enables tab for weapons and open satchel prompt as well horse name when closer
    Citizen.InvokeNative(0xAEB97D84CDF3C00B, ride.pedId, 0) -- SetAnimalIsWild


    Citizen.InvokeNative(0xFE26E4609B1C3772, ride.pedId, "HorseCompanion", true)
    Citizen.InvokeNative(0xA691C10054275290, player, ride.pedId, 0)
    Citizen.InvokeNative(0x931B241409216C1F, player, ride.pedId, 0)
    Citizen.InvokeNative(0xED1C764997A86D5A, player, ride.pedId)
    Citizen.InvokeNative(0xB8B6430EAD2D2437, ride.pedId, GetHashKey("PLAYER_HORSE"))
    Citizen.InvokeNative(0xDF93973251FB2CA5, GetEntityModel(ride.pedId), 1)
    Citizen.InvokeNative(0xAEB97D84CDF3C00B, ride.pedId, 0)
    Citizen.InvokeNative(0xE2487779957FE897, ride.pedId, 528) -- SetTransportUsageFlags
    
--Function.Call((Hash)0xDF93973251FB2CA5, API.GetEntityModel(ride.pedId), 1);

    -- https://github.com/Halen84/RDR3-Native-Flags-And-Enums/tree/main/ePedScriptConfigFlags
    local horseFlags = {
        [6] = true,
        [113] = false,
        [136] = false,
        [208] = true,
        [209] = true,
        [211] = true,
        [277] = true,
        [297] = true,
        [300] = false,
        [301] = false,
        [312] = false,
        [319] = true,
        [400] = true,
        [412] = false,
        [419] = false,
        [438] = false,
        [439] = false,
        [440] = false,
        [561] = true,


        -- [3] = true,
        -- [5] = true,
        -- [23] = true,
        -- [24] = true,
        -- [35] = true,
        -- [45] = true,
        -- [81] = true,
        -- [90] = true,
        -- [99] = true,
        -- [103] = true,
        -- [109] = true,
        -- [177] = true,
        -- [186] = true,
        -- [210] = true,
        -- [245] = true,
        -- [252] = true,
        -- [255] = true,
        -- [256] = true,
        -- [267] = true,
        -- [270] = true,
        -- [278] = true,
        -- [291] = true,
        -- [304] = true,
        -- [378] = true,
        -- [380] = true,
        -- [104] = false,
        -- [207] = true,
    }
    for flag, val in pairs(horseFlags) do
        SetPedConfigFlag(ride.pedId, flag, val); -- SetPedConfigFlag (kind of sets defaultbehavior)
    end

    local horseTunings = {24, 25, 48}
    for k, flag in ipairs(horseTunings) do
        SetAnimalTuningBoolParam(ride.pedId, flag, false); -- SetHorseTuning (no info on Vespura, didn't check any further)
    end

    Citizen.InvokeNative(0xA691C10054275290, ride.pedId, PlayerId(), 431); -- No name (mount, player, dismountedTimeStamp)

    Citizen.InvokeNative(0x6734F0A6A52C371C, PlayerId(), 431) -- No name (player, horseSlot)
    Citizen.InvokeNative(0x024EC9B649111915, ride.pedId, true) -- No name, no desc (ped, p1)
    Citizen.InvokeNative(0xEB8886E1065654CD, ride.pedId, 10, "ALL", 0) -- No name *Washing player's face/hands now* (ped, p1, p2, p3)
    
    Citizen.InvokeNative(0xA691C10054275290, ride.pedId, PlayerId(), 431)
    Citizen.InvokeNative(0x6734F0A6A52C371C, PlayerId(), 431)
    Citizen.InvokeNative(0x024EC9B649111915, ride.pedId, true)
    Citizen.InvokeNative(0xEB8886E1065654CD, ride.pedId, 10, "ALL", 10.0)
    
    if ride.gender == 'female' then
        Citizen.InvokeNative(0x5653AB26C82938CF, ride.pedId, 41611, 1.0) -- SetCharExpression
        Citizen.InvokeNative(0xCC8CA3E88256E58F, ride.pedId) -- UpdatePedVariation
    end
    local distance = GetDistanceBetweenCoords(GetEntityCoords(player), GetEntityCoords(ride.pedId), true)
    if distance < 20 then
        TaskGoToEntity(ride.pedId, player, -1, 4.0, 100.0, 0, 0) -- GoToEntity
    end
    Entity(myHorse.ped).state:set('myHorseId', myHorse.id, true)

    myHorse.blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, ride.pedId) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, myHorse.blip, "Tvuj kun") -- SetBlipName

    SetEntityAsMissionEntity(ride.pedId, false, false);
end

RegisterNetEvent('aprts_horses:spawnHorse')
AddEventHandler('aprts_horses:spawnHorse',
    function(myHorseValue, horseName, id, meta, comp, coreAttributes, attributes, gender, age, shoed)
        local player = PlayerPedId()

        -- print("Horse Spawned: ", myHorseValue, horseName, id, meta, comp)
        -- print(comp)
        myHorseComp = json.decode(comp)
        -- print("Sedlo :" .. myHorseComp["Saddles"])
        myHorse.model = tonumber(myHorseValue)
        myHorse.id = id
        myHorse.name = horseName
        myHorse.meta = meta
        myHorse.shoed = shoed
        -- print("Model: ", myHorse.model, " DB ID: ", myHorse.id)

        if myHorse.model ~= 0 then
            -- local x, y, z = table.unpack(GetEntityCoords(player))
            local foundGround, groundZ = nil, nil

            -- for height = 1, 1000 do
            --     foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, height + 0.0)
            --     if foundGround then
            --         print('FOUND GROUND!: ' .. groundZ)
            --         break
            --     end
            -- end

            RequestModel(myHorse.model)
            Citizen.CreateThread(function()
                local waiting = 0
                while not HasModelLoaded(myHorse.model) do
                    waiting = waiting + 100
                    Citizen.Wait(100)
                    if waiting > 5000 then
                        print("Could not load horse model")
                        break
                    end
                end
                local pointCoords = getClosestPoint(GetEntityCoords(PlayerPedId(), false, true))
                if pointCoords == nil then
                    notify("Nemůžu najít místo pro koně")
                    return
                end
                -- print("Spawning horse at: ", json.encode(pointCoords.coords))
                -- print("Horse Model: ", myHorse.model)
                -- local pointCoords ={coords = {x = 0, y = 0, z = 0}}
                -- pointCoords.coords = GetEntityCoords(player)
                local distance = GetDistanceBetweenCoords(GetEntityCoords(player), pointCoords.coords.x,
                    pointCoords.coords.y, pointCoords.coords.z, true)
                if distance > 100 then
                    notify("Není tu kam přivolat koně")
                    return
                end
                local coords = vector3(pointCoords.coords.x, pointCoords.coords.y, pointCoords.coords.z)
                myHorse.ped = CreatePed(myHorse.model, coords, 0.0, true, false)
                while (not DoesEntityExist(myHorse.ped)) do
                    Citizen.Wait(100)
                end
                SetRandomOutfitVariation(myHorse.ped, true)
                finishHorseSpawn({
                    pedId = myHorse.ped,
                    name = myHorse.name,
                    gender = gender,
                    age = age
                })
                SetPedNameDebug(myHorse.ped, myHorse.name)
                SetPedPromptName(myHorse.ped, myHorse.name)
                SetModelAsNoLongerNeeded(myHorse.ped)
                applyMetaTag(myHorse.ped, myHorse.meta)
                -- {"Masks":0,"Stirrup":0,"Bedrolls":0,"Saddle Bags":0,"Saddlecloths":0,"Saddles":275341736,"Saddle Horns":0}
                if myHorseComp then
                    for k, v in pairs(myHorseComp) do
                        -- print("Applying: ", k, v)
                        ApplyShopItemToPed(myHorse.ped, v, true, true, true)
                        -- if k == "holster" then
                        --     if v > 0 then
                        --         SetPlayerOwnsMount(PlayerId(), myHorse.ped, true)
                        --     end
                        -- end
                        -- if k == "Saddle Bags" then
                        --     if v > 0 then
                        --         SetPlayerOwnsMount(PlayerId(), myHorse.ped, true)
                        --     end
                        -- end
                    end
                end
                if attributes then
                    setHorseAttributes(myHorse.ped, attributes)
                end
                if coreAttributes then
                    setHorseCoreAttributes(myHorse.ped, coreAttributes.CoreHealth, coreAttributes.CoreStamina,
                        coreAttributes.Health, coreAttributes.Stamina)
                end
                -- print("Comp: ", json.encode(myHorseComp))
            end)
        end
    end)

function checkHorse()

    local playerPed = PlayerPedId() -- Update when needed
    local isMounted = IsPedOnMount(playerPed)
    local coords = GetEntityCoords(playerPed)
    local horseCoords = GetEntityCoords(myHorse.ped)
    local distance = GetDistanceBetweenCoords(coords, horseCoords, false)
    if DoesEntityExist(myHorse.ped) then
        -- dprint("Horse is spawned")
        if not isMounted and distance < 30.0 then
            TaskGoToEntity(myHorse.ped, playerPed, -1, 7.2, 2.0, 0, 0)
        else
            debugPrint("Player is mounted")
        end
    else
        TriggerServerEvent("aprts_horses:getHorse")
        -- dprint("Horse is not spawned, requesting horse from server")
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        -- DisableControlAction(0,0x24978A28,true)
        if IsDisabledControlJustPressed(0, 0x24978A28) then -- Control =  H
            debugPrint("Horse Control Pressed")
            checkHorse()
            Citizen.Wait(10000) -- Flood Protection?
        end
    end
end)
