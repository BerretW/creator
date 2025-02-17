Core = exports.vorp_core:GetCore()

RegisterServerEvent("aprts_horses:Server:updateAttributes")
AddEventHandler("aprts_horses:Server:updateAttributes", function(horseID, mainAttributes, coreAttributes, alive)
    local src = source
    print("Updating attributes for horse: " .. horseID)
    print(horseID .. " = CH:" .. coreAttributes.CoreHealth .. ", CS:" .. coreAttributes.CoreStamina .. ", HP:" ..
              coreAttributes.Health .. ", ST:" .. coreAttributes.Stamina)


    if coreAttributes.CoreHealth == 0 or coreAttributes.CoreStamina == 0 or coreAttributes.Health == 0 or
        coreAttributes.Stamina == 0 then
        DiscordWeb("Nulový kůň",
            "Ukládám koně s nulovými staty: " .. horseID .. " = CH:" .. coreAttributes.CoreHealth .. ", CS:" .. coreAttributes.CoreStamina .. ", HP:" ..
            coreAttributes.Health .. ", ST:" .. coreAttributes.Stamina)
    end
    if alive == true and coreAttributes.CoreHealth == 0 then
        coreAttributes.CoreHealth = 100
        coreAttributes.Health = 100
    end
    local Character = Core.getUser(src).getUsedCharacter
    local charId = Character.charIdentifier

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
