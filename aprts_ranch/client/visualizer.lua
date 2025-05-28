local function getFPS()
    return 1.0 / GetFrameTime()
end

function fpsTimer()
    local minFPS, maxFPS = 15, 165
    local minPause, maxPause = 0, 15
    local fps = getFPS()
    local coefficient = 1 - (fps - minFPS) / (maxFPS - minFPS)
    -- return minPause + coefficient * (maxPause - minPause)
    return 0
end

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
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (2 / dist) * 1.1

    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    local fov = (2 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.18 * scale, 0.18 * scale)
        SetTextFontForCurrentCommand(1)
        SetTextColor(180, 180, 240, 205)
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 355
    end
end
-- Funkce pro vykreslení textu, čáry a dalších prvků na základě vstupní tabulky `data`
function displayData3D(x, y, z, data, showImage, imagePath)
    -- Získání koordinátů na obrazovce a vzdálenosti od kamery
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    -- Pevná škála, která bere v potaz vzdálenost a fov kamery
    local scale = (1 / dist) * 2.0
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        -- Upravíme základní posun na ose Y, aby se prvky pohybovaly správně vzhledem k pozici
        local baseYOffset = -0.03 -- Posun, aby první řádek začal o trochu výše

        -- Projdi jednotlivé položky v `data` tabulce
        for i, row in pairs(data) do
            local yOffset = baseYOffset + (0.03 * (i - 1)) * scale -- Dynamický posun na základě škálování

            -- Zpracuj a vykresli text pro aktuální řádek
            if row.text then
                SetTextScale(0.35 * scale, 0.35 * scale) -- Zvětšíme text dle vzdálenosti
                SetTextFontForCurrentCommand(1)
                local r, g, b = hexToRGB(row.color) -- Konverze hex na RGB
                SetTextColor(r, g, b, 255)
                SetTextCentre(1)
                DisplayText(CreateVarString(10, "LITERAL_STRING", row.text, Citizen.ResultAsLong()), _x, _y + yOffset)
            end

            -- Pokud je definovaná čára (line = true), vykresli ji s procentuální hodnotou (value)
            if row.line and row.value then
                local lineLength = 0.06 * scale -- Délka čáry (přizpůsobená dle měřítka)
                local lineStartX = _x - (lineLength / 2) -- Začátek čáry
                local lineEndX = lineStartX + (lineLength * (row.value / 100)) -- Konec čáry dle procent

                local lineColorR, lineColorG, lineColorB = hexToRGB(row.lineColor or "#ffffff") -- Barva čáry
                local lineWidth = row.lineWidth or 0.005 -- Tloušťka čáry

                -- Vykreslení čáry blíže pod text
                DrawRect(lineStartX + ((lineEndX - lineStartX) / 2), _y + yOffset + (0.015 * scale),
                    (lineEndX - lineStartX), lineWidth * scale, lineColorR, lineColorG, lineColorB, 255)
            end
        end

        -- Vykreslení PNG obrázku, pokud je zapnuto
        if showImage and imagePath then
            DrawSprite(imagePath, "default", _x + 0.05 * scale, _y + 0.02 * scale, 0.05 * scale, 0.05 * scale, 0.0, 255,
                255, 255, 255)
        end
    end
end

-- Funkce pro konverzi hex kódu na RGB (např. "#fc0a03" => 252, 10, 3)
function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local tool = exports["aprts_tools"]:GetEquipedTool()
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        if tool == Config.ShovelItem and not runningAnimation then
            for _, poop in pairs(poops) do
                local poopPos = poop.coords
                local distance = GetDistanceBetweenCoords(playerPos, poopPos.x, poopPos.y, poopPos.z, false)
                if distance <= 1.0 then
                    displayData3D(poopPos.x, poopPos.y, poopPos.z + 0.1, {{
                        text = "[" .. Config.KeyLabel .. "]" .. " Sebrat",
                        color = "#fc0a03"
                    }}, false)
                    pause = fpsTimer()
                    if IsControlJustPressed(0, Config.Key) then
                        TriggerServerEvent("aprts_ranch:Server:pickupPoop", poop.id)
                        -- exports["aprts_tools"]:UnequipTool()
                    end
                    break
                elseif distance <= 10.0 then
                    local RealPoopPos = GetEntityCoords(poop.obj)
                    DrawMarker(-1795314153, RealPoopPos.x, RealPoopPos.y, RealPoopPos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5,
                        0.5, 138, 78, 0, 255, 0, 0, 0, 0)
                    pause = fpsTimer()
                end

            end
        elseif tool == Config.productPickupTool and not runningAnimation then
            -- debugPrint(json.encode(closestRailing))
            if closestRailing then
                for v, product in pairs(closestRailing.products) do
                    if product.amount == 0 then
                        break
                    end
                    -- debugPrint("produkt = " .. json.encode(product))
                    local productPos = product.coords
                    local distance = GetDistanceBetweenCoords(playerPos, productPos.x, productPos.y, productPos.z, true)
                    if distance <= 1.5 then
                        local data = {{
                            text = product.amount .. "x " .. product.name,
                            color = "#fc0a03"
                        }, {
                            text = "[" .. Config.KeyLabel .. "]" .. " Sebrat",
                            color = "#fc0a03"
                        }}
                        displayData3D(productPos.x, productPos.y, productPos.z + 0.1, data, false)
                        pause = fpsTimer()
                        if IsControlJustPressed(0, Config.Key) then
                            TriggerServerEvent("aprts_ranch:Server:pickupProduct", closestRailing.id, product.name)
                            -- exports["aprts_tools"]:UnequipTool()
                        end
                        
                    end
                    local RealProductPos = GetEntityCoords(product.obj)
                    DrawMarker(-1795314153, RealProductPos.x, RealProductPos.y, RealProductPos.z, 0, 0, 0, 0, 0, 0, 0.5,
                        0.5, 0.5, 138, 78, 125, 255, 0, 0, 0, 0)
                    pause = fpsTimer()
                end

            end
        end
        Citizen.Wait(pause)
    end
end)

local function prepareData(animal)
    local tool = exports["aprts_tools"]:GetEquipedTool()
    local animalConfig = Config.Animals[animal.breed]

    local data = {}
    -- do data naplní všechny potřebné informace o zvířeti které jsme získali ze serveru
    -- např. zdraví, hlad, žízeň, štěstí, atd.
    -- zdraví 

    if runningAnimation ~= nil then
        if animal.name then
            data[1] = {
                text = "Jméno: " .. animal.name,
                color = "#ffffff"
            }
        end

    else
        if tool == Config.BrushItem then
            if animal.name then
                data[1] = {
                    text = "Jméno: " .. animal.name,
                    color = "#ffffff"
                }
            end
            -- čistota
            data[2] = {
                text = "Čistota: " .. animal.clean .. "%",
                color = "#ffffff"
            }
            data[3] = {
                text = "Stiskni [" .. Config.KeyLabel .. "] pro vyčištění",
                color = "#ffddff"
            }
        else
            if medicine ~= nil then
                if animal.name then
                    data[1] = {
                        text = "Jméno: " .. animal.name,
                        color = "#ffffff"
                    }
                end
                data[2] = {
                    text = "Zdraví: " .. animal.health .. "%",
                    color = "#fc0a03"
                }
                data[3] = {
                    text = "Pohlaví: " .. animal.gender,
                    color = "#00aaff"
                }
                data[4] = {
                    text = "Věk: " .. animal.age .. " let",
                    color = "#ffffff"
                }
                if LocalPlayer.state.Character.Job == Config.DoctorJob then
                    data[5] = {
                        text = "Nemoc: " .. animal.sick .. "%",
                        color = "#ffffff"
                    }
                else
                    if animal.sick > 1 then
                        data[5] = {
                            text = "Nemocné",
                            color = "#fc0a03"
                        }
                    end
                end
                -- březost
                if animal.gender == "female" then
                    if animal.pregnant == 0 then
                        data[6] = {
                            text = "Není březí",
                            color = "#ffffff"
                        }
                    else
                        data[6] = {
                            text = "Březí",
                            color = "#ffffff"
                        }
                    end
                end
                data[7] = {
                    text = "Stiskni [" .. Config.KeyLabel .. "] pro léčbu",
                    color = "#ffddff"
                }
            elseif tool == nil then
                if animal.name then
                    data[1] = {
                        text = "Jméno: " .. animal.name,
                        color = "#ffffff"
                    }
                end
                data[2] = {
                    text = "Zdraví: " .. animal.health .. "%",
                    color = "#fc0a03"
                }
                -- pohlaví
                data[3] = {
                    text = "Pohlaví: " .. animal.gender,
                    color = "#00aaff"
                }
                data[4] = {
                    text = "Věk: " .. animal.age .. " let",
                    color = "#ffffff"
                }
                -- hlad
                data[5] = {
                    text = "Hlad: " .. animal.food .. "/" .. animalConfig.foodMax .. "/Žízeň: " .. animal.water ..
                        "/" .. animalConfig.waterMax,
                    color = "#00aaff"
                }

                -- štěstí
                data[6] = {
                    text = "Štěstí: " .. animal.happynes .. "%" .. "/Energie: " .. animal.energy .. "%",
                    color = "#ffffff"
                }

                -- čistota
                data[7] = {
                    text = "Čistota: " .. animal.clean .. "%" .. "/Kvalita: " .. animal.xp,
                    color = "#ffffff"
                }

                -- nemoc
                if animal.sick > 1 then
                    data[8] = {
                        text = "Nemocné",
                        color = "#fc0a03"
                    }
                end

                -- březost
                if animal.gender == "female" then
                    if animal.pregnant == 0 then
                        data[9] = {
                            text = "Není březí",
                            color = "#ffffff"
                        }
                    else
                        data[9] = {
                            text = "Březí",
                            color = "#ffffff"
                        }
                    end
                end
                data[10] = {
                    text = Config.FeedKeyLabel .. " = nakrmit, " .. Config.WaterKeyLabel .. " = napojit",
                    color = "#ffddff"
                }
            elseif tool == Config.leashItem and table.count(walkingAnimals) < Config.maxWalkedAnimals then
                if animal.name then
                    data[1] = {
                        text = "Jméno: " .. animal.name,
                        color = "#ffffff"
                    }
                end
                data[2] = {
                    text = "Zdraví: " .. animal.health .. "%",
                    color = "#fc0a03"
                }
                data[3] = {
                    text = "Energie: " .. animal.energy .. "%",
                    color = "#ffffff"
                }
                data[4] = {
                    text = "Hlad: " .. animal.food .. "/" .. animalConfig.foodMax .. " Žízeň: " .. animal.water ..
                        "/" .. animalConfig.waterMax,
                    color = "#00aaff"
                }
                data[5] = {
                    text = "Stiskni [" .. Config.KeyLabel .. "] Venčit",
                    color = "#ffddff"
                }
            else
                for k, product in pairs(animalConfig.product) do
                    if product.gather == 2 then

                        if tool == product.tool and (animal.gender == product.gender or product.gender == nil) then
                            if animal.name then
                                data[1] = {
                                    text = "Jméno: " .. animal.name,
                                    color = "#ffffff"
                                }
                            end
                            data[2] = {
                                text = "Zdraví: " .. animal.health .. "%",
                                color = "#fc0a03"
                            }
                            data[3] = {
                                text = "Produkt: " .. animal.count .. "ks",
                                color = "#ffffff"
                            }
                            data[4] = {
                                text = "Stiskni [" .. Config.KeyLabel .. "] pro sběr " .. product.name,
                                color = "#ffddff"
                            }
                            break
                        end

                    end
                end
            end
        end
    end
    return data

end

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local tool = exports["aprts_tools"]:GetEquipedTool()
        if land then
            if land.access >= 1 then
                for _, animal in pairs(animals) do
                    if DoesEntityExist(animal.obj) and animal.health > 0 then
                        -- debugPrint(json.encode(animal))
                        local animalPos = GetEntityCoords(animal.obj)
                        local distance = GetDistanceBetweenCoords(playerPos, animalPos.x, animalPos.y, animalPos.z, 1)
                        local animalConfig = Config.Animals[animal.breed]
                        if distance <= 1.5 then
                            -- DisableControlAction(0, 0xEB2AC491, true) -- Zakáže klávesu R pro sebrání mrtvoly zvířete ze země
                            -- DisableControlAction(0, 0x41AC83D1, true) -- Zakáže klávesu E pro rozebrání mrtvoly
                            displayData3D(animalPos.x, animalPos.y, animalPos.z + 1.0, prepareData(animal), false)
                            FreezeEntityPosition(animal.obj, true)
                            closestAnimal = animal
                            pause = fpsTimer()
                            if runningAnimation == nil then
                                if tool == Config.BrushItem then
                                    if IsControlJustPressed(0, Config.Key) then
                                        TriggerServerEvent("aprts_ranch:Server:cleanAnimal", animal.id)
                                        Wait(Config.Animation.clean.time)
                                        -- exports["aprts_tools"]:UnequipTool()

                                    end
                                elseif medicine ~= nil then
                                    if IsControlJustPressed(0, Config.Key) then
                                        TriggerServerEvent("aprts_ranch:Server:healAnimal", animal.id, medicine)
                                        Wait(Config.Animation.cure.time)
                                        exports["aprts_tools"]:UnequipTool()
                                        medicine = nil

                                    end
                                elseif tool == nil then
                                    if IsControlJustPressed(0, Config.FeedKey) then
                                        TriggerServerEvent("aprts_ranch:Server:feedAnimal", animal.id)
                                        Wait(Config.Animation.feed.time)
                                    end
                                    if IsControlJustPressed(0, Config.WaterKey) then
                                        TriggerServerEvent("aprts_ranch:Server:waterAnimal", animal.id, 50.0)
                                        Wait(Config.Animation.water.time)
                                    end
                                elseif tool == Config.leashItem and table.count(walkingAnimals) <
                                    Config.maxWalkedAnimals then
                                    if IsControlJustPressed(0, Config.Key) then
                                        lastRailingID = animal.railing_id
                                        TriggerServerEvent("aprts_ranch:Server:takeAnimal", animal.id)
                                    end
                                else -- sběr produktů
                                    for k, product in pairs(animalConfig.product) do
                                        if product.gather == 2 then
                                            if tool == product.tool and
                                                (animal.gender == product.gender or product.gender == nil) then
                                                if IsControlJustPressed(0, Config.Key) then
                                                    TriggerServerEvent("aprts_ranch:Server:gatherAnimalProduct",
                                                        animal.id, product)
                                                    Wait(product.anim.time)
                                                    -- exports["aprts_tools"]:UnequipTool()
                                                end
                                                break
                                            end

                                        end
                                    end
                                end
                                break
                            end
                        else
                            closestAnimal = nil
                        end

                        if IsEntityFrozen(animal.obj) then
                            FreezeEntityPosition(animal.obj, false)
                        end
                    else
                        -- if DoesEntityExist(animal.obj) then
                        --     debugPrint("Deleting animal " .. tostring(animal.obj))
                        --     DeleteEntity(animal.obj)
                        -- end
                    end
                end
            end
        end
        Citizen.Wait(pause)
    end
end)
-- exports("GetEquipedTool", GetEquipedTool)

Citizen.CreateThread(function()
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
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local pJob = LocalPlayer.state.Character.Job
        local tool = exports["aprts_tools"]:GetEquipedTool()
        while not land do
            Citizen.Wait(1000)
        end
        if land then
            if land.access >= 1 then
                if tool == Config.CleaverItem then
                    for _, animal in pairs(animals) do
                        if DoesEntityExist(animal.obj) and animal.health == 0 then

                            local animalPos = GetEntityCoords(animal.obj)
                            local distance = GetDistanceBetweenCoords(playerPos, animalPos.x, animalPos.y, animalPos.z,
                                1)
                            if distance <= 1.5 then
                                --  debugPrint(json.encode(animal))
                                displayData3D(animalPos.x, animalPos.y, animalPos.z + 1.0, {{
                                    text = "Zdechlina",
                                    color = "#fc0a03"
                                }, {
                                    text = "Stiskni [" .. Config.KeyLabel .. "] pro naporcování",
                                    color = "#fc0a03"
                                }}, false, "w")
                                pause = 0
                                if IsControlJustPressed(0, Config.Key) then

                                    TriggerServerEvent("aprts_ranch:Server:slaughterAnimal", animal.id)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
        if tool == Config.medicineItemTool and pJob == Config.DoctorJob then
            for _, animal in pairs(animals) do
                if DoesEntityExist(animal.obj) and IsEntityDead(animal.obj) then
                    local animalPos = GetEntityCoords(animal.obj)
                    local distance = GetDistanceBetweenCoords(playerPos, animalPos.x, animalPos.y, animalPos.z, 1)
                    if distance <= 1.5 then
                        displayData3D(animalPos.x, animalPos.y, animalPos.z + 1.0, {{
                            text = "Zraněné zvíře " .. animal.id,
                            color = "#fc0a03"
                        }, {
                            text = "Stiskni [" .. Config.KeyLabel .. "] pro pokus o oživení",
                            color = "#fc0a03"
                        }}, false, "w")
                        pause = 0
                        if IsControlJustPressed(0, Config.Key) then

                            TriggerServerEvent("aprts_ranch:Server:reviveAnimal", animal.id)
                        end
                    end

                end
            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        local pause = 1000
        for _, railing in pairs(railings) do
            local railingPos = vector3(railing.coords.x, railing.coords.y, railing.coords.z)
            local distance = GetDistanceBetweenCoords(playerPos, railingPos.x, railingPos.y, railingPos.z, 1)
            if distance <= railing.size then
                DisableControlAction(0, 0xCEFD9220, true) -- Zakáže klávesu E pro nasednutí
                DisableControlAction(0, 0xEB2AC491, true) -- Zakáže klávesu R pro zvednutí mrtvoly
                DisableControlAction(0, 0x41AC83D1, true) -- Zakáže klávesu E pro stažení z kůže
                pause = fpsTimer()
            end
        end
        Citizen.Wait(pause)
    end
end)
Citizen.CreateThread(function()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local tool = exports["aprts_tools"]:GetEquipedTool()
        -- print (tool)
        if land then
            if land.access >= 1 then
                for _, railing in pairs(railings) do
                    local railingPos = vector3(railing.coords.x, railing.coords.y, railing.coords.z)
                    local distance = GetDistanceBetweenCoords(playerPos, railingPos.x, railingPos.y, railingPos.z, 1)
                    local configFeeding = Config.feeding[railing.prop]
                    if distance <= railing.size then
                        -- DisableControlAction(0, 0xCEFD9220, true) -- Zakáže klávesu E pro nasednutí
                        -- DisableControlAction(0, 0xEB2AC491, true) -- Zakáže klávesu R pro zvednutí mrtvoly
                        -- DisableControlAction(0, 0x41AC83D1, true) -- Zakáže klávesu E pro stažení z kůže
                        local data = {}
                        data[1] = {
                            text = "[" .. railing.id .. "]" .. " - Zvířat: " .. getCountAnimlsonRailing(railing) ..
                                "/" .. railing.size,
                            color = "#00aaff"
                        }
                        data[2] = {
                            text = "Jídla: " .. railing.food .. "/" .. configFeeding.food,
                            color = "#00aaff"
                        }
                        data[3] = {
                            text = "Vody: " .. railing.water .. "/" .. configFeeding.water,
                            color = "#ffffff"
                        }
                        if distance <= 1.0 then

                            if tool == Config.fullWaterItem then
                                data[4] = {
                                    text = "Stiskni [" .. Config.KeyLabel .. "] doplnění vody",
                                    color = "#00aaff"
                                }
                                if IsControlJustPressed(0, Config.Key) then
                                    exports["aprts_tools"]:UnequipTool()
                                    TriggerServerEvent("aprts_ranch:Server:addWater", railing.id, 100)
                                end
                            elseif tool == Config.fullFoodItem then
                                data[4] = {
                                    text = "Stiskni [" .. Config.KeyLabel .. "] doplnění jídla",
                                    color = "#00aaff"
                                }
                                if IsControlJustPressed(0, Config.Key) then
                                    exports["aprts_tools"]:UnequipTool()
                                    TriggerServerEvent("aprts_ranch:Server:addFood", railing.id, 100)
                                end
                            elseif tool == nil and table.count(herdAnimals) < 1 and land.access > 0 and
                                table.count(walkingAnimals) > 0 then

                                data[4] = {
                                    text = "[" .. Config.KeyLabel2 .. "] Uvázat Zvířata",
                                    color = "#20aaff"
                                }
                                if IsControlJustPressed(0, Config.Key2) then
                                    for _, animal in pairs(walkingAnimals) do
                                        if DoesEntityExist(animal.obj) then
                                            local animalPos = GetEntityCoords(animal.obj)
                                            local distance =
                                                GetDistanceBetweenCoords(playerPos, animalPos.x, animalPos.y,
                                                    animalPos.z, true)
                                            if distance <= 30 then
                                                -- TaskGoToEntity(animal.obj, railing.obj, -1, 0.0, 0.0, 0.0, 0)
                                                TriggerServerEvent("aprts_ranch:Server:putAnimal", railing.id, animal)
                                                lastRailingID = railing.id
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        pause = fpsTimer()
                        displayData3D(railingPos.x, railingPos.y, railingPos.z + 1.0, data, false, "exampleImage")
                        closestRailing = railing
                        break
                    else
                        closestRailing = nil
                    end
                end

            end
        end
        Citizen.Wait(pause)
    end
end)

Citizen.CreateThread(function()
    while true do
        local pause = 1000

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local count = table.count(walkingAnimals)
        if count > 0 then
            DrawTxt("Venčím : " .. count .. "/" .. Config.maxWalkedAnimals, 0.5, 0.01, 0.5, 0.5, true, 255, 255, 255,
                255, true)
            pause = fpsTimer()
        end
        Citizen.Wait(pause)
    end
end)

