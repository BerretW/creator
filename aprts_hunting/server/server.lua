
local Animals = {}
local Butchers = {}
local Inventory = nil
local gumCore = nil
MySQL = exports.oxmysql
local RSGCore = nil

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute('SELECT * FROM aprts_hunting_animals', {}, function(animals)
            for k, v in pairs(animals) do
                Animals[v.id] = v
                -- print("Animal " .. v.name .. " loaded")
            end

        end)

    end
end)

if Config.FrameWork == "GUM" then
    gumCore = nil
    Inventory = exports.gum_inventory:gum_inventoryApi()

    TriggerEvent("getCore", function(core)
        gumCore = core
    end)
    local api
    TriggerEvent("getApi", function(gumApi)
        api = gumApi
    end)
end

function notify(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "HUNTING", message, 4000)
end

if Config.FrameWork == "RSG" then
    RSGCore = exports['rsg-core']:GetCoreObject()
end
local Core
if Config.FrameWork == "VORP" then
    Core = exports.vorp_core:GetCore()
end

RegisterServerEvent("aprts_hunting:fetchAnimals")
AddEventHandler("aprts_hunting:fetchAnimals", function()
    local _source = source

    TriggerClientEvent("aprts_hunting:receiveAnimals", _source, Animals)
end)

RegisterServerEvent("aprts_hunting:add")
AddEventHandler("aprts_hunting:add", function(item_code, item_count)
    local _source = source
    local item = exports.vorp_inventory:getItemDB(item_code)
    local skillLevel, skillXP = exports.westhaven_skill:get(source, Config.Skill)
    -- print("Skill Level: " .. skillLevel)
    local skillBonus = math.floor(skillLevel / 10)
    local message = ""
    item_count = math.random(1, item_count + skillBonus)
    if item then
        local label = item.label
        message = "Získal jsi  " .. item_count .. "x " .. label
        notify(_source, message)
        exports.vorp_inventory:addItem(_source, item_code, item_count)
    else
        debugPrint("ERROR: Item not found")
    end

end)

local function hasLevel(skillLevel, animalID)
    local level = Animals[animalID].level
    -- print("Skill Level: " .. skillLevel .. " Required Level: " .. level .. " Animal ID: " .. animalID)
    if skillLevel >= level then
        return true
    else
        return false
    end
end

RegisterServerEvent("aprts_hunting:Server:GetReward")
AddEventHandler("aprts_hunting:Server:GetReward", function(animalId)
    local _source = source
    local firstname = Player(_source).state.Character.FirstName
    local lastname = Player(_source).state.Character.LastName

    local playerName = firstname .. " " .. lastname

    local skillLevel, skillXP = exports.westhaven_skill:get(_source, Config.Skill)
    if skillLevel < 1 then
        skillLevel = 1
    end
    local getAny = false
    if hasLevel(skillLevel, animalId) then
        exports.westhaven_skill:increaseSkill(_source, Config.Skill, Animals[animalId].XP)
        -- print("Skill XP: " .. Animals[animalId].XP)
        local items = json.decode(Animals[animalId].item or "[]")

        for _, item in pairs(items) do
            local chance = 30 + skillLevel
            -- print("Chance: " .. chance)
            if math.random(1, 100) <= chance then
                exports.westhaven_skill:increaseSkill(_source, Config.Skill, 1)
                if item.quantity > 1 then
                    item.quantity = math.random(1, item.quantity)
                end
                if item.name and item.quantity and item.quantity > 0 then
                    local label = exports.vorp_inventory:getItemDB(item.name).label or item.name
                    exports.vorp_inventory:addItem(_source, item.name, item.quantity)
                    -- print("Získal " .. item.quantity .. "x " .. label)
                    notify(_source, "Získal jsi " .. item.quantity .. "x " .. label)
                    lib.logger(_source, 'DismantleAnimalReward',
                        "player:" .. playerName .. " získal " .. item.quantity .. "x " .. label,
                        "animalID:" .. animalId, "Item:" .. item.name, "Count:" .. item.quantity)
                else
                    debugPrint("ERROR s Předmětem: " .. json.encode(item))
                end
                getAny = true
            else
                -- print("Neměl štěstí")
            end

        end
        if getAny == false then
            notify(_source, "Neměl jsi štěstí")
        end
    else
        exports.westhaven_skill:increaseSkill(_source, Config.Skill, 1)
        notify(_source,
            "Nemáš dostatečnou úroveň dovednosti pro zpracování tohoto zvířete. Potřebuješ úroveň " ..
                Animals[animalId].level)
    end

    if _source then

        local player = _source
        local ped = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(ped)

        lib.logger(_source, 'DismantleAnimal', "Stáhl zvíře: " .. animalId, "x:" .. playerCoords.x,
            "y:" .. playerCoords.y, "z:" .. playerCoords.z, "player:" .. playerName)

    end
end)

RegisterServerEvent("aprts_hunting:money")
AddEventHandler("aprts_hunting:money", function(amount)
    print("Player recieved money " .. amount)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    Character.addCurrency(0, amount)
end)

RegisterServerEvent("aprts_hunting:Server:sellAnimal")
-- TriggerServerEvent("aprts_hunting:Server:sellAnimal", butcher.id, animalID, holdingName, endpiece)
AddEventHandler("aprts_hunting:Server:sellAnimal", function(butcher, animalId, label, price,networkid)
    local _source = source
    -- print("Selling animal " .. label .. " to " .. butcher .. " for " .. price, "NetworkID: " .. networkid)
    local entity = NetworkGetEntityFromNetworkId(networkid)
    -- print("Entity: " .. entity)
    DeleteEntity(entity)
    
    if _source then
        local firstname = Player(_source).state.Character.FirstName
        local lastname = Player(_source).state.Character.LastName
        local playerName = firstname .. " " .. lastname
        lib.logger(_source, 'SellCarcass', "Prodal u řezníka: " .. butcher .. " zvíře: " .. label, "player:" .. playerName,"animal:" .. animalId, "price:" .. price)
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- load butchers from database aprts_hunting_butchers
        MySQL:execute('SELECT * FROM aprts_hunting_butchers', {}, function(butchers)
            for k, v in pairs(butchers) do
                Butchers[v.id] = v
                Butchers[v.id].coords = json.decode(v.coords)
                -- print("Butcher " .. v.id .. "-" .. v.name .. " loaded")
            end
            -- TriggerClientEvent("aprts_hunting:receiveButchers", -1, Butchers)
        end)
    end
end)

RegisterServerEvent("aprts_hunting:Server:fetchButchers")
AddEventHandler("aprts_hunting:Server:fetchButchers", function()
    local _source = source
    TriggerClientEvent("aprts_hunting:Client:receiveButchers", _source, Butchers)
end)


local function getButcherGain(butcherId)
    for k, v in pairs(Butchers) do
        if v.id == butcherId then
            return v.gain
        end
        return v.gain
    end
end

exports('getButcherGain', getButcherGain)

local function setButcherGain(butcherId, gain)
    for k, v in pairs(Butchers) do
        if v.id == butcherId then
            v.gain = gain
        end
        return v.gain
    end
end
exports('setButcherGain', setButcherGain)

local function modifiButcherGain(butcherId, gain)
    -- zaokrouhlení gain an tři desetinná místa
    gain = math.floor(gain * 1000) / 1000
    -- print("Modifying Butcher Gain " .. butcherId .. " " .. gain)
    for k, v in pairs(Butchers) do
        if v.id == butcherId then
            -- print("old Gain: " .. v.gain)
            v.gain = v.gain + gain
            if v.gain < Config.minGain then
                v.gain = Config.minGain
            end
            if v.gain > Config.maxGain then
                v.gain = Config.maxGain
            end
            -- print("new Gain: " .. Butchers[butcherId].gain)
            return v.gain
        end
    end

end
exports('modifiButcherGain', modifiButcherGain)

local function updateButcherGain(butcherId)
    local gain = Butchers[butcherId].gain
    -- print("Updated Gain: " .. gain)
    MySQL:execute('UPDATE aprts_hunting_butchers SET gain = @gain WHERE id = @id', {
        ['@gain'] = gain,
        ['@id'] = butcherId
    })
end
exports('updateButcherGain', updateButcherGain)

RegisterServerEvent("aprts_hunting:Server:modifyButcherGain")
AddEventHandler("aprts_hunting:Server:modifyButcherGain", function(butcherId, gain)
    modifiButcherGain(butcherId, gain)
    TriggerClientEvent("aprts_hunting:Client:updateButcher", -1, Butchers[butcherId])
    updateButcherGain(butcherId)
end)
