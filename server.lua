-- File: server.lua
for _, item in pairs(Config.Items) do
    exports.vorp_inventory:registerUsableItem(item.item, function(data)
        TriggerClientEvent("aprts_attachments:client:toggelAttachement", data.source, item.item)
        exports.vorp_inventory:closeInventory(data.source)

    end)
end

local playerAttachments = {} -- Tabulka pro uchovávání attachmentů na serveru

-- Přidání attachmentu hráči
RegisterServerEvent('aprts_attachments:server:Equip')
AddEventHandler('aprts_attachments:server:Equip', function(item, attachment)
    local _source = source

    -- Inicializace tabulky pro hráče, pokud ještě neexistuje
    if not playerAttachments[_source] then
        playerAttachments[_source] = {}
    end

    -- Přidání attachmentu do tabulky
    table.insert(playerAttachments[_source], attachment)

    -- Odeslání informací ostatním hráčům
    TriggerClientEvent('aprts_attachments:client:Equip', -1, _source, attachment)
end)

-- Odebrání attachmentu hráči
RegisterServerEvent('aprts_attachments:server:UnEquip')
AddEventHandler('aprts_attachments:server:UnEquip', function(item)
    local _source = source

    if playerAttachments[_source] then
        for i, attachment in ipairs(playerAttachments[_source]) do
            if attachment.item == item then
                table.remove(playerAttachments[_source], i)
                break
            end
        end
    end

    -- Odeslání informací ostatním hráčům
    TriggerClientEvent('aprts_attachments:client:UnEquip', -1, _source, item)
end)

-- Požadavek na synchronizaci aktuálního stavu attachmentů
RegisterServerEvent('aprts_attachments:server:RequestSync')
AddEventHandler('aprts_attachments:server:RequestSync', function()
    local _source = source
    TriggerClientEvent('aprts_attachments:client:Sync', _source, playerAttachments)
end)

-- Požadavek na attachmenty konkrétního hráče
RegisterServerEvent('aprts_attachments:server:RequestPlayerAttachments')
AddEventHandler('aprts_attachments:server:RequestPlayerAttachments', function(playerId)
    local _source = source
    if playerAttachments[playerId] then
        TriggerClientEvent('aprts_attachments:client:SyncPlayerAttachments', _source, playerId,
            playerAttachments[playerId])
    end
end)


-- Čištění dat při odpojení hráče
AddEventHandler('playerDropped', function(reason)
    local _source = source

    if playerAttachments[_source] then
        for _, attachment in ipairs(playerAttachments[_source]) do
            TriggerClientEvent('aprts_attachments:client:UnEquip', -1, _source, attachment.item)
        end
        playerAttachments[_source] = nil
    end
end)

-- Odstranění všech attachmentů při zastavení skriptu
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    print("[aprts_attachments] Resource is stopping. Removing all attachments.")

    for playerId, attachments in pairs(playerAttachments) do
        for _, attachment in ipairs(attachments) do
            TriggerClientEvent('aprts_attachments:client:UnEquip', -1, playerId, attachment.item)
        end
    end

    playerAttachments = {} -- Vyčištění tabulky
end)
