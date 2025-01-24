MySQL = exports.oxmysql
Core = exports.vorp_core:GetCore()
playersIllnesses = {}
clothes = {}


function debugPrint(msg)
    if Config.Debug then
        print("^1[aprts_medicalAtention]^0 " .. msg)
    end
end
function notify(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "SCRIPT", message, 4000)
end
function GetPlayerName(source)
    local user = Core.getUser(source)
    if not user then
        return "nobody"
    end
    local character = user.getUsedCharacter
    local firstname = character.firstname
    local lastname = character.lastname
    return firstname .. " " .. lastname
end

function getTimeStamp()
    local time = 0
    MySQL:execute("SELECT UNIX_TIMESTAMP() as time", {}, function(result)
        if result then
            time = result[1].time
        end
    end)
    while time == 0 do
        Wait(100)
    end
    return time
end


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

function getPlayerNeckWear(charID)
    local neckWear = nil
    MySQL:execute("SELECT compPlayer FROM characters WHERE charidentifier = ?", {charID}, function(result)
       local comps = json.decode(result[1].compPlayer)
       if comps.NeckWear then
           neckWear = comps.NeckWear
       end
    end)

    while neckWear == nil do
        Wait(100)
    end

    return neckWear
end

function getPlayersNearCoords(coords, distance)
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)
        local distanceBetween = math.sqrt((coords.x - playerCoords.x)^2 + (coords.y - playerCoords.y)^2 + (coords.z - playerCoords.z)^2)
        -- debugPrint(distanceBetween)
        if distanceBetween <= distance then
            table.insert(players, player)
        end
    end
    return players
end


function IsPlayerMedic(_source)
    local user = Core.getUser(source)
    if not user then
        return "nobody"
    end
    local character = user.getUsedCharacter
    Character = Character.getUsedCharacter  
    if tostring(Character.job) == Config.Job then
        return true
    end
    return false
end


function HasPlayertJob(_source, job)
    if job == nil or job == "" then
        return true
    end
    local Character = Core.getUser(_source)
    if not Character then
        return
    end
    Character = Character.getUsedCharacter
    if tostring(Character.job) == job then
        return true
    end
    return false
end