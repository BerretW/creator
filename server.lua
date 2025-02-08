local sleeping = {}
local Core = exports.vorp_core:GetCore()
local players = {}

function debugPrint(msg)
    if Config.Debug == true then
        print(msg)
    end
end

AddEventHandler('playerDropped', function(reason)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local charid = tonumber(Character.charIdentifier)
    local gender = Character.gender
    local coords = GetEntityCoords(GetPlayerPed(_source))
    -- print("Player " .. charid .. " disconnected at " .. coords.x .. " " .. coords.y .. " " .. coords.z)
    TriggerEvent('aprts_sleepRP:server:Sleep', charid, coords, gender)
end)

RegisterServerEvent('aprts_sleepRP:server:getMeta')
AddEventHandler('aprts_sleepRP:server:getMeta', function(charid, meta)
    -- print("Player " .. charid .. " has meta " .. meta)
    table.insert(players, {
        charid = charid,
        meta = json.decode(meta)
    })
end)

RegisterServerEvent('aprts_sleepRP:server:Sleep')
AddEventHandler('aprts_sleepRP:server:Sleep', function(charid, coords, gender)
    if not charid then
        return
    end
    local src = source
    table.insert(sleeping, {
        charid = charid,
        coords = coords
    })
    local meta = nil
    for k, v in pairs(players) do
        if tonumber(v.charid) == tonumber(charid) then
            meta = v.meta
        end
    end
    -- insert into table aprts_sleepRP (charid, coords) MySQL.Async.execute, check if charid exists

    MySQL.Async.execute(
        'INSERT INTO aprts_sleepRP (charID, coords,gender,meta) VALUES (@charid, @coords,@gender,@meta)', {
            ['@charid'] = charid,
            ['@coords'] = json.encode(coords),
            ['@gender'] = gender,
            ['@meta'] = json.encode(meta)

        }, function(rowsChanged)
            -- print("Player " .. charid .. " slept at " .. coords.x .. " " .. coords.y .. " " .. coords.z)
            TriggerClientEvent('aprts_sleepRP:client:addSleeper', -1, charid, coords, gender, meta)
        end)
end)

RegisterServerEvent('aprts_sleepRP:server:WakeUpSleeper')
AddEventHandler('aprts_sleepRP:server:WakeUpSleeper', function(charID)
    if sleeping[charID] then
        table.remove(sleeping, charID)
    end
    MySQL.Async.execute('DELETE FROM aprts_sleepRP WHERE charID = @charid', {
        ['@charid'] = charID
    }, function(rowsChanged)
        if rowsChanged == 0 then
            -- print("Player " .. charid .. " not found in sleeping db")
            return
        end
        -- print("Player " .. charid .. " deleted from sleeping db")
        TriggerClientEvent('aprts_sleepRP:client:RemoveNPC', -1, charID)
    end)
end)
RegisterServerEvent('aprts_sleepRP:server:WakeUp')
AddEventHandler('aprts_sleepRP:server:WakeUp', function()

    local src = source
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local charid = tonumber(Character.charIdentifier)
    -- print("Player " .. charid .. " woke up")
    if sleeping[charid] then
        sleeping[charid] = nil
    end
    local coords = GetEntityCoords(GetPlayerPed(_source))

    -- delete from table aprts_sleepRP where charid = charid
    MySQL.Async.execute('DELETE FROM aprts_sleepRP WHERE charID = @charid', {
        ['@charid'] = charid
    }, function(rowsChanged)
        if rowsChanged == 0 then
            -- print("Player " .. charid .. " not found in sleeping db")
            return
        end
        -- print("Player " .. charid .. " deleted from sleeping db")
        TriggerClientEvent('aprts_sleepRP:client:RemoveNPC', -1, charid)
    end)
end)

-- RegisterCommand("wakeUp", function(source, args, rawCommand)
--     local _source = source
--     local Character = Core.getUser(_source).getUsedCharacter
--     local charid = tonumber(Character.charIdentifier)
--     local gender = Character.gender
--     -- print("gender: " .. gender)
--     TriggerClientEvent('aprts_sleepRP:client:RemoveNPC', -1, args[1])

-- end)

RegisterServerEvent('aprts_sleepRP:server:getSleepingPlayers')
AddEventHandler('aprts_sleepRP:server:getSleepingPlayers', function()
    local src = source
    sleeping = {}
    -- select * from table aprts_sleepRP where charid != charid
    MySQL.Async.fetchAll('SELECT * FROM aprts_sleepRP', {}, function(result)
        for k, v in pairs(result) do
            local coords = json.decode(v.coords)
            -- print("Adding sleeper " .. v.charID .. " slept at " .. coords.x .. " " .. coords.y .. " " .. coords.z)
            sleeping[v.charID] = {
                charid = v.charID,
                coords = coords,
                gender = v.gender,
                meta = json.decode(v.meta)
            }

            -- table.insert(sleeping, {
            --     charid = v.charID,
            --     coords = coords,
            --     gender = v.gender,
            --     meta = json.decode(v.meta)
            -- })
        end
        -- print(json.encode(sleeping))
        TriggerClientEvent('aprts_sleepRP:client:recieve', src, sleeping)
    end)
end)

RegisterServerEvent('aprts_sleepRP:server:updateSleeper')
AddEventHandler('aprts_sleepRP:server:updateSleeper', function(newSleeper, coords)
    local charid = newSleeper.charid
    sleeping[charid].coords = coords
    print(json.encode(sleeping[charid]))
    -- update table aprts_sleepRP set coords = coords where charid = charid
    MySQL.Async.execute('UPDATE aprts_sleepRP SET coords = @coords WHERE charID = @charid', {
        ['@coords'] = json.encode(coords),
        ['@charid'] = charid
    }, function(rowsChanged)
        if rowsChanged == 0 then

            return
        else
            -- update character position in table characters
            local pos = json.encode(
                { -- {"heading":158.7401580810547,"z":45.6578369140625,"y":-113.85494995117188,"x":-374.3999938964844}
                    heading = 0.0,
                    x = coords.x,
                    y = coords.y,
                    z = coords.z
                })
            MySQL.Async.execute('UPDATE characters SET coords = @coords WHERE charidentifier = @charid', {
                ['@coords'] = pos,
                ['@charid'] = charid
            }, function(rowsChanged)
                if rowsChanged == 0 then
                    sleeping[charid] = nil
                    debugPrint("Hráč nenalezen, mažu NPC")
                    TriggerClientEvent('aprts_sleepRP:client:RemoveNPC', -1, charid)
                    return

                else
                    debugPrint("Player " .. charid .. " moved to " .. coords.x .. " " .. coords.y .. " " .. coords.z)
                    TriggerClientEvent('aprts_sleepRP:client:update', -1, charid, coords)
                end
            end)

            -- remove Config.Cost from character money in db
            MySQL.Async.execute('UPDATE characters SET money = money - @cost WHERE charidentifier = @charid', {
                ['@cost'] = Config.Cost,
                ['@charid'] = charid
            }, function(rowsChanged)
            end)
        end
    end)
end)

RegisterServerEvent('aprts_sleepRP:server:log')
AddEventHandler('aprts_sleepRP:server:log', function(name, message, footer)
    DiscordWeb(name, message, footer)
end)
function DiscordWeb(name, message, footer)
    local embed = {{
        ["color"] = Config.DiscordColor,
        ["title"] = "",
        ["description"] = "**" .. name .. "** \n" .. message .. "\n\n",
        ["footer"] = {
            ["text"] = footer
        }
    }}
    PerformHttpRequest(Config.WebHook, function(err, text, headers)
    end, 'POST', json.encode({
        username = Config.ServerName,
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end
