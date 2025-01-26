-- File: client.lua
local equipedAttachments = {} -- Tabulka pro uchovávání nasazených attachmentů na klientovi
local playerAttachments = {} -- Tabulka pro uchovávání attachmentů ostatních hráčů

-- Funkce pro zobrazení oznámení
function notify(text)
    TriggerEvent('notifications:notify', "SCRIPT", text, 3000)
end

-- Funkce pro sundání attachmentu na lokálního hráče
function UnEquipAttachment(item)
    local ped = PlayerPedId()

    if equipedAttachments[item] then
        DeleteObject(equipedAttachments[item])
        equipedAttachments[item] = nil

        notify("Sundali jste si " .. item)

        -- Odeslání informací na server pro synchronizaci
        TriggerServerEvent('aprts_attachments:server:UnEquip', item)
    else
        notify("Tento attachment nemáte nasazen.")
    end
end

-- Funkce pro nasazení attachmentu na lokálního hráče
function EquipAttachment(Tool)
    local ped = PlayerPedId()

    -- Kontrola, zda je již attachment nasazen
    if equipedAttachments[Tool.item] then
        notify("Již máte tento attachment nasazen.")
        return
    end

    -- Kontrola, zda má hráč potřebné povolení
    local playerJob = LocalPlayer.state.Character.Job
    local playerJobLabel = string.gsub(LocalPlayer.state.Character.JobLabel, " ", "")
    local playerGrade = LocalPlayer.state.Character.Grade

    if Tool.job and playerJob ~= Tool.job then
        notify("Tento attachment může používat pouze hráči s pracovní pozicí " .. Tool.jobLabel)
        return
    end
    if Tool.grade and playerGrade < Tool.grade then
        notify("Tento attachment může používat pouze hráči s minimální hodností " .. Tool.grade)
        return
    end
    if Tool.jobLabel and tostring(playerJobLabel) ~= tostring(Tool.jobLabel) then
        print("."..playerJobLabel.."." .. " " .. "."..Tool.jobLabel..".")
        notify("Tento attachment může používat pouze hráči s pracovní pozicí " .. Tool.jobLabel .. " a máš " .. playerJobLabel)
        return
    end

    -- Kontrola a sundání stávajícího attachmentu ve stejné kategorii
    for equippedItem, obj in pairs(equipedAttachments) do
        local equippedCategory = Config.Items[equippedItem].category
        if equippedCategory == Tool.category then
            UnEquipAttachment(equippedItem)
            break -- Předpokládáme, že v každé kategorii je pouze jeden attachment
        end
    end

    -- Načtení modelu attachmentu
    local modelHash = GetHashKey(Tool.model)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(0)
        end
    end

    -- Vytvoření objektu attachmentu
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local obj = CreateObjectNoOffset(modelHash, x, y, z + 0.2, false, false, false)

    -- Připojení objektu k modelu hráče
    local boneIndex = GetEntityBoneIndexByName(ped, Tool.bone)
    AttachEntityToEntity(obj, ped, boneIndex, Tool.coords.x, Tool.coords.y, Tool.coords.z, 
        Tool.coords.xr, Tool.coords.yr, Tool.coords.zr, true, true, false, true, 1, true)

    -- Uložení attachmentu do tabulky
    equipedAttachments[Tool.item] = obj

    -- Oznámení hráči
    notify("Nasadil jste si " .. Tool.item)

    -- Odeslání informací na server pro synchronizaci
    TriggerServerEvent('aprts_attachments:server:Equip', Tool.item, Tool)
end

-- Registrace klientských událostí pro nasazení a sundání attachmentů ostatních hráčů
RegisterNetEvent('aprts_attachments:client:Equip')
AddEventHandler('aprts_attachments:client:Equip', function(playerId, attachment)
    if playerId == GetPlayerServerId(PlayerId()) then
        return -- Nepotřebujeme vykonávat akci na vlastním klientovi
    end

    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    if not targetPed or targetPed == 0 then
        return
    end

    -- Kontrola, zda již attachment není nasazen
    if playerAttachments[playerId] and playerAttachments[playerId][attachment.item] then
        return
    end

    -- Načtení modelu attachmentu
    local modelHash = GetHashKey(attachment.model)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(0)
        end
    end

    -- Vytvoření objektu attachmentu
    local x, y, z = table.unpack(GetEntityCoords(targetPed, true))
    local obj = CreateObjectNoOffset(modelHash, x, y, z + 0.2, true, true, false)

    -- Připojení objektu k modelu hráče
    local boneIndex = GetEntityBoneIndexByName(targetPed, attachment.bone)
    AttachEntityToEntity(obj, targetPed, boneIndex, attachment.coords.x, attachment.coords.y, attachment.coords.z,
        attachment.coords.xr, attachment.coords.yr, attachment.coords.zr, true, true, false, true, 1, true)

    -- Uložení attachmentu do tabulky
    if not playerAttachments[playerId] then
        playerAttachments[playerId] = {}
    end
    playerAttachments[playerId][attachment.item] = obj
end)

RegisterNetEvent('aprts_attachments:client:UnEquip')
AddEventHandler('aprts_attachments:client:UnEquip', function(playerId, item)
    if playerId == GetPlayerServerId(PlayerId()) then
        return -- Nepotřebujeme vykonávat akci na vlastním klientovi
    end

    if playerAttachments[playerId] and playerAttachments[playerId][item] then
        DeleteObject(playerAttachments[playerId][item])
        playerAttachments[playerId][item] = nil
    end
end)

RegisterNetEvent('aprts_attachments:client:toggelAttachement')
AddEventHandler('aprts_attachments:client:toggelAttachement', function(item)
    if Config.Items[item] then
        if equipedAttachments[item] then
            UnEquipAttachment(item)
        else
            EquipAttachment(Config.Items[item])
        end
    else
        notify("Neplatný attachment: " .. item)
    end
end)

-- Příkaz /attach
RegisterCommand(Config.AttachCommand, function(source, args, rawCommand)
    if #args < 1 then
        notify("Použití: /attach [item]")
        return
    end

    local item = args[1]
    TriggerEvent('aprts_attachments:client:toggelAttachement', item)
end, false)

-- Synchronizace aktuálního stavu při připojení
RegisterNetEvent('aprts_attachments:client:Sync')
AddEventHandler('aprts_attachments:client:Sync', function(attachments)
    for playerId, attachmentList in pairs(attachments) do
        if playerId ~= GetPlayerServerId(PlayerId()) then
            for _, attachment in pairs(attachmentList) do
                TriggerEvent('aprts_attachments:client:Equip', playerId, attachment)
            end
        end
    end
end)

-- Synchronizace konkrétních attachmentů při požadavku
RegisterNetEvent('aprts_attachments:client:SyncPlayerAttachments')
AddEventHandler('aprts_attachments:client:SyncPlayerAttachments', function(playerId, attachments)
    for _, attachment in pairs(attachments) do
        TriggerEvent('aprts_attachments:client:Equip', playerId, attachment)
    end
end)

-- Požádání o synchronizaci při startu klienta
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) or not NetworkIsSessionStarted() do
        Wait(250)
    end
    TriggerServerEvent('aprts_attachments:server:RequestSync')
end)

-- Dynamická synchronizace při setkání s novými hráči
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Kontrolovat každou sekundu, lze optimalizovat podle potřeby

        local players = GetActivePlayers()
        for _, playerId in ipairs(players) do
            if playerId ~= PlayerId() then
                local serverId = GetPlayerServerId(playerId)
                local ped = GetPlayerPed(playerId)
                if DoesEntityExist(ped) then
                    local distance =
                        GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped), true)
                    if distance < Config.VisibleDistance then
                        -- Požádat o attachmenty tohoto hráče, pokud ještě nejsou načtené
                        if not playerAttachments[serverId] then
                            TriggerServerEvent('aprts_attachments:server:RequestPlayerAttachments', serverId)
                        end
                    end
                end
            end
        end
    end
end)

-- Čištění attachmentů při zastavení skriptu
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    print("[aprts_attachments] Resource is stopping. Removing all attachments.")

    for playerId, attachments in pairs(playerAttachments) do
        for _, attachment in ipairs(attachments) do
            TriggerClientEvent('aprts_attachments:client:UnEquip', -1, playerId, attachment.item)
        end
    end

    playerAttachments = {} -- Vyčištění tabulky
end)
