-- local Prompt = nil
-- local promptGroup = GetRandomIntInRange(0, 0xffffff)
Progressbar = exports["feather-progressbar"]:initiate()
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


function round(num)
    return math.floor(num * 100 + 0.5) / 100
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

-- local function prompt()
--     Citizen.CreateThread(function()
--         local str = "Sběr Dehtu"
--         local wait = 0
--         Prompt = Citizen.InvokeNative(0x04F97DE45A519419)
--         PromptSetControlAction(Prompt, 0x760A9C6F)
--         str = CreateVarString(10, 'LITERAL_STRING', str)
--         PromptSetText(Prompt, str)
--         PromptSetEnabled(Prompt, true)
--         PromptSetVisible(Prompt, true)
--         PromptSetHoldMode(Prompt, true)
--         PromptSetGroup(Prompt, promptGroup)
--         PromptRegisterEnd(Prompt)
--     end)
-- end
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

Citizen.CreateThread(function()
    -- prompt()
    while true do
        local pause = 1000
        local playerPed = PlayerPedId()
        -- local name = CreateVarString(10, 'LITERAL_STRING', "Prompt")
        -- PromptSetActiveGroupThisFrame(promptGroup, name)
        -- if PromptHasHoldModeCompleted(Prompt) then

        -- end

        Citizen.Wait(pause)
    end
end)
-- 


RegisterNUICallback('closePoster', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeNewspaper', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- /poster <URL to PDF or PNG>
RegisterCommand('poster', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        print("^1Usage: /poster <imageOrPdfUrl>^0")
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPoster',
        url = url
    })
end)

-- /newspaper <PDF>
RegisterCommand('newspaper', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        print("^1Usage: /newspaper <pdfUrl>^0")
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openNewspaper',
        pdfUrl = url
    })
end)