local PromptM = nil
local PromptF = nil
local PromptOK = nil
local promptGroup = GetRandomIntInRange(0, 0xffffff)

local Prompt = nil
local promptGroup2 = GetRandomIntInRange(0, 0xffffff)

playingAnimation = false
function debugPrint(msg)
    if Config.Debug == true then
        print("^1[SCRIPT]^0 " .. msg)
    end
end

function notify(text)
    TriggerEvent('notifications:notify', "SCRIPT", text, 3000)
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
    end
end

local function spawnNPC(model, x, y, z)
    local modelHash = LoadModel(model)
    local npc_ped = CreatePed(model, x, y, z, false, false, false, false)
    PlaceEntityOnGroundProperly(npc_ped)
    Citizen.InvokeNative(0x283978A15512B2FE, npc_ped, true)
    print('npc_ped: ' .. npc_ped)
    SetEntityHeading(npc_ped, 0.0)
    SetEntityCanBeDamaged(npc_ped, false)
    SetEntityInvincible(npc_ped, true)
    FreezeEntityPosition(npc_ped, true)
    SetBlockingOfNonTemporaryEvents(npc_ped, true)
    SetEntityCompletelyDisableCollision(npc_ped, false, false)

    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 6)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 0)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 1)
    Citizen.InvokeNative(0xC163DAC52AC975D3, npc_ped, 2)

    SetModelAsNoLongerNeeded(modelHash)
    return npc_ped
end

-- jobtable = {
--     "woodworker","blacksmith","carpenter"
-- }
function hasJob(jobtable)
    local job = LocalPlayer.state.Character.Job
    for _, v in pairs(jobtable) do
        if job == v then
            return true
        end
    end
    return false
end
-- SetResourceKvp("aprts_vzor:deht", 0)
-- local deht = GetResourceKvpString("aprts_vzor:deht")

local function prompt()
    Citizen.CreateThread(function()
        local str = "Budu ženou"
        local wait = 0
        PromptF = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PromptF, Config.KeyF)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PromptF, str)
        PromptSetEnabled(PromptF, true)
        PromptSetVisible(PromptF, true)
        PromptSetHoldMode(PromptF, true)
        PromptSetGroup(PromptF, promptGroup)
        PromptRegisterEnd(PromptF)

        local str = "Budu mužem"
        local wait = 0
        PromptM = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PromptM, Config.KeyM)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PromptM, str)
        PromptSetEnabled(PromptM, true)
        PromptSetVisible(PromptM, true)
        PromptSetHoldMode(PromptM, true)
        PromptSetGroup(PromptM, promptGroup)
        PromptRegisterEnd(PromptM)

        local str = "Potvrdit"
        local wait = 0
        PromptOK = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(PromptOK, Config.KeyOK)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PromptOK, str)
        PromptSetEnabled(PromptOK, false)
        PromptSetVisible(PromptOK, true)
        PromptSetHoldMode(PromptOK, true)
        PromptSetGroup(PromptOK, promptGroup)
        PromptRegisterEnd(PromptOK)

        local str = "Vstoupit do IC"
        local wait = 0
        Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Prompt, 0xC7B5340A)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Prompt, str)
        PromptSetEnabled(Prompt, true)
        PromptSetVisible(Prompt, true)
        PromptSetHoldMode(Prompt, true)
        PromptSetGroup(Prompt, promptGroup2)
        PromptRegisterEnd(Prompt)
    end)
end
function playAnim(entity, dict, name, flag, time)
    playingAnimation = true
    RequestAnimDict(dict)
    local waitSkip = 0
    while not HasAnimDictLoaded(dict) do
        waitSkip = waitSkip + 1
        if waitSkip > 100 then
            break
        end
        Citizen.Wait(0)
    end
    TaskPlayAnim(entity, dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)
    Wait(time)
    playingAnimation = false
end

function equipProp(model, bone, coords)
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    local mainProp = CreateObject(model, playerPos.x, playerPos.y, playerPos.z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(ped, bone)
    AttachEntityToEntity(mainProp, ped, boneIndex, coords.x, coords.y, coords.z, coords.xr, coords.yr, coords.zr, true,
        true, false, true, 1, true)
    return mainProp
end

function loadBody(gender)
    SkinColorTracker = SkinColorTracker
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
    Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, headtexture, 0x7FC5B1E1)
    UpdatePedVariation()
end

function GetName(Result)
    local splitString = {}
    for i in string.gmatch(Result, "%S+") do
        splitString[#splitString + 1] = i
    end

    if #splitString < 2 then
        return false
    end

    for _, word in ipairs(Config.BannedNames) do
        if string.find(splitString[1], word) or string.find(splitString[2], word) then
            return nil
        end
    end
    local lastname = splitString[1]
    
    if table.count(splitString) > 1 then
        lastname = splitString[2]
    end
    return splitString[1], lastname
end

Citizen.CreateThread(function()
    prompt()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        if InCharacterCreator == true then
            pause = 0
            PromptSetActiveGroupThisFrame(promptGroup, CreateVarString(10, 'LITERAL_STRING', "Pohlaví"))
            if PromptHasHoldModeCompleted(PromptF) then
                CreatePlayerModel("mp_female")
                PromptSetEnabled(PromptOK, true)
            end
            if PromptHasHoldModeCompleted(PromptM) then
                CreatePlayerModel("mp_male")
                PromptSetEnabled(PromptOK, true)
            end
            if PromptHasHoldModeCompleted(PromptOK) then
                CreateMenu()
                -- FreezeEntityPosition(PlayerPedId(), false)

                -- if Camera then
                --     RenderScriptCams(false, false, 0, 1, 0)
                --     DestroyCam(Camera, false)
                --     Camera = nil
                -- end
                -- NetworkEndTutorialSession()
                -- TriggerServerEvent("murphy_clothing:instanceplayers", 0)
                InCharacterCreator = false
                Playerdata.gender = GetGender()
                playAnim(PlayerPedId(), "amb_generic@world_human_generic_standing@lf_fwd@male_a@base", "base", 1, -1)
                jo.menu.setCurrentMenu(menuID)
                jo.menu.show(true)
            end
        end
        Citizen.Wait(pause)
    end
end)
-- 
NPC = nil
Citizen.CreateThread(function()

    while true do
        local pause = 1000

        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local distance = Vdist2(playerPos.x, playerPos.y, playerPos.z, Config.NPC.coords.x, Config.NPC.coords.y,
            Config.NPC.coords.z)
        if distance < 100.0 then
            if not DoesEntityExist(NPC) then
                NPC = spawnNPC(Config.NPC.model, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
                TaskStartScenarioInPlace(NPC, Config.NPC.sceneario, 0, true)
                SetEntityHeading(NPC, Config.NPC.heading)
            end
        else
            if DoesEntityExist(NPC) then
                DeleteEntity(NPC)
                NPC = 0
            end
        end
        if distance < 2.0 then
            local name = CreateVarString(10, 'LITERAL_STRING', "OOC => IC")
            PromptSetActiveGroupThisFrame(promptGroup2, name)

            if PromptHasHoldModeCompleted(Prompt) then
                SetEntityCoords(playerPed, Config.NPC.targetCoords.x, Config.NPC.targetCoords.y,
                    Config.NPC.targetCoords.z)
                NetworkEndTutorialSession()
                TriggerServerEvent("murphy_clothing:instanceplayers", 0)
                NetworkEndTutorialSession()
                TriggerServerEvent('aprts_charCreator:Server:defaults')
            end

            pause = 0
        end
        Citizen.Wait(pause)
    end
end)

-- 
Citizen.CreateThread(function()
    while PlayerPedId() == 0 do
        print(PlayerPedId())
        Citizen.Wait(0)
    end
    local x, y, z = Config.Camera.lookAt.x, Config.Camera.lookAt.y, Config.Camera.lookAt.z + 1.0
    local camx, camy, camz = Config.Camera.coords.x, Config.Camera.coords.y, Config.Camera.coords.z
    local minZ = z - 1.5
    local maxZ = z + 1.5
    local minY = y - 1.5
    local maxY = y + 1.5
    local minmax = 1.5
    print("Getting heading")
    local heading = GetEntityHeading(PlayerPedId())
    print("player heading" .. heading)
    while true do
        local pause = 1000

        if Camera then
            PointCamAtCoord(Camera, x, y, z)
            DrawLightWithRange(camx, camy, camz, 255, 255, 255, 8.5, 10.0)
            SetCamCoord(Camera, camx, camy, camz)
            if IsDisabledControlPressed(0, Config.KeyUP) then
                camz = camz + 0.01
                if camz > camz + minmax then
                    camz = camz + minmax
                end
                z = z + 0.01
                if z > maxZ then
                    z = maxZ
                end

            end
            if IsDisabledControlPressed(0, Config.KeyDOWN) then
                camz = camz - 0.01
                if camz < camz - minmax then
                    camz = camz - minmax
                end
                z = z - 0.01
                if z < minZ then
                    z = minZ
                end
            end
            if IsDisabledControlPressed(0, 0xB4E465B4) then
                -- SetCamFov(Camera, GetCamFov(Camera) - 1.0)0xB4E465B4
                y = y - 0.01
                if y < minY then
                    y = minY
                end
            end
            if IsDisabledControlPressed(0, 0x7065027D) then
                -- SetCamFov(Camera, GetCamFov(Camera) + 1.0)
                y = y + 0.01
                if y > maxY then
                    y = maxY
                end
            end
            if IsDisabledControlPressed(0, 0x8FFC75D6) then
                SetCamFov(Camera, GetCamFov(Camera) - 1.0)

            end
            if IsDisabledControlPressed(0, 0x8AAA0AD4) then
                SetCamFov(Camera, GetCamFov(Camera) + 1.0)

            end
            if IsDisabledControlPressed(0, 0xB2F377E8) and IsInputDisabled(0) then -- 1  slot
                heading = heading + 1.0
                SetEntityHeading(PlayerPedId(), heading)
            end
            if IsDisabledControlPressed(0, 0x760A9C6F) and IsInputDisabled(0) then -- 1  slot
                heading = heading - 1.0
                SetEntityHeading(PlayerPedId(), heading)
            end
            pause = 0
        end

        Citizen.Wait(pause)

    end
end)
