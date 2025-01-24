-- příkaz pro vytvoření stopy, bude ve formátu /stopa [vzdálenost] [text]  text může obsahovat mezery a až 20 slov
-- TriggerEvent("chat:addSuggestion", "/" .. Config.ClueCommand, "[viditelnost v metrech] [text]", {{
--     name = "vzdálenost",
--     help = "metry"
-- }, {
--     name = "text",
--     help = "text"
-- }})
-- RegisterCommand(Config.ClueCommand, function(source, args, rawCommand)
--     local playerCoords = GetEntityCoords(PlayerPedId())
--     local distance = tonumber(args[1])
--     local text = table.concat(args, " ", 2)
--     local coords = playerCoords
--     local prop = nil
--     TriggerServerEvent("aprts_clue:Server:addClue", text, coords, prop, distance)
-- end, false)
-- RegisterCommand("komp", function(source, args, rawCommand)
--     local ped = PlayerPedId()
--     local hasweapon, pedWeapon = GetCurrentPedWeapon(ped, true, 0, true)
--     local WeaponObject = GetCurrentPedWeaponEntityIndex(PlayerPedId(), 0)
--     local ComponentModelHash = GetHashKey("COMPONENT_BOW_ROLE_ENGRAVING_IMPROVED_ALLIGATOR")
--     GiveWeaponComponentToEntity(ped, ComponentModelHash, pedWeapon, true)
--     RequestModel(ComponentModelHash)
--     while not HasModelLoaded(ComponentModelHash) do
--         Wait(0)
--     end
-- end, false)
if Config.Debug then
    TriggerEvent("chat:addSuggestion", "/" .. "selfcure", "Zbaví tě nemoci", {})
    RegisterCommand("selfcure", function(source, args, rawCommand)

        TriggerServerEvent("aprts_medicalAtention:Server:playerGetCured")
    end, false)

    RegisterCommand("getSick", function(source, args, rawCommand)

        playerIllness = Config.Illnesses["itch"]
        TriggerServerEvent("aprts_medicalAtention:Server:playerGetSick", playerIllness)
    end, false)
    RegisterCommand("infect", function(source, args, rawCommand)

        infectPlayers()

    end, false)

    RegisterCommand("damage", function(source, args, rawCommand)

        local player = PlayerPedId()
        Citizen.InvokeNative(0xC6258F41D86676E0, player, 0, 1) -- _SET_ATTRIBUTE_CORE_VALUE HEALTH
        SetEntityHealth(player, 1, 1)
        ChangePedStamina(player, 0)
        Citizen.InvokeNative(0xC6258F41D86676E0, player, 1, 1) -- _SET_ATTRIBUTE_CORE_VALUE STAMINA
        Citizen.InvokeNative(0x675680D089BFA21F, player, 1065330373)
    end, false)
    local compID = 0
    RegisterCommand("dressComp", function(source, args, rawCommand)
        local playerPed = PlayerPedId()
        if not args[1] then
            notify("Musíš zadat id oblečení")
            return
        end
        compID = tonumber(args[1])
        -- local components = exports.vorp_character:GetAllPlayerComponents()
        -- print("Components :" ..  json.encode(components))
        RemoveShopItemFromPedByCategory(playerPed, 0x9925C067, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x485EE834, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x18729F39, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x3107499B, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x3C1A74CD, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x3F1F01E5, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x3F7F3587, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x49C89D9B, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x4A73515C, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x514ADCEA, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x5FC29285, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x79D7DF96, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x7A96FACA, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x877A2CF7, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x9B2C8B89, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xA6D134C6, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xE06D30CE, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x662AC34, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xAF14310B, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x72E6EF74, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xEABE0032, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0x2026C46D, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xB6B6122D, true, true, true)
        RemoveShopItemFromPedByCategory(playerPed, 0xB9E2FA01, true, true, true)

        local comp = clothes[tonumber(args[1])].hash
        ApplyShopItemToPed(playerPed, comp, true, true, true)

        -- ApplyShopItemToPed(PlayerPedId(), args[1], true,true)
        -- ApplyShopItemToPed(playerPed, 0x5BA76CCF, true, true, true)
        print("Dressing :" .. args[1])
        notify("Toto oblečení má nastavenou teplotu : " .. clothes[tonumber(args[1])].temp .. "°C")
        -- UpdatePedVariation()
    end, false)

    RegisterCommand("setTemp", function(source, args, rawCommand)
        local id = compID
        local temp = tonumber(args[1])
        if not id or not temp then
            notify("Musíš zadat id a teplotu")
            return
        end
        TriggerServerEvent("aprts_medicalAtention:Server:setClothesTemp", id, temp)
        notify("Nastavil jsem teplotu oblečení s id " .. id .. " na " .. temp .. "°C")
    end, false)
end


-- Příklad spuštění interakce (můžeš nahradit vlastní logikou)
-- RegisterCommand('startdoctor1899', function(source, args, rawCommand)
--     local playerName = LocalPlayer.state.Character.FirstName .. " " .. LocalPlayer.state.Character.LastName
--     startMedicalProcedure1899(playerName)
-- end, false)

-- Registrace triggeru z jiného skriptu nebo události
-- Můžeš například volat TriggerEvent z serveru nebo jiné části klienta
-- Příklad:
-- TriggerEvent('startMedicalProcedure1899', 'Novák')
