Citizen.CreateThread(function()
    exports.vorp_inventory:registerUsableItem(Config.Tool1, function(data)
        local _source = data.source
        exports.vorp_inventory:closeInventory(data.source)
        TriggerClientEvent('aprts_medicalAtention:Client:diagnose', _source)
    end)

    for _, illness in pairs(Config.Illnesses) do
        exports.vorp_inventory:registerUsableItem(illness.cure, function(data)
            local _source = data.source
            exports.vorp_inventory:closeInventory(data.source)
            exports.vorp_inventory:subItem(_source, illness.cure, 1)
            if Player(_source).state.Character.Job == Config.Job then
                TriggerClientEvent('aprts_medicalAtention:Client:tryCure', _source, illness.cure)
            else
                local chance = math.random(1, 100)
                if chance <= 50 then
                    -- notify(_source, "Máš pocit že to pomohlo!")
                    TriggerClientEvent('aprts_medicalAtention:Client:tryCure', _source, illness.cure)
                else
                    notify(_source, "Nemáš tušení co dělat, ale lépe ti není")
                end
            end
        end)
    end

    for _, item in pairs(Config.AlternateMedicine) do
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            local _source = data.source
            exports.vorp_inventory:subItem(_source, item.item, 1)
            exports.vorp_inventory:closeInventory(data.source)
            TriggerClientEvent('aprts_medicalAtention:Client:tryCure', _source, item.cure)
        end)
    end

    for _, item in pairs(Config.Items) do
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            if item.job then
                if not HasPlayertJob(data.source, item.job) then
                    notify(data.source, "Nemáš pocit že by tohle pomáhalo")
                    return
                end
            end
            TriggerClientEvent("aprts_medicalAtention:Client:useItem", data.source, item)
            exports.vorp_inventory:closeInventory(data.source)
            exports.vorp_inventory:subItem(data.source, item.item, 1)
            -- local _source = data.source
            -- exports.vorp_inventory:closeInventory(data.source)
            -- TriggerClientEvent('aprts_medicalAtention:Client:useItem', _source, item)
        end)
    end

    for _, item in pairs(Config.ReviveItems) do
        exports.vorp_inventory:registerUsableItem(item.item, function(data)
            if HasPlayertJob(data.source, item.job) then
                TriggerClientEvent("aprts_medicalAtention:Client:revive", data.source, item)
            else
                notify(data.source, "Nemáš pocit že by tohle pomáhalo")
            end
        end)
    end
end)
