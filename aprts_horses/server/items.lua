function getItems(callback)
    local query = 'SELECT * FROM aprts_stables_items'

    MySQL.Async.fetchAll(query, {}, function(result)
        if result then
            callback(result)
        else
            print('Nepodařilo se získat předměty z databáze')
        end
    end)
end

getItems(function(items)
    for _, item in ipairs(items) do
        -- print('ID: ' .. item.id)
        -- print('Name: ' .. item.name)
        -- print('Item: ' .. item.item)
        -- print('Modifiers: ' .. item.modifiers)
        item.modifiers = json.decode(item.modifiers)
        -- print('Core Modifiers: ' .. item.core_modifiers)
        item.core_modifiers = json.decode(item.core_modifiers)
        -- print('Timer: ' .. item.timer)
        -- print('Animation: ' .. (item.Animation or 'nil'))
        -- print('Animation Parameter: ' .. (item.AnimationParameter or 'nil'))
        -- print('On Mount Animation: ' .. item.onMountAnimation)
        -- print('On Mount Animation Parameter: ' .. item.onMountAnimationParameter)
        -- print('Prop: ' .. item.prop)
        -- print('----------------------')
        -- Inventory.RegisterUsableItem(item.item, function(data)
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            TriggerClientEvent("aprts_horses:useItem", data.source, item)
            if item.oneTime == 1 then
                exports.vorp_inventory:subItem(data.source, item.item, 1)
            end
            -- exports.vorp_inventory:subItem(data.source, item.item, 1)
            exports.vorp_inventory:closeInventory(data.source)
        end)
    end
end)

