local function getFPS()
    local frameTime = GetFrameTime()
    local frame = 1.0 / frameTime
    return frame
end

function fpsTimer()
    local minFPS = 15
    local maxFPS = 165
    local minSpeed = 0
    local maxSpeed = 15
    local coefficient = 1 - (getFPS() - minFPS) / (maxFPS - minFPS)
    return minSpeed + coefficient * (maxSpeed - minSpeed)
end

local function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
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

local function openInventory(horseID)
    print("Opening inventory for horse " .. horseID)
    TriggerServerEvent("aprts_horses:Server:openInventory", horseID)
end

local function bag_check()
    debugPrint("Start checking for bags")
    while not LocalPlayer.state do
        Wait(100)
    end
    while not LocalPlayer.state.Character do
        Wait(100)
    end
    repeat
        Wait(100)
    until LocalPlayer.state.IsInSession

    while true do
        local pause = 1000
        local coords = GetEntityCoords(PlayerPedId(), true, true)
        -- debugPrint("Player pos" .. coords.x .. " " .. coords.y .. " " .. coords.z)
        if myHorse.ped then
            -- debugPrint("Checking for bags")
            local horseCoords = GetEntityCoords(myHorse.ped)
            -- debugPrint("Horse pos" .. horseCoords.x .. " " .. horseCoords.y .. " " .. horseCoords.z)

            local distance = GetDistanceBetweenCoords(coords, horseCoords.x, horseCoords.y, horseCoords.z, false)
            local hasBags = Citizen.InvokeNative(0xFB4891BD7578CDC1, myHorse.ped, -2142954459) -- IsMetaPedUsingComponent
            -- debugPrint("Distance: " .. distance)
            if distance < 2.0 then
                if hasBags then
                    pause = 0
                    if IsDisabledControlJustPressed(0, 0x4CC0E2FE) then
                        notify("Otevírám inventář koně")
                        openInventory(myHorse.id)
                    end
                end
            end
        end
        Citizen.Wait(pause)
    end
end

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        debugPrint("Horses loaded")
        while not LocalPlayer.state do
            Wait(100)
        end
        while not LocalPlayer.state.Character do
            Wait(100)
        end
        repeat
            Wait(100)
        until LocalPlayer.state.IsInSession
        bag_check()
    end
end)

function getLoot()
    -- select random loot from table Config.horseLoot
    local loot = Config.horseLoot[math.random(1, #Config.horseLoot)]
    if math.random() > loot.chance then
        return loot.item, loot.count
    else
        notify("Nic jsi nenašel")
        return nil
    end
end

function Interactions()
    while not LocalPlayer.state do
        Wait(100)
    end
    while not LocalPlayer.state.Character do
        Wait(100)
    end
    repeat
        Wait(5000)
    until LocalPlayer.state.IsInSession
    local playerPed = PlayerPedId()

    while true do
        local sleep = 1000
        local ready = true
        local horse = 0
        -- print("Checking for horse")
        if (IsEntityDead(playerPed)) or (not IsPedOnFoot(playerPed)) then
            -- print("Player is dead or not on foot")
            ready = false
        else
            horse = Citizen.InvokeNative(0x0501D52D24EA8934, 1, Citizen.ResultAsInteger()) -- Get HorsePedId in Range
            if (horse == 0) or (horse == myHorse.ped) then

                ready = false
            end
        end

        -- if ready == true then
        --     sleep = 0
        --     -- PromptSetActiveGroupThisFrame(LootGroup, CreateVarString(10, 'LITERAL_STRING', "Vybrat koně"), 1, 0, 0, 0)
            -- if IsDisabledControlJustPressed(0, 0xFF8109D8) then
            --     FreezeEntityPosition(playerPed, true)
            --     -- Wait(5000)
            --     FreezeEntityPosition(playerPed, false)
            --     notify("Otevírám inventář cizího koně")
            --     local horseId = Entity(horse).state.myHorseId
            --     if horseId == nil then
            --         notify("Nepodařilo se zjistit ID koně")
            --     else

            --         openInventory(horseId)
            --     end

            -- end
        -- end
        Citizen.Wait(sleep)

    end
end

CreateThread(Interactions)

