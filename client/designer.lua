horseBodyParts = {
    ["taila"] = "1",
    ["head"] = "2",
    ["body"] = "3",
    ["brows"] = "4",
    ["mane"] = "5",
    ["tail"] = "6",
    ["tail1"] = "7"
}
myHorseComp = {
    ["Saddlecloths"] = 0,
    ["Saddle Horns"] = 0,
    ["Saddle Bags"] = 0,
    ["Saddles"] = 0,
    ["Bedrolls"] = 0,
    ["Masks"] = 0,
    ["Stirrup"] = 0,
    ["extra"] = 0
}

colorPalettes = {{1064202495}, {1034157518}, {17129595}, {399232131}, {864404955}, {1090645383}, {1669565057},
                 {1734720533}, {-1952348042}, {-1698476236}, {-1543234321}, {-1529893936}, {-1436165981}, {-1251868068},
                 {-1175980254}, {-783849117}, {-677781054}, {-596915909}, {-541985204}, {-183908539}, {-113397560},
                 {-76459397}}

function getComponentCategoryByIndex(ped, componentIndex)
    local result = Citizen.InvokeNative(0xCCB97B51893C662F, ped, componentIndex, 0, Citizen.ResultAsInteger())
    return result
end

function GetCategoryOfComponentAtIndex(ped, componentIndex)
    local result = Citizen.InvokeNative(0xCCB97B51893C662F, ped, componentIndex, 0, Citizen.ResultAsInteger())
    -- dprint("Category for index ", componentIndex, " is ", result)
    return result

end

function getMetaTag(entity)
    print("GetMetaTag")
    local metatag = {}
    local numComponents = GetNumComponentsInPed(entity)

    print("Num components: ", numComponents)
    print("Num catagories: ", GetNumComponentCategoriesInPed(entity))
    for i = 0, numComponents - 1, 1 do
        local index, drawable, albedo, normal, material = GetMetaPedAssetGuids(entity, i)
        local iindex, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(entity, i)
        -- print(GetPedComponentCategoryByIndex(entity, i))
        metatag[tostring(i)] = {
            drawable = tonumber(drawable),
            albedo = tonumber(albedo),
            normal = tonumber(normal),
            material = tonumber(material),
            palette = tonumber(palette),
            tint0 = tonumber(tint0),
            tint1 = tonumber(tint1),
            tint2 = tonumber(tint2)
        }
        -- dprint(drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end
    return metatag
end

function applyMetaTag(horsePed, metaTag)
    print("Applying Meta Tag" .. json.encode(metaTag))
    for i, data in pairs(metaTag) do
        local data = metaTag[tostring(i)]
        SetMetaPedTag(horsePed, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0,
            data.tint1, data.tint2)
    end
    UpdatePedVariation(horsePed, 0, 1, 1, 1, false)
    -- get horseID

    -- TriggerServerEvent("aprts_horses:Server:updateHorseMeta", myHorse.id, metaTag)
end

-- Citizen.CreateThread(function()
--     while true do
--         local pause = 1000
--         if myHorse.ped then
--             local damage = HasPedTakenGoreDamage(myHorse.ped, 13)
--             notify("Tvůj kun si poškodil pravou nohu" .. damage)
--         end

--         Wait(pause)
--     end
-- end)

-- HasPedTakenGoreDamage
