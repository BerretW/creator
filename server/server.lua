MySQL = exports.oxmysql
Core = exports.vorp_core:GetCore()


function debugPrint(msg)
    if Config.Debug == true then
        print("^1[SCRIPT]^0 " .. msg)
    end
end
function notify(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "SCRIPT", message, 4000)
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function hasJob(player,jobtable)
    local job = Player(player).state.Character.Job
    if job == nil then
        return false
    end
    for _, v in pairs(jobtable) do
        if job == v then
            return true
        end
    end
    return false
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

function unixToDateTime(unixTime)
    return os.date('%Y-%m-%d %H:%M:%S', unixTime)
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
