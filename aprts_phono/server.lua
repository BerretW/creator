-- CREATE TABLE IF NOT EXISTS `aprts_phono_cylinders` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `item` varchar(50) NOT NULL,
--   `url` varchar(255) NOT NULL,
--   `coords` longtext NOT NULL,
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    if cb then cb() end
end

function AddPhonograph(handle, url, title, volume, offset, coords)
    if not Phonographs[handle] then
        title  = title or url
        volume = Clamp(volume, 0, 100, 50)
        offset = offset or 0

        Phonographs[handle] = {
            url       = url,
            title     = title,
            volume    = volume,
            startTime = os.time() - offset,
            offset    = 0,
            paused    = nil,
            coords    = coords  -- Můžeme si ukládat i reálné coords pro info
        }

        Enqueue(SyncQueue, function()
            TriggerClientEvent('phonograph:play', -1, handle)
        end)
    end
end

function RemovePhonograph(handle)
    print('phonograph:stop', handle)
    Phonographs[handle] = nil
    Enqueue(SyncQueue, function()
        TriggerClientEvent('phonograph:stop', -1, handle)
    end)
end

-- Hlavní start event
AddEventHandler('phonograph:start', function(handle, url, volume, offset, filter, locked, video, videoSize, muted, coords)
    if coords then
        -- spočítáme handle z reálných coords
        handle = GetHandleFromCoords(coords)
    end
    if Phonographs[handle] then
        -- Pokud už existuje, ignorujeme (zde)
        return
    end

    AddPhonograph(handle, url, url, volume, offset, coords)
    TriggerClientEvent('phonograph:start', -1, handle, url, url, volume, offset, false, false, false, 50, false, coords)
end)

-- Sync offset co půl sekundy, minimální zátěž
CreateThread(function()
    while true do
        Wait(500)
        for _, info in pairs(Phonographs) do
            if not info.paused then
                info.offset = os.time() - info.startTime
            end
        end
        Dequeue(SyncQueue)
    end
end)

-------------------------------
-- Když se hráč připojí, pošleme mu info o všech hrajících fonografech
-- (Aby je slyšel od správného offsetu)
AddEventHandler('playerJoining', function()
    local newPlayer = source
    for handle, info in pairs(Phonographs) do
        local offset = os.time() - info.startTime
        TriggerClientEvent('phonograph:start', newPlayer, handle, info.url, info.title, info.volume, offset,
            false, false, false, 50, false, info.coords)
        TriggerClientEvent('phonograph:play', newPlayer, handle)
    end
end)

---------------------------------------
-- PŘÍKLAD: Načítání itemů z DB tabulky aprts_phono
-- a registrace itemů, které při použití spustí váleček (drum).
local drums = {}
local inserterDrums = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        -- 1) Načteme drums pro usableItem
        MySQL:execute('SELECT * FROM aprts_phono', {}, function(results)
            drums = results
            for _, drum in pairs(drums) do
                if drum.item then
                    exports.vorp_inventory:registerUsableItem(drum.item, function(data)
                        local _source = data.source
                        exports.vorp_inventory:closeInventory(_source)
                        -- Po použití => vyvoláme phonograph:Client:insertDrum (na clientu)
                        TriggerClientEvent("phonograph:Client:insertDrum", _source, drum)
                    end)
                end
            end
        end)

        -- 2) Načteme existující cylinders (válečky) z aprts_phono_cylinders
        MySQL:execute('SELECT * FROM aprts_phono_cylinders', {}, function(results)
            for _, drum in pairs(results) do
                local c = json.decode(drum.coords)
                -- Uložíme do tabulky
                table.insert(inserterDrums, {
                    id    = drum.id,
                    item  = drum.item,
                    url   = drum.url,
                    coords= c -- {x=..., y=..., z=...}
                })
                -- Můžeš rovnou spustit fonograph tady, pokud ho chceš slyšet hned po restartu
                local handle = GetHandleFromCoords(c)
                AddPhonograph(handle, drum.url, drum.url, 25, 0, c)
                TriggerClientEvent('phonograph:start', -1, handle, drum.url, drum.url, 25, 0,
                    false, false, false, 50, false, c)
            end
        end)
    end
end)

-- Vypomocná funkce na vzdálenost dvou vektorů
local function distance(coordsA, coordsB)
    local vA = vector3(coordsA.x, coordsA.y, coordsA.z)
    local vB = vector3(coordsB.x, coordsB.y, coordsB.z)
    return #(vA - vB)
end

-- Vloží drum do fonografu (DB) => vymaže starý (pokud je “stejný” = malá tolerance)
RegisterServerEvent('phonograph:Server:insertDrum')
AddEventHandler('phonograph:Server:insertDrum', function(item, coords, drumURL)
    local _source = source
    -- coords je reálný vektor (x,y,z), uložme ho do DB
    -- ale nejdřív odstraň starý drum, pokud je “příliš blízko”

    for i, drum in ipairs(inserterDrums) do
        local dist = distance(drum.coords, coords)
        -- tolerance, např. 0.2 metru
        if dist < 0.2 then
            -- Odstraníme starý z DB
            MySQL:execute('DELETE FROM aprts_phono_cylinders WHERE id = ?', {drum.id})
            exports.vorp_inventory:addItem(_source, drum.item, 1)
            table.remove(inserterDrums, i)
            -- Zrušíme starý fonograph
            local handle = GetHandleFromCoords(drum.coords)
            RemovePhonograph(handle)
            break
        end
    end

    -- Vložíme do DB
    local cjson = json.encode(coords)
    MySQL:insert('INSERT INTO aprts_phono_cylinders (item, url, coords) VALUES (?, ?, ?)', {item, drumURL, cjson},
    function(insertId)
        if insertId then
            table.insert(inserterDrums, {
                id     = insertId,
                item   = item,
                url    = drumURL,
                coords = coords
            })
            print(("Inserted drum %s %s [id=%d]"):format(item, drumURL, insertId))
        end
    end)
    -- Odeber item z inventáře
    exports.vorp_inventory:subItem(_source, item, 1)
end)

-- Odstraní existující drum z fonografu (a vrátí item do inv)
RegisterServerEvent("phonograph:Server:removeDrum")
AddEventHandler("phonograph:Server:removeDrum", function(coordsHash)
    local _source = source
    -- V původní verzi jsi sem posílal handle => teď je to spíš handle
    -- anebo voláš to Prompt? (playDrum ... removeDrum... atp.)
    -- Tady to tedy interpretujeme jako "handle", tak najdeme reálné coords v inserterDrums.
    for i, drum in ipairs(inserterDrums) do
        local handleDrum = GetHandleFromCoords(drum.coords)

        if coordsHash == handleDrum then
            -- Smažeme z DB
            MySQL:execute('DELETE FROM aprts_phono_cylinders WHERE id = ?', {drum.id})
            exports.vorp_inventory:addItem(_source, drum.item, 1)
            table.remove(inserterDrums, i)
            -- Zrušíme fonograph
            RemovePhonograph(coordsHash)
            break
        end
    end
end)

-- Přehrát Drum => najdeme drum v tabulce podle handle
RegisterServerEvent("phonograph:Server:playDrum")
AddEventHandler("phonograph:Server:playDrum", function(coordsHash)
    for _, drum in ipairs(inserterDrums) do
        local handleDrum = GetHandleFromCoords(drum.coords)
        if coordsHash == handleDrum then
            -- Spustíme hudbu pro VŠECHNY ( -1 ), ať to slyší kdokoli poblíž
            TriggerClientEvent('phonograph:Client:play', -1, drum)
            break
        end
    end
end)
