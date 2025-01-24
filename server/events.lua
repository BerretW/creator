AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute("SELECT meta, charidentifier FROM characters", {}, function(result)
            for k, v in pairs(result) do

                if v.meta then
                    local meta = json.decode(v.meta)
                    if meta.illness then
                        print(json.encode(meta.illness))
                        playersIllnesses[v.charidentifier] = meta.illness
                    end
                end
            end
        end)
        -- aprts_clothing id|gender|name|component|variant|hash|armor|temp
        MySQL:execute("SELECT * FROM aprts_clothing ORDER BY id", {}, function(result)
            for k, v in pairs(result) do
                clothes[v.id] = v
            end
        end)
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:getIllness")
AddEventHandler("aprts_medicalAtention:Server:getIllness", function()
    local _source = source
    local user = Core.getUser(_source)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    if playersIllnesses[charID] then
        TriggerClientEvent("aprts_medicalAtention:Client:GetIllness", _source, playersIllnesses[charID])
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:getPlayerIllness")
AddEventHandler("aprts_medicalAtention:Server:getPlayerIllness", function(pedID)
    local _source = source
    local user = Core.getUser(pedID)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    if playersIllnesses[charID] then
        debugPrint("Player " .. charID .. " má nemoc")
        TriggerClientEvent("aprts_medicalAtention:Client:GetPlayerIllness", _source, playersIllnesses[charID])
    else
        notify(_source, "Hráč je zdraví")
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:playerGetSick")
AddEventHandler("aprts_medicalAtention:Server:playerGetSick", function(illness)

    local _source = source
    local user = Core.getUser(_source)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    local firstname = character.firstname
    local lastname = character.lastname
    local name = "(".. GetPlayerName(source)  .. ") " .. firstname .. " " .. lastname
    local message = "onemocněl: " .. illness.name .. " zbývá: " .. illness.duration
    local footer = "aprts_medicalAtention"
    DiscordWeb(name, message, footer)
    playersIllnesses[charID] = illness

    local time = getTimeStamp()
    illness.startTime = time

    MySQL:execute("SELECT meta FROM characters WHERE charidentifier = ?", {charID}, function(result)
        local meta = json.decode(result[1].meta)
        meta.illness = illness
        MySQL:execute("UPDATE characters SET meta = ? WHERE charidentifier = ?", {json.encode(meta), charID})
    end)
    -- load meta from db and add illness

end)

RegisterServerEvent("aprts_medicalAtention:Server:updateTime")
AddEventHandler("aprts_medicalAtention:Server:updateTime", function(newTime)
    local _source = source
    local user = Core.getUser(_source)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    local illness = playersIllnesses[charID]
    local time = getTimeStamp()
    if illness then
        illness.startTime = time
        MySQL:execute("SELECT meta FROM characters WHERE charidentifier = ?", {charID}, function(result)
            local meta = json.decode(result[1].meta)
            meta.illness.duration = newTime
            debugPrint(charID .. ": new time: " .. newTime)
            MySQL:execute("UPDATE characters SET meta = ? WHERE charidentifier = ?", {json.encode(meta), charID})
        end)
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:infectPlayers")
AddEventHandler("aprts_medicalAtention:Server:infectPlayers", function(playerIllness, coords)
    local players = getPlayersNearCoords(coords, 10.0)

    for _, player in ipairs(players) do
        local chance = math.random(1, 100)
        if chance <= playerIllness.chance then
            local user = Core.getUser(player)
            local character = user.getUsedCharacter
            local charID = character.charIdentifier
            if playersIllnesses[charID] then
                debugPrint("Player " .. charID .. " už je nemocný")
                return
            else
                debugPrint("Player " .. charID .. " by měl onemocnět")
                local firstname = character.firstname
                local lastname = character.lastname
                local name = "(".. GetPlayerName(source)  .. ") " .. firstname .. " " .. lastname
                local message = "Byl nakažen: " .. playerIllness.name .. " hráčem: " .. Core.getUser(source).getUsedCharacter.firstname .. " " .. Core.getUser(source).getUsedCharacter.lastname
                local footer = "aprts_medicalAtention"
                DiscordWeb(name, message, footer)
                local time = getTimeStamp()
                playerIllness.startTime = time
                -- MySQL:execute("SELECT meta FROM characters WHERE charidentifier = ?", {charID}, function(result)
                --     local meta = json.decode(result[1].meta)
                --     meta.illness = playerIllness
                --     MySQL:execute("UPDATE characters SET meta = ? WHERE charidentifier = ?", {json.encode(meta), charID})
                -- end)
                TriggerClientEvent("aprts_medicalAtention:Client:GetIllness", player, playerIllness)
            end
        end
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:playerGetCured")
AddEventHandler("aprts_medicalAtention:Server:playerGetCured", function()
    local _source = source
    local user = Core.getUser(_source)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    local firstname = character.firstname
    local lastname = character.lastname
    local name = "(".. GetPlayerName(source)  .. ") " .. firstname .. " " .. lastname
    local message = "uzdraven"
    local footer = "aprts_medicalAtention"
    DiscordWeb(name, message, footer)
    playersIllnesses[charID] = nil
    MySQL:execute("SELECT meta FROM characters WHERE charidentifier = ?", {charID}, function(result)
        local meta = json.decode(result[1].meta)
        meta.illness = nil
        MySQL:execute("UPDATE characters SET meta = ? WHERE charidentifier = ?", {json.encode(meta), charID})
    end)
    TriggerClientEvent("aprts_medicalAtention:Client:GetCured", _source)
end)

RegisterServerEvent("aprts_medicalAtention:Server:Cure")
AddEventHandler("aprts_medicalAtention:Server:Cure", function(pedID, cure)
    TriggerClientEvent("aprts_medicalAtention:Client:Cure", pedID, cure)
end)



RegisterNetEvent("aprts_medicalAtention:Server:revive")
AddEventHandler("aprts_medicalAtention:Server:revive", function(target, item)
    print("revive " .. target)
    if target then
        -- TriggerClientEvent('vorp:resurrectPlayer', target)

        TriggerClientEvent("aprts_medicalAtention:Client:reviveME", target, item)
    end
end)

RegisterServerEvent("aprts_medicalAtention:Server:getClothes")
AddEventHandler("aprts_medicalAtention:Server:getClothes", function()
    local _source = source
    TriggerClientEvent("aprts_medicalAtention:Client:getClothes", _source, clothes)
end)

RegisterServerEvent("aprts_medicalAtention:Server:setClothesTemp")
AddEventHandler("aprts_medicalAtention:Server:setClothesTemp", function(id, temp)
    local _source = source
    -- update temp in db by id
    MySQL:execute("UPDATE aprts_clothing SET temp = ? WHERE id = ?", {temp, id})
    clothes[id].temp = temp
    TriggerClientEvent("aprts_medicalAtention:Client:setClothesTemp", _source, id, temp)
    
end)


RegisterServerEvent("aprts_medicalAtention:Server:heal")
AddEventHandler("aprts_medicalAtention:Server:heal", function(ped, item)
    local _source = source
    if ped == 999 then
        ped = _source
    end
    print("Pokus o léčení " .. ped .. " item: " .. item.label .. " od " .. _source)
    TriggerClientEvent("aprts_medicalAtention:Client:healSelf", ped, item.effect)
end)

RegisterServerEvent("aprts_medicalAtention:Server:takeMoney")
AddEventHandler("aprts_medicalAtention:Server:takeMoney", function(price)
    local _source = source
    local user = Core.getUser(_source)
    local character = user.getUsedCharacter
    local charID = character.charIdentifier
    local money = character.money
    character.removeCurrency(0, price)
   

    if money >= price then
        notify(_source, "Zaplatil jsi " .. price .. "$")
    else
        local metadata = {}
        metadata.custom_name = "Účtenka na " .. price .. "$"
        exports.vorp_inventory:addItem(_source, Config.Receipt_Item, 1, metadata)
        notify(_source, "Nemáš dostatek peněz")
    end
end)