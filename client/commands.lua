if Config.Debug then

    -- Funkce pro nastavení koně jako divokého
    function SetHorseWildAgain(horseEntity)
        Citizen.InvokeNative(0xAEB97D84CDF3C00B, horseEntity, true) -- SetAnimalIsWild
        Citizen.InvokeNative(0xBCC76708E5677E1D, horseEntity, true) -- ClearActiveAnimalOwner
        Citizen.InvokeNative(0x9FF1E042FA597187, horseEntity, 97, false) -- SetAnimalTuningBoolParam
    end

    RegisterCommand('setWild', function(source, args, rawCommand)
        -- Příklad použití
        local playerPed = PlayerPedId() -- Získej ID hráčovy postavy
        local horseEntity = GetMount(PlayerPedId())

        -- Zavolej funkci pro nastavení koně jako divokého, pokud existuje
        if DoesEntityExist(horseEntity) and IsPedOnMount(playerPed) then
            SetHorseWildAgain(horseEntity)
        end
    end)

    --     RemoveTagFromMetaPed(
    -- 	ped --[[ Ped ]], 
    -- 	component --[[ Hash ]], 
    -- 	p2 --[[ integer ]]
    -- )
    RegisterCommand("remoComp", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        local componentHash = tonumber(args[1])
        if horse == 0 then
            print("No horse to equip")
            return
        end
        RemoveTagFromMetaPed(horse, componentHash, 0)

    end)

    RegisterCommand("setTamed", function(source, args, rawCommand)
        breakedHorse = {
            horse = GetMount(PlayerPedId()),
            name = "test",
            breed = "Breton",
            hash = GetEntityModel(GetMount(PlayerPedId()))
        }
    end)
    RegisterCommand('becomehorse', function(source, args, rawCommand)
        RequestModel(-1963397600)
        Citizen.CreateThread(function()
            local waiting = 0
            while not HasModelLoaded(-1963397600) do
                waiting = waiting + 100
                Citizen.Wait(100)
                if waiting > 5000 then
                    print("Could not load ped model")
                    break
                end
            end
            local playerPed = PlayerPedId()
            SetPlayerModel(playerPed, -1963397600)
            Citizen.InvokeNative(0x283978A15512B2FE, playerPed, true) -- SetRandomOutfitVariation
            SetModelAsNoLongerNeeded(-1963397600)
        end)
    end)

    RegisterCommand("horseInfo", function(source, args, rawCommand)
        print(getHorseName(GetMount(PlayerPedId())))
    end)

    RegisterCommand("useHay", function(source, args, rawCommand)
        TriggerEvent("aprts_horses:useItem")
    end)

    local function getAttributeIndex(attribute)
        for i, atr in pairs(ePedAttribute) do
            if atr == attribute then
                return i
            end
        end
    end

    RegisterCommand("horseAtrAll", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        -- local index =getAttributeIndex("SA_SICKNESS")
        local Atributes = {}
        for index, atr in pairs(ePedAttribute) do
            Atributes[atr] = {}
            print(index - 1, "-", atr)
            Atributes[atr].index = index - 1
            Atributes[atr].Name = atr
            -- Atribute.BaseRank = GetAttributeBaseRank(horse, index)
            Atributes[atr].Rank = GetAttributeRank(horse, index - 1)
            Atributes[atr].BonusRank = GetAttributeBonusRank(horse, index)
            -- Atribute.maxRank = GetMaxAttributeRank(horse, index)
            Atributes[atr].Points = GetAttributePoints(horse, index - 1)
            -- Atribute.maxPoints = GetMaxAttributePoints(horse, index)
            print(json.encode(Atributes[atr]))
        end
        -- print(json.encode(Atributes))
    end)

    local function getAtributeParameters(horse, index)
        local Atribute = {}
        Atribute.BaseRank = GetAttributeBaseRank(horse, index)
        Atribute.Rank = GetAttributeRank(horse, index)
        Atribute.BonusRank = GetAttributeBonusRank(horse, index)
        Atribute.maxRank = GetMaxAttributeRank(horse, index)
        Atribute.Points = GetAttributePoints(horse, index)
        Atribute.maxPoints = GetMaxAttributePoints(horse, index)
        return Atribute
    end
    RegisterCommand("horseAtr", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        -- local index =getAttributeIndex("SA_SICKNESS")
        local index = tonumber(args[1])
        local message = "Horse Atribute: " .. ePedAttribute[index + 1] .. " - " ..
                            getAtributeParameters(horse, index).Points
        TriggerEvent('chat:addMessage', {
            args = {'Horse Atribute', message}
        })
        print(json.encode(getAtributeParameters(horse, index)))

    end)
    RegisterCommand("horseSetAtrPoints", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        local index = tonumber(args[1])
        local value = tonumber(args[2])
        SetAttributePoints(horse, index, value)
        print(json.encode(getAtributeParameters(horse, index)))
    end)
    RegisterCommand("hotseSetAtrBonus", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        local index = tonumber(args[1])
        local value = tonumber(args[2])
        SetAttributeBonusRank(horse, index, value)
        print(json.encode(getAtributeParameters(horse, index)))
    end)

    -- RegisterCommand("select", function()
    --     exports["aprts_select"]:startSelecting(true)
    -- end)

    -- RegisterNetEvent("aprts_select:entitySelected", function(entity)
    --     local isHorse = IsThisModelAHorse(GetEntityModel(entity))
    --     print(isHorse)
    --     if isHorse > 0 then
    --         print(entity, " Horse Selected")
    --     else
    --         print(entity, " Not a horse")
    --     end
    -- end)
    RegisterCommand("horseSetAtr", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        local index = tonumber(args[1])
        local value = tonumber(args[2])
        local bonusRank = tonumber(args[3])
        local points = tonumber(args[4])
        SetAttributeBaseRank(horse, index, value)
        SetAttributeBonusRank(horse, index, bonusRank)
        if args[3] == nil then
        else
            SetAttributePoints(horse, index, points)
        end

    end)
    RegisterCommand("restoreStamina", function(source, args, rawCommand) -- restoreStamina 100 stamina jádra koně
        TriggerEvent("aprts_horses:restoreStamina", GetMount(PlayerPedId()), tonumber(args[1]))
    end)
    RegisterCommand("rechargeStamina", function(source, args, rawCommand) -- přidá args[1] k součané stamině koně
        TriggerEvent("aprts_horses:rechargeStamina", GetMount(PlayerPedId()), tonumber(args[1]))
    end)
    RegisterCommand('registerhorse', function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local isMounted = IsPedOnMount(playerPed)
        local isOwned = IsEntityAMissionEntity(GetMount(playerPed))
        local horse = GetMount(playerPed)
        if args[1] ~= nil and isMounted then
            if not isOwned then
                createVehicle('horse', args[1])
            else
                sendNotification("Horse is owned by someone!")
            end
        elseif isMounted then
            if not isOwned then
                createVehicle('horse', horse)
                DeleteEntity(horse)
            else
                sendNotification("Horse is owned by someone!")
            end
        else
            sendNotification("You must be mounted on a horse!")

            print('Not mounted!')
        end
    end)

    RegisterCommand('defaulthorse', function(source, args, rawCommand)
        setDefaultHorse(args[1])
    end)

    RegisterCommand("equipHorseComp", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = exports["aprts_select"]:startSelecting(true)
        print("Appliing component to horse ", horse)
        local componentHash = tonumber(args[1])
        if horse == nil then
            print("No horse to equip")
            return
        end
        -- local horseName = myHorse.name
        ApplyShopItemToPed(horse, componentHash, true, true, true)
        for _, comp in pairs(HorseComp) do
            for _, item in pairs(comp) do
                if item.hash == componentHash then
                    print(json.encode(item))
                    -- print("Match!!!", item.hash, " in category ", item.category)    
                    myHorseComp[item.category] = item.hash
                end
            end
        end
        -- print(json.encode(myHorseComp))
        TriggerServerEvent("aprts_horses:equipHorseComponent", myHorse.id, myHorseComp)
        -- UpdatePedVariation(horsePed, 0, 1, 1, 1, false)
    end)

    RegisterCommand("unequipComp", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = myHorse.ped
        local componentHash = tonumber(args[1])
        if horse == 0 then
            print("No horse to equip")
            return
        end
        local horseName = myHorse.name

        Citizen.InvokeNative(0x0D7FFA1B2F69ED82, horse, componentHash, 0, 0) -- RemoveShopItemFromPed
        Citizen.InvokeNative(0xCC8CA3E88256E58F, horse, 0, 1, 1, 1, 0) -- UpdatePedVariation

        for _, comp in pairs(HorseComp) do
            for _, item in pairs(comp) do
                if item.hash == componentHash then
                    myHorseComp[item.category] = 0
                end
            end
        end
        TriggerServerEvent("aprts_horses:equipHorseComponent", horseName, myHorseComp)

    end)
    RegisterCommand("outfit", function(source, args, rawCommand)
        local pedID = tonumber(args[1])
        local index = tonumber(args[2])
        local categories = {{
            name = "head",
            hash = 833267460
        }, {
            name = "klobouk",
            hash = 2004797167
        }, {
            name = "top",
            hash = -853084561
        }, {
            name = "košile",
            hash = -818624178
        }, {
            name = "kabat",
            hash = 630468808
        }, {
            name = "boty",
            hash = -818624178
        }, {
            name = "boty",
            hash = -818624178
        }, {
            name = "boty",
            hash = -818624178
        }}

        local sourceMeta = getMetaTag(pedID)
        local playermeta = getMetaTag(PlayerPedId())
        for i, data in pairs(sourceMeta) do
            -- print(i)
            if tonumber(i) == index then
                local category = GetPedComponentCategoryByIndex(pedID, tonumber(i) + 1)
                print("Category: ", category)
                print("SetMetaPedTag to player ped ", tonumber(pedID), data.drawable, data.albedo, data.normal,
                    data.material, data.palette, data.tint0)
                SetMetaPedTag(PlayerPedId(), data.drawable, data.albedo, data.normal, data.material, data.palette,
                    data.tint0, data.tint1, data.tint2)
            end

        end
        UpdatePedVariation(PlayerPedId(), 0, 1, 1, 1, false)
    end)
    function GetComponentIndexByCategory(ped, category)
        local numComponents = GetNumComponentsInPed(ped)
        for i = 0, numComponents - 1, 1 do
            local componentCategory = GetCategoryOfComponentAtIndex(ped, i)
            if componentCategory == category then
                return i
            end
        end
    end

    RegisterCommand("copyHair", function(source, args, rawCommand)
        local pedID = tonumber(args[1])
        local categoryhash = GetHashKey("hair")
        print(tonumber(categoryhash))
        local componentIndex = GetComponentIndexByCategory(pedID, categoryhash)
        local sourceMeta = getMetaTag(pedID)
        for i, data in pairs(sourceMeta) do
            -- print(i)
            if tonumber(i) == componentIndex then
                SetMetaPedTag(PlayerPedId(), data.drawable, data.albedo, data.normal, data.material, data.palette,
                    data.tint0, data.tint1, data.tint2)
            end

        end
        UpdatePedVariation(PlayerPedId(), 0, 1, 1, 1, false)
    end)
    RegisterCommand("copyoutfit", function(source, args, rawCommand)
        local pedID = tonumber(args[1])
        local outfit = {}

        local sourceMeta = getMetaTag(pedID)
        local playermeta = getMetaTag(PlayerPedId())
        for i, data in pairs(sourceMeta) do
            -- print(i)
            local category = GetPedComponentCategoryByIndex(pedID, tonumber(i))
            if tonumber(i) <= 3 then
                table.insert(outfit, data)
                -- print("SetMetaPedTag to player ped ", tonumber(pedID), data.drawable, data.albedo, data.normal,
                --      data.material, data.palette, data.tint0)

                SetMetaPedTag(PlayerPedId(), data.drawable, data.albedo, data.normal, data.material, data.palette,
                    data.tint0, data.tint1, data.tint2)
            end

        end
        -- print(json.encode(outfit))
        -- applyMetaTag(PlayerPedId(), outfit)
        UpdatePedVariation(PlayerPedId(), 0, 1, 1, 1, false)
    end)

    RegisterCommand("reoutfit", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, playerPed, 0, 0)
    end)

    RegisterCommand("unequpAll", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        if horse == 0 then
            print("No horse to equip")
            return
        end
        ResetPedComponents(horse)
        SetRandomOutfitVariation(horse, true)
        UpdatePedVariation(horsePed, 0, 1, 1, 1, false)
    end)

    RegisterCommand("getHorseMeta", function(source, args, rawCommand)
        local currentHorse = GetMount(PlayerPedId())
        local meta = getMetaTag(currentHorse)
        for _, comp in pairs(meta) do
            -- print(comp.drawable, comp.albedo, comp.normal, comp.material, comp.palette, comp.tint0, comp.tint1, comp.tint2)
            print(json.encode(comp))
            for i, component in pairs(HorseComp) do
                -- print("Component: ", i)
                for j, item in pairs(component) do
                    -- print("Item: ", item.hash,"-", tonumber(comp.drawable))
                    if tonumber(item.hash) == tonumber(comp.albedo) then
                        print("Match!!!", item.hash)
                    end
                end
            end
        end
    end)

    RegisterCommand("getHashOfComponent", function(source, args, rawCommand)
        local currentHorse = GetMount(PlayerPedId())
        dprint("Hash of Category at index ", args[1], " is ",
            getComponentCategoryByIndex(currentHorse, tonumber(args[1])))
        local metaTag = getMetaTag(currentHorse)
        metaTag[tostring(args[1])].tint0 = tonumber(255)
        applyMetaTag(currentHorse, metaTag)
    end)

    RegisterCommand("getShopComponents", function(source, args, rawCommand)
        for i = 0, 1000, 1 do
            local retval, argStruct, argStruct2 = GetShopItemComponentAtIndex(GetMount(PlayerPedId()), i, true)
            if retval then
                print(i, retval)
            end
        end

    end)

    RegisterCommand('setHorseColor', function(source, args, rawCommand)
        local currentHorse = GetMount(PlayerPedId())
        local metaTag = getMetaTag(currentHorse)

        for partName, partIndex in pairs(horseBodyParts) do
            metaTag[partIndex].tint0 = tonumber(args[1])
            metaTag[partIndex].tint1 = tonumber(args[2])
            metaTag[partIndex].tint2 = tonumber(args[3])

            dprint("Category ", getComponentCategoryByIndex(GetMount(PlayerPedId()), tonumber(partIndex)))
        end
        applyMetaTag(currentHorse, metaTag)
    end)

    RegisterCommand('setHorsePalette', function(source, args, rawCommand)
        local currentHorse = exports["aprts_select"]:startSelecting(true)
        print(currentHorse)
        local metaTag = getMetaTag(currentHorse)

        local paletteIndex = tonumber(args[1])
        if not colorPalettes[paletteIndex] then
            dprint("Invalid palette")
            return
        end
        print(#metaTag)

        for partName, partIndex in pairs(horseBodyParts) do
            if metaTag[partIndex] then
                metaTag[partIndex].palette = colorPalettes[paletteIndex][1]
            end
        end

        applyMetaTag(currentHorse, metaTag)
    end)

    RegisterCommand("getFlags", function(source, args, rawCommand)
        local currentHorse = GetMount(PlayerPedId())
        -- get flag by GetPedConfigFlag flag index 1 - 1000
        for i = 0, 1000, 1 do
            local flag = GetPedConfigFlag(currentHorse, i, true)
            if flag then
                -- print in this format: [6] = true,
                print("[" .. i .. "] = " .. tostring(flag) .. ",")
            end
        end
    end)

    RegisterCommand("hideWeapon", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        local horse = GetMount(playerPed)
        SendWeaponToInventory(playerPed, GetPedCurrentHeldWeapon(playerPed))
        Citizen.InvokeNative("N_0x14ff0c2545527f9b", playerPed, GetPedCurrentHeldWeapon(playerPed), horse)
    end)
end
