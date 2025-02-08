RegisterNetEvent('aprts_sleepRP:setOutfit')
AddEventHandler('aprts_sleepRP:setOutfit', function(sleeper)
    ResetPedComponents(sleeper.NPC)
    -- Wait(4000)

    for i, data in pairs(sleeper.meta) do
        local category = GetPedComponentCategoryByIndex(sleeper.NPC, tonumber(i))

        SetMetaPedTag(sleeper.NPC, data.drawable, data.albedo, data.normal, data.material, data.palette,
            data.tint0, data.tint1, data.tint2)
    end
    UpdatePedVariation(sleeper.NPC, 0, 1, 1, 1, false)
    -- print(json.encode(sleeper))
end)
