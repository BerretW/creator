-- příkaz pro vytvoření stopy, bude ve formátu /stopa [vzdálenost] [text]  text může obsahovat mezery a až 20 slov
-- TriggerEvent("chat:addSuggestion", "/" .. Config.ClueCommand, "[viditelnost v metrech] [text]", {{
--     name = "vzdálenost",
--     help = "metry"
-- }, {
--     name = "text",
--     help = "text"
-- }})
RegisterCommand("addBook", function(source, args, rawCommand)

    local id = tonumber(args[1])

    TriggerServerEvent("aprts_library:Server:addBook", id)
end, false)
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
