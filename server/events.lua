AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute('SELECT * FROM books', {}, function(results)
        
            for _, book in pairs(results) do
                Books[book.id] = book
            end
        end)
        -- MySQL:execute("SELECT * FROM aprts_clues", {}, function(result)
        --     for k, v in pairs(result) do
        --         v.coords = json.decode(v.coords)
        --         clues[v.id] = v

        --     end
        --     TriggerClientEvent("aprts_clue:Client:LoadClues", -1, clues)
        -- end)
    end
end)

-- RegisterServerEvent("aprts_vzor:Server:RegisterInventory")
-- AddEventHandler("aprts_vzor:Server:RegisterInventory", function(inventoryName, prefix,shared,weapons,itemLimit, weightLimit)
--     local _source = source
--     local stor_id = Player(_source).state.Character.CharId

--     local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(prefix .. tostring(stor_id))

--     if isRegistered then
--         debgPrint("Inventář " .. prefix .. tostring(stor_id) .. " je již zaregistrovaný")
--         exports.vorp_inventory:removeInventory(prefix .. tostring(stor_id))
--     end

--     local data = {
--         id = prefix .. tostring(stor_id),
--         name = inventoryName,
--         limit = itemLimit,
--         acceptWeapons = weapons,
--         shared = shared,
--         ignoreItemStackLimit = true,
--         whitelistItems = false,
--         UsePermissions = false,
--         UseBlackList = false,
--         whitelistWeapons = false,
--         useWeight = true,
--         weight = weightLimit
--     }
--     exports.vorp_inventory:registerInventory(data)
-- end)

RegisterServerEvent("aprts_vzor:Server:log", function(eventName, playerMessage)
    local _source = source
    if _source then
        local firstname = Player(_source).state.Character.FirstName
        local lastname = Player(_source).state.Character.LastName

        local playerName = firstname .. " " .. lastname
        local player = _source
        local ped = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(ped)
        local message = {
            characterID = Player(_source).state.Character.CharId,
            playerName = playerName,
            playerJob = Player(_source).state.Character.Job,
            playerGrade = Player(_source).state.Character.Grade,
            playerJoblabel = Player(_source).state.Character.JobLabel,
            coords = playerCoords
        }
        table.merge(message, playerMessage)
        lib.logger(_source, eventName, message)
    end
end)

AddEventHandler("vorp_inventory:useItem")
RegisterServerEvent("vorp_inventory:useItem", function(data)
    local _source = source
    local itemName = data.item
    if itemName == "library_book" then
        exports.vorp_inventory:getItemByMainId(_source, data.id, function(data)
            if data == nil then
                return
            end
            local metadata = data.metadata
            if metadata then
                print(json.encode(metadata))
                exports.vorp_inventory:closeInventory(_source)
                TriggerClientEvent("books:openBookID", _source, metadata.bookID)
            end
        end)
    elseif itemName == "library_newspaper" then
        exports.vorp_inventory:getItemByMainId(_source, data.id, function(data)
            if data == nil then
                return
            end
            local metadata = data.metadata
            if metadata then
                print(json.encode(metadata))
                exports.vorp_inventory:closeInventory(_source)
                
            end
        end)
    elseif itemName == "library_poster" then
        exports.vorp_inventory:getItemByMainId(_source, data.id, function(data)
            if data == nil then
                return
            end
            local metadata = data.metadata
            if metadata then
                print(json.encode(metadata))
                exports.vorp_inventory:closeInventory(_source)
                
            end
        end)
    end
end)


RegisterServerEvent("aprts_library:Server:addBook")
AddEventHandler("aprts_library:Server:addBook", function(id)
    local _source = source
    local book = Books[id]
    local metadata = {
        custom_name = book.title .. " - " .. book.author,
        bookID = id
    }
    
    exports.vorp_inventory:addItem(_source, "library_book", 1, metadata)
end)