InCharacterCreator = false
isMale = false
Camera = nil
function ShowBusyspinnerWithText(text)
    N_0x7f78cd75cc4539e4(VarString(10, "LITERAL_STRING", text))
end

function ApplyShopItemToPed(comp, ped)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, false, false)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, true, false)
end

function UpdateShopItemWearableState(comp, wearable)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, PlayerPedId(), comp, wearable, 0, 1, 1)
end

function IsMetaPedUsingComponent(comp)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, PlayerPedId(), comp)
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped or PlayerPedId(), false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped or PlayerPedId(), true)
end

function PrepareCreatorMusic()
    Citizen.InvokeNative(0x120C48C614909FA4, "AZL_RDRO_Character_Creation_Area", true) -- CLEAR_AMBIENT_ZONE_LIST_STATE
    Citizen.InvokeNative(0x9D5A25BADB742ACD, "AZL_RDRO_Character_Creation_Area_Other_Zones_Disable", true) -- CLEAR_AMBIENT_ZONE_LIST_STATE
    PrepareMusicEvent("MP_CHARACTER_CREATION_START")
    Wait(100)
    TriggerMusicEvent("MP_CHARACTER_CREATION_START")
end

function RemoveTagFromMetaPed(hash, ped)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
end

function LoadPlayer(sex)
    if not HasModelLoaded(sex) then
        RequestModel(sex, false)
        repeat
            Wait(0)
        until HasModelLoaded(sex)
    end
end

function IsPedReadyToRender(ped)
    repeat
        Wait(0)
    until Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped or PlayerPedId())
end

function SetCharExpression(ped, value, expression)
    Citizen.InvokeNative(0x5653AB26C82938CF, ped, value, expression)
end

function GetNewCompOldStructure(comps)
    local NewComps = {}
    for key, value in pairs(comps) do
        NewComps[key] = value.comp
    end
    return NewComps
end

function RegisterBodyIndexs(skin)
    for gender, value in pairs(Config.DefaultChar) do
        if GetGender() == gender then
            for skinColor, v in ipairs(value) do
                for bodyIndex, a in ipairs(v.Body) do
                    if skin.BodyType == tonumber("0x" .. a) then
                        BodyTypeTracker = bodyIndex
                        SkinColorTracker = skinColor

                        break
                    end
                end

                for legIndex, j in ipairs(v.Legs) do
                    if skin.Legs == tonumber("0x" .. j) then
                        LegsTypeTracker = legIndex
                        break
                    end
                end

                for index, d in ipairs(v.Heads) do
                    if skin.HeadType == tonumber("0x" .. d) then
                        HeadIndexTracker = index
                        break
                    end
                end
            end
        end
    end

    for key, value in pairs(Config.BodyType.Body) do
        if skin.Body == value then
            BodyTracker = key
            break
        end
    end

    for key, value in pairs(Config.BodyType.Waist) do
        if skin.Waist == value then
            WaistTracker = key
            break
        end
    end

    if WaistTracker == 0 then
        WaistTracker = 1
    end

    if BodyTracker == 0 then
        BodyTracker = 1
    end

    if BodyTypeTracker == 0 then
        BodyTypeTracker = 1
    end

    if SkinColorTracker == 0 then
        SkinColorTracker = 1
    end
end

function StartAnimation(anim)
    local __player = PlayerPedId()
    if not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") then
        RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")
        repeat
            Wait(0)
        until HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE")
    end

    if not IsEntityPlayingAnim(__player, "FACE_HUMAN@GEN_MALE@BASE", anim, 1) then
        TaskPlayAnim(__player, "FACE_HUMAN@GEN_MALE@BASE", anim, 8.0, -8.0, -1, 16, 0.0, false, 0, false, "", false)
    end
end

function GetGender()
    local Gender = IsPedMale(PlayerPedId()) and "Male" or "Female"
    return Gender
end

function DefaultPedSetup(ped, male)
    local compEyes = male and 612262189 or 928002221
    local compBody = male and tonumber("0x" .. Config.DefaultChar.Male[math.random(1, 6)].Body[math.random(1, 4)]) or
                         tonumber("0x" .. Config.DefaultChar.Female[math.random(1, 6)].Body[math.random(1, 4)])
    local compHead = male and tonumber("0x" .. Config.DefaultChar.Male[3].Heads[9]) or
                         tonumber("0x" .. Config.DefaultChar.Female[3].Heads[4])
    local compLegs = male and tonumber("0x" .. Config.DefaultChar.Male[3].Legs[1]) or
                         tonumber("0x" .. Config.DefaultChar.Female[3].Legs[1])
    local albedo = male and joaat("mp_head_mr1_sc03_c0_000_ab") or joaat("mp_head_fr1_sc08_c0_000_ab")
    local body = male and 2362013313 or 0x3F1F01E5
    local model = male and "mp_male" or "mp_female"
    local teeth = male and 712446626 or 959712255
    local gunbelt = male and 795591403 or 1511461630
    local hair = male and 2112480140 or 3887861344
    HeadIndexTracker = male and 9 or 4
    SkinColorTracker = male and 3 or 3

    if not male then
        EquipMetaPedOutfitPreset(ped, 7)
    end

    IsPedReadyToRender()
    EquipMetaPedOutfitPreset(ped, 3)
    UpdatePedVariation()

    if male then
        -- work around to fix skin on char creator
        IsPedReadyToRender()
        UpdateShopItemWearableState(-457866027, -425834297)
        UpdatePedVariation()
        IsPedReadyToRender()
        ApplyShopItemToPed(-218859683)
        ApplyShopItemToPed(gunbelt)
        UpdateShopItemWearableState(-218859683, -2081918609)
        UpdatePedVariation()
    end
    PlayerClothing.Gunbelt.comp = gunbelt
    PlayerClothing.Teeth.comp = teeth
    PlayerSkin.HeadType = compHead
    PlayerSkin.BodyType = compBody
    PlayerSkin.LegsType = compLegs
    PlayerSkin.body = body
    PlayerSkin.Eyes = compEyes
    PlayerSkin.sex = model
    PlayerSkin.albedo = albedo
    PlayerSkin.Hair = hair
    PlayerSkin.eyebrows_visibility = 0
    PlayerSkin.eyebrows_tx_id = 0
    PlayerSkin.eyebrows_opacity = 0.0
    PlayerSkin.eyebrows_color = 0x3F6E70FF

end

local function CreateCamera(CamCoords, coords)
    local newCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(newCam, CamCoords.x, CamCoords.y, CamCoords.z)
    SetCamActive(newCam, true)
    PointCamAtCoord(newCam, coords.x, coords.y, coords.z + 1.0)
    -- DoScreenFadeOut(500)
    -- Wait(500)
    -- DoScreenFadeIn(200)
    RenderScriptCams(true, false, 0, 0, 0)
    SetCamFocusDistance(camera, 4.0)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, 'Leaderboard_Show', 'MP_Leaderboard_Sounds', true, 0) -- PlaySoundFrontend
    return newCam
end

function Setup()
    local room = math.random(1, 1000)
    TriggerServerEvent("murphy_clothing:instanceplayers", room)
    NetworkStartSoloTutorialSession()
    -- exports.weathersync:setSyncEnabled(false)
    -- NetworkClockTimeOverride(12, 0, 0, 0, true)
    -- SetTimecycleModifier('Online_Character_Editor')

    RemoveAllPedWeapons(PlayerPedId(), true, true)
    HidePedWeapons(PlayerPedId(), true)

    Camera = CreateCamera(Config.Camera.coords, Config.Camera.lookAt)
    print("Camera: ", Camera)
    FreezeEntityPosition(PlayerPedId(), true)

    -- amb_generic@world_human_generic_standing@lf_fwd@male_a@base

    CreatePlayerModel("mp_male")
    print("PlayerPedId: ", PlayerPedId())
end

function CreatePlayerModel(model)
    local Gender = model == "mp_male" and "male" or "female"
    isMale = model == "mp_male" and true or false
    -- DoScreenFadeOut(0)
    -- repeat
    --     Wait(0)
    -- until IsScreenFadedOut()

    SetEntityCoords(PlayerPedId(), Config.Camera.lookAt.x, Config.Camera.lookAt.y, Config.Camera.lookAt.z, true, true,
        true, false)
    SetEntityHeading(PlayerPedId(), Config.Camera.heading)

    LoadPlayer(model)
    SetPlayerModel(PlayerId(), joaat(model), false)
    SetModelAsNoLongerNeeded(model)
    UpdatePedVariation(PlayerPedId())
    -- RenderScriptCams(false, true, 3000, true, true, 0)
    Wait(1000)
    DefaultPedSetup(PlayerPedId(), isMale)
    Wait(1000)
    -- DoScreenFadeIn(1000)
    -- IsInCharCreation = true
    -- RegisterGenderPrompt()
    -- CreateThread(function()
    -- 	StartPrompts()
    -- end)
    -- EnableCharCreationPrompts(true)
    -- local Clothing = OrganiseClothingData(Gender)
    RemoveTagFromMetaPed(0x3F1F01E5)
    UpdatePedVariation(PlayerPedId())
    SetEntityVisible(PlayerPedId(), true)
    SetEntityInvincible(PlayerPedId(), true)
    SetPedScale(PlayerPedId(), 1.0)
    -- RenderScriptCams(true, true, 1000, true, true, 0)
    -- CreateThread(function()
    -- 	DrawLight()
    -- end)
    -- Wait(2000)
    DoScreenFadeIn(3000)
    -- repeat
    --     Wait(0)
    -- until IsScreenFadedIn()
    -- ApplyDefaultClothing()
    PrepareCreatorMusic()
    -- OpenCharCreationMenu(Clothing, false)
end

function setSkinColor(index, gender)
    print("Index: " .. index, gender)
    SkinColorTracker = index
    local heads = tonumber("0x" .. Config.DefaultChar[gender][SkinColorTracker].Heads[index])

    local SkinColor = Config.DefaultChar[gender][index]
    local legs = tonumber("0x" .. SkinColor.Legs[LegsTypeTracker])
    local bodyType = tonumber("0x" .. SkinColor.Body[BodyTypeTracker])
    local headtexture = joaat(SkinColor.HeadTexture[1])
    local albedo = Config.texture_types[gender].albedo
    PlayerSkin.HeadType = heads
    PlayerSkin.BodyType = bodyType
    PlayerSkin.LegsType = legs
    PlayerSkin.albedo = headtexture
    IsPedReadyToRender()
    ApplyShopItemToPed(heads)
    ApplyShopItemToPed(bodyType)
    ApplyShopItemToPed(legs)
    Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
    UpdatePedVariation()

end

function getNaked()
    IsPedReadyToRender()
    for Category, Components in pairs(Config.HashList) do

        if IsMetaPedUsingComponent(Config.HashList[Category]) then
            RemoveTagFromMetaPed(Config.HashList[Category])
        end
    end
    UpdatePedVariation()
end

function setBody(index, gender)
    local Comp = Config.DefaultChar[gender][SkinColorTracker]
    local compType = tonumber("0x" .. Comp["Body"][index])
    PlayerSkin.Torso = compType
    PlayerSkin.Body = compType
    BodyTypeTracker = index

    IsPedReadyToRender()
    ApplyShopItemToPed(compType)
    UpdatePedVariation()
    print("BodyVariant: "..PlayerSkin.Body)
end

function setLegs(index, gender)
    local Comp = Config.DefaultChar[gender][SkinColorTracker]
    local compType = tonumber("0x" .. Comp["Legs"][index])

    PlayerSkin.LegsType = compType
    PlayerSkin.legs = compType
    LegsTypeTracker = index

    IsPedReadyToRender()
    ApplyShopItemToPed(compType)
    UpdatePedVariation()
end

function setHead(index, gender)
    local Comp = Config.DefaultChar[gender][SkinColorTracker]
    local compType = tonumber("0x" .. Comp["Heads"][index])

    PlayerSkin.HeadType = compType
    HeadIndexTracker = index

    IsPedReadyToRender()
    ApplyShopItemToPed(compType)
    UpdatePedVariation()
end

function setWaist(index)
    local Waist = Config.BodyType.Waist[index]
    IsPedReadyToRender()
    EquipMetaPedOutfit(PlayerPedId(), Waist)
    UpdatePedVariation()
    PlayerSkin.Waist = Waist
    WaistTracker = index
end

function setBodyVariant(index)
    local body = Config.BodyType.Body[index]
    IsPedReadyToRender()
    EquipMetaPedOutfit(PlayerPedId(), body)
    UpdatePedVariation()
    PlayerSkin.body = body
    print("BodyVariant: "..PlayerSkin.body)
    BodyTracker = index
end

function setEyeColor(index, gender)
    StartAnimation("mood_normal_eyes_wide")
    IsPedReadyToRender()
    PlayerSkin.Eyes = Config.Eyes[gender][index]
    ApplyShopItemToPed(PlayerSkin.Eyes)
    UpdatePedVariation()
    EyeColorIndexTracker = index
end

function setFaceFeatures(comp, hash, value)
    PlayerSkin[comp] = value
    IsPedReadyToRender()
    SetCharExpression(PlayerPedId(), hash, value)
    UpdatePedVariation()
end

function setScale(scale)
    SetPedScale(PlayerPedId(), scale)
    PlayerSkin.Scale = scale
end

function ApplyOverlay(category, data)
    jo.pedTexture.remove(PlayerPedId(), category)
    PlayerSkin.overlays[category] = data

    IsPedReadyToRender()
    if PlayerSkin.overlays[category].opacity == 0.0 then
        PlayerSkin.overlays[category].id = nil
        jo.pedTexture.remove(PlayerPedId(), category)
        return
    else
        print(category, json.encode(PlayerSkin.overlays[category]))
        jo.pedTexture.apply(PlayerPedId(), category, PlayerSkin.overlays[category])
    end
end
