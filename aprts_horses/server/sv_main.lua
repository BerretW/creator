Core = exports.vorp_core:GetCore()

local playerTimeouts = {}

-- Helper Functions
local function debugPrint(msg)
    if Config.Debug == true then
        print(msg)
    end
end

local function notify(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "Koně", message, 4000)
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function DiscordWeb(name, message, footer)
    local embed = {{
        ["color"] = Config.DiscordColor,
        ["title"] = "",
        ["description"] = "**" .. name .. "** \n" .. message .. "\n\n",
        ["footer"] = {
            ["text"] = footer or ""
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

-- Cache for Horses and Components
local HorseComp = {}
local Horses = {}

-- Utility Functions
local function getItemCategory(item)
    for _, category in pairs(HorseComp) do
        for _, comp in pairs(category) do
            if comp.item == item then
                return category
            end
        end
    end
    return nil
end

local function getItemByHash(hash)
    for _, category in pairs(HorseComp) do
        for _, comp in pairs(category) do
            if comp.hash == hash then
                return comp.item
            end
        end
    end
    return nil
end

local function getInventoryLimit(horseHash)
    local horse = Horses[tostring(horseHash)]
    return horse and horse.invLimit or 20
end

local function getBaseStats(horseHash)
    for _, horse in pairs(Horses) do
        if GetHashKey(horse.horse_id) == horseHash then
            return horse.stats
        end
    end
    return nil
end

-- Event Handlers

-- Update Horse Meta
RegisterServerEvent('aprts_horses:Server:updateHorseMeta')
AddEventHandler('aprts_horses:Server:updateHorseMeta', function(horseID, meta)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        notify(_source, 'Uživatel nebyl nalezen.')
        return
    end
    local character = user.getUsedCharacter
    if not character then
        notify(_source, 'Charakter nebyl nalezen.')
        return
    end

    MySQL.execute("UPDATE aprts_stables SET `meta`=@meta WHERE `id`=@id", {
        meta = json.encode(meta),
        id = horseID
    }, function(rowsChanged, affectedRows, lastInsertId)
        if table.count(rowsChanged) == 0 then
            notify(_source, 'Něco se nepovedlo při aktualizaci metadat koně.')
        else
            debugPrint("Horse meta updated: ID " .. horseID .. " Meta: " .. json.encode(meta))
            notify(_source, 'Metadata koně byla úspěšně aktualizována.')
        end
    end)
end)

-- Sell Horse (By ID or Hash)
RegisterServerEvent('aprts_horses:sellHorse')
AddEventHandler('aprts_horses:sellHorse', function(identifier, byHash)

    local _source = source
    local user = Core.getUser(_source)
    if not user then
        notify(_source, 'Uživatel nebyl nalezen.')
        return
    end
    local character = user.getUsedCharacter
    if not character then
        notify(_source, 'Charakter nebyl nalezen.')
        return
    end
    local charID = Player(_source).state.Character.CharId

    if playerTimeouts[charID] and os.time() - playerTimeouts[charID] < Config.SellTimeout and byHash then

        local remainingTime = Config.SellTimeout - (os.time() - playerTimeouts[charID])
        notify(_source, "Počkejte prosím ještě " .. string.format("%.2f", remainingTime / 60) ..
            "m před dalším prodejem koně.")
        return
    end

    local price = 0
    if byHash == nil then
        local query = "SELECT * FROM aprts_stables WHERE `id`=@id"
        local params = {
            id = identifier
        }

        MySQL.query(query, params, function(result)
            if result[1] then
                local horseData = result[1]
                for _, horse in pairs(Horses) do
                    if GetHashKey(horse.horse_id) == tonumber(horseData.vehicles) then
                        price = math.floor(horse.cashPrice / Config.Sell)
                        break
                    end
                end

                if price < 1 then
                    price = 30
                end

                character.addCurrency(0, price)
                MySQL.execute("DELETE FROM aprts_stables WHERE `id`=@id", {
                    id = horseData.id
                }, function(rowsChanged, affectedRows, lastInsertId)
                    if table.count(rowsChanged) == 0 then
                        notify(_source, 'Něco se nepovedlo při prodeji koně.')
                    else

                        notify(_source, 'Prodal jsi koně za ' .. price .. ' $.')
                    end
                end)
                -- LOGGING
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
                    coords = playerCoords,
                    horse = horseData.name,
                    horseID = (tonumber(identifier) and horseData.id or horseData.vehicles),
                    price = price
                }
                -- print("SellHorse: " .. json.encode(message))
                lib.logger(_source, 'SellHorse', message)

            else
                notify(_source, 'Kůň nebyl nalezen.')
            end
        end)
    else
        local identifed = false
        for _, horse in pairs(Horses) do
            if GetHashKey(horse.horse_id) == tonumber(identifier) then
                price = math.floor(horse.cashPrice /Config.Sell)
                notify(_source, 'Prodal jsi koně za ' .. price .. ' $.')
                TriggerClientEvent('aprts_horses:delMount', _source)
                character.addCurrency(0, price)
                identifed = true
                break
            end
        end
        if identifed == false then
            price = 50
            notify(_source, 'Prodal jsi koně za ' .. price .. ' $.')
            TriggerClientEvent('aprts_horses:delMount', _source)
            character.addCurrency(0, price)

        end
    end
    if price > 0 and byHash then
        playerTimeouts[charID] = os.time()
    end
end)

-- Get Horse Data
RegisterServerEvent('aprts_horses:getHorse')
AddEventHandler('aprts_horses:getHorse', function()
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        notify(_source, 'Uživatel nebyl nalezen.')
        return
    end
    local character = user.getUsedCharacter
    if not character then
        notify(_source, 'Charakter nebyl nalezen.')
        return
    end

    local charid = character.charIdentifier
    local identifier = character.identifier
    local currentTime = os.time()

    MySQL.query(
        'SELECT *, UNIX_TIMESTAMP(shoed_time) as shoed_time_unix FROM aprts_stables WHERE `identifier`=@identifier AND `charid`=@charid AND `type`=@type AND `default`=1 LIMIT 1;',
        {
            identifier = identifier,
            charid = charid,
            type = 'horse'
        }, function(horses)
            if horses[1] then
                local horse = horses[1]
                local attributes = json.decode(horse.Att)

                -- Handle shoed logic
                if horse.shoed == 1 then
                    local lastShoe = horse.shoed_time_unix or 0
                    local diff = currentTime - lastShoe
                    if diff > Config.shoeTime * 24 * 60 * 60 then
                        MySQL.execute("UPDATE aprts_stables SET `shoed`=0 WHERE `id`=@id", {
                            id = horse.id
                        }, function(rowsChanged, affectedRows, lastInsertId)
                            if table.count(rowsChanged) > 0 then
                                horse.shoed = 0
                                notify(_source, "Kůň již nemá nasazené podkovy.")
                            else
                                notify(_source, "Něco se nepovedlo při odstraňování podkov.")
                            end
                        end)
                    else
                        attributes.PA_AGILITY.Points = attributes.PA_AGILITY.Points + Config.shoeBonus
                    end
                end

                DiscordWeb("Zavolání koně!", "Hráč " .. GetPlayerName(_source) .. " zavolal koně " .. horse.name,
                    "ID: " .. horse.id)

                -- Inventory Management
                local inventoryId = Config.InventoryPrefix .. tostring(horse.id)
                local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(inventoryId)

                if isRegistered then
                    exports.vorp_inventory:removeInventory(inventoryId)
                end

                Wait(50)

                local limit = getInventoryLimit(horse.vehicles)
                debugPrint("Inventory Limit: " .. limit)

                exports.vorp_inventory:registerInventory({
                    id = inventoryId,
                    name = "Brašny u koně " .. tostring(horse.id),
                    limit = 10000,
                    acceptWeapons = false,
                    shared = true,
                    ignoreItemStackLimit = false,
                    whitelistItems = false,
                    UsePermissions = false,
                    UseBlackList = false,
                    whitelistWeapons = false,
                    useWeight = true,
                    weight = tonumber(limit)
                })

                -- Decode meta and cAtt
                local meta = json.decode(horse.meta)
                local cAtt = json.decode(horse.cAtt or '{}')
                local comp = horse.comp

                -- Trigger client to spawn horse
                TriggerClientEvent("aprts_horses:spawnHorse", _source, horse.vehicles, horse.name, horse.id, meta, comp,
                    cAtt, attributes, horse.gender, horse.age, horse.shoed)
            else
                notify(_source, "Výchozí kůň nebyl nalezen.")
            end
        end)

    -- Update all horses to stabled = 0 except the default one
    MySQL.execute(
        "UPDATE aprts_stables SET `stabled`=0 WHERE `identifier`=@identifier AND `charid`=@charid AND `type`=@type AND `default`!=1",
        {
            identifier = character.identifier,
            charid = character.charIdentifier,
            type = 'horse'
        }, function(rowsChanged, affectedRows, lastInsertId)
            if table.count(rowsChanged) < 0 then
                debugPrint("Něco se nepovedlo při aktualizaci stavu koní.")
            end
        end)
end)

RegisterServerEvent('aprts_horses:newVehicle')
AddEventHandler('aprts_horses:newVehicle', function(vehHash, vehType, vehName, metatag, horseBreed)
    local _source = source

    local charID = Player(_source).state.Character.CharId

    if playerTimeouts[charID] and os.time() - playerTimeouts[charID] < Config.SellTimeout then

        local remainingTime = Config.SellTimeout - (os.time() - playerTimeouts[charID])
        notify(source, "Počkejte prosím ještě " .. string.format("%.2f", remainingTime / 60) ..
            "m před dalším prodejem koně.")
        return
    end

    local Character = Core.getUser(_source).getUsedCharacter
    local charid = Character.charIdentifier
    local money = Character.money
    local baseStats = getBaseStats(vehHash)
    if not baseStats then
        notify(_source, "Neznámý druh koně.(vehHash: " .. vehHash .. ")")
        return
    end
    local cAtt = json.decode('{"CoreHealth":100,"Stamina":240.0,"Health":240,"CoreStamina":100}')

    local Att = json.decode(
        '{"SA_POISONED":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_POISONED","index":11},"MTR_STRENGTH":{"BonusRank":0,"Rank":0,"Points":0,"Name":"MTR_STRENGTH","index":18},"PA_SPECIALABILITY":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_SPECIALABILITY","index":2},"PA_STAMINA":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_STAMINA","index":1},"SA_BODYWEIGHT":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_BODYWEIGHT","index":13},"SA_INEBRIATED":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_INEBRIATED","index":10},"SA_DIRTINESSSKIN":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_DIRTINESSSKIN","index":22},"PA_HEALTH":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_HEALTH","index":0},"PA_COURAGE":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_COURAGE","index":3},"SA_DIRTINESS":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_DIRTINESS","index":16},"PA_AGILITY":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_AGILITY","index":4},"SA_OVERFED":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_OVERFED","index":14},"SA_SICKNESS":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_SICKNESS","index":15},"SA_BODYHEAT":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_BODYHEAT","index":12},"PA_SPEED":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_SPEED","index":5},"SA_DIRTINESSHAT":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_DIRTINESSHAT","index":17},"MTR_INSTINCT":{"BonusRank":0,"Rank":0,"Points":0,"Name":"MTR_INSTINCT","index":20},"SA_HUNGER":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_HUNGER","index":8},"PA_ACCELERATION":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_ACCELERATION","index":6},"PA_BONDING":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_BONDING","index":7},"PA_UNRULINESS":{"BonusRank":0,"Rank":0,"Points":0,"Name":"PA_UNRULINESS","index":21},"SA_FATIGUED":{"BonusRank":0,"Rank":0,"Points":0,"Name":"SA_FATIGUED","index":9},"MTR_GRIT":{"BonusRank":0,"Rank":0,"Points":0,"Name":"MTR_GRIT","index":19}}')
    -- find horseBase 
    Att.PA_HEALTH.Points = 1700
    Att.PA_STAMINA.Points = baseStats.Sta
    Att.PA_SPEED.Points = baseStats.Spd
    Att.PA_ACCELERATION.Points = baseStats.Acc
    Att.PA_AGILITY.Points = baseStats.Agi
    Att.MTR_STRENGTH.Points = baseStats.Str
    Att.PA_BONDING.Points = 0

    MySQL.Async.fetchAll('SELECT * FROM aprts_stables WHERE `identifier`=@identifier AND `charid`=@charid;', {
        identifier = Character.identifier,
        charid = charid
    }, function(horses)
        local count = #horses
        local nameInUse = false

        if count < Config.StableSlots then
            DiscordWeb("Koupení Koně", "Hráč " .. GetPlayerName(_source) .. " koupil koně " .. vehName,
                "ID: " .. vehHash)
            MySQL.Async.execute(
                'INSERT INTO aprts_stables (`identifier`, `charid`, `vehicles`, `name`, `type`, `meta`, `breed`, `cAtt`, `Att`) VALUES (@identifier, @charid, @vehicles, @name, @kind, @meta, @breed, @coreAtt,@Att);',
                {
                    identifier = Character.identifier,
                    charid = charid,
                    vehicles = vehHash,
                    name = vehName,
                    kind = vehType,
                    meta = json.encode(metatag),
                    breed = horseBreed,
                    coreAtt = json.encode(cAtt),
                    Att = json.encode(Att)
                })
            notify(_source, "Kůň zakoupen")
            TriggerClientEvent("aprts_horses:delMount", _source)
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
                    coords = playerCoords,
                    breed = horseBreed,
                    name = vehName
                }
                lib.logger(_source, 'StableHorse', message)
            end

            playerTimeouts[charID] = os.time()

        else
            notify(_source, "Tvoje stáj je plná")
        end
    end)

end)

-- Stable Horse
RegisterServerEvent('aprts_horses:stableHorse')
AddEventHandler('aprts_horses:stableHorse', function(id)
    local _source = source
    MySQL.execute("UPDATE aprts_stables SET `stabled`=1 WHERE id=@id", {
        id = id
    }, function(rowsChanged, affectedRows, lastInsertId)
        if table.count(rowsChanged) == 0 then
            notify(_source, "Koně se nepodařilo uložit do stáje!")
        else
            notify(_source, "Koně byl uložen do stáje.")
        end
    end)
end)

-- Buy Horse
RegisterServerEvent('aprts_horses:buyHorse')
AddEventHandler('aprts_horses:buyHorse',
    function(vehHash, vehType, vehName, metatag, horseBreed, price, baseStats, horseGender)
        local _source = source
        local user = Core.getUser(_source)
        if not user then
            notify(_source, 'Uživatel nebyl nalezen.')
            return
        end
        local character = user.getUsedCharacter
        if not character then
            notify(_source, 'Charakter nebyl nalezen.')
            return
        end

        local charid = character.charIdentifier
        local identifier = character.identifier
        local money = character.money
        local priceNum = tonumber(price)

        if priceNum > money then
            notify(_source, "Nemáš dostatek peněz.")
            return
        end

        MySQL.query('SELECT COUNT(*) as count FROM aprts_stables WHERE `identifier`=@identifier AND `charid`=@charid;',
            {
                identifier = identifier,
                charid = charid
            }, function(result)
                local count = result[1].count or 0

                if count < Config.StableSlots then
                    local cAtt = {
                        CoreHealth = 100,
                        Stamina = 240.0,
                        Health = 240,
                        CoreStamina = 100
                    }

                    local Att = {
                        SA_POISONED = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_POISONED",
                            index = 11
                        },
                        MTR_STRENGTH = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "MTR_STRENGTH",
                            index = 18
                        },
                        PA_SPECIALABILITY = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_SPECIALABILITY",
                            index = 2
                        },
                        PA_STAMINA = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_STAMINA",
                            index = 1
                        },
                        SA_BODYWEIGHT = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_BODYWEIGHT",
                            index = 13
                        },
                        SA_INEBRIATED = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_INEBRIATED",
                            index = 10
                        },
                        SA_DIRTINESSSKIN = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_DIRTINESSSKIN",
                            index = 22
                        },
                        PA_HEALTH = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_HEALTH",
                            index = 0
                        },
                        PA_COURAGE = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_COURAGE",
                            index = 3
                        },
                        SA_DIRTINESS = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_DIRTINESS",
                            index = 16
                        },
                        PA_AGILITY = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_AGILITY",
                            index = 4
                        },
                        SA_OVERFED = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_OVERFED",
                            index = 14
                        },
                        SA_SICKNESS = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_SICKNESS",
                            index = 15
                        },
                        SA_BODYHEAT = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_BODYHEAT",
                            index = 12
                        },
                        PA_SPEED = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_SPEED",
                            index = 5
                        },
                        SA_DIRTINESSHAT = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_DIRTINESSHAT",
                            index = 17
                        },
                        MTR_INSTINCT = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "MTR_INSTINCT",
                            index = 20
                        },
                        SA_HUNGER = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_HUNGER",
                            index = 8
                        },
                        PA_ACCELERATION = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_ACCELERATION",
                            index = 6
                        },
                        PA_BONDING = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_BONDING",
                            index = 7
                        },
                        PA_UNRULINESS = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "PA_UNRULINESS",
                            index = 21
                        },
                        SA_FATIGUED = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "SA_FATIGUED",
                            index = 9
                        },
                        MTR_GRIT = {
                            BonusRank = 0,
                            Rank = 0,
                            Points = 0,
                            Name = "MTR_GRIT",
                            index = 19
                        }
                    }

                    -- Set base stats
                    Att.PA_HEALTH.Points = 1700
                    Att.PA_STAMINA.Points = baseStats.Sta
                    Att.PA_SPEED.Points = baseStats.Spd
                    Att.PA_ACCELERATION.Points = baseStats.Acc
                    Att.PA_AGILITY.Points = baseStats.Agi
                    Att.MTR_STRENGTH.Points = baseStats.Str
                    Att.PA_BONDING.Points = 0

                    MySQL.execute(
                        'INSERT INTO aprts_stables (`identifier`, `charid`, `vehicles`, `name`, `type`, `meta`, `breed`, `cAtt`, `Att`, `gender`) VALUES (@identifier, @charid, @vehicles, @name, @type, @meta, @breed, @cAtt, @Att, @gender);',
                        {
                            identifier = identifier,
                            charid = charid,
                            vehicles = vehHash,
                            name = vehName,
                            type = vehType,
                            meta = json.encode(metatag),
                            breed = horseBreed,
                            cAtt = json.encode(cAtt),
                            Att = json.encode(Att),
                            gender = horseGender
                        }, function(rowsChanged, affectedRows, lastInsertId)
                            if table.count(rowsChanged) > 0 then
                                character.removeCurrency(0, priceNum)
                                notify(_source, "Kůň byl úspěšně zakoupen.")
                                DiscordWeb("Koupení Koně",
                                    "Hráč " .. GetPlayerName(_source) .. " koupil koně " .. vehName .. " za " ..
                                        priceNum .. " $", "ID: " .. vehHash)

                            else
                                notify(_source, "Něco se nepovedlo při nákupu koně.")
                            end
                        end)
                    if _source then
                        local firstname = Player(_source).state.Character.FirstName
                        local lastname = Player(_source).state.Character.LastName

                        local playerName = firstname .. " " .. lastname
                        local player = _source
                        local ped = GetPlayerPed(player)
                        local playerCoords = GetEntityCoords(ped)
                        -- (vehHash, vehType, vehName, metatag, horseBreed, price, baseStats, horseGender)
                        local message = {
                            characterID = Player(_source).state.Character.CharId,
                            playerName = playerName,
                            playerJob = Player(_source).state.Character.Job,
                            playerGrade = Player(_source).state.Character.Grade,
                            playerJoblabel = Player(_source).state.Character.JobLabel,
                            coords = playerCoords,
                            horse = vehHash,
                            breed = horseBreed,
                            gender = horseGender,
                            name = vehName,
                            price = price
                        }
                        lib.logger(_source, 'BuyHorse', message)
                    end
                else
                    notify(_source, "Tvoje stáj je plná.")
                end
            end)
    end)

-- Define Horse
RegisterServerEvent('aprts_horses:Server:defHorse')
AddEventHandler('aprts_horses:Server:defHorse', function(horseID)
    local _source = source
    debugPrint("Setting default horse to ID: " .. horseID)

    local user = Core.getUser(_source)
    if not user then
        notify(_source, 'Uživatel nebyl nalezen.')
        return
    end
    local character = user.getUsedCharacter
    if not character then
        notify(_source, 'Charakter nebyl nalezen.')
        return
    end

    local charid = character.charIdentifier

    -- Begin atomic operation using nested callbacks
    MySQL.execute("UPDATE aprts_stables SET `default`=0 WHERE `charid`=@charid", {
        charid = charid
    }, function(rowsChanged1, affectedRows1, lastInsertId1)
        if table.count(rowsChanged1) < 0 then
            notify(_source, "Něco se nepovedlo při zrušení předchozího výchozího koně.")
            debugPrint("Error resetting default horse for charid: " .. charid)
            return
        end

        MySQL.execute("UPDATE aprts_stables SET `default`=1 WHERE `id`=@horseid AND `charid`=@charid", {
            horseid = horseID,
            charid = charid
        }, function(rowsChanged2, affectedRows2, lastInsertId2)
            if table.count(rowsChanged2) == 0 then
                notify(_source, "Něco se nepovedlo při nastavení nového výchozího koně.")
                debugPrint("Error setting default horse. HorseID: " .. horseID .. ", charid: " .. charid)
            else
                notify(_source, "Kůň byl nastaven jako výchozí.")
                DiscordWeb("Nastavení výchozího koně",
                    "Hráč " .. GetPlayerName(_source) .. " nastavil koně ID " .. horseID .. " jako výchozího.",
                    "ID: " .. horseID)
            end
        end)
    end)
end)

-- Transfer Horse to Another Player
RegisterServerEvent('aprts_horses:transferHorse')
AddEventHandler('aprts_horses:transferHorse', function(horseID, newCharID)
    local _source = source

    -- Validate newCharID exists
    print("Transfering horse: " .. horseID .. " to charid: " .. newCharID)
    -- local newCharacter = Core.getUserByCharId(newCharID)
    local user = Core.getUser(newCharID)
    local newCharacter = user.getUsedCharacter
    if not newCharacter then
        notify(_source, 'Cílový charakter nebyl nalezen.')
        return
    end

    local newIdentifier = newCharacter.identifier
    local charID = newCharacter.charIdentifier
    -- Check if the horse belongs to the current player
    MySQL.query("SELECT * FROM aprts_stables WHERE `id`=@id", {
        id = horseID
    }, function(result)
        if result[1] then
            local horseData = result[1]

            -- Transfer the horse
            MySQL.execute("UPDATE aprts_stables SET `identifier`=@newIdentifier, `charid`=@newCharID WHERE `id`=@id", {
                newIdentifier = newIdentifier,
                newCharID = charID,
                id = horseID
            }, function(rowsChanged, affectedRows, lastInsertId)
                if table.count(rowsChanged) == 0 then
                    notify(_source, 'Něco se nepovedlo při převodu koně.')
                    debugPrint("Error transferring horse ID: " .. horseID)
                else
                    notify(_source, "Kůň byl úspěšně převeden na jiného hráče.")
                    DiscordWeb("Převod Koně",
                        "Hráč " .. GetPlayerName(_source) .. " převedl koně " .. horseData.name .. " (ID: " ..
                            horseID .. ") na charid: " .. charID, "ID: " .. horseID)

                    notify(newCharID,
                        "Obdržel jsi koně " .. horseData.name .. " od hráče " .. GetPlayerName(_source) .. ".")

                end
            end)
        else
            notify(_source, 'Kůň nebyl nalezen nebo ti nepatří.')
        end
    end)
end)

-- Get All Horses
RegisterServerEvent('aprts_horses:getHorses')
AddEventHandler('aprts_horses:getHorses', function()
    print(os.date())
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        notify(_source, 'Uživatel nebyl nalezen.')
        return
    end
    local character = user.getUsedCharacter
    if not character then
        notify(_source, 'Charakter nebyl nalezen.')
        return
    end

    local charid = character.charIdentifier
    local identifier = character.identifier

    MySQL.query('SELECT * FROM aprts_stables WHERE `identifier`=@identifier AND `charid`=@charid AND `type`=@type;', {
        identifier = identifier,
        charid = charid,
        type = 'horse'
    }, function(horses)
        local horsesData = {}
        for _, horse in ipairs(horses) do
            table.insert(horsesData, {
                id = horse.id,
                name = horse.name,
                vehicles = horse.vehicles,
                default = horse.default,
                meta = json.decode(horse.meta),
                breed = horse.breed
            })
        end
        TriggerClientEvent("aprts_horses:sendHorses", _source, horsesData)
    end)
end)

-- Equip Horse Component
RegisterServerEvent("aprts_horses:equipHorseComponent")
AddEventHandler("aprts_horses:equipHorseComponent", function(horseID, components)
    local src = source
    MySQL.execute("UPDATE aprts_stables SET `comp`=@components WHERE `id`=@id", {
        components = json.encode(components),
        id = horseID
    }, function(rowsChanged, affectedRows, lastInsertId)
        if table.count(rowsChanged) == 0 then
            notify(src, 'Něco se nepovedlo při vybavení komponenty koně.')
        else
            notify(src, 'Komponenta koně byla úspěšně vybavena.')
        end
    end)
end)

-- Return Component to Inventory
RegisterServerEvent("aprts_horses:Server:returnComp")
AddEventHandler("aprts_horses:Server:returnComp", function(compHash, sender)

    local src = source
    if not sender then
        sender = src
    end
    local item = getItemByHash(compHash)
    if item then
        exports.vorp_inventory:addItem(sender, item, 1)
        notify(sender, "Obdržel jsi " .. (exports.vorp_inventory:getItemDB(item).label or "předmět") .. ".")
    else
        notify(sender, "Předmět nebyl nalezen.")
    end
end)

-- Take Item from Inventory
RegisterServerEvent("aprts_horses:Server:takeItem")
AddEventHandler("aprts_horses:Server:takeItem", function(item)
    local _source = source
    exports.vorp_inventory:subItem(_source, item, 1)
    notify(_source, "Odebral jsi " .. (exports.vorp_inventory:getItemDB(item).label or "předmět") .. ".")
end)

-- Give Item to Inventory
RegisterServerEvent("aprts_horses:Server:giveItem")
AddEventHandler("aprts_horses:Server:giveItem", function(item)
    local _source = source
    exports.vorp_inventory:addItem(_source, item.item, 1)
    notify(_source, "Dostal jsi " .. (exports.vorp_inventory:getItemDB(item.item).label or "předmět") .. ".")
end)

-- Equip Horse Component for All Clients
RegisterServerEvent("aprts_horses:Server:equipHorseComponent")
AddEventHandler("aprts_horses:Server:equipHorseComponent", function(horsePed, componentHash)
    local sender = source
    TriggerClientEvent("aprts_horses:Client:equipHorseComponent", -1, horsePed, componentHash, sender)
end)

-- Open Horse Inventory
RegisterServerEvent("aprts_horses:Server:openInventory")
AddEventHandler("aprts_horses:Server:openInventory", function(horseID)
    local src = source
    print("Opening inventory for horse ID: " .. horseID)
    local inventoryId = Config.InventoryPrefix .. tostring(horseID)
    exports.vorp_inventory:openInventory(src, inventoryId)
end)



-- On Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    MySQL.ready(function()
        -- Reset all horses to stabled = 1 where stabled = 0
        MySQL.execute("UPDATE aprts_stables SET `stabled`=1 WHERE `stabled`=0", {},
            function(rowsChanged, affectedRows, lastInsertId)
                if table.count(rowsChanged) < 0 then
                    debugPrint("Něco se nepovedlo při resetování stavu koní.")
                else
                    debugPrint("Stav koní byl úspěšně resetován.")
                end
            end)

        -- Load Horse Components
        MySQL.query('SELECT * FROM aprts_stables_comp;', {}, function(components)
            for _, comp in pairs(components) do
                -- Register usable items
                exports.vorp_inventory:registerUsableItem(comp.item, function(data)
                    exports.vorp_inventory:closeInventory(data.source)
                    TriggerClientEvent("aprts_horses:Client:use_" .. comp.item, data.source, comp.category)
                end)

                -- Initialize category table
                if not HorseComp[comp.category] then
                    HorseComp[comp.category] = {}
                end

                -- Insert component data
                table.insert(HorseComp[comp.category], {
                    hash = math.floor(comp.hash),
                    cashPrice = comp.cashPrice,
                    name = comp.name,
                    desc = comp.desc,
                    category = comp.category,
                    item = comp.item
                })
            end
            debugPrint("Horse components byly načteny a registrovány.")
        end)

        -- Load Horses Data
        MySQL.query('SELECT * FROM aprts_stables_horses;', {}, function(horsesData)
            for _, horse in pairs(horsesData) do
                Horses[tostring(horse.horse_id)] = {
                    breed = horse.breed,
                    horse_id = horse.horse_id,
                    color = horse.color,
                    cashPrice = horse.cashPrice,
                    invLimit = horse.invLimit,
                    job = horse.job,
                    canBuy = horse.canBuy,
                    canStable = horse.canStable,
                    NPCid = json.decode(horse.NPCid or '{}'),
                    stats = json.decode(horse.stats or '{}'),
                    maxStats = json.decode(horse.maxStats or '{}')
                }
            end
            debugPrint("Data koní byla úspěšně načtena.")
        end)
    end)
end)

-- Get All Components and Horses
RegisterServerEvent("aprts_horses:Server:getAllComponents")
AddEventHandler("aprts_horses:Server:getAllComponents", function()
    local src = source
    TriggerClientEvent("aprts_horses:Client:sendAllComponents", src, HorseComp)
    TriggerClientEvent("aprts_horses:Client:sendAllHorses", src, Horses)
end)

-- Export Horses Data
exports('getHorses', function()
    return Horses
end)

RegisterServerEvent("aprts_horses:Server:tameHorseLog")
AddEventHandler("aprts_horses:Server:tameHorseLog", function(model)
    local _source = source
    for _, horse in pairs(Horses) do
        if GetHashKey(horse.horse_id) == model then
            model = horse.horse_id
        end

    end

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
        coords = playerCoords,
        breed = model
    }
    lib.logger(_source, 'TameHorse', message)
end)
