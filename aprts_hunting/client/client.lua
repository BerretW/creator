Butchers = {}
local currentMonth
local blipEntries = {}
local prompts = {}
local butcherNPC = nil
local butcher = nil
function notify(text)
    TriggerEvent('notifications:notify', "Lovec", text, 3000)
end

Citizen.CreateThread(function()
    TriggerServerEvent("aprts_hunting:fetchAnimals")
    TriggerServerEvent("aprts_hunting:getDateTime") -- Fetch the current date and time
end)
function debugPrint(msg)
    if Config.Debug == true then
        print(msg)
    end
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end


AddEventHandler("onClientResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print("Resource started")
    TriggerServerEvent("aprts_hunting:Server:fetchButchers")
end)

RegisterNetEvent("aprts_hunting:Client:receiveButchers")
AddEventHandler("aprts_hunting:Client:receiveButchers", function(butchers)
    Butchers = butchers
    -- print("Butchers loaded: " .. #Butchers)

    for _, butcher in pairs(Butchers) do
        -- print(butcher.name, butcher.coords.x, butcher.coords.y, butcher.coords.z)
    end

end)

RegisterNetEvent("aprts_hunting:Client:updateButcher")
AddEventHandler("aprts_hunting:Client:updateButcher", function(butcher)
    -- print("Updating butcher: " .. Butchers[butcher.id].id .. " old gain: " .. Butchers[butcher.id].gain)
    Butchers[butcher.id].gain = butcher.gain
    -- print("New gain: " .. Butchers[butcher.id].gain)
    -- print("Butcher updated: " .. butcher.name)
end)

RegisterNetEvent("aprts_hunting:receiveAnimals")
AddEventHandler("aprts_hunting:receiveAnimals", function(animals)
    Animals = animals
    -- print("Animals loaded: " .. #Animal)
    debugPrint("Animals loaded")
    for _, animal in pairs(Animals) do
        debugPrint(animal.name .. "," .. animal.model .. "," .. animal.base_price .. "," .. animal.poor_price .. "," ..
                       animal.good_price .. "," .. animal.perfect_price)

    end
    print(table.count(Animals) .. " animals loaded")
end)

RegisterNetEvent("aprts_hunting:receiveDateTime")
AddEventHandler("aprts_hunting:receiveDateTime", function(result)
    currentMonth = tonumber(result.month)
    -- print("Current date and time is " .. result.year)
    SetClockDate(tonumber(result.day), currentMonth, 1899)
    Citizen.Wait(1000)
    local day = GetClockDayOfMonth()
    local month = GetClockMonth()
    local year = GetClockYear()
    local hour = GetClockHours()
    debugPrint("Today is " .. day .. "/" .. currentMonth .. "/" .. year .. " and the time is " .. hour .. ":00")
end)

function isHuntingSeason(season)

    if not season then
        return false
    end
    local seasonTable = json.decode(season)
    for _, month in ipairs(seasonTable) do
        if month == currentMonth then
            return true
        end
    end
    return false
end

-- local promptGroup = UipromptGroup:new("Butcher")

-- local prompt1 = Uiprompt:new(0x760A9C6F, "Menu", promptGroup)

-- local prompt2 = Uiprompt:new(0xF3830D8E, "Sell", promptGroup)

-- prompt2:setOnControlJustPressed(function()
--     print("Prompt1 pressed")
-- 	TriggerEvent("aprts_hunting:sellCarcass")
-- end)

-- prompt1:setOnControlJustPressed(function()	
--     print("Prompt2 pressed")
--     TriggerEvent("aprts_hunting:openTraderMenu")
-- end)

local ButcherGroup = UipromptGroup:new("Butcher")

local selPrompt = Uiprompt:new(0x760A9C6F, "Prodat kožešinu nebo mrtvolu", ButcherGroup)
selPrompt:setEnabledAndVisible(true)
selPrompt:setOnControlJustPressed(function()
    if butcherNPC == nil then
        -- notify("Není žádný řezník v blízkosti.")
        return
    end
    -- print("Prompt1 pressed")
    TriggerEvent("aprts_hunting:sellCarcass")
    Wait(3000)
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        if not IsPedDeadOrDying(playerPed) then
            selPrompt:handleEvents(playerPed)
        end
        Wait(0)
    end
end)

-- ButcherGroup:setEnabled(true)

Citizen.CreateThread(function()
    while #Butchers < 1 do
        Citizen.Wait(1000)
    end
    for i = 1, #Butchers do
        local pos = Butchers[i]
        -- print("Creating butcher " .. json.encode(pos.coords))
        if pos.showblip == "true" then
            -- print("Creating blip for " .. pos.name)
            local ButcherBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, pos.coords.x, pos.coords.y,
                pos.coords.z)
            SetBlipSprite(ButcherBlip, joaat(pos.blipsprite), true)
            SetBlipScale(ButcherBlip, pos.blipscale)
            Citizen.InvokeNative(0x9CB1A1623062F402, ButcherBlip, pos.name)

            blipEntries[#blipEntries + 1] = {
                type = "BLIP",
                handle = ButcherBlip
            }
        end
    end
end)

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

-- Manage NPC rendering
Citizen.CreateThread(function()
    while true do
        local pause = 500
        for _, npc in pairs(Butchers) do
            local butcherFound = false
            local pcoords = GetEntityCoords(PlayerPedId())
            local dist = GetDistanceBetweenCoords(pcoords, npc.coords.x, npc.coords.y, npc.coords.z, 1)

            if dist < Config.drawDistance and not DoesEntityExist(npc.NPC) then

                npc.NPC = spawnNPCs(npc.model, npc.coords.x, npc.coords.y, npc.coords.z, npc.npcH*1.0)
                debugPrint("NPC spawned " .. npc.NPC)

            elseif dist > Config.drawDistance and DoesEntityExist(npc.NPC) then
                DeleteEntity(npc.NPC)
                SetModelAsNoLongerNeeded(GetHashKey(npc.model))
            end

            if dist < 2.5 then
                butcherNPC = npc.NPC
                butcher = npc
                -- print("Prompt1 enabled")
                ButcherGroup:setActiveThisFrame()
                pause = fpsTimer()
                break
            else
                butcherNPC = nil
                butcher = nil
                -- print("Prompt1 disabled")
                -- ButcherGroup:setEnabled(false)
            end

        end
        Citizen.Wait(pause)
    end
end)

RegisterNetEvent("aprts_hunting:sellCarcass")
AddEventHandler("aprts_hunting:sellCarcass", function(msg)
    if butcher == nil then
        notify("Není žádný řezník v blízkosti.")
        return
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped) -- ISPEDHOLDING
    local model = GetEntityModel(holding)
    local holdingName = nil
    local isSeason = false
    local holdintgOutfit = tonumber(GetPedMetaOutfitHash(holding, 1))
    if not holding or holding == 0 then
        notify("Tohle nechci!")
        return
    end
    print("Holding is " .. holding or "!!!")
    print("Holding outfit is " .. holdintgOutfit or "!!!")
    -- notify("Holding is " .. holding)
    local itemPrice = nil
    local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
    print("Kvalita kůže je: " .. tostring(quality) or  "!!!")
    local animalID = 0
    if holding ~= false then
        for i, row in pairs(Animals) do
            isSeason = isHuntingSeason(Animals[i]["hunting_season"])
            if holdintgOutfit == Animals[i].outfit and holdintgOutfit ~= 0 then
                holdingName = Animals[i].label
                itemPrice = Animals[i].base_price
                debugPrint("Holding outfit is " .. Animals[i].outfit)
                animalID = i
                break
            elseif holdintgOutfit == 0 and model == Animals[i].model and Animals[i].outfit == 0 then
                holdingName = Animals[i].label
                itemPrice = Animals[i].base_price
                debugPrint("Holding outfit is " .. Animals[i].outfit)
                animalID = i
                break
            elseif quality == Animals[i].poor then
                holdingName = Animals[i].label .. ": Zničená kůže"
                itemPrice = Animals[i].poor_price
                animalID = i
                break
            elseif quality == Animals[i].good then
                holdingName = Animals[i].label .. ": Dobrá kůže"
                itemPrice = Animals[i].good_price
                animalID = i
                break
            elseif quality == Animals[i].perfect then
                holdingName = Animals[i].label .. ": Perfektní kůže"
                itemPrice = Animals[i].perfect_price
                animalID = i
                break
            end
        end
    end
    -- print("Holding quality is " .. quality)
    if holding ~= false and holdingName then
        local entity = holding
        local endpiece = 1 * (isSeason and itemPrice * 1.5 or itemPrice)
        endpiece = endpiece * tonumber(butcher.gain)
        TriggerServerEvent("aprts_hunting:Server:modifyButcherGain", butcher.id, Config.GainLose)
        -- Wait(500)
        -- SetEntityAsMissionEntity(entity, false, false)
        -- Wait(500)
        DeleteEntity(entity)
        NetworkRegisterEntityAsNetworked(entity)
        local networkId = NetworkGetNetworkIdFromEntity(entity)
        Wait(10)
        if DoesEntityExist(entity) then
            Wait(1000)
        end
        -- endpiece = math.round(endpiece,3)
        -- print("Selling " .. holdingName .. " for $" .. endpiece .. " to " .. butcher.name)
        TriggerServerEvent("aprts_hunting:money", endpiece)
        TriggerServerEvent("aprts_hunting:Server:sellAnimal", butcher.id, animalID, holdingName, endpiece,networkId)

        Wait(1500)
        notify("Prodals " .. holdingName .. " za $" .. endpiece)

    else
        notify("Neneseš žádné zvíře ani kůži.")
    end

end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, prompt in ipairs(prompts) do
            debugPrint("Removing prompt " .. prompt)
            Citizen.InvokeNative(0x8A0FB4D03A630D21, prompt, false)
            Citizen.InvokeNative(0x71215ACCFDE075EE, prompt, false)
        end
        prompts = {}
        for _, blip in ipairs(blipEntries) do
            if blip.type == "BLIP" then
                RemoveBlip(blip.handle)
            end
        end
        for _, npc in ipairs(Butchers) do
            DeleteEntity(npc.NPC)
        end
    end
end)
local function getButcher()
    return butcher
end

exports("Client:getButcher", getButcher)

local function getButcherId()
    return butcher.id
end

exports("Client:getButcherId", getButcherId)
