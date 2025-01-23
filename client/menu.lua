-- P R O M Ě N N É
menuID = "char_creation_menu"
local vizualMenuID = "char_creation_vizual_menu"
local bodyMenuID = "body"
local bodyModifyMenuID = "bodyModify"

SkinColorTracker = 1
HeadIndexTracker = 9
BodyTypeTracker = 1
LegsTypeTracker = 1
WaistTracker = 1
BodyTracker = 1

Playerdata = {}

-- Vytvoření hlavního menu s defaultní aplikací
function CreateMenu()
    Playerdata.gender = GetGender()
    Playerdata.skin = json.encode(PlayerSkin)

    -- *** Nastav default indexy a použij je ***
    SkinColorTracker = 1
    HeadIndexTracker = 1
    BodyTypeTracker = 1
    LegsTypeTracker = 1
    WaistTracker = 1
    BodyTracker = 1

    local gender = Playerdata.gender
    local SkinColor = Config.DefaultChar[gender][SkinColorTracker]

    local legs = tonumber("0x" .. SkinColor.Legs[LegsTypeTracker])
    local bodyType = tonumber("0x" .. SkinColor.Body[BodyTypeTracker])
    local heads = tonumber("0x" .. SkinColor.Heads[HeadIndexTracker])
    local headtexture = joaat(SkinColor.HeadTexture[1])
    local albedo = Config.texture_types[gender].albedo

    IsPedReadyToRender()
    ApplyShopItemToPed(heads)
    ApplyShopItemToPed(bodyType)
    ApplyShopItemToPed(legs)
    -- Aplikace textury
    Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)

    UpdatePedVariation()
    getNaked()

    jo.menu.delete(menuID)

    local menu = jo.menu.create(menuID, {
        title = "Tvorba postavy",
        onEnter = function()
            -- např. cam = CreateCamera(Config.NPC.camera.coords, Config.NPC.placeCoords)
        end,
        onBack = function()
            jo.menu.setCurrentMenu(menuID)
            jo.menu.show(true)
        end,
        onExit = function()
            -- sem kdyžtak logiku, co se má dít, když opouštíš celé menu
        end
    })

    menu:addItem({
        title = "Tvoje postava",
        onClick = function()
            jo.menu.show(false)

            local input = lib.inputDialog('Tvoje postava:', {
                {
                    type = 'input',
                    label = 'Tvoje jméno a příjmení',
                    description = 'Sem napiš tvoje jméno a příjmení',
                    required = true,
                    min = 2,
                    max = 16
                }, {
                    type = 'number',
                    label = 'Tvůj věk',
                    description = 'Kolik ti je let',
                    required = true,
                    icon = 'hashtag'
                }, {
                    type = 'input',
                    label = 'Popis Postavy',
                    description = 'Sem napiš popis tvojí postavy',
                    required = false,
                    min = 2,
                    max = 256
                }
            })

            debugPrint(json.encode(input))
            if input == nil then
                jo.menu.show(true)
            else
                Playerdata.firstname, Playerdata.lastname = GetName(input[1])
                Playerdata.age = tonumber(input[2])
                Playerdata.desc = input[3]
                Playerdata.nickname = input[1]

                notify("Vše vypadá v pořádku: " .. Playerdata.firstname .. " " .. Playerdata.lastname)
                jo.menu.show(true)
            end
        end
    })

    menu:addItem({
        title = "Vzhled",
        child = vizualMenuID
    })

    menu:addItem({
        title = "Dovednosti",
        child = "skillMenu"
    })

    menu:addItem({
        title = "Uložit postavu",
        onClick = function()
            if Playerdata.firstname == nil or Playerdata.lastname == nil or Playerdata.age == nil then
                notify("Musíš vyplnit všechny údaje!")
            else
                exports.weathersync:setSyncEnabled(true)
                Playerdata.skin = json.encode(PlayerSkin)
                Playerdata.charDescription = Playerdata.desc or "none"
                local NewTable = GetNewCompOldStructure(PlayerClothing)
                Playerdata.comps = json.encode(NewTable)

                jo.menu.show(false)
                RenderScriptCams(false, true, 3000, true, true, 0)
                FreezeEntityPosition(PlayerPedId(), false)

                TriggerServerEvent("vorpcharacter:saveCharacter", Playerdata)
                Wait(5000)
                TriggerServerEvent("aprts_charCreator:Server:saveSkills", skillValues)
                Camera = nil
            end
        end
    })

    menu:send()

    createSkillMenu()
    CreateVizualMenu()    -- Vizuální (pod)menu
    CreateSkinColorMenu() -- Menu pro barvu kůže + generování "body" submenu
    CreateFaceMenu()
end

-- Vizuální menu (hlavní podmenu pro vzhled)
function CreateVizualMenu()
    local menu = jo.menu.create(vizualMenuID, {
        title = "Tvorba postavy",
        onEnter = function()
            -- např. cam = CreateCamera(...)
        end,
        onBack = function()
            -- navrátit se zpátky
        end,
        onExit = function()
        end
    })

    menu:addItem({
        title = "Tělo",
        child = bodyMenuID
    })

    menu:addItem({
        title = "Obličej",
        child = "face"
    })

    menu:addItem({
        title = "Zpět",
        child = menuID
    })

    menu:send()
end

-- Tohle menu (bodyMenuID) se stará o inicializaci barvy kůže a tlačítka pro "Úprava Těla"
function CreateSkinColorMenu()
    local gender = GetGender()
    debugPrint("gender is: " .. gender)

    -- Aplikuje se default barva (1) a overlay hair/eyebrow
    setSkinColor(1, gender)
    ApplyOverlay("hair", Config.Overlays.hair)
    ApplyOverlay("eyebrow", Config.Overlays.eyebrow)

    local function generateSwitches(targetTable)
        local switches = {}
        for i, v in ipairs(targetTable) do
            table.insert(switches, {
                label = Config.DefaultChar[gender][SkinColorTracker].label .. "/" .. v,
                data = i
            })
        end
        return switches
    end

    local bodySwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Body)
    local headSwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Heads)
    local legsSwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Legs)
    local waistSwitches = generateSwitches(Config.BodyType.Waist)
    local bodyVariantSwitches = generateSwitches(Config.BodyType.Body)

    local bodyTypeSwitches = {}
    for i = 1, #Config.DefaultChar[gender] do
        table.insert(bodyTypeSwitches, {
            label = Config.DefaultChar[gender][i].label,
            data = i
        })
    end

    local bodyMenu = jo.menu.create(bodyMenuID, {
        title = "Tvorba postavy",
        onEnter = function()
        end,
        onBack = function()
        end,
        onExit = function()
        end
    })

    bodyMenu:addItem({
        title = "Barva kůže",
        sliders = {{
            type = "switch",
            current = 1,
            values = bodyTypeSwitches
        }},
        onChange = function(currentData)
            -- Při změně rasy resetnu indexy
            LegsTypeTracker = 1
            BodyTracker = 1
            HeadIndexTracker = 1
            WaistTracker = 1

            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index rasy: " .. index)
            setSkinColor(index, gender)

            bodySwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Body)
            headSwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Heads)
            legsSwitches = generateSwitches(Config.DefaultChar[gender][SkinColorTracker].Legs)
            waistSwitches = generateSwitches(Config.BodyType.Waist)
            bodyVariantSwitches = generateSwitches(Config.BodyType.Body)

            createBodyMenu(headSwitches, bodySwitches, legsSwitches, waistSwitches, bodyVariantSwitches, gender)
        end
    })

    bodyMenu:addItem({
        title = "Úprava Těla",
        child = bodyModifyMenuID
    })

    bodyMenu:send()

    -- Vytvoření podmenu "Úprava těla"
    createBodyMenu(headSwitches, bodySwitches, legsSwitches, waistSwitches, bodyVariantSwitches, gender)
end

function createBodyMenu(headSwitches, bodySwitches, legsSwitches, waistSwitches, bodyVariantSwitches, gender)
    local menu = jo.menu.create(bodyModifyMenuID, {
        title = "Úprava těla",
        onEnter = function()
            playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
        end,
        onBack = function()
        end,
        onExit = function()
        end
    })

    menu:addItem({
        title = "Typ hlavy",
        sliders = {{
            type = "switch",
            current = 1,
            values = headSwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index hlavy: " .. index)
            setHead(index, gender)
        end
    })

    menu:addItem({
        title = "Podrost",
        sliders = {{
            type = "grid",
            labels = {'Vůbec', 'Naplno'},
            values = {{
                current = 0.0,
                max = 1.0,
                min = 0.0
            }}
        },{
            type = "palette",
            title = "tint",
            tint = "tint_hair",
            max = 135,
            current = 135
        }},
        onChange = function(currentData)
            local category = "hair"
            local value = currentData.item.sliders[1].value[1]
            local overlay = Config.Overlays[category]
            overlay.opacity = value
            overlay.id = 0
            overlay.tint0 = currentData.item.sliders[2].current
            debugPrint("intenzita: " .. value)
            ApplyOverlay(category, overlay)
        end
    })

    local eyebrowIds = jo.pedTexture.variations["eyebrow"] or {}
    local eyebrowSwitches = {}
    local ggg = IsPedMale(PlayerPedId()) and "m" or "f"

    for i, v in pairs(eyebrowIds) do
        if v.value and v.value.id then
            if v.value.sexe == ggg then
                table.insert(eyebrowSwitches, {
                    label = v.label,
                    data = v.value.id
                })
            end
        end
    end
    print(json.encode(eyebrowSwitches))

    menu:addItem({
        title = "Obočí",
        sliders = {{
            type = "switch",
            current = (eyebrowSwitches[1] and eyebrowSwitches[1].data) or 1,
            values = eyebrowSwitches
        },{
            type = "grid",
            labels = {'Vůbec', 'Naplno'},
            values = {{
                current = 0.0,
                max = 1.0,
                min = 0.0
            }}
        },{
            type = "palette",
            title = "tint",
            tint = "tint_hair",
            max = 135,
            current = 135
        }},
        onChange = function(currentData)
            local category = "eyebrow"
            local value = currentData.item.sliders[2].value[1]
            local overlay = Config.Overlays[category]
            overlay.opacity = value
            overlay.id = tonumber(currentData.item.sliders[1].current)
            overlay.tint0 = currentData.item.sliders[3].current
            debugPrint("intenzita: " .. value)
            ApplyOverlay(category, overlay)
        end
    })

    menu:addItem({
        title = "Textura Těla",
        sliders = {{
            type = "switch",
            current = 1,
            values = bodySwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index těla: " .. index)
            setBody(index, gender)
        end
    })

    menu:addItem({
        title = "Tělo",
        sliders = {{
            type = "switch",
            current = 1,
            values = bodyVariantSwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index varianty těla: " .. index)
            setBodyVariant(index)
        end
    })

    menu:addItem({
        title = "Pas",
        sliders = {{
            type = "switch",
            current = 1,
            values = waistSwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index pasu: " .. index)
            setWaist(index)
        end
    })

    menu:addItem({
        title = "Textura nohou",
        sliders = {{
            type = "switch",
            current = 1,
            values = legsSwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index nohou: " .. index)
            setLegs(index, gender)
        end
    })

    menu:addItem({
        title = "Velikost",
        sliders = {{
            type = "grid",
            labels = {'Vůbec', 'Naplno'},
            values = {{
                current = 1.0,
                max = 1.2,
                min = 0.8
            }}
        }},
        onChange = function(currentData)
            local value = currentData.item.sliders[1].value[1]
            debugPrint("Velikost: " .. value)
            setScale(value)
        end
    })

    menu:send()
end

function CreateFaceMenu()
    local gender = GetGender()
    local faceMenu = jo.menu.create("face", {
        title = "Úprava obličeje",
        onEnter = function()
            playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
        end,
        onBack = function()
            playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
        end,
        onExit = function()
        end
    })

    local function generateSwitches(targetTable, labelsTable)
        local switches = {}
        for i, v in ipairs(targetTable) do
            table.insert(switches, {
                label = labelsTable[i] or "N/A",
                data = i
            })
        end
        return switches
    end

    local eyesSwitches = generateSwitches(Config.Eyes[gender], Config.EyeImgColor)

    faceMenu:addItem({
        title = "Barva očí",
        sliders = {{
            type = "switch",
            current = 1,
            values = eyesSwitches
        }},
        onChange = function(currentData)
            local index = math.floor(tonumber(currentData.item.sliders[1].current))
            debugPrint("Index barvy očí: " .. index)
            setEyeColor(index, gender)
        end
    })

    -- Vytvoření submenu pro jednotlivé face features (nos, tváře, atd.)
    for featureType, category in pairs(Config.FaceFeatures) do
        faceMenu:addItem({
            title = "Úprava " .. (Config.FaceFeaturesLabels[featureType] or featureType),
            child = featureType
        })

        local subMenu = jo.menu.create(featureType, {
            title = "Úprava " .. (Config.FaceFeaturesLabels[featureType] or featureType),
            onEnter = function()
                playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
            end,
            onBack = function()
                playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
            end,
            onExit = function()
            end
        })

        for cat, param in pairs(category) do
            subMenu:addItem({
                title = cat,
                sliders = {{
                    type = "grid",
                    labels = {'Vůbec', 'Naplno'},
                    values = {{
                        current = 0.0,
                        max = 1.0,
                        min = -1.0
                    }}
                }},
                onChange = function(currentData)
                    local value = currentData.item.sliders[1].value[1]
                    debugPrint("Hodnota: " .. value)
                    setFaceFeatures(param.comp, param.hash, value)
                end
            })
        end
        subMenu:send()
    end

    faceMenu:addItem({
        title = "Zpět",
        child = vizualMenuID
    })

    faceMenu:send()
end