wagons = {}
cargos = {}
ShippingPosts = {}
RegisterServerEvent('aprts_hunting_job:Server:loadWagons')
AddEventHandler('aprts_hunting_job:Server:loadWagons', function()
    print("Client requesting Wagons")
    TriggerClientEvent('aprts_hunting_job:Client:loadWagons', source, wagons)
end)

RegisterServerEvent('aprts_hunting_job:Server:loadCargos')
AddEventHandler('aprts_hunting_job:Server:loadCargos', function()
    print("Client requesting Cargos")
    TriggerClientEvent('aprts_hunting_job:Client:loadCargos', source, cargos)
end)

RegisterServerEvent('aprts_hunting_job:Server:newWagon')
AddEventHandler('aprts_hunting_job:Server:newWagon', function(wagon, coords, butcherID)
    local _source = source
    print("New Wagon " .. wagon)
    local number = tonumber(wagon)
    wagons[wagon] = {}
    wagons[wagon].coords = coords
    wagons[wagon].obj = wagon
    wagons[wagon].count = 0
    wagons[wagon].butcherID = butcherID
    TriggerClientEvent('aprts_hunting_job:Client:newWagon', -1, wagons[wagon])
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
            butcherID = butcherID,
        }
        lib.logger(_source, 'NewJob', message)
    end
end)

RegisterServerEvent('aprts_hunting_job:Server:newCargo')
AddEventHandler('aprts_hunting_job:Server:newCargo', function(cargo, coords)
    print("New Cargo " .. cargo)
    local number = tonumber(cargo)
    cargos[number] = {}
    cargos[number].obj = number
    cargos[number].coords = coords
    cargos[number].count = Config.cargoCount
    TriggerClientEvent('aprts_hunting_job:Client:newCargo', -1, cargos[number])
end)

RegisterServerEvent('aprts_hunting_job:Server:takeBox')
AddEventHandler('aprts_hunting_job:Server:takeBox', function(cargo)
    local number = tonumber(cargo)
    if not cargos[number] then
        return
    end
    cargos[number].count = cargos[number].count - 1

    if cargos[number].count <= 0 then
        TriggerClientEvent('aprts_hunting_job:Client:deleteCargo', -1, cargos[number].obj)
        cargos[number] = nil
    else
        TriggerClientEvent('aprts_hunting_job:Client:takeBox', -1, cargos[number])
    end

end)

RegisterServerEvent('aprts_hunting_job:Server:putBox')
AddEventHandler('aprts_hunting_job:Server:putBox', function(wagon)
    local number = tonumber(wagon)
    wagons[number].count = wagons[number].count + 1
    TriggerClientEvent('aprts_hunting_job:Client:putBox', -1, wagons[number])
end)

RegisterServerEvent('aprts_hunting_job:Server:updateWagonCoords')
AddEventHandler('aprts_hunting_job:Server:updateWagonCoords', function(wagon, coords)
    local number = tonumber(wagon)
    if not wagons[number] then
        return
    end
    wagons[number].coords = coords
    -- print("Updating Wagon Position: "..json.encode(coords))
    TriggerClientEvent('aprts_hunting_job:Client:updateWagonCoords', -1, wagon, coords)
end)

RegisterServerEvent('aprts_hunting_job:Server:takeBoxFromWagon')
AddEventHandler('aprts_hunting_job:Server:takeBoxFromWagon', function(wagon)
    local number = tonumber(wagon)
    if wagons[number].count <= 0 then
        return
    end
    wagons[number].count = wagons[number].count - 1
    TriggerClientEvent('aprts_hunting_job:Client:takeBoxFromWagon', -1, wagons[number])
end)

RegisterServerEvent('aprts_hunting_job:Server:sellBox')
AddEventHandler('aprts_hunting_job:Server:sellBox', function(butcherID)
    local _source = source
    -- print("Selling Box from Butcher " .. butcherID)

    local butcherGain = exports['aprts_hunting']:getButcherGain(butcherID)
    local amount = Config.boxPrice / (butcherGain * 10)

    local Core = exports.vorp_core:GetCore()
    local Character = Core.getUser(_source).getUsedCharacter
    local money = Character.money


    
    local Character = Core.getUser(_source).getUsedCharacter
    --zaokrouhlení na dvě desetinná čísla
    -- amount = math.round(amount,3) 
    notifyClient(_source, "Získal jsi " .. amount .. " za bednu")
    Character.addCurrency(0, amount)
    -- for _, reward in pairs(Config.CrateReward) do
    --     if reward.id == butcherID then
    --         local label = exports.vorp_inventory:getItemDB(reward.name).label
    --         notifyClient(_source, "Získal jsi " .. label)
    --         -- exports.vorp_inventory:addItem(_source, reward.name, 1)
    --     end
    -- end

    TriggerEvent('aprts_hunting:Server:modifyButcherGain', butcherID, Config.GainUp)

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
            moneyBefore = money,
            moneyAfter = Character.money,
        }
        lib.logger(_source, 'SellBox', message)
    end
end)

RegisterServerEvent('aprts_hunting_job:Server:deleteWagon')
AddEventHandler('aprts_hunting_job:Server:deleteWagon', function(obj)
    if not wagons[obj] then
        return
    end
    wagons[obj] = nil
    TriggerClientEvent('aprts_hunting_job:Client:deleteWagon', -1, obj)
end)

RegisterServerEvent('aprts_hunting_job:Server:deleteCargo')
AddEventHandler('aprts_hunting_job:Server:deleteCargo', function(obj)
    if not cargos[obj] then
        return
    end
    cargos[obj] = nil
    TriggerClientEvent('aprts_hunting_job:Client:deleteCargo', -1, obj)
end)

-- Exportování struktury pro tabulka vorp.aprts_hunting_shipment
-- CREATE TABLE IF NOT EXISTS `aprts_hunting_shipment` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `name` varchar(255) DEFAULT NULL,
--   `count` int(11) DEFAULT NULL,
--   `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`coords`)),
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -- Exportování dat pro tabulku vorp.aprts_hunting_shipment: ~1 rows (přibližně)
-- INSERT INTO `aprts_hunting_shipment` (`id`, `name`, `count`, `coords`) VALUES
-- 	(1, 'Sklady FlatNeck', 0, '{"x":-329.508698, "y":-368.719666, "z":87.446007}');
local MySQL = exports.oxmysql
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- načte stavy skladů
        print("Loading Shipments")
        MySQL:execute('SELECT * FROM aprts_hunting_shipment', {}, function(shipments)
            for k, v in pairs(shipments) do
                ShippingPosts[v.id] = v
                ShippingPosts[v.id].coords = json.decode(v.coords)
                print("Shipment " .. v.name .. " loaded")
            end
        end)
    end
end)

RegisterServerEvent('aprts_hunting_job:Server:LoadShipments')
AddEventHandler('aprts_hunting_job:Server:LoadShipments', function()
    print("Client requesting Shipments")
    TriggerClientEvent('aprts_hunting_job:Client:LoadShipments', source, ShippingPosts)
end)

RegisterServerEvent('aprts_hunting_job:Server:putToShipment')
AddEventHandler('aprts_hunting_job:Server:putToShipment', function(shipmentID)
    local _source = source
    local shipment = ShippingPosts[shipmentID]
    if not shipment then
        return
    end

    ShippingPosts[shipmentID].count = ShippingPosts[shipmentID].count + 1
    MySQL:execute('UPDATE aprts_hunting_shipment SET count = @count WHERE id = @id', {
        ['@count'] = ShippingPosts[shipmentID].count,
        ['@id'] = shipmentID
    })
    notifyClient(_source, "Přidal jsi bednu do skladu")
    TriggerClientEvent('aprts_hunting_job:Client:updateShipment', -1, shipment)
end)
