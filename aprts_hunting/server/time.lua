-- Konstanty pro výpočet data a času
local SECONDS_IN_MINUTE = 60
local SECONDS_IN_HOUR = 3600
local SECONDS_IN_DAY = 86400
local SECONDS_IN_YEAR = 31556926
local SECONDS_IN_MONTH = 2629743
local DST = 1 -- Daylight saving time

local timeDate = {}
-- Funkce pro převod Unix timestamp na formátované datum a čas
local function convertTimestampToDateTime(timestamp)
    -- Převod milisekund na sekundy
    local seconds = timestamp / 1000

    -- Výpočet let, měsíců, dnů, hodin, minut, sekund
    local year = 1970
    local month = 1
    local day = 1
    local hour = 0
    local minute = 0
    local second = math.floor(seconds)

    -- Výpočet roku
    while second >= SECONDS_IN_YEAR do
        second = second - SECONDS_IN_YEAR
        year = year + 1
    end

    -- Výpočet měsíce
    while second >= SECONDS_IN_MONTH do
        second = second - SECONDS_IN_MONTH
        month = month + 1
    end

    -- Výpočet dne
    while second >= SECONDS_IN_DAY do
        second = second - SECONDS_IN_DAY
        day = day + 1
    end

    -- Výpočet hodiny
    while second >= SECONDS_IN_HOUR do
        second = second - SECONDS_IN_HOUR
        hour = hour + 1
    end

    -- Výpočet minuty
    while second >= SECONDS_IN_MINUTE do
        second = second - SECONDS_IN_MINUTE
        minute = minute + 1
    end

    -- Zbytek sekund
    second = math.floor(second)

    -- Formátování data a času
    local time = {}
    local time = {
        hour = hour,
        minute = minute,
        second = second,
        day = day,
        month = month,
        year = year
    }
    timeDate = time
    return time
end

-- get current date from mysql server with SELECT CURDATE();
local function getCurrentDate(callback)
    local query = "SELECT CURRENT_TIMESTAMP() as currentTime"
    MySQL:execute(query, {}, function(result)
        if result and result[1] and result[1].currentTime then
            callback(result[1].currentTime)
        else
            callback(nil)
        end
    end)
end

RegisterServerEvent("aprts_hunting:getDateTime")
AddEventHandler("aprts_hunting:getDateTime", function()
    local _source = source
    getCurrentDate(function(result)
        if result then
            -- opravit čas podle letního času a časové zóny
            local time = convertTimestampToDateTime(result)
            --time.hour = time.hour + DST
            TriggerClientEvent("aprts_hunting:receiveDateTime", _source, convertTimestampToDateTime(result))
            -- print("Current date and time is " .. convertTimestampToDateTime(result).year)
        end
    end)
end)

local function getCurrentTime()
    local time = {}
    getCurrentDate(function(result)
        if result then
            -- opravit čas podle letního času a časové zóny
            time = convertTimestampToDateTime(result)
            --time.hour = time.hour + DST

        end
    end)
    while time.hour == nil do
        Wait(100)
    end
   -- print("Current date and time is " .. time.year)
    return time
end


local function getTimeStamp()
    local time = 0
    getCurrentDate(function(result)
        if result then
            -- opravit čas podle letního času a časové zóny
            time = result
        end
    end)
    while time == 0 do
        Wait(100)
    end
    return time
    
end
exports("getCurrentTime", getCurrentTime)
exports("getTimeStamp", getTimeStamp)
