Core = exports.vorp_core:GetCore()

RegisterServerEvent("aprts_horses:Server:updateAttributes")
AddEventHandler("aprts_horses:Server:updateAttributes", function(horseID, mainAttributes, coreAttributes)
    local src = source
    dprint("Horse ID: ", horseID)

    local Character = Core.getUser(src).getUsedCharacter
    local charId = Character.charIdentifier
    dprint("Character ID: ", charId)
    dprint("Core Attributes: ", json.encode(coreAttributes))
    dprint("Main Attributes: ", json.encode(mainAttributes))
    MySQL.Async.execute("UPDATE aprts_stables SET `cAtt`=@coreAtt , `Att`=@Att WHERE `id`=@id ", {
        coreAtt = json.encode(coreAttributes),
        Att = json.encode(mainAttributes),
        charid = charId,
        id = horseID
    }, function(rowsChanged)
        if rowsChanged == 0 then
            dprint("Error updating horse attributes")
            -- notify(src, 'error_horse_not_stabled')
        else
            dprint("Horse attributes updated")
            -- notify(src, 'horse_components_updated')
        end
    end)
end)
