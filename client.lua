local time = 7000
local chatMessage = true
local stav_state = false
local displaying = false
local displaying_2 = false
local displaying_3 = false
local stavInfo = {}
local meTable = {}
local doTable = {}
local fps = -1
local prevtime = GetGameTimer()
local prevframes = GetFrameCount()
local stavInfo = {}
local meTable = {}
local doTable = {}
local chatMessage = {}

local VORPcore = exports.vorp_core:GetCore()

function fpsToTick(frame)
    for i, threshold in ipairs(Config.fpsThresholds) do
        if frame < threshold[1] then
            return threshold[2]
        end
    end
    return 0.3
end

function displayText3D(x, y, z, text, scale, color)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local dist = GetDistanceBetweenCoords(table.unpack(GetGameplayCamCoord()), x, y, z, 1)
    scale = scale * (2 / dist) * (2 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFontForCurrentCommand(1)
        SetTextColor(color[1], color[2], color[3], 205)
        SetTextCentre(1)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong()), _x, _y)

        local factor = string.len(text) / 355
        DrawSprite("feeds", "help_text_1c", _x + 0.01 * (scale / 2), _y + 0.0115 * (scale / 2),
            (0.0155 + factor) * scale, 0.02 * scale, 0.1, 1, 1, 1, 190, 0)
    end
end

RegisterNetEvent('3dme:getState')
AddEventHandler('3dme:getState', function(stav)
    stavInfo = stav
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) or not NetworkIsSessionStarted() do
        Wait(250)
        prevframes = GetFrameCount()
        prevtime = GetGameTimer()
    end
    while true do
        local curtime = GetGameTimer()
        local curframes = GetFrameCount()
        if (curtime - prevtime) > 1000 then
            fps = curframes - prevframes - 1
            prevtime = curtime
            prevframes = curframes
        end
        if IsGameplayCamRendering() and fps >= 0 then
            fpsToTick(fps)
        end
        Wait(1000)
    end
end)

local prevtime = GetGameTimer();
local prevframes = GetFrameCount();
local fps = -1;

function getFPS()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime
    return frame
end

local function fpsTimer()
    local minFPS = 15
    local maxFPS = 165
    local minSpeed = 0
    local maxSpeed = 15
    local coefficient = 1 - (getFPS() - minFPS) / (maxFPS - minFPS)
    return minSpeed + coefficient * (maxSpeed - minSpeed)
end

RegisterCommand('me', function(source, args)
    local text = ' '
    for i = 1, #args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '
    TriggerServerEvent('3dme:shareDisplay', text)

    -- TriggerServerEvent("chatMessage", "ja", text)
    -- local oocName = GetPlayerName(source)
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "ME", text)
end, false)

-- Exportuj funkci
exports('me', function(text)
    if text == nil then
        return false
    else
        print("ME: " .. text)
        TriggerServerEvent('3dme:shareDisplay', text)
        TriggerServerEvent("aprts_3dme:Server:sendMessage", "ME", text)
    end
    return true
end)

Citizen.CreateThread(function()
    TriggerServerEvent('3dme:getState')
end)

RegisterCommand('do', function(source, args)
    local text = ' '
    for i = 1, #args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '

    TriggerServerEvent('3ddo:shareDisplay', text)
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "DO", text)
end, false)

-- Exportuj funkci
exports('medo', function(text)
    if text == nil then
        return false
    else
        TriggerServerEvent('3ddo:shareDisplay', text)
        TriggerServerEvent("aprts_3dme:Server:sendMessage", "DO", text)
    end
    return true
end)

RegisterCommand("try", function(source, args, rawCommand)
    AnoNe(args)
end, false)
function AnoNe(args)
    local anonene = 6
    if args[1] ~= nil and tonumber(args[1]) then
        anonene = tonumber(args[1])
    end
    local number_1 = math.random(1, 2)
    local answer = "NE"
    if number_1 == 1 then
        TriggerServerEvent('3ddo:shareDisplay', " | TRY : Ano")
        answer = "ANO"
    elseif anonene == 2 then
        TriggerServerEvent('3ddo:shareDisplay', " | TRY : Ne")
    else
        TriggerServerEvent('3ddo:shareDisplay', " | TRY : Ne")
    end

    TriggerServerEvent("aprts_3dme:Server:sendMessage", "TRY", answer)
end

RegisterCommand('stav', function(source, args)
    local text = ' - '
    for i = 1, #args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ' '
    if text ~= nil and args[1] ~= nil then
        TriggerServerEvent('3dstav:shareDisplay', text)
    else
        TriggerServerEvent('3dstav:stateDisable', text)
    end
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "STAV", text)
end, false)

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(text, source)
    table.insert(meTable, {GetPlayerFromServerId(source), text, 100})
end)

RegisterNetEvent('3ddo:triggerDisplay')
AddEventHandler('3ddo:triggerDisplay', function(text, source)
    table.insert(doTable, {GetPlayerFromServerId(source), text, 100})
end)

RegisterNetEvent('3ddoc:triggerDisplay')
AddEventHandler('3ddoc:triggerDisplay', function(text, source)
    table.insert(doTable, {GetPlayerFromServerId(source), text, 10})
end)

RegisterNetEvent('3dstav:triggerDisplay')
AddEventHandler('3dstav:triggerDisplay', function(stav, source)
    stavInfo = stav
end)
local chatMessage = {}
Citizen.CreateThread(function()
    while true do
        local optimize = 500
        local coordsMe = GetEntityCoords(PlayerPedId(), false)
        for k, v in pairs(stavInfo) do
            if v ~= nil then
                local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(k)), false)
                local dist = Vdist2(coordsMe.x, coordsMe.y, coordsMe.z, coords.x, coords.y, coords.z)
                if dist < 60 then
                    optimize = 0
                    if GetMount(GetPlayerPed(GetPlayerFromServerId(k))) ~= 0 then
                        DrawText3D_stav(coords['x'], coords['y'], coords['z'] + 2.2, v)
                    else
                        DrawText3D_stav(coords['x'], coords['y'], coords['z'] + 1.4, v)
                    end
                end
            end
        end
        for a, b in pairs(meTable) do
            local coords = GetEntityCoords(GetPlayerPed(b[1]))
            local dist = GetDistanceBetweenCoords(coordsMe.x, coordsMe.y, coordsMe.z, coords.x, coords.y, coords.z, 1)
            if dist < 10 then
                if chatMessage["me" .. b[2] .. "" .. b[1] .. ""] == nil then
                    chatMessage["me" .. b[2] .. "" .. b[1] .. ""] = true
                    TriggerEvent('chat:addMessage', {
                        color = {14, 140, 236},
                        multiline = true,
                        id = a,
                        type = "me",
                        args = {"^4[ME] ", b[2]}
                    })
                    -- TriggerServerEvent("westhaven_log:chat",{
                    -- 	color = { 14, 140, 236 },
                    -- 	multiline = true,
                    -- 	id = a,
                    -- 	type = "me",
                    -- 	args = {"^4[ME] ", b[2]}}
                    -- )
                end
            end
            if b[3] < 0 then
                chatMessage["me" .. b[2] .. "" .. b[1] .. ""] = nil
                table.remove(meTable, a)
            else
                b[3] = b[3] - fpsToTick(fps) / 2
            end
            if dist < 30 then
                optimize = 0
                DrawText3D(coords.x, coords.y, coords.z + 1.0, b[2])
            end
        end
        for a, b in pairs(doTable) do
            local coords = GetEntityCoords(GetPlayerPed(b[1]))
            local dist = GetDistanceBetweenCoords(coordsMe.x, coordsMe.y, coordsMe.z, coords.x, coords.y, coords.z, 1)
            if dist < 10 then
                if chatMessage["do" .. b[2] .. "" .. b[1] .. ""] == nil then
                    chatMessage["do" .. b[2] .. "" .. b[1] .. ""] = true
                    TriggerEvent('chat:addMessage', {
                        color = {169, 14, 138},
                        multiline = true,
                        id = a,
                        type = "do",
                        args = {"^9[DO] ", b[2]}
                    })
                end
            end
            if b[3] < 0 then
                chatMessage["do" .. b[2] .. "" .. b[1] .. ""] = nil
                table.remove(doTable, a)
            else
                b[3] = b[3] - fpsToTick(fps) / 2
            end
            if dist < 30 then
                optimize = fpsTimer()
                DrawText3D_do(coords.x, coords.y, coords.z + 1.2, b[2])
            end
        end
        Citizen.Wait(optimize)
    end
end)
CreateThread(function()

    while not NetworkIsPlayerActive(PlayerId()) or not NetworkIsSessionStarted() do

        Wait(250);
        prevframes = GetFrameCount();
        prevtime = GetGameTimer();
    end
    while true do

        curtime = GetGameTimer();
        curframes = GetFrameCount();
        if ((curtime - prevtime) > 1000) then

            fps = (curframes - prevframes) - 1;
            prevtime = curtime;
            prevframes = curframes;
        end
        if IsGameplayCamRendering() and fps >= 0 then

            fpsToTick(fps)
        end
        Wait(1000);
    end
end);

function fpsToTick(frame)
    local add = 0
    if frame < 20 then
        add = 3
    elseif frame < 30 then
        add = 2
    elseif frame < 40 then
        add = 1.5
    elseif frame < 50 then
        add = 1.20
    elseif frame < 60 then
        add = 1
    elseif frame < 70 then
        add = 0.858
    elseif frame < 80 then
        add = 0.75
    elseif frame < 90 then
        add = 0.6667
    elseif frame < 100 then
        add = 0.6
    elseif frame < 110 then
        add = 0.546
    elseif frame < 120 then
        add = 0.5
    elseif frame < 130 then
        add = 0.4
    elseif frame > 131 then
        add = 0.3
    end
    return add
end

local shouldStopDoc = false -- Globální proměnná pro zastavení odpočítávání

-- Příkaz doc
RegisterCommand("doc", function(source, args, rawCommand)
    shouldStopDoc = false -- Reset proměnné při každém spuštění příkazu doc

    if args[1] == nil then
        return false
    end

    local count = tonumber(args[1])
    if count == nil or count <= 0 then
        print("Chybné číslo. Zadej kladné celé číslo.")
        return
    end

    for i = 1, count do
        if shouldStopDoc then
            print("Odpočítávání bylo přerušeno.")
            break
        end
        TriggerServerEvent('3ddoc:shareDisplay', "" .. i .. "/" .. count)
        Citizen.Wait(1000)
    end
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "DOC", tostring(args[1]))
end, false)

function notify(text)
    TriggerEvent('notifications:notify', "CHAT", text, 3000)
end

RegisterCommand("id", function(source, args, rawCommand)
    local id = GetPlayerServerId(PlayerId())
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "ID", "Hráč se zeptal na svoje ID")
    notify("Tvoje ID je: " .. id)
    print("Tvoje ID je: " .. id)
end, false)

-- Příkaz pro zastavení doc
RegisterCommand("stopdoc", function(source, args, rawCommand)
    shouldStopDoc = true -- Nastavení proměnné pro zastavení odpočítávání
    print("Příkaz doc bude přerušen.")
    TriggerServerEvent("aprts_3dme:Server:sendMessage", "DOC", "Hráč přerušil svoje DOC")
end, false)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (2 / dist) * 1.1

    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local fov = (2 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.18 * scale, 0.25 * scale)
        SetTextFontForCurrentCommand(6)

        SetTextColor(92, 240, 206, 205)
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 355
        -- DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.1, 0.1, 35, 35, 35, 220, 0)
        DrawSprite("feeds", "hud_menu_5a", _x + 0.0068 * (scale / 2), _y + 0.018 * (scale / 2),
            (0.011 + factor) * scale, 0.015 * scale, 0.1, 1, 1, 1, 190, 0)
    end
end

function DrawText3D_do(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local scale = (2 / dist) * 1.1
    local fov = (2 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.18 * scale, 0.25 * scale)
        SetTextFontForCurrentCommand(6)
        SetTextColor(255, 213, 0, 205)
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 355
        -- DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.1, 0.1, 35, 35, 35, 220, 0)
        DrawSprite("feeds", "hud_menu_5a", _x + 0.0068 * (scale / 2), _y + 0.018 * (scale / 2),
            (0.011 + factor) * scale, 0.015 * scale, 0.1, 1, 1, 1, 190, 0)
    end
end

function DrawText3D_stav(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local scale = (2 / dist) * 1.1
    local fov = (2 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.18 * scale, 0.25 * scale)
        SetTextFontForCurrentCommand(6)
        SetTextColor(193, 193, 193, 204)
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 355
        -- DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.1, 0.1, 35, 35, 35, 220, 0)
        -- DrawSprite("feeds", "hud_menu_5a", _x + 0.0068 * (scale / 2), _y + 0.018 * (scale / 2),
        --     (0.011 + factor) * scale, 0.015 * scale, 0.1, 1, 1, 1, 190, 0)
    end
end
