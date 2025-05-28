if Config.Debug == true then
    RegisterCommand("CreateRanch", function(source, args, rawCommand)
        if land then
            if land.access >= 4 then
                local name = args[1]
                if not name then
                    name = "Ranch"

                end
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("aprts_ranch:Server:createRanch", name, land.id, coords)
            else
                notify("Musíte mít přístup k pozemku červeným klíčem")
            end
        else
            notify("Nemáte pozemek")
        end
    end, false)

end
-- RegisterCommand("placeRailing", function(source, args, rawCommand)
--     placeRailing(GetEntityCoords(PlayerPedId()),"p_mp_feedbaghang01x")
-- end, false)
RegisterCommand("buyAnimal", function(source, args, rawCommand)
    if LocalPlayer.state.Character.Group == "admin" then
        newAnimal(args[1])
    end
end, false)
-- RegisterCommand("getAnimalMeta", function(source, args, rawCommand)
--     local ped = exports["aprts_select"]:startSelecting(true)
--     local meta = getMetaTag(ped)
--     -- print(json.encode(meta))
-- end, false)

-- RegisterCommand("copyAnimalMeta", function(source, args, rawCommand)
--     local ped = exports["aprts_select"]:startSelecting(true)
--     local meta = getMetaTag(ped)
--     local ped2 = exports["aprts_select"]:startSelecting(true)
--     for i, data in pairs(meta) do
--         SetMetaPedTag(ped2, data.drawable, data.albedo, data.normal, data.material,
--             data.palette, data.tint0, data.tint1, data.tint2)
--     end
--     -- print(json.encode(meta))
-- end, false)

RegisterCommand("getWalking", function(source, args, rawCommand)
    print(json.encode(walkingAnimals))
end, false)
