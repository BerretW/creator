-- Exportování struktury pro tabulka s29_dev-redm.aprts_diary
-- CREATE TABLE IF NOT EXISTS `aprts_diary` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `name` varchar(255) NOT NULL,
--   `data` longtext NOT NULL DEFAULT '{}',
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
MySQL = exports.oxmysql
Core = exports.vorp_core:GetCore()

function debugPrint(msg)
    if Config.Debug then
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

function hasJob(player, jobtable)
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

demoDiaryData = {
    diary_id = 0,
    custom_name = "Demo Diary",
    marks = {{
        page = 1,
        mark = "Lorem ipsum pyčo"
    }},
    pages = 30,
    data = {{
        page = 1,
        text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec purus nec nunc"
    }, {
        page = 2,
        text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec purus nec nunc"
    }, {
        page = 3,
        text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec purus nec nunc"
    }}
}

-- function loadDiary(diaryID)
--     local diary = {}

--     local dataLoaded = false
--     MySQL:execute("SELECT * FROM aprts_diary WHERE id = @diary_id", {
--         ["@diary_id"] = diaryID
--     }, function(result)
--         if result then
--             diary.data = json.decode(result[1].data)
--             diary.name = result[1].name
--             dataLoaded = true
--         end
--     end)
--     while dataLoaded == false do
--         Wait(100)
--     end
--     return diary
-- end

-- function saveDiary(diary)
--     local data = json.encode(diary.data)
--     local name = diary.custom_name
--     local diaryID = diary.diary_id
--     if diaryID == 0 then
--         MySQL:execute("INSERT INTO aprts_diary (name, data) VALUES (@name, @data)", {
--             ["@name"] = name,
--             ["@data"] = data
--         }, function(result)
--             diary.diary_id = result.insertId
--             debugPrint("Diary saved with ID: " .. result.insertId)
--         end)
--     else
--         MySQL:execute("UPDATE aprts_diary SET name = @name, data = @data WHERE id = @diary_id", {
--             ["@name"] = name,
--             ["@data"] = data,
--             ["@diary_id"] = diaryID
--         })
--     end
--     diary.data ={}
--     return diary

-- end
