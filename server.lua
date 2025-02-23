-- Exportování struktury pro tabulka s29_dev-redm.aprts_phono_cylinders
-- CREATE TABLE IF NOT EXISTS `aprts_phono_cylinders` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `item` varchar(50) NOT NULL,
--   `url` varchar(255) NOT NULL,
--   `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`coords`)),
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- Minimalistická verze server.lua
--  - Přidává a odebírá "Phonograph" do tabulky Phonographs
--  - Spouští hudbu z eventu "phonograph:start"
--  - Umožňuje načíst itemy z DB, které po použití spustí hudbu (TriggerClientEvent)
local Phonographs = {}
local SyncQueue = {}
local MySQL = exports.oxmysql

-- SERVER EVENTY
RegisterNetEvent('phonograph:start')

function Enqueue(queue, cb)
    table.insert(queue, 1, cb)
end

function Dequeue(queue)
    local cb = table.remove(queue)
    if cb then
        cb()
    end
end

-- Přidá phonograph do server tabulky
function AddPhonograph(handle, url, title, volume, offset, coords)
    if not Phonographs[handle] then
        title = title or url
        volume = Clamp(volume, 0, 100, 50)
        offset = offset or 0

        Phonographs[handle] = {
            url = url,
            title = title,
            volume = volume,
            startTime = os.time() - offset,
            offset = 0,
            paused = nil
        }

        -- Po přidání odešleme informaci klientům, ať se to hned "pustí"
        Enqueue(SyncQueue, function()
            TriggerClientEvent('phonograph:play', -1, handle)
        end)
    end
end

function RemovePhonograph(handle)
    Phonographs[handle] = nil
    Enqueue(SyncQueue, function()
        TriggerClientEvent('phonograph:stop', -1, handle)
    end)
end

-- Hlavní start event
AddEventHandler('phonograph:start',
    function(handle, url, volume, offset, filter, locked, video, videoSize, muted, coords)
        local _source = source
        print("Starting phonograph", handle, url, volume, offset, filter, locked, video, videoSize, muted, coords)
        -- Pokud handle == nil, ale coords != nil => handle spočítáme z coords
        if coords then
            handle = GetHandleFromCoords(coords)
        end

        if Phonographs[handle] then
            -- Pokud už existuje, nic nedělej (minimal verze ignoruje)
            return
        end

        -- Vložíme do "Phonographs" a pošleme klientům
        AddPhonograph(handle, url, url, volume, offset, coords)
        -- Všichni klienti si to musí "initnout"
        TriggerClientEvent('phonograph:start', -1, handle, url, url, volume, offset, false, false, false, 50, false,
            coords)
    end)

-- SYNC FUNGOVAL DŘÍVE - TEĎ HO MÁME ZJEDNODUŠENÝ
CreateThread(function()
    while true do
        Wait(500)
        for handle, info in pairs(Phonographs) do
            if not info.paused then
                info.offset = os.time() - info.startTime
            end
        end
        Dequeue(SyncQueue)
    end
end)

---------------------------------------
-- PŘÍKLAD: Načítání itemů z DB tabulky aprts_phono
-- a registrace itemů, které při použití spustí váleček.

local drums = {}
local inserterDrums = {}
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute('SELECT * FROM aprts_phono', {}, function(results)
            drums = results
            for _, drum in pairs(drums) do
                if drum.item then
                    exports.vorp_inventory:registerUsableItem(drum.item, function(data)
                        local _source = data.source
                        exports.vorp_inventory:closeInventory(_source)
                        -- Po použití itemu spustíme přehrávání
                        -- TriggerClientEvent => fonograf, abychom měli 3D audio u fonografu poblíž
                        -- TriggerClientEvent('phonograph:Client:play', _source, drum)
                        TriggerClientEvent("phonograph:Client:insertDrum", _source, drum)
                    end)
                end
            end
        end)
        MySQL:execute('SELECT * FROM aprts_phono_cylinders', {}, function(results)
            for _, drum in pairs(results) do
                drum.coords = json.decode(drum.coords)
                table.insert(inserterDrums, drum)
            end
        end)
    end
end)

function distance(vector, coords)
    local coords = vector3(coords.x, coords.y, coords.z)
    return #(vector - coords)
end

RegisterServerEvent('phonograph:Server:insertDrum')
AddEventHandler('phonograph:Server:insertDrum', function(item, coords, drumURL)
    -- add Drum to table, if there is another drum on the same coords, remove it and give it to players inventory
    local _source = source
    local coords = GetHandleFromCoords(coords)
    for i, drum in ipairs(inserterDrums) do
        if coords == drum.coords then
            MySQL:execute('DELETE FROM aprts_phono_cylinders WHERE id = ?', {drum.id})
            exports.vorp_inventory:addItem(_source, drum.item, 1)

            table.remove(inserterDrums, i)
            RemovePhonograph(coords)
            break
        end
    end
    MySQL:execute('INSERT INTO aprts_phono_cylinders (item, url, coords) VALUES (?, ?, ?)', {item, drumURL, coords},
        function(result)
            -- print(json.encode(insertId))
            print("Inserted drum", item, drumURL, coords, result.insertId)
            table.insert(inserterDrums, {
                id = result.insertId,
                item = item,
                url = drumURL,
                coords = coords
            })
        end)
    exports.vorp_inventory:subItem(_source, item, 1)
end)

RegisterServerEvent("phonograph:Server:removeDrum")
AddEventHandler("phonograph:Server:removeDrum", function(coords)
    local _source = source
    print("Removing drum", coords)
    for i, drum in ipairs(inserterDrums) do
        if coords == drum.coords then
            MySQL:execute('DELETE FROM aprts_phono_cylinders WHERE id = ?', {drum.id})
            exports.vorp_inventory:addItem(_source, drum.item, 1)
            table.remove(inserterDrums, i)
            RemovePhonograph(coords)
            break
        end
    end
end)

RegisterServerEvent("phonograph:Server:playDrum")
AddEventHandler("phonograph:Server:playDrum", function(coords)
    local _source = source
    for i, drum in ipairs(inserterDrums) do
        print("Searching drum", coords, drum.coords)
        if coords == drum.coords then
            print("Drum found")
            TriggerClientEvent('phonograph:Client:play', -1, drum)
            break
        end
    end
end)
