--[[
    cl_horse_shop.lua
    Description: This script handles the client-side operations for the horse shop, including displaying the menu and purchasing horses.
]]
local horseShopNPC = nil

-- Added the missing LoadModel function
local function LoadModel(model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end
    return modelHash
end

local function CreateCamera(coords, targetEntity)
    local newCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(newCam, coords.x, coords.y, coords.z + 1.2)
    SetCamActive(newCam, true)
    PointCamAtEntity(newCam, targetEntity, 0, 0, 0, true)
    -- DoScreenFadeOut(500)
    -- Wait(500)
    DoScreenFadeIn(200)
    RenderScriptCams(true, false, 0, 0, 0)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
    return newCam
end

local function showHorse(model, coords, h)
    local modelHash = LoadModel(model)

    -- Using PlaceEntityOnGroundProperly instead of manual ground Z coordinate calculation
    local horse = CreatePed(modelHash, coords.x, coords.y, coords.z, h or 0.0, false, false, false, false)
    PlaceEntityOnGroundProperly(horse)
    SetEntityInvincible(horse, true)
    FreezeEntityPosition(horse, true)
    SetEntityHeading(horse, h or 0.0)
    SetBlockingOfNonTemporaryEvents(horse, true)
    SetRandomOutfitVariation(horse, true)
    SetEntityCollision(horse, false, false)
    -- SetModelAsNoLongerNeeded(modelHash)
    return horse
end

local function getNPCData(npcID)
    for _, npc in ipairs(Config.HorseShopNPC) do
        if npc.id == npcID then
            return npc
        end
    end
end

local function checkNPC(npcID, horseNPCIDs)
    if #horseNPCIDs == 0 then
        return true
    end
    for _, NPC in ipairs(horseNPCIDs) do
        if NPC == npcID then
            return true
        end
    end
    return false
end

local function chechJob(jobs, neededJob)
    if neededJob == "" then
        return true
    end

    for _, job in ipairs(jobs) do
        if job.job == neededJob then
            return true
        end
    end
    return false
end

local function openHorseShopMenu(NPCid)
    HolsterPedWeapons(PlayerPedId(), true, true, true, true)
    HidePedWeapons(PlayerPedId(), 2, true)

    local job = LocalPlayer.state.Character.Job
    local npc = getNPCData(NPCid)
    if not npc then
        return dprint('NPC not found:', NPCid)
    end
    local currentHorse = nil
    local currentCam = nil
    local menu = jo.menu.create('horseShopMenu', {
        title = npc.name,
        subtitle = "Purchase a horse",
        onEnter = function()
            print('Entered Horse Shop Menu')
        end,
        onBack = function()
            print('Exited Horse Shop Menu')
            if currentHorse then
                DeleteEntity(currentHorse)
                currentHorse = nil
            end
            if currentCam then
                RenderScriptCams(false, false, 0, 1, 0)
                DestroyCam(currentCam, false)
                currentCam = nil
            end
            DoScreenFadeIn(150)
            jo.menu.show(false)
        end
    })

    for _, horse in ipairs(Horses) do
        -- Assuming job check logic is correct
        if true then
            if checkNPC(NPCid, horse.NPCid) then
                local horseName = horse.breed .. " " .. horse.color
                menu:addItem({
                    title = horseName .. " - $" .. horse.cashPrice,
                    statistics = {{
                        label = "The label",
                        value = "The value"
                    }},
                    onClick = function()
                        print('Exited Horse Shop Menu')
                        local meta = getMetaTag(currentHorse)
                        if currentCam then
                            RenderScriptCams(false, false, 0, 1, 0)
                            DestroyCam(currentCam, false)
                            currentCam = nil
                        end
                        DoScreenFadeIn(150)
                        jo.menu.show(false)
                        horse.name = nil
                        local inPut1 = nil

                        Citizen.CreateThread(function()
                            AddTextEntry("FMMC_MPM_TYP8", "Name your horse:")
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_TYP8", "", "Name", "", "", "", 30)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0)
                                Citizen.Wait(0)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                inPut1 = GetOnscreenKeyboardResult()
                                dprint('Horse Hash?', currentHorseModel, inPut1)
                                dprint("Horse with meta: ", meta)
                                TriggerServerEvent('aprts_horses:buyHorse', GetHashKey(horse.horse_id), "horse", inPut1,
                                    meta, horse.breed, horse.cashPrice)
                                horse.name = inPut1
                            end
                        end)
                        if currentHorse then
                            DeleteEntity(currentHorse)
                            currentHorse = nil
                        end
                    end,
                    onActive = function()
                        DoScreenFadeOut(150)
                        while DoesEntityExist(currentHorse) do
                            DeleteEntity(currentHorse)
                            Wait(100)
                        end

                        currentHorse = showHorse(horse.horse_id, npc.horseCoords, npc.horseHeading)
                        Wait(1000)
                        if currentCam then
                            RenderScriptCams(false, false, 0, 1, 0)
                            DestroyCam(currentCam, false)
                            currentCam = nil
                        end
                        currentCam = CreateCamera(npc.cameraCoords, currentHorse)
                    end,
                    onBack = function()
                        if currentHorse then
                            DeleteEntity(currentHorse)
                            currentHorse = nil
                        end
                        Wait(200)
                    end
                })
            end
        end
    end

    menu:send()
    -- Define the current menu
    jo.menu.setCurrentMenu('horseShopMenu', false, true)
    jo.menu.show(true)
end

local function spawnNPC(shopNPC)
    local modelHash = LoadModel(shopNPC.model)
    local npc = CreatePed(modelHash, shopNPC.coords.x, shopNPC.coords.y, shopNPC.coords.z, shopNPC.heading, false, false,
        false, false)
    PlaceEntityOnGroundProperly(npc)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityCompletelyDisableCollision(npc, false, false)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc, 6)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc, 0)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc, 1)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc, 2)
    SetModelAsNoLongerNeeded(modelHash)
    return npc
end

local function manageNPCs()
    horseShopNPC = nil
    local pcoords = GetEntityCoords(PlayerPedId())
    for _, npc in ipairs(Config.HorseShopNPC) do
        local dist = GetDistanceBetweenCoords(pcoords, npc.coords.x, npc.coords.y, npc.coords.z, 1)

        if dist < Config.drawDistance and not DoesEntityExist(npc.obj) then
            npc.obj = spawnNPC(npc)
        elseif dist > Config.drawDistance and DoesEntityExist(npc.obj) then
            DeleteEntity(npc.obj)
            SetModelAsNoLongerNeeded(GetHashKey(npc.model))
        end
    end
end

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

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local pcoords = GetEntityCoords(PlayerPedId())
        for _, npc in ipairs(Config.HorseShopNPC) do
            local dist = GetDistanceBetweenCoords(pcoords, npc.coords.x, npc.coords.y, npc.coords.z, 1)
            if dist < npc.shopDistance then
                DrawTxt("Press [~b~G~s~] to open Horse Shop", 0.5, 0.88, 0.4, 0.4, true, 255, 255, 255, 255, true)
                horseShopNPC = npc.id
                pause = fpsTimer()
                if IsControlJustReleased(0, 0xA1ABB953) then -- G key
                    print('Opening Horse Shop ' .. horseShopNPC)
                    openHorseShopMenu(horseShopNPC)
                end
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(500)
        manageNPCs()
    end
end)

RegisterNetEvent('aprts_horses:openShopMenu')
AddEventHandler('aprts_horses:openShopMenu', function()
    if not horseShopNPC then
        return
    end
    openHorseShopMenu(horseShopNPC)
end)

RegisterNetEvent('aprts_horses:purchaseSuccess')
AddEventHandler('aprts_horses:purchaseSuccess', function(horseName)
    notify("You have successfully purchased a " .. horseName)
end)

RegisterNetEvent('aprts_horses:purchaseFailed')
AddEventHandler('aprts_horses:purchaseFailed', function(reason)
    notify("Purchase failed: " .. reason)
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    if enableShadow then
        SetTextDropshadow(1, 0, 0, 0, 255)
    end
    Citizen.InvokeNative(0xADA9255D, 22)
    DisplayText(str, x, y)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    for _, v in pairs(Config.HorseShopNPC) do
        if v.obj then
            DeleteEntity(v.obj)
        end
    end
    for _, npc in pairs(NPCs) do
        if DoesEntityExist(npc.obj) then
            DeleteEntity(npc.obj)
        end
    end
end)
