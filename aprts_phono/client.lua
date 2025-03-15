local Phonographs = {}  -- [handle] = { url=..., volume=..., coords=..., netId=... }

-- Event, co server volá po startu
RegisterNetEvent('phonograph:start')
AddEventHandler('phonograph:start', function(handle, url, title, volume, offset, filter, locked, video, videoSize, muted, coords)
    Phonographs[handle] = {
        url    = url,
        volume = volume or 50,
        coords = coords,  -- vector3(x,y,z) nebo nil
        netId  = (handle ~= nil) and handle or nil
    }
    -- Pošleme do NUI => vytvoř <audio>
    SendNUIMessage({
        type   = 'init',
        handle = handle,
        url    = url,
        title  = title or url,
        volume = volume or 50,
        offset = offset or 0
    })
end)

-- Event, co server volá => "přehraj"
RegisterNetEvent('phonograph:play')
AddEventHandler('phonograph:play', function(handle)
    print('phonograph:play', handle)
    SendNUIMessage({
        type   = 'play',
        handle = handle
    })
end)

-- Event, co server volá => "zastav"
RegisterNetEvent('phonograph:stop')
AddEventHandler('phonograph:stop', function(handle)
    print('phonograph:stop', handle)
    Phonographs[handle] = nil
    SendNUIMessage({
        type   = 'stop',
        handle = handle
    })
end)

-- Použití itemu => spustí fonograf (z `server.lua` se volá: TriggerClientEvent("phonograph:Client:insertDrum", ...))
RegisterNetEvent("phonograph:Client:insertDrum")
AddEventHandler("phonograph:Client:insertDrum", function(drum)
    local object = GetClosestPhonograph()
    if not object then return end

    local coords = GetEntityCoords(object)
    -- Pošleme serveru, že vkládáme drum do fonografu
    TriggerServerEvent("phonograph:Server:insertDrum", drum.item, coords, drum.url)
end)

RegisterNetEvent('phonograph:Client:play')
AddEventHandler('phonograph:Client:play', function(drum)
    local object = GetClosestPhonograph()
    if not object then return end
    local coords = GetEntityCoords(object)
    StartPhonograph(object, drum.url)
end)

RegisterNetEvent('phonograph:Client:stop')
AddEventHandler('phonograph:Client:stop', function()
    local object = GetClosestPhonograph()
    if not object then return end
    local coords = GetEntityCoords(object)
    local handle = GetHandleFromCoords(coords)

    -- Poslat správný příkaz do NUI
    SendNUIMessage({
        type   = 'stop',
        handle = handle
    })

    -- Oprava: skutečně odstraníme fonograf ze seznamu
    Phonographs[handle] = nil
end)

-- Zavolá server, aby spustil hudbu na daném objektu
function StartPhonograph(object, url)
    local netId = ObjToNet(object)
    if netId and NetworkDoesNetworkIdExist(netId) then
        TriggerServerEvent('phonograph:start', netId, url, 25, 0, false, false, false, 50, false)
    else
        local coords = GetEntityCoords(object)
        TriggerServerEvent('phonograph:start', nil, url, 25, 0, false, false, false, 50, false, coords)
    end
end

-- Najde nejbližší p_phonograph01x do ~2m
function GetClosestPhonograph()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local handleObject = nil
    local minDist = 2.0
    for obj in EnumerateObjects() do
        if GetEntityModel(obj) == GetHashKey('p_phonograph01x') then
            local dist = #(coords - GetEntityCoords(obj))
            if dist < minDist then
                minDist = dist
                handleObject = obj
            end
        end
    end
    return handleObject
end

------------------------------------------------------------------
-- Enumerátory pro vyhledávání objektů
local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}
function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        local enum = { handle = iter, destructor = disposeFunc }
        setmetatable(enum, entityEnumerator)
        local nextOk
        repeat
            coroutine.yield(id)
            nextOk, id = moveFunc(iter)
        until not nextOk
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

------------------------------------------------------------------
-- LOGARITMICKÁ FUNKCE PRO VÝPOČET HLUKU
local function GetLogVolume(distance, maxDist, baseVol)
    if distance <= 1.0 then
        return baseVol
    end
    if distance >= maxDist then
        return 0.0
    end
    local factor = math.log(distance) / math.log(maxDist)
    local vol = (1 - factor) * baseVol
    if vol < 0.0 then vol = 0.0 end
    return vol
end

-- Každých 500ms spočítá vzdálenost a do NUI pošle "distanceVolume"
    CreateThread(function()
        while true do
            Wait(500)
            local pedCoords = GetEntityCoords(PlayerPedId())
    
            for handle, info in pairs(Phonographs) do
                local realVolume = 0.0
                local objCoords = nil
    
                if info.netId and NetworkDoesNetworkIdExist(info.netId) then
                    local obj = NetToObj(info.netId)
                    if obj and obj ~= 0 then
                        objCoords = GetEntityCoords(obj)
                    end
                end
                if not objCoords and info.coords then
                    objCoords = vector3(info.coords.x, info.coords.y, info.coords.z)
                end
    
                if objCoords then
                    local dist = #(pedCoords - objCoords)
                    if dist > Config.MaxDistance then
                        -- Pokud je hráč mimo dosah, okamžitě stopni zvuk
                        SendNUIMessage({
                            type   = 'stop',
                            handle = handle
                        })
                        Phonographs[handle] = nil
                    else
                        local baseVol = (info.volume / 100.0) -- 0.0 - 1.0
                        realVolume = GetLogVolume(dist, Config.MaxDistance, baseVol)
                        
                        -- Poslat hlasitost do NUI
                        SendNUIMessage({
                            type   = 'distanceVolume',
                            handle = handle,
                            volume = realVolume
                        })
                    end
                end
            end
        end
    end)
    

------------------------------------------------------------------
-- Pokud chceš, aby nově připojený hráč slyšel už hrající fonograf,
-- nastav mu offset a "play". Třeba takto:
AddEventHandler('playerJoining', function()
    local newPlayer = source
    for handle, info in pairs(Phonographs) do
        local offset = os.time() - info.startTime
        TriggerClientEvent('phonograph:start', newPlayer, handle, info.url, info.title, info.volume, offset, false, false, false, 50, false, info.coords)
        TriggerClientEvent('phonograph:play', newPlayer, handle)
    end
end)
