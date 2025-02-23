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
    SendNUIMessage({
        type   = 'play',
        handle = handle
    })
end)

-- Event, co server volá => "zastav"
RegisterNetEvent('phonograph:stop')
AddEventHandler('phonograph:stop', function(handle)
    Phonographs[handle] = nil
    SendNUIMessage({
        type   = 'stop',
        handle = handle
    })
end)

RegisterNetEvent('phonograph:Client:stop')
AddEventHandler('phonograph:Client:stop', function(coords)
    local object = GetClosestPhonograph()
    if not object then return end
    local coords = GetEntityCoords(object)
    local handle = GetHandleFromCoords(coords)
    Phonographs[handle] = nil
    SendNUIMessage({
        type   = 'stop',
        handle = handle
    })
end)
-- Použití itemu => spustí fonograf
RegisterNetEvent('phonograph:Client:play')
AddEventHandler('phonograph:Client:play', function(drum)
    local object = GetClosestPhonograph()
    if not object then return end
    local coords = GetEntityCoords(object)
    StartPhonograph(object, drum.url)
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
        local enum = {handle = iter, destructor = disposeFunc}
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
-- Když je distance <= 1 => plná hlasitost
-- Když je distance >= maxDist => 0
-- Jinak logaritmicky klesá: volume = (1 - ( log(distance)/log(maxDist) )) * baseVol
-- Lze upravit dle gusta
local function GetLogVolume(distance, maxDist, baseVol)
    if distance <= 1.0 then
        return baseVol
    end
    if distance >= maxDist then
        return 0.0
    end

    -- Vezmeme poměr log(distance)/log(maxDist) => 0 => 1. 
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

            -- Zkusíme coords z netId
            if info.netId and NetworkDoesNetworkIdExist(info.netId) then
                local obj = NetToObj(info.netId)
                if obj and obj ~= 0 then
                    objCoords = GetEntityCoords(obj)
                end
            end
            -- pokud nenašli netId => vezmeme ručně uložené coords
            if not objCoords and info.coords then
                objCoords = vector3(info.coords.x, info.coords.y, info.coords.z)
            end

            if objCoords then
                local dist = #(pedCoords - objCoords)
                local baseVol = (info.volume / 100.0) -- 0.0 - 1.0
                realVolume = GetLogVolume(dist, Config.MaxDistance, baseVol)
            end

            SendNUIMessage({
                type   = 'distanceVolume',
                handle = handle,
                volume = realVolume
            })
        end
    end
end)




RegisterNetEvent("phonograph:Client:insertDrum")
AddEventHandler("phonograph:Client:insertDrum", function(drum)
    local object = GetClosestPhonograph()
    if not object then return end
    local coords = GetEntityCoords(object)
    TriggerServerEvent("phonograph:Server:insertDrum", drum.item, coords,drum.url)
end)