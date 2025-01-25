RegisterServerEvent("aprts_diary:Server:saveDiary")
AddEventHandler("aprts_diary:Server:saveDiary", function(data)
    local _source = source
    

    -- Uložit data deníku
    exports.vorp_inventory:setItemMetadata(_source, data.diary_id, data)
    notify(_source, "Diary saved")
    debugPrint("Diary saved")
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        for _, diary in pairs(Config.diaryTypes) do
            exports.vorp_inventory:registerUsableItem(diary.item, function(data)
                local _source = data.source
                local metadata = data.item.metadata
                exports.vorp_inventory:closeInventory(data.source)
                debugPrint("Loaded diary: " .. json.encode(data))
                
                -- Check if metadata is valid
                if not metadata then
                    metadata = {}
                end
                 -- Check if diary has pages from config
                if not metadata.pages then
                  metadata.pages = diary.pages
                 end
                metadata.diary_id = data.item.mainid
                local colors = {}
                for _, pen in pairs(Config.pens) do
                    if exports.vorp_inventory:getItem(_source, pen.item) then
                        table.insert(colors, pen.color)
                    end
                end
                TriggerClientEvent("aprts_diary:Client:openDiary", _source, metadata, colors)

            end)
        end
    end
end)