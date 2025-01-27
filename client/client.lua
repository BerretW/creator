myHorses = {}
local displayHorses = {}
local horseOnDisplay = nil
local isSpawning = false -- Přidáno pro kontrolu, zda již probíhá spawn



function debugPrint(msg)
    if Config.Debug then
        print(msg)
    end
end

-- Get horse with id 
local function getHorse(id)
    for _, horse in ipairs(myHorses) do
        if horse.id == id then
            return horse
        end
    end
    return nil
end

-- Get NPC by name
local function getNPC(name)
    for _, npc in ipairs(NPCs) do
        if npc.name == name then
            return npc
        end
    end
    return nil
end

-- View Horses While in Menu
local function CreateCamera(npc)
    local horseCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(horseCam, npc.camCoords.x, npc.camCoords.y, npc.camCoords.z + 1.2)
    SetCamActive(horseCam, true)
    PointCamAtCoord(horseCam, npc.displayCoords.x - 0.5, npc.displayCoords.y, npc.displayCoords.z)
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
    return horseCam
end

function LoadModel(model)
    local modelHash = GetHashKey(model)
    if not IsModelValid(modelHash) then
        return dprint('Invalid model:', model)
    end
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end
    return modelHash
end

local function LoadModelHash(hash)
    if not IsModelValid(hash) then
        return dprint('Invalid model:', hash)
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
    end
end

local function getHorseName(horse)
    local model = tonumber(GetEntityModel(horse))
    for _, Horse in ipairs(Horses) do
        if GetHashKey(Horse.horse_id) == model then
            return Horse.breed .. " " .. Horse.color, Horse.cashPrice
        end
    end
end

local function getHorsePrice(horse)
    for _, Horse in pairs(Horses) do
        if GetHashKey(Horse.horse_id) == tonumber(horse.vehicles) then
            return Horse.cashPrice
        end
    end
    return 0
end

function getHorseBreed(horse)
    local name = GetDiscoverableNameHashAndTypeForEntity(horse)
    local breed = GetStringFromHashKey()
    local model = GetEntityModel(horse)
    local coat = GetHorseCoatFromModel(tonumber(model))
    dprint("Name: ", GetStringFromHashKey(name))
    dprint("model: ", coat)
    return GetStringFromHashKey(name)
end

local function getModelString(horse)
    local model = horse.vehicles
    local modelString = GetStringFromHashKey(tonumber(model))
    dprint(modelString)
    return modelString
end

-- Spawn frozen horse for display
local function spawnHorse(horse, pos, h)
    if isSpawning then
        dprint("Already spawning a horse. Please wait.")
        return
    end
    isSpawning = true
    dprint("Spawning Horse: ", horse.name, horse.vehicles)
    local model = tonumber(horse.vehicles)
    LoadModelHash(model)

    local foundGround, groundZ
    for height = 1, 1000 do
        foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(pos.x, pos.y, height + 0.0)
        if foundGround then
            dprint('FOUND GROUND!: ' .. groundZ)
            break
        end
    end

    local newHorse = CreatePed(model, pos.x, pos.y, groundZ, h, 1, 0)
    SetEntityInvincible(newHorse, true)
    SetBlockingOfNonTemporaryEvents(newHorse, true)
    while not DoesEntityExist(newHorse) do
        Citizen.Wait(100)
    end
    SetRandomOutfitVariation(newHorse, true)
    print("Horse spawned: ", newHorse .. json.encode(horse.meta))
    applyMetaTag(newHorse, horse.meta)
    FreezeEntityPosition(newHorse, true)
    isSpawning = false
    return newHorse
end

-- Funkce pro vyčištění koní
local function CleanupHorses()
    for _, horse in ipairs(displayHorses) do
        if DoesEntityExist(horse) then
            DeleteEntity(horse)
        end
    end
    displayHorses = {}
    if horseOnDisplay and DoesEntityExist(horseOnDisplay) then
        DeleteEntity(horseOnDisplay)
        horseOnDisplay = nil
    end
end

-- Funkce pro vyčištění při zastavení resource
local function CleanupOnResourceStop()
    if DoesEntityExist(horseOnDisplay) then
        DeleteEntity(horseOnDisplay)
    end
    for _, horse in pairs(displayHorses) do
        print("Deleting horse " .. horse)
        if DoesEntityExist(horse) then
            DeleteEntity(horse)
        end
    end
    displayHorses = {}
    DestroyAllCams(true)
    jo.menu.show(false)
    FreezeEntityPosition(PlayerPedId(), false)
end
local function CleanupHorsesAndCams()
    CleanupHorses()
    if horseOnDisplay then
        DeleteEntity(horseOnDisplay)
        horseOnDisplay = nil
    end
    DestroyAllCams(true)
    FreezeEntityPosition(PlayerPedId(), false)
end


-- Funkce pro efekt přechodu kamery
local function FadeCamera()
    DoScreenFadeOut(200)
    Citizen.Wait(200)
    DoScreenFadeIn(200)
end

-- Funkce pro nastavení koně jako defaultního
local function SetDefaultHorse(kun)
    print("Selected horse ", json.encode(kun))
    jo.notif.rightSuccess('Horse ' .. kun.name .. ' was set to Default')
    TriggerServerEvent("aprts_horses:Server:defHorse", kun.id)
    fleeHorse(myHorse.ped)
    jo.menu.show(false)
    CleanupHorsesAndCams()
end

-- Funkce pro potvrzení prodeje koně
local function ConfirmSellHorse(kun)
    dprint("Selected horse ", json.encode(kun))
    local answer = exports.aprts_inputButtons:getAnswer("Opravdu chcete prodat tohoto koně?", {
        { label = "Ano", value = 1, image = "check.png" },
        { label = "Ne", value = 2, image = "cross.png" }
    }, 10000, "black_paper.png")

    if answer == 1 then
        print(json.encode(kun))
        TriggerServerEvent("aprts_horses:sellHorse", kun.id)
        jo.menu.show(false)
        CleanupHorsesAndCams()
    end
end

-- Funkce pro zobrazení koně při aktivaci položky menu
local function HandleHorseDisplay(index, horse, camera, menuType)
    if isSpawning then
        dprint("Currently spawning a horse. Please wait.")
        return
    end

    local posKey = "displayCoords" .. (index > 1 and tostring(index) or "")
    local camKey = "camCoords" .. (index > 1 and tostring(index) or "")

    if Config.multiStable and closestNPC[camKey] then
        FadeCamera()
        SetCamCoord(camera, closestNPC[camKey].x, closestNPC[camKey].y, closestNPC[camKey].z + 1.2)
        PointCamAtCoord(camera, closestNPC[posKey].x - 0.5, closestNPC[posKey].y, closestNPC[posKey].z)
    else
        if horseOnDisplay then
            DeleteEntity(horseOnDisplay)
            horseOnDisplay = nil
        end
        FadeCamera()
        horseOnDisplay = spawnHorse(horse, closestNPC.displayCoords, closestNPC.displayH)
        SetCamCoord(camera, closestNPC.camCoords.x, closestNPC.camCoords.y, closestNPC.camCoords.z + 1.2)
        PointCamAtCoord(camera, closestNPC.displayCoords.x - 0.5, closestNPC.displayCoords.y, closestNPC.displayCoords.z)
    end
end

local function CreateMenu()
    if not closestNPC then
        print("No NPC found")
        return
    end

    TriggerServerEvent("aprts_horses:getHorses")

    -- Čekání na načtení koní s timeoutem
    local waitTime = 0
    while table.count(myHorses) < 1 do
        waitTime = waitTime + 1
        if waitTime > 100 then -- Přibližně 5 sekund
            notify("Nemáte žádné koně")
            return
        end
        Citizen.Wait(50) -- Krátká pauza před dalším zkontrolováním
    end

    FreezeEntityPosition(PlayerPedId(), true)
    local camera = CreateCamera(closestNPC)

    -- Odstranění existujících koní z display
    CleanupHorses()

    -- Spawn koní pokud je multiStable povolen
    if Config.multiStable then
        for i, kun in ipairs(myHorses) do
            local posKey = "displayCoords" .. (i > 1 and tostring(i) or "")
            if closestNPC[posKey] then
                local pos = closestNPC[posKey]
                table.insert(displayHorses, spawnHorse(kun, pos, closestNPC.displayH))
            end
        end
    else
        if #myHorses > 0 then
            horseOnDisplay = spawnHorse(myHorses[1], closestNPC.displayCoords, closestNPC.displayH)
        end
    end
    -- Funkce pro vyčištění koní a kamer

    -- Inicializace menu
    local menu = jo.menu.create('menu1', {
        title = closestNPC.name,
        subtitle = "Horse Management",
        onEnter = function()
            dprint('onEnter menu1')
        end,
        onBack = function()
            dprint('onBack menu1')
            jo.menu.show(false)
            FreezeEntityPosition(PlayerPedId(), false)
            CleanupHorsesAndCams()
        end,
        onExit = function()
            dprint('onExit menu1')
        end
    })

    -- Přidání položek do hlavního menu
    menu:addItem({ title = "Moje Koně", child = "subMenu" })
    menu:addItem({ title = "Prodej Koní", child = "sellMenu" })
    menu:send()

    -- Vytvoření podmenu "Moje Koně"
    local subMenu = jo.menu.create('subMenu', {
        title = "Moje Koně",
        onEnter = function() dprint('enter subMenu') end,
        onBack = function() dprint('pressed BACK subMenu') end,
        onExit = function() dprint('exit subMenu') end
    })

    -- Vytvoření podmenu "Prodej Koní"
    local sellMenu = jo.menu.create('sellMenu', {
        title = "Prodej Koní",
        onEnter = function() dprint('enter sellMenu') end,
        onBack = function() dprint('pressed BACK sellMenu') end,
        onExit = function() dprint('exit sellMenu') end
    })



    -- Přidání koní do podmenu "Moje Koně"
    for i, kun in ipairs(myHorses) do
        subMenu:addItem({
            title = string.format("%s - %s", kun.name, kun.breed),
            onActive = function()
                HandleHorseDisplay(i, kun, camera, "subMenu")
            end,
            onClick = function()
                SetDefaultHorse(kun)
            end,
            onExit = function()
                DeleteEntity(horseOnDisplay)
                dprint('onExit sub')
            end
        })
    end
    subMenu:send()

    -- Přidání koní do podmenu "Prodej Koní"
    for i, kun in ipairs(myHorses) do
        local price = math.floor(getHorsePrice(kun) / 10)
        sellMenu:addItem({
            title = string.format("%s - %s - %d$", kun.name, kun.breed, price),
            onActive = function()
                HandleHorseDisplay(i, kun, camera, "sellMenu")
            end,
            onClick = function()
                ConfirmSellHorse(kun)
            end,
            onExit = function()
                DeleteEntity(horseOnDisplay)
                dprint('onExit sellMenu')
            end
        })
    end
    sellMenu:send()

    -- Nastavení aktuálního menu a jeho zobrazení
    jo.menu.setCurrentMenu('menu1', false, true)
    jo.menu.show(true)
end

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    CleanupOnResourceStop()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerServerEvent("aprts_horses:getHorses")
end)

RegisterNetEvent("aprts_horses:openMenu")
AddEventHandler("aprts_horses:openMenu", function()
    print("Opening Menu")
    if jo.menu.isOpen() then
        jo.menu.show(false)
        FreezeEntityPosition(PlayerPedId(), false)
        CleanupHorses()
        DestroyAllCams(true)
    else
        CreateMenu()
    end
end)

RegisterNetEvent("aprts_horses:sendHorses")
AddEventHandler("aprts_horses:sendHorses", function(horses)
    myHorses = horses
    for _, horse in ipairs(myHorses) do
        dprint(horse.name .. " - " .. horse.breed)
    end
end)

function getClosestHorseID(range)
    local closestHorse = nil
    if range == nil then
        range = 1
    end
    local horse = Citizen.InvokeNative(0x0501D52D24EA8934, range, Citizen.ResultAsInteger()) 
    if (horse == 0) then
        return nil
    end
    return Entity(horse).state.myHorseId
end

--------------------- Call body pro koně --------------------------
spawnPoints = {}
RegisterNetEvent("aprts_roadpoints:Client:getPoints")
AddEventHandler("aprts_roadpoints:Client:getPoints", function(serverPoints)
    spawnPoints = serverPoints
end)
RegisterNetEvent("aprts_roadpoints:Client:addPoint")
AddEventHandler("aprts_roadpoints:Client:addPoint", function(point)
    spawnPoints[point.id] = point
end)

function getClosestPoint(coords)
    local closestPoint = nil
    local closestDistance = math.huge
    for id, point in pairs(spawnPoints) do
        local distance = GetDistanceBetweenCoords(coords, point.coords.x, point.coords.y, point.coords.z, false)
        if distance < closestDistance then
            closestDistance = distance
            closestPoint = point
        end
    end
    return closestPoint
end
