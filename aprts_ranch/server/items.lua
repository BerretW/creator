Citizen.CreateThread(function()
    for _, medicine in pairs(Config.medicineItems) do
        exports.vorp_inventory:registerUsableItem(medicine.item, function(data)
            local _source = data.source
            exports.vorp_inventory:closeInventory(data.source)
            TriggerClientEvent('aprts_ranch:Client:useMedicine', _source, medicine)
        end)
    end
    exports.vorp_inventory:registerUsableItem(Config.NameTagItem, function(data)
        local _source = data.source
        exports.vorp_inventory:closeInventory(data.source)
        TriggerClientEvent('aprts_ranch:Client:useNameTag', _source)
    end)



    for _, item in pairs(Config.feeding) do
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            local _source = data.source
            exports.vorp_inventory:closeInventory(data.source)
            exports.vorp_inventory:subItem(_source, item.item, 1)
            TriggerClientEvent('aprts_ranch:Client:placeRailing', _source,item.prop)
        end)
        if item.upgradeItem ~= nil then
            exports.vorp_inventory:registerUsableItem(item.upgradeItem, function(data)
                local _source = data.source
                exports.vorp_inventory:closeInventory(data.source)
                exports.vorp_inventory:subItem(_source, item.upgradeItem, 1)
                TriggerClientEvent('aprts_ranch:Client:tryUpgrade', _source,item.prop)
            end)
        end



    end

    -- exports.vorp_inventory:registerUsableItem(Config.railing1Item, function(data)
    --     local _source = data.source
    --     exports.vorp_inventory:closeInventory(data.source)
    --     exports.vorp_inventory:subItem(_source, Config.railing1Item, 1)
    --     TriggerClientEvent('aprts_ranch:Client:placeRailing', _source,"p_mp_feedbaghang01x")
    -- end)
    -- exports.vorp_inventory:registerUsableItem("tool_feeding_trough_upgrade1", function(data)
    --     local _source = data.source
    --     exports.vorp_inventory:closeInventory(data.source)
    --     exports.vorp_inventory:subItem(_source, "tool_feeding_trough_upgrade1", 1)
    --     TriggerClientEvent('aprts_ranch:Client:tryUpgrade', _source,"p_feedtrough01x")
    -- end)



    for _, item in pairs(Config.CureItems) do
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            local _source = data.source
            exports.vorp_inventory:closeInventory(data.source)
            exports.vorp_inventory:subItem(_source, item.item, 1)
            TriggerClientEvent('aprts_ranch:Client:useCure', _source, item.cure)
        end)
    end
end)

